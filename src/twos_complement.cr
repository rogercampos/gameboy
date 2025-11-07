module Gameboy
  module TwosComplement
    def self.convert(number : Int32, bits : Int32 = 8) : Int32
      if number >> (bits - 1) == 0
        number
      else
        number - (2 ** bits)
      end
    end
  end
end
