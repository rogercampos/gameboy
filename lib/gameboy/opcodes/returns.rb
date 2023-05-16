module Gameboy
  Instruction.define do
    family(:return) do
      opcode(0xc9, 8, 1) { destination = MMU.wread(Registers.sp); Registers.sp += 2; Registers.pc = destination }

      opcode(0xc0, 8, 1) { Flags.z == 0 ? Instruction[0xc9].run : nil }
      opcode(0xc8, 8, 1) { Flags.z == 1 ? Instruction[0xc9].run : nil }
      opcode(0xd0, 8, 1) { Flags.c == 0 ? Instruction[0xc9].run : nil }
      opcode(0xd8, 8, 1) { Flags.c == 1 ? Instruction[0xc9].run : nil }

      # TODO missing enable interrupts
      opcode(0xd9, 8, 1) { Instruction[0xc9].run  }
    end
  end
end