module Gameboy
  class Tile
    def initialize(bytes)
      raise "Given a tile of incorrect bytesize! #{bytes.length}" if bytes.length != 16
      @bytes = bytes
    end

    # Returns an array of arrays representing the pixels of the tile.
    # array (Y-dimension top to bottom) of arrays (X-dimension left to right)
    # Each pixel is an integer of only 4 possible values: from 0 (black) to 3 (white).
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