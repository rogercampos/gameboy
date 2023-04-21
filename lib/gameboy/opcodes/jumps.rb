module Gameboy
  Instruction.define do
    family(:jump) do
      opcode(0xc3, 12, 3) { Registers.pc = MMU.wread(Registers.pc) }

      opcode(0xc2, 12, 3) { Flags.z == 0 ? Registers.pc = MMU.wread(Registers.pc) : Registers.pc += 2 }
      opcode(0xca, 12, 3) { Flags.z == 1 ? Registers.pc = MMU.wread(Registers.pc) : Registers.pc += 2 }
      opcode(0xd2, 12, 3) { Flags.c == 0 ? Registers.pc = MMU.wread(Registers.pc) : Registers.pc += 2 }
      opcode(0xda, 12, 3) { Flags.c == 1 ? Registers.pc = MMU.wread(Registers.pc) : Registers.pc += 2 }

      opcode(0xe9, 4, 1) { Registers.pc = Registers.hl }

      opcode(0x18, 8, 2) { Registers.pc += MMU.bread(Registers.pc, as: :signed) }

      opcode(0x20, 8, 2) { Flags.z == 0 ? Registers.pc += MMU.bread(Registers.pc, as: :signed) : Registers.pc += 1 }
      opcode(0x28, 8, 2) { Flags.z == 1 ? Registers.pc += MMU.bread(Registers.pc, as: :signed) : Registers.pc += 1 }
      opcode(0x30, 8, 2) { Flags.c == 0 ? Registers.pc += MMU.bread(Registers.pc, as: :signed) : Registers.pc += 1 }
      opcode(0x38, 8, 2) { Flags.c == 1 ? Registers.pc += MMU.bread(Registers.pc, as: :signed) : Registers.pc += 1 }
    end
  end
end