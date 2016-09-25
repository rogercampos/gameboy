module Gameboy
  class Instruction
    attr_accessor :opcode, :cycles, :size, :impl, :family, :pc_modifier

    def initialize(family, opcode, cycles, size, impl, pc_modifier = false)
      @family = family
      @opcode = opcode
      @cycles = cycles
      @size = size
      @impl = impl
      @pc_modifier = pc_modifier
    end

    def run
      @impl.call

      unless @pc_modifier
        # Increment by the number of bytes used for the instruction's arguments so we leave PC pointing to the next instruction
        Registers.pc += (@size - 1)
      end
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

        def opcode(address, cycles, size, pc_modifier = false, &impl)
          raise "Please include this opcode in a family first. Opcode: #{address.to_s(16)}" if @family.nil?
          @instructions[address] = Instruction.new(@family, address, cycles, size, impl, pc_modifier)
        end

        def family(name)
          @family = name
          yield
          @family = nil
        end
      end

      def define(&block)
        @instructions.merge!(Builder.new(&block).instructions)
      end

      def [](value)
        @instructions[value] || raise("Undefined instruction with opcode #{value.to_s(16)}")
      end
    end
  end

  Dir["lib/gameboy/opcodes/*.rb"].each { |x| require_relative "../../#{x}" }
end