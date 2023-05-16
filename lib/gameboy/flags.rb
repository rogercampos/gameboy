module Gameboy
  module Flags
    extend self

    def z
      Registers.f[7]
    end

    def n
      Registers.f[6]
    end

    def h
      Registers.f[5]
    end

    def c
      Registers.f[4]
    end

    def z=(value)
      value = value % 2
      value == 1 ? Registers.f |= 1 << 7 : Registers.f &= (0b1111_1111 ^ (1 << 7))
    end

    def n=(value)
      value = value % 2
      value == 1 ? Registers.f |= 1 << 6 : Registers.f &= (0b1111_1111 ^ (1 << 6))
    end

    def h=(value)
      value = value % 2
      value == 1 ? Registers.f |= 1 << 5 : Registers.f &= (0b1111_1111 ^ (1 << 5))
    end

    def c=(value)
      value = value % 2
      value == 1 ? Registers.f |= 1 << 4 : Registers.f &= (0b1111_1111 ^ (1 << 4))
    end

    def debug
      "Z: #{z}; N: #{n}; H: #{h}; C: #{c}"
    end
  end
end