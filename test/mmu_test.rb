require_relative 'test_helper'

module Gameboy
  class TestMMU < Minitest::Test
    def setup
      MMU.reset!
    end

    def test_byte_access
      # bounds
      assert_raises(Exception) { MMU.bwrite(-1, 0) }
      assert_raises(Exception) { MMU.bwrite(MMU::MMU_SIZE, 0) }
      assert_raises(Exception) { MMU.bwrite(MMU::MMU_SIZE + 1, 0) }

      assert_raises(Exception) { MMU.bread(-1, 0) }
      assert_raises(Exception) { MMU.bread(MMU::MMU_SIZE, 0) }
      assert_raises(Exception) { MMU.bread(MMU::MMU_SIZE + 1, 0) }

      # write / read
      MMU.bwrite 45, 13
      assert_equal 13, MMU.bread(45)

      MMU.bwrite 60, 256
      assert_equal 0, MMU.bread(60)

      MMU.bwrite 69, 257
      assert_equal 1, MMU.bread(69)

      MMU.bwrite 0, 33
      assert_equal 33, MMU.bread(0)

      MMU.bwrite MMU::MMU_SIZE - 1, 33
      assert_equal 33, MMU.bread(MMU::MMU_SIZE - 1)

      # signed
      MMU.bwrite 102, 203
      assert_equal(-53, MMU.bread(102, as: :signed))

      MMU.bwrite 107, 123
      assert_equal 123, MMU.bread(107, as: :signed)

      MMU.bwrite 108, 128
      assert_equal(-128, MMU.bread(108, as: :signed))

      # echo
      MMU.bwrite 0xc000, 88
      assert_equal 88, MMU.bread(0xc000 + 8192)

      MMU.bwrite 0xc001 + 8192, 90
      assert_equal 90, MMU.bread(0xc001)
    end

    def test_word_access
      # bounds
      assert_raises(Exception) { MMU.wwrite(-1, 0) }
      assert_raises(Exception) { MMU.wwrite MMU::MMU_SIZE, 0 }
      assert_raises(Exception) { MMU.wwrite MMU::MMU_SIZE - 1, 0 }
      assert_raises(Exception) { MMU.wwrite MMU::MMU_SIZE + 10000, 0 }

      assert_raises(Exception) { MMU.wread(-1, 0) }
      assert_raises(Exception) { MMU.wread MMU::MMU_SIZE, 0 }
      assert_raises(Exception) { MMU.wread MMU::MMU_SIZE - 1, 0 }
      assert_raises(Exception) { MMU.wread MMU::MMU_SIZE + 10000, 0 }

      # write / read
      MMU.wwrite 45, 13
      assert_equal 13, MMU.wread(45)

      MMU.wwrite 60, 65536
      assert_equal 0, MMU.wread(60)

      MMU.wwrite 69, 65537
      assert_equal 1, MMU.wread(69)

      MMU.wwrite 0, 34123
      assert_equal 34123, MMU.wread(0)

      MMU.wwrite MMU::MMU_SIZE - 2, 60142
      assert_equal 60142, MMU.wread(MMU::MMU_SIZE - 2)

      # mixed access
      MMU.wwrite 79, 0xa3f7
      assert_equal 0xa3, MMU.bread(79)
      assert_equal 0xf7, MMU.bread(80)

      MMU.bwrite 93, 0xaa
      MMU.bwrite 94, 0x73
      assert_equal 0xaa73, MMU.wread(93)

      # signed
      MMU.wwrite 102, 37856
      assert_equal(-27680, MMU.wread(102, as: :signed))

      MMU.wwrite 107, 12376
      assert_equal 12376, MMU.wread(107, as: :signed)

      MMU.wwrite 108, 32768
      assert_equal(-32768, MMU.wread(108, as: :signed))


      # echo
      MMU.wwrite 0xc000, 88
      assert_equal 88, MMU.wread(0xc000 + 8192)

      MMU.wwrite 0xc001 + 8192, 90
      assert_equal 90, MMU.wread(0xc001)
    end
  end
end