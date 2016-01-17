Instruction.define do
  # LD n, nn
  opcode(0x01, 12, 3) { Registers.bc = MMU.read(Registers.pc, 2) }
  opcode(0x11, 12, 3) { Registers.de = MMU.read(Registers.pc, 2) }
  opcode(0x21, 12, 3) { Registers.hl = MMU.read(Registers.pc, 2) }
  opcode(0x31, 12, 3) { Registers.sp = MMU.read(Registers.pc, 2) }

  # LD SP, HL
  opcode(0xf9, 8, 1) { Registers.sp = Registers.hl }

  # LDHL SP, n
  opcode(0xf8, 12, 2) { n = MMU.read(Registers.pc, 1, as: :signed); Registers.hl = n + Registers.sp }

  # LD (nn), SP
  opcode(0x08, 20, 3) { MMU.write(MMU.read(Registers.pc, 2), Registers.sp) }
end