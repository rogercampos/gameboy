require_relative '../test_helper'

module Gameboy
  class AluIntegrationTest < BaseTest
    def setup
      super
      MMU.reset!
      Registers.reset!
    end

    def test_example
      # Example ROM: LD A, 0x0F; LD B, 0x10; ADD A, B
      initial_rom = DummyRom.new [0x3E, 0x0F, 0x06, 0x10, 0x80]

      emulator = Emulator.new(Rom.new(initial_rom.body))
      emulator.run!(3)

      assert_equal(0x1F, Registers.a)
      assert_equal(0x10, Registers.b)
    end

    def test_2
      initial_data = [0x3E, 0x0F,   # LD A, 0x0F     ; Load register A with value 0x0F
                     0x06, 0x05,    # LD B, 0x05     ; Load register B with value 0x05
                     0x80,          # ADD A, B        ; Add register B to A
                     0x0E, 0x0A,    # LD C, 0x0A     ; Load register C with value 0x0A
                     0x81,          # ADD A, C        ; Add register C to A with carry
                     0x3C,          # INC A           ; Increment register A
                     0xC6, 0x02,    # ADD A, 0x02     ; Add immediate value 0x02 to A
                     0xC6, 0x00,    # ADD A, 0x00     ; Add immediate value 0x00 to A
                     0x3D]          # DEC A           ; Decrement register A

      initial_rom = DummyRom.new initial_data

      emulator = Emulator.new(Rom.new(initial_rom.body))
      emulator.run!(9)

      assert_equal(0x20, Registers.a)
      assert_equal(0x05, Registers.b)
      assert_equal(0x0A, Registers.c)
    end
  end
end