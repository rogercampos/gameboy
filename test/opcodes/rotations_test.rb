require_relative '../test_helper'

module Gameboy
  class RotationsTest < BaseTest
    def setup
      super
      Flags.z = 0
      Flags.n = 0
      Flags.c = 0
      Flags.h = 0
    end

    def test_rlca
      instruction = Instruction[0x07]
      Registers.a = 0b10001111
      instruction.run
      assert_equal 0b00011111, Registers.a
      assert_equal 1, Flags.c
    end

    def test_rla
      instruction = Instruction[0x17]
      Registers.a = 0b10001111
      Flags.c = 0
      instruction.run
      assert_equal 0b00011110, Registers.a
      assert_equal 1, Flags.c
    end

    def test_rla_c_set
      instruction = Instruction[0x17]
      Registers.a = 0b10001111
      Flags.c = 1
      instruction.run
      assert_equal 0b00011111, Registers.a
      assert_equal 1, Flags.c
    end
  end
end