class Instruction
  attr_accessor :opcode, :cycles, :size, :impl

  def initialize(opcode, cycles, size, impl)
    @opcode = opcode
    @cycles = cycles
    @size = size
    @impl = impl
  end

  def run
    @impl.call
  end

  @instructions = {}

  class << self
    attr_accessor :instructions

    class Builder
      attr_accessor :instructions

      def initialize(&block)
        @instructions = {}
        instance_eval(&block)
      end

      def opcode(address, cycles, size, &impl)
        @instructions[address] = Instruction.new(address, cycles, size, impl)
      end
    end

    def define(&block)
      a = Builder.new(&block)
      @instructions = a.instructions
    end

    def [](value)
      @instructions[value]
    end
  end
end


Instruction.define do
  def add_alu_flags(old_value, increment)
    new_value = (old_value + increment) % 2 ** 8
    Flags.z = 1 if new_value == 0
    Flags.n = 0
    Flags.c = 1 if old_value > new_value
    Flags.h = 1 if ((old_value ^ increment ^ new_value) & 0x10) != 0
  end

  # noop
  opcode(0x00, 4, 1) {}


  # 8 bit ALU
  opcode(0x87, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.a; add_alu_flags(old_value, Registers.a) } }
  opcode(0x80, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.b; add_alu_flags(old_value, Registers.b) } }
  opcode(0x81, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.c; add_alu_flags(old_value, Registers.c) } }
  opcode(0x82, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.d; add_alu_flags(old_value, Registers.d) } }
  opcode(0x83, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.e; add_alu_flags(old_value, Registers.e) } }
  opcode(0x84, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.h; add_alu_flags(old_value, Registers.h) } }
  opcode(0x85, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.l; add_alu_flags(old_value, Registers.l) } }
  opcode(0x86, 8, 1) { Registers.a.tap { |old_value| Registers.a += Registers.hl; add_alu_flags(old_value, Registers.hl) } }
  opcode(0xc6, 8, 2) { i = MMU.read(Registers.pc, 1); Registers.a.tap { |old_value| Registers.a += i; add_alu_flags(old_value, i) } }


  # Jumps
  opcode(0xc3, 12, 3) { Registers.pc = MMU.read(Registers.pc, 2) }

  opcode(0xc2, 12, 3) { Registers.pc = MMU.read(Registers.pc, 2) if Flags.z == 0 }
  opcode(0xca, 12, 3) { Registers.pc = MMU.read(Registers.pc, 2) if Flags.z == 1 }
  opcode(0xd2, 12, 3) { Registers.pc = MMU.read(Registers.pc, 2) if Flags.c == 0 }
  opcode(0xda, 12, 3) { Registers.pc = MMU.read(Registers.pc, 2) if Flags.c == 1 }

  opcode(0xe9, 4, 1) { Registers.pc = Registers.hl }

  opcode(0x18, 8, 2) { Registers.pc += MMU.read(Registers.pc, 1, as: :signed) }

  opcode(0x20, 8, 2) { Registers.pc += MMU.read(Registers.pc, 1, as: :signed) if Flags.z == 0 }
  opcode(0x28, 8, 2) { Registers.pc += MMU.read(Registers.pc, 1, as: :signed) if Flags.z == 1 }
  opcode(0x30, 8, 2) { Registers.pc += MMU.read(Registers.pc, 1, as: :signed) if Flags.c == 0 }
  opcode(0x38, 8, 2) { Registers.pc += MMU.read(Registers.pc, 1, as: :signed) if Flags.c == 1 }


end