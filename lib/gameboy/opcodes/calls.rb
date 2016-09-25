module Gameboy
  Instruction.define do
    family(:call) do
      opcode(0xcd, 12, 3, true) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.pc + 2); Registers.pc = MMU.wread(Registers.pc) }

      # opcode(0xc4, 12, 3) { Instruction[0xcd].run if Flags.z == 0 }
      # opcode(0xcc, 12, 3) { Instruction[0xcd].run if Flags.z == 1 }
      # opcode(0xd4, 12, 3) { Instruction[0xcd].run if Flags.c == 0 }
      # opcode(0xdc, 12, 3) { Instruction[0xcd].run if Flags.c == 1 }
    end
  end
end