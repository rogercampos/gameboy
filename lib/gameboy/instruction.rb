module Gameboy
  class Instruction
    attr_accessor :opcode, :cycles, :size, :impl, :family

    def initialize(family, opcode, cycles, size, impl)
      @family = family
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
          raise "Please include this opcode in a family first. Opcode: #{address.to_s(16)}" if @family.nil?
          @instructions[address] = Instruction.new(@family, address, cycles, size, impl)
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