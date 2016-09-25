module Gameboy
  Instruction.define do
    family(:ld_16) do
      # LD n, nn
      opcode(0x01, 12, 3) { Registers.bc = MMU.wread(Registers.pc) }
      opcode(0x11, 12, 3) { Registers.de = MMU.wread(Registers.pc) }
      opcode(0x21, 12, 3) { Registers.hl = MMU.wread(Registers.pc) }
      opcode(0x31, 12, 3) { Registers.sp = MMU.wread(Registers.pc) }

      # LD SP, HL
      opcode(0xf9, 8, 1) { Registers.sp = Registers.hl }

      # LD (nn), SP
      opcode(0x08, 20, 3) { MMU.bwrite(MMU.wread(Registers.pc), Registers.sp) }
    end

    family(:ldhl_16) do
      # LDHL SP, n
      opcode(0xf8, 12, 2) { n = MMU.bread(Registers.pc, as: :signed); Registers.hl = n + Registers.sp }
    end

    family(:push_16) do
      # PUSH nn
      opcode(0xf5, 16, 1) { MMU.bwrite(Registers.sp - 1, Registers.a); MMU.bwrite(Registers.sp - 2, Registers.f); Registers.sp -= 2 }
      opcode(0xc5, 16, 1) { MMU.bwrite(Registers.sp - 1, Registers.b); MMU.bwrite(Registers.sp - 2, Registers.c); Registers.sp -= 2 }
      opcode(0xd5, 16, 1) { MMU.bwrite(Registers.sp - 1, Registers.d); MMU.bwrite(Registers.sp - 2, Registers.e); Registers.sp -= 2 }
      opcode(0xe5, 16, 1) { MMU.bwrite(Registers.sp - 1, Registers.h); MMU.bwrite(Registers.sp - 2, Registers.l); Registers.sp -= 2 }
    end

    family(:pop_16) do
      # POP nn
      opcode(0xf1, 12, 1) { Registers.a = MMU.bread(Registers.sp + 1); Registers.f = MMU.bread(Registers.sp); Registers.sp += 2 }
      opcode(0xc1, 12, 1) { Registers.b = MMU.bread(Registers.sp + 1); Registers.c = MMU.bread(Registers.sp); Registers.sp += 2 }
      opcode(0xd1, 12, 1) { Registers.d = MMU.bread(Registers.sp + 1); Registers.e = MMU.bread(Registers.sp); Registers.sp += 2 }
      opcode(0xe1, 12, 1) { Registers.h = MMU.bread(Registers.sp + 1); Registers.l = MMU.bread(Registers.sp); Registers.sp += 2 }
    end
  end
end