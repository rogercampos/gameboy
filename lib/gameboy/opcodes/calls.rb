module Gameboy
  Instruction.define do
    family(:call) do
      opcode(0xcd, 12, 3) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.pc + 2); Registers.pc = MMU.wread(Registers.pc) }

      opcode(0xc4, 12, 3) { Flags.z == 0 ? Instruction[0xcd].run : Registers.pc += 2 }
      opcode(0xcc, 12, 3) { Flags.z == 1 ? Instruction[0xcd].run : Registers.pc += 2 }
      opcode(0xd4, 12, 3) { Flags.c == 0 ? Instruction[0xcd].run : Registers.pc += 2 }
      opcode(0xdc, 12, 3) { Flags.c == 1 ? Instruction[0xcd].run : Registers.pc += 2 }
    end
  end
end