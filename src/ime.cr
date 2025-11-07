module Gameboy
  # Interrupt Master Enable (IME) flag
  # Controls whether interrupts can be handled
  module IME
    extend self

    @@enabled : Bool = false
    @@pending_enable : Bool = false  # EI has 1-instruction delay

    def enabled? : Bool
      @@enabled
    end

    def enable!
      @@enabled = true
    end

    def disable!
      @@enabled = false
    end

    # EI instruction schedules IME to be enabled after next instruction
    def schedule_enable!
      @@pending_enable = true
    end

    # Called after each instruction to apply pending EI
    def tick
      if @@pending_enable
        @@enabled = true
        @@pending_enable = false
      end
    end

    def reset!
      @@enabled = false
      @@pending_enable = false
    end
  end
end
