require "./registers"
require "./flags"
require "./mmu"
require "./instructions"
require "./timer"
require "./interrupt"
require "./ppu"
require "./joypad"
require "./rom"
require "./rom_loader"
require "./display"
require "./ime"

module Gameboy
  CPU_SPEED = 4194304
  TARGET_FPS = 59.73

  class Emulator
    @rom : Rom
    @debug : Bool
    @display : Display?
    @cpu_halted : Bool = false
    @ppu_batch_cycles : Int32 = 0

    # Interrupt handler addresses
    INTERRUPT_HANDLERS = {
      0 => 0x0040,  # V-Blank
      1 => 0x0048,  # LCD STAT
      2 => 0x0050,  # Timer
      3 => 0x0058,  # Serial
      4 => 0x0060,  # Joypad
    }

    def initialize(@rom : Rom, @debug : Bool = false, @display : Display? = nil)
    end

    def self.from_file(filename : String, debug : Bool = false, with_display : Bool = true)
      rom = Rom.from_file(filename)
      display = with_display ? Display.new : nil
      new(rom, debug, display)
    end

    def check_interrupts
      ie = Interrupt.ie
      if_flags = Interrupt.if_reg

      # Check if any interrupt is both enabled and flagged
      pending = ie & if_flags

      if pending != 0
        # Wake up from HALT if there's a pending interrupt
        @cpu_halted = false

        # Only handle interrupt if IME (master interrupt enable) is on
        if IME.enabled?
          # Find highest priority interrupt (lowest bit number)
          5.times do |i|
            if (pending & (1 << i)) != 0
              # Handle this interrupt
              handle_interrupt(i)
              break
            end
          end
        end
      end
    end

    def handle_interrupt(interrupt_bit : Int32)
      # Push PC to stack
      Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF)
      MMU.wwrite(Registers.sp, Registers.pc)

      # Jump to interrupt handler
      Registers.pc = INTERRUPT_HANDLERS[interrupt_bit]

      # Clear the interrupt flag
      Interrupt.if_reg = Interrupt.if_reg & ~(1 << interrupt_bit)

      # Disable interrupts (will be re-enabled by RETI)
      IME.disable!
    end

    def run!(max_cycles : Int32? = nil)
      if @debug
        puts "=== ROM Debug Info ==="
        @rom.debug
        puts "======================"
      end

      # Load ROM into memory
      RomLoader.new(@rom).load!

      # Reset components
      Registers.reset!
      Timer.reset!
      Joypad.reset!
      PPU.reset!
      IME.reset!

      puts "\nStarting emulation..."
      puts "Press Ctrl+C to stop\n\n"

      instruction_count = 0_i64
      total_cycles = 0_i64
      frame_cycles = 0
      frame_count = 0_i64
      last_fps_time = Time.monotonic

      # Main emulation loop
      running = true
      while running && (max_cycles.nil? || instruction_count < max_cycles)
        # Check if CPU is halted - if so, skip instruction execution
        unless @cpu_halted
          opcode = MMU.bread(Registers.pc)

          # Check for extended opcodes (CB prefix)
          extended_opcode = opcode == 0xcb
          if extended_opcode
            opcode = (opcode << 8) | MMU.bread(Registers.pc + 1)
          end

          instruction = Instructions[opcode]

          if @debug
            puts "PC=0x#{Registers.pc.to_s(16).rjust(4, '0')} " \
                 "#{instruction.family.ljust(16)} " \
                 "A=0x#{Registers.a.to_s(16).rjust(2, '0')} " \
                 "BC=0x#{Registers.bc.to_s(16).rjust(4, '0')} " \
                 "DE=0x#{Registers.de.to_s(16).rjust(4, '0')} " \
                 "HL=0x#{Registers.hl.to_s(16).rjust(4, '0')} " \
                 "SP=0x#{Registers.sp.to_s(16).rjust(4, '0')} " \
                 "Z=#{Flags.z} N=#{Flags.n} H=#{Flags.h} C=#{Flags.c}"
          end

          Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF)
          Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) if extended_opcode  # Skip extra byte for CB prefix

          # Execute instruction
          instruction.run

          # Handle EI instruction's 1-instruction delay
          IME.tick

          total_cycles += instruction.cycles
          cycles_this_instruction = instruction.cycles
        else
          # When halted, still consume cycles (4 cycles per HALT check)
          cycles_this_instruction = 4
          total_cycles += 4
        end

        # Update PPU and Timer
        # NOTE: Reduced batching threshold to catch brief LCDC changes
        # If LCDC briefly enables LCD/BG and then disables it within a large batch,
        # the PPU might never see the enabled state
        @ppu_batch_cycles += cycles_this_instruction

        if @ppu_batch_cycles >= 4
          Timer.tick(@ppu_batch_cycles)
          PPU.tick(@ppu_batch_cycles)
          @ppu_batch_cycles = 0
        end

        # Check for interrupts
        check_interrupts

        # Frame tracking
        frame_cycles += cycles_this_instruction

        # One frame = 70224 cycles (154 scanlines * 456 cycles)
        if frame_cycles >= 70224
          frame_cycles -= 70224
          frame_count += 1

          # Flush any remaining batched PPU/Timer cycles
          if @ppu_batch_cycles > 0
            Timer.tick(@ppu_batch_cycles)
            PPU.tick(@ppu_batch_cycles)
            @ppu_batch_cycles = 0
          end

          # Render frame if display is available
          if display = @display
            display.render_frame
            display.poll_events

            # Check if window was closed
            running = false unless display.running?

            # Frame timing - limit to ~60 FPS
            # TODO: More precise timing
          end

          # FPS counter (every second)
          current_time = Time.monotonic
          elapsed = (current_time - last_fps_time).total_seconds
          if elapsed >= 1.0
            fps = frame_count / elapsed
            if @display
              puts "\rFPS: #{fps.round(2).to_s.rjust(6)} | Frames: #{frame_count} | Instructions: #{instruction_count}"
            else
              puts "\rFPS: #{fps.round(2).to_s.rjust(6)} | Frames: #{frame_count} | Instructions: #{instruction_count} | Cycles: #{total_cycles}"
            end
            STDOUT.flush
            frame_count = 0
            last_fps_time = current_time
          end

          # Stop if running for testing purposes
          if max_cycles && instruction_count >= max_cycles
            running = false
          end
        end

        instruction_count += 1

        # Safety: stop if we've executed too many instructions without a ROM
        if instruction_count > 1_000_000 && Registers.pc == 0
          puts "\n\nError: PC stuck at 0, stopping..."
          running = false
        end
      end

      puts "\n\nEmulation stopped."
      puts "Total instructions: #{instruction_count}"
      puts "Total cycles: #{total_cycles}"

      # Clean up display
      if display = @display
        display.close
      end
    end
  end
end
