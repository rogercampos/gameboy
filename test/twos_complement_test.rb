require_relative 'test_helper'

module Gameboy
  class TestTwosComplement < Minitest::Test
    def test_data_4_bits
      assert_equal(0, TwosComplement.convert(0))
      assert_equal(7, TwosComplement.convert(0b0111, 4))
      assert_equal(-1, TwosComplement.convert(0b1111, 4))
      assert_equal(-7, TwosComplement.convert(0b1001, 4))
      assert_equal(-2, TwosComplement.convert(0b1110, 4))
    end

    def test_data_8_bits
      assert_equal(126, TwosComplement.convert(0b0111_1110))
      assert_equal(-1, TwosComplement.convert(0b1111_1111))
      assert_equal(-111, TwosComplement.convert(0b1001_0001))
      assert_equal(-22, TwosComplement.convert(0b1110_1010))
    end
  end
end