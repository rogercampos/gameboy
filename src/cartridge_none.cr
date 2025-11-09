require "./cartridge"

module Gameboy
  # Cartridge without MBC - simple ROMs up to 32KB
  class CartridgeNone < Cartridge
    def read_rom(address : Int32) : UInt8
      # Simple 32KB ROM, no banking
      if address < @rom.bytes.size
        @rom.bytes[address]
      else
        0xFFu8
      end
    end

    def write_rom(address : Int32, value : UInt8) : Nil
      # No MBC, writes to ROM area are ignored
    end

    def read_ram(address : Int32) : UInt8
      # Map 0xA000-0xBFFF to external RAM
      ram_address = address - 0xA000
      if ram_address >= 0 && ram_address < @external_ram.size
        @external_ram[ram_address]
      else
        0xFFu8
      end
    end

    def write_ram(address : Int32, value : UInt8) : Nil
      # Map 0xA000-0xBFFF to external RAM
      ram_address = address - 0xA000
      if ram_address >= 0 && ram_address < @external_ram.size
        @external_ram[ram_address] = value
      end
    end
  end
end
