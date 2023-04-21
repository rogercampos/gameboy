module Gameboy
  CPU_SPEED = 4194304

  class DeferredAction
    def initialize(count, &block)
      raise "count must be > 1" if count <= 0

      @count = count
      @impl = block
    end

    def cycle!
      @count -= 1

      if @count == 0
        @impl.call
        true
      end
    end
  end

  CPU_DEFERRED_QUEUE = []

  class Emulator
    def initialize(rom)
      @rom = rom
      @debug = false
    end

    def run!(expected_cycles = nil)
      SDL2.init(SDL2::INIT_VIDEO)

      # Accept a rom object or a path to a rom file
      @rom = Rom.new(File.binread(@rom)) unless @rom.is_a?(Rom)

      if @debug
        puts "--- ROM ---"
        @rom.debug
        puts "--- START COMMAND IN ROM ---"
        p @rom.bytes[0x100..0x103].map { |x| x.to_s(16) }
      end

      RomLoader.new(@rom).load!

      display = Display.new
      i = 0

      # Compensate first 2 opcodes, first is always 0 and second is always
      # a jump to where the rom really starts.
      expected_cycles += 2 if expected_cycles

      running = true

      while running && (expected_cycles.nil? || i < expected_cycles)
        case event = SDL2::Event.poll
        when SDL2::Event::Quit
          running = false
        when SDL2::Event::KeyDown
          if event.sym == SDL2::Key::ESCAPE
            running = false
          end
        end

        opcode = MMU.bread(Registers.pc)

        if @debug
          puts "Running opcode: #{opcode.to_s(16)} | Following content in memory: #{Array.new(10) { |i| MMU.bread(Registers.pc + i).to_s(16) }.join(" ")}"
        end

        extended_opcode = [0xcb, 0xed].include?(opcode)
        opcode = (opcode << 8) + MMU.bread(Registers.pc + 1) if extended_opcode

        instruction = Instruction[opcode]
        Registers.pc += 1
        Registers.pc += 1 if extended_opcode # +1 if the current opcode is 2 bytes long

        instruction.run

        # Interrupt enabler changes happens deferred
        CPU_DEFERRED_QUEUE.each { |action| CPU_DEFERRED_QUEUE.delete(action) if action.cycle! }

        # sleep

        # display
        if i % 10000 == 0
          display.render
        end

        # interrupts

        i += 1
      end
    end
  end
end