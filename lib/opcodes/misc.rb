Instruction.define do
  # NOP
  opcode(0x00, 4, 1) {}

  # SWAP
  opcode(0xcb37, 8, 1) { Registers.a = ((Registers.a & 0xF) << 4) | ((Registers.a & 0xF0) >> 4); Flags.z = 0 if Registers.a == 0 }
  opcode(0xcb30, 8, 1) { Registers.b = ((Registers.b & 0xF) << 4) | ((Registers.b & 0xF0) >> 4); Flags.z = 0 if Registers.b == 0 }
  opcode(0xcb31, 8, 1) { Registers.c = ((Registers.c & 0xF) << 4) | ((Registers.c & 0xF0) >> 4); Flags.z = 0 if Registers.c == 0 }
  opcode(0xcb32, 8, 1) { Registers.d = ((Registers.d & 0xF) << 4) | ((Registers.d & 0xF0) >> 4); Flags.z = 0 if Registers.d == 0 }
  opcode(0xcb33, 8, 1) { Registers.e = ((Registers.e & 0xF) << 4) | ((Registers.e & 0xF0) >> 4); Flags.z = 0 if Registers.e == 0 }
  opcode(0xcb34, 8, 1) { Registers.h = ((Registers.h & 0xF) << 4) | ((Registers.h & 0xF0) >> 4); Flags.z = 0 if Registers.h == 0 }
  opcode(0xcb35, 8, 1) { Registers.l = ((Registers.l & 0xF) << 4) | ((Registers.l & 0xF0) >> 4); Flags.z = 0 if Registers.l == 0 }
  opcode(0xcb36, 16, 1) { raise("Not implemented swap on (HL)") }

  # DAA
  opcode(0x27, 4, 1) { raise "TODO" }

  # CPL
  opcode(0x2f, 4, 1) { Registers.a = ~Registers.a; Flags.n = 1; Flags.h = 1 }

  # CCF
  opcode(0x3f, 4, 1) { Flags.c = Flags.c == 1 ? 0 : 1; Flags.n = 0; Flags.h = 0 }

  # SCF
  opcode(0x37, 4, 1) { Flags.c = 1; Flags.n = 0; Flags.h = 0 }

  # HALT
  opcode(0x76, 4, 1) { raise "TODO" }

  # STOP
  opcode(0x10, 4, 1) { raise "TODO" }

  # DI
  opcode(0xf3, 4, 1) { raise "TODO" }

  # EI
  opcode(0xfb, 4, 1) { raise "TODO" }
end