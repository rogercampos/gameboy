module Gameboy
  Instruction.define do
    family(:ld_16) do
      # LD n, nn
      opcode(0x01, 12, 3) { Registers.bc = MMU.wread(Registers.pc); Registers.pc += 2 }
      opcode(0x11, 12, 3) { Registers.de = MMU.wread(Registers.pc); Registers.pc += 2 }
      opcode(0x21, 12, 3) { Registers.hl = MMU.wread(Registers.pc); Registers.pc += 2 }
      opcode(0x31, 12, 3) { Registers.sp = MMU.wread(Registers.pc); Registers.pc += 2 }

      # LD SP, HL
      opcode(0xf9, 8, 1) { Registers.sp = Registers.hl }

      # LD (nn), SP
      opcode(0x08, 20, 3) { MMU.wwrite(MMU.wread(Registers.pc), Registers.sp); Registers.pc += 2 }
    end

    family(:ldhl_16) do
      # LDHL SP, n
      opcode(0xf8, 12, 2) { n = MMU.bread(Registers.pc, as: :signed); Registers.hl = n + Registers.sp; Registers.pc += 1 }
    end

    family(:push_16) do
      # PUSH nn
      opcode(0xf5, 16, 1) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.af) }
      opcode(0xc5, 16, 1) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.bc) }
      opcode(0xd5, 16, 1) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.de) }
      opcode(0xe5, 16, 1) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.hl) }
    end

    family(:pop_16) do
      # POP nn
      opcode(0xf1, 12, 1) { Registers.af = MMU.wread(Registers.sp); Registers.sp += 2 }
      opcode(0xc1, 12, 1) { Registers.bc = MMU.wread(Registers.sp); Registers.sp += 2 }
      opcode(0xd1, 12, 1) { Registers.de = MMU.wread(Registers.sp); Registers.sp += 2 }
      opcode(0xe1, 12, 1) { Registers.hl = MMU.wread(Registers.sp); Registers.sp += 2 }
    end
  end
end