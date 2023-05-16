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
        (send(double_register[1]) << 8) + send(double_register[0])
      end

      define_method("#{double_register}=") do |value|
        value = value % (2 ** 16)

        send("#{double_register[0]}=", value % (2 ** 8))
        send("#{double_register[1]}=", value >> 8)
      end
    end

    def reset!
      Registers.a = 0
      Registers.f = 0
      Registers.b = 0
      Registers.c = 0
      Registers.d = 0
      Registers.e = 0
      Registers.h = 0
      Registers.l = 0
      Registers.af = 0
      Registers.bc = 0
      Registers.de = 0
      Registers.hl = 0
      Registers.sp = 0xfffe
      Registers.pc = 0x100
    end

    def debug
      "A: #{a.to_s(16)}; F: #{f.to_s(16)}; B: #{b.to_s(16)}; C: #{c.to_s(16)}; D: #{d.to_s(16)}; E: #{e.to_s(16)}; H: #{h.to_s(16)}; L: #{l.to_s(16)}; SP: #{sp.to_s(16)}; PC: #{pc.to_s(16)}"
    end
  end

  Registers.reset!
end