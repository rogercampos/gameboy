require_relative '../test_helper'

module Gameboy
  class CallTest < BaseTest
    def setup
      super
      Flags.z = 0
      Flags.n = 0
      Flags.c = 0
      Flags.h = 0
    end

    def test_simple_call
      instruction = Instruction[0xcd]
      Registers.pc = 0x2000
      Registers.sp = 0xcfff
      set_arg_1_w(0x1212)
      instruction.run
      assert_equal 0x1212, Registers.pc
      assert_equal 0x2002, MMU.wread(Registers.sp)
    end

    def test_call_conditional_z
      instruction = Instruction[0xc4]
      Registers.pc = 0x2000
      set_arg_1_w(0x1212)
      Flags.z = 0
      instruction.run
      assert_equal 0x1212, Registers.pc
      assert_equal 0x2002, MMU.wread(Registers.sp)
    end

    def test_call_conditional_z_not
      instruction = Instruction[0xc4]
      Registers.pc = 0x2000
      set_arg_1_w(0x1212)
      Flags.z = 1
      instruction.run
      assert_equal 0x2002, Registers.pc
    end

    def test_call_conditional_c
      instruction = Instruction[0xd4]
      Registers.pc = 0x2000
      set_arg_1_w(0x1212)
      Flags.c = 0
      instruction.run
      assert_equal 0x1212, Registers.pc
      assert_equal 0x2002, MMU.wread(Registers.sp)
    end

    def test_call_conditional_c_not
      instruction = Instruction[0xd4]
      Registers.pc = 0x2000
      set_arg_1_w(0x1212)
      Flags.c = 1
      instruction.run
      assert_equal 0x2002, Registers.pc
    end
  end
end