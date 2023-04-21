require_relative '../test_helper'

module Gameboy
  class Alu16bitTest < BaseTest
    def setup
      super
      Flags.z = 0
      Flags.n = 0
      Flags.c = 0
      Flags.h = 0
    end

    def test_alu_16_add_half_carry
      instruction = Instruction[0x09]
      Registers.hl = 0x0fff
      Registers.bc = 0x0001
      instruction.run
      assert_equal 0x1000, Registers.hl
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 1, Flags.h
    end

    def test_alu_16_add_carry
      instruction = Instruction[0x09]
      Registers.hl = 0xffff
      Registers.bc = 0x0001
      instruction.run
      assert_equal 0x0000, Registers.hl
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 1, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_16_add_no_carry
      instruction = Instruction[0x09]
      Registers.hl = 0x0000
      Registers.bc = 0x0001
      instruction.run
      assert_equal 0x0001, Registers.hl
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_16_add_constant
      instruction = Instruction[0xe8]
      Registers.sp = 0x0003
      set_arg_1(0x01)
      instruction.run
      assert_equal 0x0004, Registers.sp
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_16_add_constant_signed
      instruction = Instruction[0xe8]
      Registers.sp = 0x0003
      set_arg_1(0xfe)
      instruction.run
      assert_equal 0x0001, Registers.sp
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_16_inc
      instruction = Instruction[0x03]
      Registers.bc = 0x0000
      instruction.run
      assert_equal 0x0001, Registers.bc
    end

    def test_alu_16_dec
      instruction = Instruction[0x0b]
      Registers.bc = 0x0001
      instruction.run
      assert_equal 0x0000, Registers.bc
    end
  end
end