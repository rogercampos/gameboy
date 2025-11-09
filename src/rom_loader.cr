require "./rom"
require "./mmu"
require "./cartridge"
require "./cartridge_none"
require "./cartridge_mbc1"
require "./cartridge_mbc3"
require "./cartridge_mbc5"

module Gameboy
  class RomLoader
    @rom : Rom

    def initialize(@rom : Rom)
    end

    def load!
      raise "Invalid ROM: header checksum failed" unless @rom.valid_header_checksum?

      puts "Loading ROM: #{@rom.title_string}"
      @rom.debug

      # Create appropriate cartridge based on ROM type
      cartridge = Cartridge.create(@rom)
      MMU.cartridge = cartridge

      # Load fixed ROM bank 0 into memory for compatibility
      # Some code may still directly access MMU.data for the first 32KB
      min_size = [@rom.bytes.size, 0x8000].min
      @rom.bytes[0...min_size].each_with_index do |byte, i|
        MMU.data[i] = byte
      end

      puts "ROM loaded successfully! (#{@rom.bytes.size} bytes)"
      puts "Cartridge type: #{cartridge_type_name(@rom.cartridge_type)}"
    end

    private def cartridge_type_name(type : UInt8) : String
      case type
      when 0x00 then "ROM ONLY"
      when 0x01 then "MBC1"
      when 0x02 then "MBC1+RAM"
      when 0x03 then "MBC1+RAM+BATTERY"
      when 0x0F then "MBC3+TIMER+BATTERY"
      when 0x10 then "MBC3+TIMER+RAM+BATTERY"
      when 0x11 then "MBC3"
      when 0x12 then "MBC3+RAM"
      when 0x13 then "MBC3+RAM+BATTERY"
      when 0x19 then "MBC5"
      when 0x1A then "MBC5+RAM"
      when 0x1B then "MBC5+RAM+BATTERY"
      when 0x1C then "MBC5+RUMBLE"
      when 0x1D then "MBC5+RUMBLE+RAM"
      when 0x1E then "MBC5+RUMBLE+RAM+BATTERY"
      else "UNKNOWN (0x#{type.to_s(16)})"
      end
    end
  end
end
