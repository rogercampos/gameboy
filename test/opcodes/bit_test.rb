require_relative '../test_helper'

module Gameboy
  class BitTest < BaseTest
    def setup
      super
      Flags.z = 0
      Flags.n = 0
      Flags.c = 0
      Flags.h = 0
    end

    def test_0_bit_on_b_set
      instruction = Instruction[0xcb40]
      Registers.b = 0x80
      instruction.run
      assert_equal 1, Flags.z
      assert_equal 1, Flags.h
    end

    def test_0_bit_on_b_not_set
      instruction = Instruction[0xcb40]
      Registers.b = 0x7f
      instruction.run
      assert_equal 0, Flags.z
      assert_equal 1, Flags.h
    end

    def test_1_bit_on_c_set
      instruction = Instruction[0xcb41]
      Registers.c = 0x80
      instruction.run
      assert_equal 1, Flags.z
      assert_equal 1, Flags.h
    end

    def test_bit_res
      instruction = Instruction[0xcb80]
      Registers.b = 0xff
      instruction.run
      assert_equal 0xfe, Registers.b

      instruction = Instruction[0xcb81]
      Registers.c = 0xff
      instruction.run
      assert_equal 0xfe, Registers.c
    end

    def test_bit_set
      instruction = Instruction[0xcbc0]
      Registers.b = 0x00
      instruction.run
      assert_equal 0x01, Registers.b

      instruction = Instruction[0xcbc1]
      Registers.c = 0x00
      instruction.run
      assert_equal 0x01, Registers.c
    end
  end
end