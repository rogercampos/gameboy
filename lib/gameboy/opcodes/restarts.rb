module Gameboy
  Instruction.define do
    family(:restart) do
      opcode(0xc7, 32, 1) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x0 }
      opcode(0xcf, 32, 1) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x8 }
      opcode(0xd7, 32, 1) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x10 }
      opcode(0xdf, 32, 1) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x18 }
      opcode(0xe7, 32, 1) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x20 }
      opcode(0xef, 32, 1) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x28 }
      opcode(0xf7, 32, 1) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x30 }
      opcode(0xff, 32, 1) { Registers.sp -= 2; MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x38 }
    end
  end
end