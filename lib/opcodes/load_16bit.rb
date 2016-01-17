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

  # PUSH nn
  opcode(0xf5, 16, 1) { MMU.write(Registers.sp - 1, Registers.a); MMU.write(Registers.sp - 2, Registers.f); Registers.sp -= 2 }
  opcode(0xc5, 16, 1) { MMU.write(Registers.sp - 1, Registers.b); MMU.write(Registers.sp - 2, Registers.c); Registers.sp -= 2 }
  opcode(0xd5, 16, 1) { MMU.write(Registers.sp - 1, Registers.d); MMU.write(Registers.sp - 2, Registers.e); Registers.sp -= 2 }
  opcode(0xe5, 16, 1) { MMU.write(Registers.sp - 1, Registers.h); MMU.write(Registers.sp - 2, Registers.l); Registers.sp -= 2 }

  # POP nn
  opcode(0xf1, 12, 1) { Registers.a = MMU.read(Registers.sp - 1); Registers.f = MMU.read(Registers.sp); Registers.sp += 2 }
  opcode(0xc1, 12, 1) { Registers.b = MMU.read(Registers.sp - 1); Registers.c = MMU.read(Registers.sp); Registers.sp += 2 }
  opcode(0xd1, 12, 1) { Registers.d = MMU.read(Registers.sp - 1); Registers.e = MMU.read(Registers.sp); Registers.sp += 2 }
  opcode(0xe1, 12, 1) { Registers.h = MMU.read(Registers.sp - 1); Registers.l = MMU.read(Registers.sp); Registers.sp += 2 }
end