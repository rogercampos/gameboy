require_relative 'test_helper'

module Gameboy
  class TestRegisters < BaseTest
    def setup
      super
      Registers.reset!
    end

    def test_registers_simple
      %w(a f b c d e h l).each do |register|
        Registers.send("#{register}=", 45)
        assert_equal 45, Registers.send(register)

        Registers.send("#{register}=", 256)
        assert_equal 0, Registers.send(register)

        Registers.send("#{register}=", 257)
        assert_equal 1, Registers.send(register)
      end
    end

    def test_special_registers
      %w(pc sp).each do |register|
        Registers.send("#{register}=", 45812)
        assert_equal 45812, Registers.send(register)

        Registers.send("#{register}=", 65536)
        assert_equal 0, Registers.send(register)

        Registers.send("#{register}=", 65537)
        assert_equal 1, Registers.send(register)
      end
    end

    def test_double_registers
      %w(af bc de hl).each do |double_register|
        Registers.send("#{double_register}=", 0xff34)
        assert_equal 0xff34, Registers.send(double_register)

        Registers.send("#{double_register}=", 65536)
        assert_equal 0, Registers.send(double_register)

        Registers.send("#{double_register}=", 65537)
        assert_equal 1, Registers.send(double_register)

        a = double_register[0]
        b = double_register[1]
        Registers.send("#{double_register}=", 0x83be)
        assert_equal 0xbe, Registers.send(b)
        assert_equal 0x83, Registers.send(a)

        Registers.send("#{b}=", 0x59)
        Registers.send("#{a}=", 0xaa)
        assert_equal 0xaa59, Registers.send(double_register)
      end
    end
  end
end