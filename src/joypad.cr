require "./mmu"
require "./interrupt"

module Gameboy
  module Joypad
    extend self

    P1 = 0xFF00

    # Button states (true = pressed)
    @@button_right : Bool = false
    @@button_left : Bool = false
    @@button_up : Bool = false
    @@button_down : Bool = false
    @@button_a : Bool = false
    @@button_b : Bool = false
    @@button_select : Bool = false
    @@button_start : Bool = false

    def reset!
      @@button_right = false
      @@button_left = false
      @@button_up = false
      @@button_down = false
      @@button_a = false
      @@button_b = false
      @@button_select = false
      @@button_start = false
      update_p1
    end

    def press(button : Symbol)
      case button
      when :right
        @@button_right = true
      when :left
        @@button_left = true
      when :up
        @@button_up = true
      when :down
        @@button_down = true
      when :a
        @@button_a = true
      when :b
        @@button_b = true
      when :select
        @@button_select = true
      when :start
        @@button_start = true
      end
      update_p1
    end

    def release(button : Symbol)
      case button
      when :right
        @@button_right = false
      when :left
        @@button_left = false
      when :up
        @@button_up = false
      when :down
        @@button_down = false
      when :a
        @@button_a = false
      when :b
        @@button_b = false
      when :select
        @@button_select = false
      when :start
        @@button_start = false
      end
      update_p1
    end

    def update_p1
      p1 = MMU.bread(P1)
      select_buttons = (p1 & 0x20) == 0
      select_directions = (p1 & 0x10) == 0

      # Start with all buttons released (bits set)
      result = 0xCF

      # Keep the selection bits from what was written
      result = (result & 0x0F) | (p1 & 0x30)

      if select_directions
        result &= 0xFE if @@button_right   # Bit 0 - clear if pressed
        result &= 0xFD if @@button_left    # Bit 1 - clear if pressed
        result &= 0xFB if @@button_up      # Bit 2 - clear if pressed
        result &= 0xF7 if @@button_down    # Bit 3 - clear if pressed
      end

      if select_buttons
        result &= 0xFE if @@button_a       # Bit 0 - clear if pressed
        result &= 0xFD if @@button_b       # Bit 1 - clear if pressed
        result &= 0xFB if @@button_select  # Bit 2 - clear if pressed
        result &= 0xF7 if @@button_start   # Bit 3 - clear if pressed
      end

      # Write directly to memory (direct array access)
      MMU.data[P1] = result.to_u8

      # Trigger joypad interrupt if any button is pressed
      if (result & 0x0F) != 0x0F
        Interrupt.if_joypad = 1
      end
    end
  end
end
