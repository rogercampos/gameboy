module Gameboy
  class Instruction
    attr_accessor :opcode, :cycles, :size, :impl

    def initialize(opcode, cycles, size, impl)
      @opcode = opcode
      @cycles = cycles
      @size = size
      @impl = impl
    end

    def run
      puts "Running #{@opcode.to_s(16)}"
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
        @instructions.merge!(Builder.new(&block).instructions)
      end

      def [](value)
        @instructions[value] || raise("Undefined instruction with opcode #{value.to_s(16)}")
      end
    end
  end

  Dir["lib/gameboy/opcodes/*.rb"].each { |x| p x; require_relative "../../#{x}" }
end