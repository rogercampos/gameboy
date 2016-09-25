module Gameboy
  class TwosComplement
    def self.convert(number, bits = 8)
      if number >> bits - 1 == 0
        number
      else
        number - 2 ** bits
      end
    end
  end
end