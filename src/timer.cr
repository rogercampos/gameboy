require "./mmu"
require "./interrupt"

module Gameboy
  module Timer
    extend self

    DIV_ADDRESS = 0xFF04
    TIMA_ADDRESS = 0xFF05
    TMA_ADDRESS = 0xFF06
    TAC_ADDRESS = 0xFF07

    @@div_counter = 0
    @@tima_counter = 0

    # Clock frequencies in CPU cycles
    CLOCK_FREQUENCIES = {
      0b00 => 1024,  # 4096 Hz
      0b01 => 16,    # 262144 Hz
      0b10 => 64,    # 65536 Hz
      0b11 => 256,   # 16384 Hz
    }

    def reset!
      @@div_counter = 0
      @@tima_counter = 0
      MMU.bwrite(DIV_ADDRESS, 0)
      MMU.bwrite(TIMA_ADDRESS, 0)
      MMU.bwrite(TMA_ADDRESS, 0)
      MMU.bwrite(TAC_ADDRESS, 0)
    end

    def tick(cycles : Int32)
      update_divider(cycles)
      update_timer(cycles) if timer_enabled?
    end

    def timer_enabled? : Bool
      (MMU.bread(TAC_ADDRESS) & 0b100) != 0
    end

    def clock_select : Int32
      MMU.bread(TAC_ADDRESS) & 0b11
    end

    def update_divider(cycles : Int32)
      @@div_counter += cycles

      # DIV increments every 256 cycles
      while @@div_counter >= 256
        @@div_counter -= 256
        div_value = (MMU.bread(DIV_ADDRESS) + 1) & 0xFF
        # Write directly to avoid reset behavior
        MMU.data[DIV_ADDRESS] = div_value.to_u8
      end
    end

    def update_timer(cycles : Int32)
      @@tima_counter += cycles
      frequency = CLOCK_FREQUENCIES[clock_select]

      while @@tima_counter >= frequency
        @@tima_counter -= frequency
        tima = MMU.bread(TIMA_ADDRESS)

        if tima == 0xFF
          # TIMA overflow - trigger interrupt and reload from TMA
          MMU.bwrite(TIMA_ADDRESS, MMU.bread(TMA_ADDRESS))
          Interrupt.if_timer = 1
        else
          MMU.bwrite(TIMA_ADDRESS, tima + 1)
        end
      end
    end

    # Writing to DIV resets it to 0
    def handle_div_write
      @@div_counter = 0
      MMU.data[DIV_ADDRESS] = 0u8
    end
  end
end
