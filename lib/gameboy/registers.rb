module Gameboy
  module Registers
    extend self

    %w(a f b c d e h l).each do |register|
      define_method("#{register}=") do |value|
        instance_variable_set "@#{register}", value % (2 ** 8)
      end

      define_method(register) do
        instance_variable_get("@#{register}")
      end
    end

    %w(sp pc).each do |register|
      define_method("#{register}=") do |value|
        instance_variable_set "@#{register}", value % (2 ** 16)
      end

      define_method(register) do
        instance_variable_get("@#{register}")
      end
    end

    %w(af bc de hl).each do |double_register|
      define_method(double_register) do
        (send(double_register[0]) << 8) + send(double_register[1])
      end

      define_method("#{double_register}=") do |value|
        value = value % (2 ** 16)

        send("#{double_register[1]}=", value % (2 ** 8))
        send("#{double_register[0]}=", value >> 8)
      end
    end

    def reset!
      Registers.a = 1
      Registers.f = 0xb0
      Registers.b = 0
      Registers.c = 0xd
      Registers.d = 0
      Registers.e = 0xd8
      Registers.h = 1
      Registers.l = 0x4d
      Registers.sp = 0xfffe
      Registers.pc = 0x100
    end

    def debug
      %w(a b c d e f h l sp pc).map do |register|
        "#{register.upcase}: #{DebugPrinter.format_byte(send(register))}"
      end.join("; ")
    end
  end

  Registers.reset!
end