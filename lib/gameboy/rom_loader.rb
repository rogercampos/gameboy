module Gameboy
  class RomLoader
    def initialize(rom)
      @rom = rom
    end

    def load!
      raise "Invalid rom" unless @rom.valid_header_checksum?

      @rom.bytes.each.with_index do |x, i|
        MMU.bwrite(i, x)
      end
    end
  end
end