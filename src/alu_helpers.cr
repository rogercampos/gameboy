require "./flags"

module Gameboy
  module ALUHelpers
    extend self

    # Addition with flags
    def add(old_value : Int32, increment : Int32) : Int32
      new_value = (old_value + increment) & 0xFF
      Flags.z = new_value == 0 ? 1 : 0
      Flags.n = 0
      Flags.c = old_value + increment > 0xFF ? 1 : 0
      Flags.h = ((old_value ^ increment ^ new_value) & 0x10) != 0 ? 1 : 0
      new_value
    end

    # Subtraction with flags
    def sub(old_value : Int32, decrement : Int32) : Int32
      new_value = (old_value - decrement) & 0xFF
      Flags.z = new_value == 0 ? 1 : 0
      Flags.n = 1
      Flags.c = (old_value - decrement) < 0 ? 1 : 0
      Flags.h = ((old_value ^ decrement ^ new_value) & 0x10) != 0 ? 1 : 0
      new_value
    end

    # Set flags for subtraction without storing result (for CP)
    def sub_flags(old_value : Int32, decrement : Int32)
      new_value = (old_value - decrement) & 0xFF
      Flags.z = new_value == 0 ? 1 : 0
      Flags.n = 1
      Flags.c = (old_value - decrement) < 0 ? 1 : 0
      Flags.h = ((old_value ^ decrement ^ new_value) & 0x10) != 0 ? 1 : 0
    end

    # Increment with flags
    def inc_flags(old_value : Int32, new_value : Int32)
      Flags.z = new_value == 0 ? 1 : 0
      Flags.n = 0
      Flags.h = ((old_value ^ 1 ^ new_value) & 0x10) != 0 ? 1 : 0
    end

    # Decrement with flags
    def dec_flags(old_value : Int32, new_value : Int32)
      Flags.z = new_value == 0 ? 1 : 0
      Flags.n = 1
      Flags.h = ((old_value ^ 1 ^ new_value) & 0x10) != 0 ? 1 : 0
    end

    # Set zero flag only
    def set_zero_flag(value : Int32)
      Flags.z = value == 0 ? 1 : 0
    end

    # Bitwise AND with flags
    def bit_and(value : Int32) : Int32
      result = value & 0xFF
      Flags.z = result == 0 ? 1 : 0
      Flags.n = 0
      Flags.h = 1
      Flags.c = 0
      result
    end

    # Bitwise OR with flags
    def bit_or(value : Int32) : Int32
      result = value & 0xFF
      Flags.z = result == 0 ? 1 : 0
      Flags.n = 0
      Flags.h = 0
      Flags.c = 0
      result
    end

    # Bitwise XOR with flags
    def bit_xor(value : Int32) : Int32
      result = value & 0xFF
      Flags.z = result == 0 ? 1 : 0
      Flags.n = 0
      Flags.h = 0
      Flags.c = 0
      result
    end

    # 16-bit addition with flags (for ADD HL,rr and ADD SP,n)
    # Note: Z flag is NOT affected by 16-bit ADD (except ADD SP,n sets Z=0)
    def add_16bit_flags(old_value : Int32, increment : Int32, set_z_to_zero : Bool = false)
      new_value = (old_value + increment) & 0xFFFF
      Flags.n = 0

      # Carry flag: set if result overflows 16 bits
      if increment >= 0
        Flags.c = (old_value + increment) > 0xFFFF ? 1 : 0
      else
        Flags.c = (old_value + increment) < 0 ? 1 : 0
      end

      # Half-carry flag: set if carry from bit 11 to bit 12
      # Check if bit 12 changed from 0 to 1
      Flags.h = ((old_value & 0x0FFF) + (increment & 0x0FFF)) > 0x0FFF ? 1 : 0

      # For ADD SP,n instruction, explicitly set Z=0
      if set_z_to_zero
        Flags.z = 0
      end
    end
  end
end
