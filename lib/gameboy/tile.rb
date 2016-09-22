module Gameboy
  class Tile
    def initialize(bytes)
      raise "Given a tile of incorrect bytesize! #{bytes.length}" if bytes.length != 16
      @bytes = bytes
    end

    # Returns an array of pixels reresenting the tile (8 pixels long)
    def to_pixels
      res = []

      @bytes.each_slice(2) do |row_pair|
        little_row = row_pair[0]
        big_row = row_pair[1]

        binary = 8.times.map do |i|
          little_bit = bit(little_row, i)
          big_bit = bit(big_row, i)

          big_bit * 2 + little_bit
        end

        res << binary.reverse
      end

      res
    end

    def bit(byte, k)
      (byte & (1 << k)) >> k
    end
  end
end