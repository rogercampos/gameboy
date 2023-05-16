require_relative '../test_helper'

module Gameboy
  class JumpsTest < BaseTest
    def setup
      super
      Flags.z = 0
      Flags.n = 0
      Flags.c = 0
      Flags.h = 0
    end

    def test_simple_jump
      instruction = Instruction[0xc3]
      Registers.pc = 0x2000
      MMU.wwrite(0x2000, 0x2001)
      instruction.run
      assert_equal 0x2001, Registers.pc
    end

    def test_not_jump_if_zero
      instruction = Instruction[0xc2]
      Registers.pc = 0x2000
      MMU.wwrite(0x2000, 0x2001)
      Flags.z = 1
      instruction.run
      assert_equal 0x2002, Registers.pc
    end

    def test_jump_if_not_zero
      instruction = Instruction[0xc2]
      Registers.pc = 0x2000
      MMU.wwrite(0x2000, 0x42)
      Flags.z = 0
      instruction.run
      assert_equal 0x42, Registers.pc
    end

    def test_jump_if_carry
      instruction = Instruction[0xda]
      Registers.pc = 0x2000
      MMU.wwrite(0x2000, 0x2001)
      Flags.c = 1
      instruction.run
      assert_equal 0x2001, Registers.pc
    end

    def test_not_jump_if_carry_set
      instruction = Instruction[0xda]
      Registers.pc = 0x2000
      MMU.wwrite(0x2000, 0x2001)
      Flags.c = 0
      instruction.run
      assert_equal 0x2002, Registers.pc
    end

    def test_jump_to_hl
      instruction = Instruction[0xe9]
      Registers.hl = 0x2000
      instruction.run
      assert_equal 0x2000, Registers.pc
    end

    def test_jump_relative
      instruction = Instruction[0x18]
      Registers.pc = 0x2000
      MMU.bwrite(0x2000, 0x01)
      instruction.run
      assert_equal 0x2001, Registers.pc
    end

    def test_jump_relative_negative
      instruction = Instruction[0x18]
      Registers.pc = 0x2000
      MMU.bwrite(0x2000, 0xff)
      instruction.run
      assert_equal 0x1fff, Registers.pc
    end

    def test_jump_relative_if_zero
      instruction = Instruction[0x20]
      Registers.pc = 0x2000
      MMU.bwrite(0x2000, 0x01)
      Flags.z = 1
      instruction.run
      assert_equal 0x2001, Registers.pc
    end

    def test_jump_relative_if_not_zero
      instruction = Instruction[0x20]
      Registers.pc = 0x2000
      MMU.bwrite(0x2000, 0x01)
      Flags.z = 0
      instruction.run
      assert_equal 0x2001, Registers.pc
    end

    def test_jump_relative_if_carry
      instruction = Instruction[0x38]
      Registers.pc = 0x2000
      MMU.bwrite(0x2000, 0x01)
      Flags.c = 1
      instruction.run
      assert_equal 0x2001, Registers.pc
    end

    def test_jump_relative_if_not_carry
      instruction = Instruction[0x38]
      Registers.pc = 0x2000
      MMU.bwrite(0x2000, 0x01)
      Flags.c = 0
      instruction.run
      assert_equal 0x2001, Registers.pc
    end

    def test_jump_relative_if_carry_negative
      instruction = Instruction[0x38]
      Registers.pc = 0x2000
      MMU.bwrite(0x2000, 0xff)
      Flags.c = 1
      instruction.run
      assert_equal 0x1fff, Registers.pc
    end
  end
end