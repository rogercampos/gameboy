module Gameboy
  Instruction.define do
    def set_zero_flag(value)
      value == 0 ? Flags.z = 1 : Flags.z = 0
    end

    family(:noop) do
      opcode(0x00, 4, 1) {}
    end

    family(:swap) do
      opcode(0xcb37, 8, 1) { Registers.a = ((Registers.a & 0xF) << 4) | ((Registers.a & 0xF0) >> 4); set_zero_flag(Registers.a) }
      opcode(0xcb30, 8, 1) { Registers.b = ((Registers.b & 0xF) << 4) | ((Registers.b & 0xF0) >> 4); set_zero_flag Registers.b }
      opcode(0xcb31, 8, 1) { Registers.c = ((Registers.c & 0xF) << 4) | ((Registers.c & 0xF0) >> 4); set_zero_flag Registers.c }
      opcode(0xcb32, 8, 1) { Registers.d = ((Registers.d & 0xF) << 4) | ((Registers.d & 0xF0) >> 4); set_zero_flag Registers.d }
      opcode(0xcb33, 8, 1) { Registers.e = ((Registers.e & 0xF) << 4) | ((Registers.e & 0xF0) >> 4); set_zero_flag Registers.e }
      opcode(0xcb34, 8, 1) { Registers.h = ((Registers.h & 0xF) << 4) | ((Registers.h & 0xF0) >> 4); set_zero_flag Registers.h }
      opcode(0xcb35, 8, 1) { Registers.l = ((Registers.l & 0xF) << 4) | ((Registers.l & 0xF0) >> 4); set_zero_flag Registers.l }
      opcode(0xcb36, 16, 1) { raise("Not implemented swap on (HL)") }
    end

    family(:daa) do
      opcode(0x27, 4, 1) { raise "TODO" }
    end

    family(:cpl) do
      opcode(0x2f, 4, 1) { Registers.a = (~Registers.a) & 0xFF; Flags.n = 1; Flags.h = 1 }
    end

    family(:ccf) do
      opcode(0x3f, 4, 1) { Flags.c = Flags.c == 1 ? 0 : 1; Flags.n = 0; Flags.h = 0 }
    end

    family(:scf) do
      opcode(0x37, 4, 1) { Flags.c = 1; Flags.n = 0; Flags.h = 0 }
    end

    family(:halt) do
      opcode(0x76, 4, 1) { raise "TODO" }
    end

    family(:stop) do
      opcode(0x10, 4, 1) {
        puts "Wait until button pressed"
        gets # TODO
        exit 0
      }
    end

    family(:di) do
      opcode(0xf3, 4, 1) { CPU_DEFERRED_QUEUE.push(DeferredAction.new(2) { Interrupt._ie = 0 }) }
    end

    family(:ei) do
      opcode(0xfb, 4, 1) { CPU_DEFERRED_QUEUE.push(DeferredAction.new(2) { Interrupt._ie = 0b0001_1111 }) }
    end
  end
end