module Gameboy
  # Base interface for cartridge/MBC implementations
  abstract class Cartridge
    @rom : Rom
    @external_ram : Bytes

    def initialize(@rom : Rom)
      ram_size = calculate_ram_size(@rom.ram_size)
      @external_ram = Bytes.new(ram_size, 0u8)
    end

    # Read from ROM area (0x0000-0x7FFF)
    abstract def read_rom(address : Int32) : UInt8

    # Write to ROM area (actually writes to MBC control registers)
    abstract def write_rom(address : Int32, value : UInt8) : Nil

    # Read from external RAM (0xA000-0xBFFF)
    abstract def read_ram(address : Int32) : UInt8

    # Write to external RAM (0xA000-0xBFFF)
    abstract def write_ram(address : Int32, value : UInt8) : Nil

    # Reset the cartridge state
    def reset!
      @external_ram.fill(0u8)
    end

    private def calculate_ram_size(ram_size_code : UInt8) : Int32
      case ram_size_code
      when 0x00 then 0          # No RAM
      when 0x01 then 0          # Unused
      when 0x02 then 8 * 1024   # 8KB
      when 0x03 then 32 * 1024  # 32KB (4 banks of 8KB)
      when 0x04 then 128 * 1024 # 128KB (16 banks of 8KB)
      when 0x05 then 64 * 1024  # 64KB (8 banks of 8KB)
      else 0
      end
    end

    # Factory method to create appropriate cartridge type
    def self.create(rom : Rom) : Cartridge
      case rom.cartridge_type
      when 0x00
        CartridgeNone.new(rom)
      when 0x01, 0x02, 0x03
        CartridgeMBC1.new(rom)
      when 0x0F, 0x10, 0x11, 0x12, 0x13
        CartridgeMBC3.new(rom)
      when 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E
        CartridgeMBC5.new(rom)
      else
        puts "WARNING: Unsupported cartridge type 0x#{rom.cartridge_type.to_s(16)}, using MBC1"
        CartridgeMBC1.new(rom)
      end
    end
  end
end
