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
    def initialize(rom_path)
      @rom_path = rom_path
    end

    def run!
      rom = Rom.new(File.binread(@rom_path))
      RomLoader.new(rom).load!

      loop do
        opcode = MMU.bread(Registers.pc)
        extended_opcode = [0xcb, 0xed].include?(opcode)
        opcode = (0xcb << 8) + MMU.bread(Registers.pc + 1) if extended_opcode

        instruction = Instruction[opcode]
        Registers.pc += 1
        Registers.pc += 1 if extended_opcode # +1 if the current opcode is 2 bytes long

        old_pc = Registers.pc

        instruction.run

        # Interrupt enabler changes happens deferred
        CPU_DEFERRED_QUEUE.each { |queue| CPU_DEFERRED_QUEUE.delete(queue) if queue.cycle! }

        if old_pc == Registers.pc # Skip if the instruction has specifically set the PC.
          # Increment by the number of bytes used for the instruction's arguments so we leave PC pointing to the next instruction
          Registers.pc += (instruction.size - 1)
        end

        # sleep
        # interrupts
      end
    end
  end
end