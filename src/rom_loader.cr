require "./rom"
require "./mmu"

module Gameboy
  class RomLoader
    @rom : Rom

    def initialize(@rom : Rom)
    end

    def load!
      raise "Invalid ROM: header checksum failed" unless @rom.valid_header_checksum?

      puts "Loading ROM: #{@rom.title_string}"
      @rom.debug

      # Load ROM bytes directly into MMU data array (bypass bwrite to avoid ROM protection)
      @rom.bytes.each_with_index do |byte, i|
        MMU.data[i] = byte
      end

      puts "ROM loaded successfully! (#{@rom.bytes.size} bytes)"
    end
  end
end
