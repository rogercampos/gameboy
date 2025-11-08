require "./cartridge"

module Gameboy
  # MBC5 - Most advanced MBC
  # Supports up to 8MB ROM (512 banks) and 128KB RAM (16 banks)
  class CartridgeMBC5 < Cartridge
    @ram_enabled : Bool = false
    @rom_bank : UInt16 = 1u16    # Current ROM bank (9-bit value, 0-511)
    @ram_bank : UInt8 = 0u8      # Current RAM bank (0-15)

    def read_rom(address : Int32) : UInt8
      case address
      when 0x0000..0x3FFF
        # Bank 0 (fixed)
        read_rom_byte(address)
      when 0x4000..0x7FFF
        # Switchable ROM bank
        bank = @rom_bank.to_i32
        rom_address = (bank * 0x4000) + (address - 0x4000)
        read_rom_byte(rom_address)
      else
        0xFF
      end
    end

    def write_rom(address : Int32, value : UInt8) : Nil
      case address
      when 0x0000..0x1FFF
        # RAM Enable
        @ram_enabled = (value & 0x0F) == 0x0A
      when 0x2000..0x2FFF
        # Lower 8 bits of ROM Bank Number
        @rom_bank = (@rom_bank & 0x0100) | value.to_u16
      when 0x3000..0x3FFF
        # Upper bit of ROM Bank Number (9th bit)
        @rom_bank = (@rom_bank & 0x00FF) | ((value.to_u16 & 0x01) << 8)
      when 0x4000..0x5FFF
        # RAM Bank Number (4 bits)
        @ram_bank = (value & 0x0F).to_u8
      end
    end

    def read_ram(address : Int32) : UInt8
      return 0xFF unless @ram_enabled
      return 0xFF if @external_ram.size == 0

      ram_address = (@ram_bank.to_i32 * 0x2000) + (address - 0xA000)

      if ram_address >= 0 && ram_address < @external_ram.size
        @external_ram[ram_address]
      else
        0xFF
      end
    end

    def write_ram(address : Int32, value : UInt8) : Nil
      return unless @ram_enabled
      return if @external_ram.size == 0

      ram_address = (@ram_bank.to_i32 * 0x2000) + (address - 0xA000)

      if ram_address >= 0 && ram_address < @external_ram.size
        @external_ram[ram_address] = value
      end
    end

    private def read_rom_byte(address : Int32) : UInt8
      if address >= 0 && address < @rom.bytes.size
        @rom.bytes[address]
      else
        0xFF
      end
    end
  end
end
