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
      SDL2.init(SDL2::INIT_VIDEO)

      rom = Rom.new(File.binread(@rom_path))
      RomLoader.new(rom).load!

      display = Display.new
      i = 0

      running = true

      while running
        case event = SDL2::Event.poll
        when SDL2::Event::Quit
          running = false
        when SDL2::Event::KeyDown
          if event.sym == SDL2::Key::ESCAPE
            running = false
          end
        end

        opcode = MMU.bread(Registers.pc)
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