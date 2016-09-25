module Gameboy
  module MMU
    extend self
    MMU_SIZE = 2 ** 16

    @data = Array.new(MMU_SIZE) { 0 }

    def bread(address, opts = {})
      raise "Access data out of limits #{address}" if address < 0 || address >= MMU_SIZE

      address = handle_echo(address)
      parse(@data[address], opts.fetch(:as, :unsigned), 8)
    end

    def bwrite(address, value)
      raise "Access data out of limits #{address}" if address < 0 || address >= MMU_SIZE

      address = handle_echo(address)
      @data[address] = value % 256
    end

    def wread(address, opts = {})
      raise "Access data out of limits #{address}" if address < 0 || address >= MMU_SIZE - 1

      address = handle_echo(address)
      value = (@data[address] << 8) + @data[address + 1]

      parse(value, opts.fetch(:as, :unsigned), 16)
    end

    def wwrite(address, value)
      raise "Access data out of limits #{address}" if address < 0 || address >= MMU_SIZE - 1

      address = handle_echo(address)
      @data[address] = (value >> 8) % 256
      @data[address + 1] = value % 256
    end

    def reset!
      @data = Array.new(MMU_SIZE) { 0 }
    end


    private

    def handle_echo(address)
      if address >= 0xc000 && address < 0xe000
        address + 8192
      else
        address
      end
    end

    def parse(value, type, size_in_bytes)
      case type
        when :unsigned
          value
        when :signed
          TwosComplement.convert(value, size_in_bytes)
        else
          raise "Cannot evaluate byte as #{type}"
      end
    end
  end
end