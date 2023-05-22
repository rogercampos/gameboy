require_relative '../test_helper'

module Gameboy
  class Alu8bitTest < BaseTest
    def setup
      super
      Flags.z = 0
      Flags.n = 0
      Flags.c = 0
      Flags.h = 0
    end

    def test_alu_8_add_half_carry
      instruction = Instruction[0x87]
      Registers.a = 0x0f
      instruction.run
      assert_equal 0x1e, Registers.a
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 1, Flags.h
    end

    def test_alu_8_add_carry
      instruction = Instruction[0x87]
      Registers.a = 0xff
      instruction.run
      assert_equal 0xfe, Registers.a
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 1, Flags.c
      assert_equal 1, Flags.h
    end

    def test_alu_8_add_zero
      instruction = Instruction[0x87]
      Registers.a = 0x00
      instruction.run
      assert_equal 0x00, Registers.a
      assert_equal 1, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_8_hl_register
      instruction = Instruction[0x86]
      Registers.a = 0x0f
      Registers.hl = 0x2000
      MMU.bwrite(0x2000, 0x12)
      instruction.run
      assert_equal 0x21, Registers.a
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 1, Flags.h
    end

    def test_alu_8_constant_add
      instruction = Instruction[0xc6]
      Registers.a = 0x0f
      set_arg_1(0x12)
      instruction.run
      assert_equal 0x21, Registers.a
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 1, Flags.h
    end

    def test_alu_8_adc
      instruction = Instruction[0x8f]
      Registers.a = 0x0f
      Flags.c = 1
      instruction.run
      assert_equal 0x1f, Registers.a
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_8_sub
      instruction = Instruction[0x97]
      Registers.a = 0x0f
      instruction.run
      assert_equal 0x00, Registers.a
      assert_equal 1, Flags.z
      assert_equal 1, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_8_sub_half_carry
      instruction = Instruction[0x90]
      Registers.a = 0x10
      Registers.b = 0x01
      instruction.run
      assert_equal 0x0f, Registers.a
      assert_equal 0, Flags.z
      assert_equal 1, Flags.n
      assert_equal 0, Flags.c
      assert_equal 1, Flags.h
    end

    def test_alu_8_sub_carry
      instruction = Instruction[0x90]
      Registers.a = 0x01
      Registers.b = 0x03
      instruction.run
      assert_equal 0xfe, Registers.a
      assert_equal 0, Flags.z
      assert_equal 1, Flags.n
      assert_equal 1, Flags.c
      assert_equal 1, Flags.h
    end

    def test_alu_8_sbc
      instruction = Instruction[0x9f]
      Registers.a = 0x0f
      Flags.c = 1
      instruction.run
      assert_equal 0xff, Registers.a
      assert_equal 0, Flags.z
      assert_equal 1, Flags.n
      assert_equal 1, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_8_and
      instruction = Instruction[0xa7]
      Registers.a = 0x0f
      instruction.run
      assert_equal 0x0f, Registers.a
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 1, Flags.h
    end

    def test_alu_8_and_zero
      instruction = Instruction[0xa7]
      Registers.a = 0x00
      instruction.run
      assert_equal 0x00, Registers.a
      assert_equal 1, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 1, Flags.h
    end

    def test_alu_8_or
      instruction = Instruction[0xb7]
      Registers.a = 0x0f
      instruction.run
      assert_equal 0x0f, Registers.a
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_8_or_zero
      instruction = Instruction[0xb7]
      Registers.a = 0x00
      instruction.run
      assert_equal 0x00, Registers.a
      assert_equal 1, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_8_xor
      instruction = Instruction[0xaf]
      Registers.a = 0x0f
      instruction.run
      assert_equal 0x00, Registers.a
      assert_equal 1, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_8_xor_zero
      instruction = Instruction[0xaf]
      Registers.a = 0x00
      instruction.run
      assert_equal 0x00, Registers.a
      assert_equal 1, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_8_cp
      instruction = Instruction[0xb8]
      Registers.a = 0x0f
      Registers.b = 0x01
      instruction.run
      assert_equal 0x0f, Registers.a
      assert_equal 0, Flags.z
      assert_equal 1, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_8_cp_zero
      instruction = Instruction[0xbf]
      Registers.a = 0x00
      instruction.run
      assert_equal 0x00, Registers.a
      assert_equal 1, Flags.z
      assert_equal 1, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_8_cp_carry
      instruction = Instruction[0xb8]
      Registers.a = 0x01
      Registers.b = 0x03
      instruction.run
      assert_equal 0x01, Registers.a
      assert_equal 0, Flags.z
      assert_equal 1, Flags.n
      assert_equal 1, Flags.c
      assert_equal 1  , Flags.h
    end

    def test_alu_8_inc
      instruction = Instruction[0x3c]
      Registers.a = 0x14
      instruction.run
      assert_equal 0x15, Registers.a
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_8_inc_zero
      instruction = Instruction[0x3c]
      Registers.a = 0xff
      instruction.run
      assert_equal 0x00, Registers.a
      assert_equal 1, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 1, Flags.h
    end

    def test_alu_8_inc_half_carry
      instruction = Instruction[0x3c]
      Registers.a = 0x0f
      instruction.run
      assert_equal 0x10, Registers.a
      assert_equal 0, Flags.z
      assert_equal 0, Flags.n
      assert_equal 0, Flags.c
      assert_equal 1, Flags.h
    end

    def test_alu_8_dec
      instruction = Instruction[0x3d]
      Registers.a = 0x14
      instruction.run
      assert_equal 0x13, Registers.a
      assert_equal 0, Flags.z
      assert_equal 1, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_8_dec_zero
      instruction = Instruction[0x3d]
      Registers.a = 0x01
      instruction.run
      assert_equal 0x00, Registers.a
      assert_equal 1, Flags.z
      assert_equal 1, Flags.n
      assert_equal 0, Flags.c
      assert_equal 0, Flags.h
    end

    def test_alu_8_dec_half_carry
      instruction = Instruction[0x3d]
      Registers.a = 0x10
      instruction.run
      assert_equal 0x0f, Registers.a
      assert_equal 0, Flags.z
      assert_equal 1, Flags.n
      assert_equal 0, Flags.c
      assert_equal 1, Flags.h
    end
  end
end