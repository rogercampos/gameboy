require_relative '../test_helper'

module Gameboy
  class StackTest < BaseTest
    def setup
      super
      MMU.reset!
      Registers.reset!
    end

    def test_push_and_pop
      initial_data = [0x01, 0xa1, 0xf2,   # LD bc, 0xf2a1
                      0x11, 0x12, 0x34,   # LD de, 0x3412
                      0xc5,    # PUSH bc
                      0xd5,    # PUSH de
                      0xf1,    # POP af
                      0xe1    # POP hl
                      ]

      initial_rom = DummyRom.new initial_data

      emulator = Emulator.new(Rom.new(initial_rom.body))

      assert_equal 0xfffe, Registers.sp
      emulator.run!(6)

      assert_equal(0xf2a1, Registers.bc)
      assert_equal(0x3412, Registers.de)

      assert_equal 0x3412, Registers.af
      assert_equal 0xf2a1, Registers.hl

      assert_equal 0xfffe, Registers.sp
    end

    def test_call
      initial_data = [0x3E, 0x0F,   # LD A, 0x0F
                      0xcd, 0x50 + 7, 0x01,   # CALL 0x0005
                      0x06, 0x05,    # LD B, 0x05
                      0x0E, 0x0A,    # LD C, 0x0A
                      ]

      initial_rom = DummyRom.new initial_data

      emulator = Emulator.new(Rom.new(initial_rom.body))

      emulator.run!(4)

      assert_equal 0x00, Registers.b # LD B, 0x05 is skipped
      assert_equal 0x0A, Registers.c
      assert_equal 0x0F, Registers.a
    end

    def test_call_and_return
      initial_data = [0x3E, 0x0F,   # LD A, 0x0F
                      0xcd, 0x50 + 7, 0x01,   # CALL 0x0005
                      0x06, 0x05,    # LD B, 0x05
                      0x0E, 0x0A,    # LD C, 0x0A
                      0xc9,          # RET
                      ]

      initial_rom = DummyRom.new initial_data

      emulator = Emulator.new(Rom.new(initial_rom.body))

      emulator.run!(6)

      assert_equal 0x05, Registers.b # LD B, 0x05 is executed
      assert_equal 0x0A, Registers.c
      assert_equal 0x0F, Registers.a
    end
  end
end