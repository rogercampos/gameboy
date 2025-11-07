require "./registers"

module Gameboy
  module Flags
    extend self

    # Get flag values (read bit from F register)
    def z : Int32
      ((Registers.f >> 7) & 1).to_i32
    end

    def n : Int32
      ((Registers.f >> 6) & 1).to_i32
    end

    def h : Int32
      ((Registers.f >> 5) & 1).to_i32
    end

    def c : Int32
      ((Registers.f >> 4) & 1).to_i32
    end

    # Set flag values
    def z=(value : Int32)
      bit_value = value & 1
      if bit_value == 1
        Registers.f = Registers.f | (1u8 << 7)
      else
        Registers.f = Registers.f & (0b1111_1111u8 ^ (1u8 << 7))
      end
    end

    def n=(value : Int32)
      bit_value = value & 1
      if bit_value == 1
        Registers.f = Registers.f | (1u8 << 6)
      else
        Registers.f = Registers.f & (0b1111_1111u8 ^ (1u8 << 6))
      end
    end

    def h=(value : Int32)
      bit_value = value & 1
      if bit_value == 1
        Registers.f = Registers.f | (1u8 << 5)
      else
        Registers.f = Registers.f & (0b1111_1111u8 ^ (1u8 << 5))
      end
    end

    def c=(value : Int32)
      bit_value = value & 1
      if bit_value == 1
        Registers.f = Registers.f | (1u8 << 4)
      else
        Registers.f = Registers.f & (0b1111_1111u8 ^ (1u8 << 4))
      end
    end

    def debug : String
      "Z: #{z}; N: #{n}; H: #{h}; C: #{c}"
    end
  end
end
