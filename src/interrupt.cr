require "./mmu"

module Gameboy
  module Interrupt
    extend self

    # Interrupt enable register (IE) at 0xFFFF
    # Interrupt flag register (IF) at 0xFF0F

    # Read IE register
    def ie : Int32
      MMU.bread(0xFFFF) & 0b0001_1111
    end

    # Write IE register
    def ie=(value : Int32)
      MMU.bwrite(0xFFFF, value)
    end

    # Read IF register
    def if_reg : Int32
      MMU.bread(0xFF0F) & 0b0001_1111
    end

    # Write IF register
    def if_reg=(value : Int32)
      MMU.bwrite(0xFF0F, value)
    end

    # VBlank interrupt (bit 0)
    def if_vblank : Int32
      (if_reg >> 0) & 1
    end

    def if_vblank=(value : Int32)
      if (value & 1) == 1
        self.if_reg = if_reg | (1 << 0)
      else
        MMU.bwrite(0xFF0F, if_reg & (0b1111_1111 ^ (1 << 0)))
      end
    end

    # LCD STAT interrupt (bit 1)
    def if_lcd_stat : Int32
      (if_reg >> 1) & 1
    end

    def if_lcd_stat=(value : Int32)
      if (value & 1) == 1
        self.if_reg = if_reg | (1 << 1)
      else
        MMU.bwrite(0xFF0F, if_reg & (0b1111_1111 ^ (1 << 1)))
      end
    end

    # Timer interrupt (bit 2)
    def if_timer : Int32
      (if_reg >> 2) & 1
    end

    def if_timer=(value : Int32)
      if (value & 1) == 1
        self.if_reg = if_reg | (1 << 2)
      else
        MMU.bwrite(0xFF0F, if_reg & (0b1111_1111 ^ (1 << 2)))
      end
    end

    # Serial interrupt (bit 3)
    def if_serial : Int32
      (if_reg >> 3) & 1
    end

    def if_serial=(value : Int32)
      if (value & 1) == 1
        self.if_reg = if_reg | (1 << 3)
      else
        MMU.bwrite(0xFF0F, if_reg & (0b1111_1111 ^ (1 << 3)))
      end
    end

    # Joypad interrupt (bit 4)
    def if_joypad : Int32
      (if_reg >> 4) & 1
    end

    def if_joypad=(value : Int32)
      if (value & 1) == 1
        self.if_reg = if_reg | (1 << 4)
      else
        MMU.bwrite(0xFF0F, if_reg & (0b1111_1111 ^ (1 << 4)))
      end
    end

    # IE register helpers (same pattern)
    def ie_vblank : Int32
      (ie >> 0) & 1
    end

    def ie_vblank=(value : Int32)
      if (value & 1) == 1
        self.ie = ie | (1 << 0)
      else
        MMU.bwrite(0xFFFF, ie & (0b1111_1111 ^ (1 << 0)))
      end
    end

    def ie_lcd_stat : Int32
      (ie >> 1) & 1
    end

    def ie_lcd_stat=(value : Int32)
      if (value & 1) == 1
        self.ie = ie | (1 << 1)
      else
        MMU.bwrite(0xFFFF, ie & (0b1111_1111 ^ (1 << 1)))
      end
    end

    def ie_timer : Int32
      (ie >> 2) & 1
    end

    def ie_timer=(value : Int32)
      if (value & 1) == 1
        self.ie = ie | (1 << 2)
      else
        MMU.bwrite(0xFFFF, ie & (0b1111_1111 ^ (1 << 2)))
      end
    end

    def ie_serial : Int32
      (ie >> 3) & 1
    end

    def ie_serial=(value : Int32)
      if (value & 1) == 1
        self.ie = ie | (1 << 3)
      else
        MMU.bwrite(0xFFFF, ie & (0b1111_1111 ^ (1 << 3)))
      end
    end

    def ie_joypad : Int32
      (ie >> 4) & 1
    end

    def ie_joypad=(value : Int32)
      if (value & 1) == 1
        self.ie = ie | (1 << 4)
      else
        MMU.bwrite(0xFFFF, ie & (0b1111_1111 ^ (1 << 4)))
      end
    end
  end
end
