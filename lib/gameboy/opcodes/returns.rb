module Gameboy
  Instruction.define do
    opcode(0xc9, 8, 1) { destination = MMU.wread(Registers.sp); Registers.sp += 2; Registers.pc = destination }

    opcode(0xc0, 8, 1) { Instruction[0xc9].call if Flags.z == 0 }
    opcode(0xc8, 8, 1) { Instruction[0xc9].call if Flags.z == 1 }
    opcode(0xd0, 8, 1) { Instruction[0xc9].call if Flags.c == 0 }
    opcode(0xd8, 8, 1) { Instruction[0xc9].call if Flags.c == 1 }

    # TODO
    # opcode(0xd9, 8, 1) { Instruction[0xc9].call;  }
  end
end