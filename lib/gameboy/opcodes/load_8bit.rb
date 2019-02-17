module Gameboy
  Instruction.define do
    family(:ld_8) do
      # LD nn,n
      opcode(0x06, 8, 2) { Registers.b = MMU.bread(Registers.pc); Registers.pc += 1 }
      opcode(0x0e, 8, 2) { Registers.c = MMU.bread(Registers.pc); Registers.pc += 1 }
      opcode(0x16, 8, 2) { Registers.d = MMU.bread(Registers.pc); Registers.pc += 1 }
      opcode(0x1e, 8, 2) { Registers.e = MMU.bread(Registers.pc); Registers.pc += 1 }
      opcode(0x26, 8, 2) { Registers.h = MMU.bread(Registers.pc); Registers.pc += 1 }
      opcode(0x2e, 8, 2) { Registers.l = MMU.bread(Registers.pc); Registers.pc += 1 }

      # LD r1,r2
      opcode(0x36, 12, 2) { MMU.bwrite(Registers.hl, MMU.bread(Registers.pc)); Registers.pc += 1 }

      opcode(0x7f, 4, 1) { Registers.a = Registers.a }
      opcode(0x78, 4, 1) { Registers.a = Registers.b }
      opcode(0x79, 4, 1) { Registers.a = Registers.c }
      opcode(0x7a, 4, 1) { Registers.a = Registers.d }
      opcode(0x7b, 4, 1) { Registers.a = Registers.e }
      opcode(0x7c, 4, 1) { Registers.a = Registers.h }
      opcode(0x7d, 4, 1) { Registers.a = Registers.l }
      opcode(0x7e, 8, 1) { Registers.a = MMU.bread(Registers.hl) }

      opcode(0x40, 4, 1) { Registers.b = Registers.b }
      opcode(0x41, 4, 1) { Registers.b = Registers.c }
      opcode(0x42, 4, 1) { Registers.b = Registers.d }
      opcode(0x43, 4, 1) { Registers.b = Registers.e }
      opcode(0x44, 4, 1) { Registers.b = Registers.h }
      opcode(0x45, 4, 1) { Registers.b = Registers.l }
      opcode(0x46, 8, 1) { Registers.b = MMU.bread(Registers.hl) }

      opcode(0x48, 4, 1) { Registers.c = Registers.b }
      opcode(0x49, 4, 1) { Registers.c = Registers.c }
      opcode(0x4a, 4, 1) { Registers.c = Registers.d }
      opcode(0x4b, 4, 1) { Registers.c = Registers.e }
      opcode(0x4c, 4, 1) { Registers.c = Registers.h }
      opcode(0x4d, 4, 1) { Registers.c = Registers.l }
      opcode(0x4e, 8, 1) { Registers.c = MMU.bread(Registers.hl) }

      opcode(0x50, 4, 1) { Registers.d = Registers.b }
      opcode(0x51, 4, 1) { Registers.d = Registers.c }
      opcode(0x52, 4, 1) { Registers.d = Registers.d }
      opcode(0x53, 4, 1) { Registers.d = Registers.e }
      opcode(0x54, 4, 1) { Registers.d = Registers.h }
      opcode(0x55, 4, 1) { Registers.d = Registers.l }
      opcode(0x56, 8, 1) { Registers.d = MMU.bread(Registers.hl) }

      opcode(0x58, 4, 1) { Registers.e = Registers.b }
      opcode(0x59, 4, 1) { Registers.e = Registers.c }
      opcode(0x5a, 4, 1) { Registers.e = Registers.d }
      opcode(0x5b, 4, 1) { Registers.e = Registers.e }
      opcode(0x5c, 4, 1) { Registers.e = Registers.h }
      opcode(0x5d, 4, 1) { Registers.e = Registers.l }
      opcode(0x5e, 8, 1) { Registers.e = MMU.bread(Registers.hl) }

      opcode(0x60, 4, 1) { Registers.h = Registers.b }
      opcode(0x61, 4, 1) { Registers.h = Registers.c }
      opcode(0x62, 4, 1) { Registers.h = Registers.d }
      opcode(0x63, 4, 1) { Registers.h = Registers.e }
      opcode(0x64, 4, 1) { Registers.h = Registers.h }
      opcode(0x65, 4, 1) { Registers.h = Registers.l }
      opcode(0x66, 8, 1) { Registers.h = MMU.bread(Registers.hl) }

      opcode(0x68, 4, 1) { Registers.l = Registers.b }
      opcode(0x69, 4, 1) { Registers.l = Registers.c }
      opcode(0x6a, 4, 1) { Registers.l = Registers.d }
      opcode(0x6b, 4, 1) { Registers.l = Registers.e }
      opcode(0x6c, 4, 1) { Registers.l = Registers.h }
      opcode(0x6d, 4, 1) { Registers.l = Registers.l }
      opcode(0x6e, 8, 1) { Registers.l = MMU.bread(Registers.hl) }

      opcode(0x70, 8, 1) { MMU.bwrite(Registers.hl, Registers.b) }
      opcode(0x71, 8, 1) { MMU.bwrite(Registers.hl, Registers.c) }
      opcode(0x72, 8, 1) { MMU.bwrite(Registers.hl, Registers.d) }
      opcode(0x73, 8, 1) { MMU.bwrite(Registers.hl, Registers.e) }
      opcode(0x74, 8, 1) { MMU.bwrite(Registers.hl, Registers.h) }
      opcode(0x75, 8, 1) { MMU.bwrite(Registers.hl, Registers.l) }

      # LD A,n
      opcode(0x0a, 8, 1) { Registers.a = MMU.bread(Registers.bc) }
      opcode(0x1a, 8, 1) { Registers.a = MMU.bread(Registers.de) }
      opcode(0x7e, 8, 1) { Registers.a = MMU.bread(Registers.hl) }
      opcode(0xfa, 16, 3) { Registers.a = MMU.bread(MMU.wread(Registers.pc)); Registers.pc += 2 }
      opcode(0x3e, 8, 3) { Registers.a = MMU.wread(Registers.pc); Registers.pc += 2 }

      # LD n, A
      opcode(0x47, 4, 1) { Registers.b = Registers.a }
      opcode(0x4f, 4, 1) { Registers.c = Registers.a }
      opcode(0x57, 4, 1) { Registers.d = Registers.a }
      opcode(0x5f, 4, 1) { Registers.e = Registers.a }
      opcode(0x67, 4, 1) { Registers.h = Registers.a }
      opcode(0x6f, 4, 1) { Registers.l = Registers.a }

      opcode(0x02, 8, 1) { MMU.bwrite(Registers.bc, Registers.a) }
      opcode(0x12, 8, 1) { MMU.bwrite(Registers.de, Registers.a) }
      opcode(0x77, 8, 1) { MMU.bwrite(Registers.hl, Registers.a) }

      opcode(0xea, 16, 3) { MMU.bwrite(MMU.wread(Registers.pc), Registers.a); Registers.pc += 2 }

      # LD A, (C)
      opcode(0xf2, 8, 1) { Registers.a = MMU.bread(0xff00 + Registers.c) }

      # LD (C), A
      opcode(0xe2, 8, 1) { MMU.bwrite(0xff00 + Registers.c, Registers.a) }
    end

    family(:ldd_8) do
      # LDD A, (HL)
      opcode(0x3a, 8, 1) { Registers.a = MMU.bread(Registers.hl); Instruction[0x35].run }

      # LDD (HL), A
      opcode(0x32, 8, 1) { MMU.bwrite(Registers.hl, Registers.a); Instruction[0x35].run }
    end

    family(:ldi_8) do
      # LDI A, (HL)
      opcode(0x2a, 8, 1) { Registers.a = MMU.bread(Registers.hl); Instruction[0x3c].run }

      # LDI (HL), A
      opcode(0x22, 8, 1) { MMU.bwrite(Registers.hl, Registers.a); Instruction[0x3c].run }
    end

    family(:ldh_8) do
      # LDH (n), A
      opcode(0xe0, 12, 2) { MMU.bwrite(0xff00 + MMU.bread(Registers.pc), Registers.a); Registers.pc += 1 }

      # LDH A, (n)
      opcode(0xf0, 12, 2) { Registers.a = MMU.bread(0xff00 + MMU.bread(Registers.pc)); Registers.pc += 1 }
    end
  end
end