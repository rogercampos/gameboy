module Gameboy
  Instruction.define do
    def add_alu_flags(old_value, increment)
      new_value = (old_value + increment) % 2 ** 16
      Flags.n = 0
      Flags.c = 1 if old_value > new_value
      Flags.h = 1 if old_value <= 0b0000_1111_1111_1111 && new_value[12] == 1
    end

    family(:alu_16_add) do
      opcode(0x09, 8, 1) { Registers.hl.tap { |old_value| Registers.hl += Registers.bc; add_alu_flags(old_value, Registers.bc) } }
      opcode(0x19, 8, 1) { Registers.hl.tap { |old_value| Registers.hl += Registers.de; add_alu_flags(old_value, Registers.de) } }
      opcode(0x29, 8, 1) { Registers.hl.tap { |old_value| Registers.hl += Registers.hl; add_alu_flags(old_value, Registers.hl) } }
      opcode(0x39, 8, 1) { Registers.hl.tap { |old_value| Registers.hl += Registers.sp; add_alu_flags(old_value, Registers.sp) } }
      opcode(0xe8, 16, 2) { i = MMU.bread(Registers.pc, as: :signed); Registers.sp.tap { |old_value| Registers.sp += i; Flags.z = 0; add_alu_flags(old_value, i) } }
    end

    family(:alu_16_inc) do
      opcode(0x03, 8, 1) { Registers.bc += 1 }
      opcode(0x13, 8, 1) { Registers.de += 1 }
      opcode(0x23, 8, 1) { Registers.hl += 1 }
      opcode(0x33, 8, 1) { Registers.sp += 1 }
    end

    family(:alu_16_dec) do
      opcode(0x0b, 8, 1) { Registers.bc -= 1 }
      opcode(0x1b, 8, 1) { Registers.de -= 1 }
      opcode(0x2b, 8, 1) { Registers.hl -= 1 }
      opcode(0x3b, 8, 1) { Registers.sp -= 1 }
    end
  end
end