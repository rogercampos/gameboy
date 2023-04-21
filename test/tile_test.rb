require_relative 'test_helper'

module Gameboy
  class TestTile < BaseTest
    def setup
      super
      @tile = Tile.new([
                           0x7c, 0x7c,
                           0x00, 0xc6,
                           0xc6, 0x00,
                           0x00, 0xfe,
                           0xc6, 0xc6,
                           0x00, 0xc6,
                           0xc6, 0x00,
                           0x00, 0x00
                       ])
    end

    def test_pixels
      res = @tile.to_pixels

      graphic_result = [
          " 33333  ",
          "22   22 ",
          "11   11 ",
          "2222222 ",
          "33   33 ",
          "22   22 ",
          "11   11 ",
          "        "
      ]

      assert_equal graphic_result, res.map { |x| x.join.gsub("0", " ") }
      assert_equal 8, res.size
    end
  end
end