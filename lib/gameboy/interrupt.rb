module Gameboy
  module Interrupt
    extend self

    NAMES = {
        0 => "vblank",
        1 => "lcd_stat",
        2 => "timer",
        3 => "serial",
        4 => "joypad"
    }

    # Interrupt enabler
    def _ie
      MMU.bread(0xffff) & 0b0001_1111
    end

    def _ie=(value)
      MMU.bwrite(0xffff, value)
    end

    0.upto(4).each do |n_bit|
      define_method "ie_#{NAMES[n_bit]}" do
        _ie[n_bit]
      end

      define_method "ie_#{NAMES[n_bit]}=" do |value|
        if value % 2 == 1
          _ie |= 1 << n_bit
        else
          MMU.bwrite(0xffff, _ie & (0b1111_1111 ^ (1 << n_bit)))
        end
      end
    end


    # Interrupt flags
    def _if
      MMU.bread(0xff0f) & 0b0001_1111
    end

    def _if=(value)
      MMU.bwrite(0xff0f, value)
    end

    0.upto(4).each do |n_bit|
      define_method "if_#{NAMES[n_bit]}" do
        _if[n_bit]
      end

      define_method "if_#{NAMES[n_bit]}=" do |value|
        if value % 2 == 1
          _if |= 1 << n_bit
        else
          MMU.bwrite(0xffff, _if & (0b1111_1111 ^ (1 << n_bit)))
        end
      end
    end
  end
end