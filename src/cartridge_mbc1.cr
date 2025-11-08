require "./cartridge"

module Gameboy
  # MBC1 - Most common cartridge type
  # Supports up to 2MB ROM (125 banks) and 32KB RAM (4 banks)
  class CartridgeMBC1 < Cartridge
    @ram_enabled : Bool = false
    @rom_bank : UInt8 = 1u8      # Current ROM bank (1-127)
    @ram_bank : UInt8 = 0u8      # Current RAM bank (0-3)
    @banking_mode : UInt8 = 0u8  # 0 = ROM banking mode, 1 = RAM banking mode

    def read_rom(address : Int32) : UInt8
      case address
      when 0x0000..0x3FFF
        # Bank 0 (or banked in mode 1)
        bank = @banking_mode == 1 ? ((@ram_bank.to_i32 << 5) & 0x60) : 0
        rom_address = (bank * 0x4000) + address
        read_rom_byte(rom_address)
      when 0x4000..0x7FFF
        # Switchable ROM bank
        # Combine lower 5 bits from rom_bank and upper 2 bits from ram_bank
        bank = (@rom_bank.to_i32 & 0x1F) | ((@ram_bank.to_i32 << 5) & 0x60)
        # Bank 0x00, 0x20, 0x40, 0x60 are inaccessible, map to 0x01, 0x21, 0x41, 0x61
        bank = bank + 1 if (bank & 0x1F) == 0
        rom_address = (bank * 0x4000) + (address - 0x4000)
        read_rom_byte(rom_address)
      else
        0xFFu8
      end
    end

    def write_rom(address : Int32, value : UInt8) : Nil
      case address
      when 0x0000..0x1FFF
        # RAM Enable
        @ram_enabled = (value & 0x0F) == 0x0A
      when 0x2000..0x3FFF
        # ROM Bank Number (lower 5 bits)
        @rom_bank = (value & 0x1F).to_u8
        @rom_bank = 1u8 if @rom_bank == 0u8  # Bank 0 maps to bank 1
      when 0x4000..0x5FFF
        # RAM Bank Number / Upper bits of ROM Bank Number
        @ram_bank = (value & 0x03).to_u8
      when 0x6000..0x7FFF
        # Banking Mode Select
        @banking_mode = (value & 0x01).to_u8
      end
    end

    def read_ram(address : Int32) : UInt8
      return 0xFFu8 unless @ram_enabled
      return 0xFFu8 if @external_ram.size == 0

      bank = @banking_mode == 1 ? @ram_bank.to_i32 : 0
      ram_address = (bank * 0x2000) + (address - 0xA000)

      if ram_address >= 0 && ram_address < @external_ram.size
        @external_ram[ram_address]
      else
        0xFFu8
      end
    end

    def write_ram(address : Int32, value : UInt8) : Nil
      return unless @ram_enabled
      return if @external_ram.size == 0

      bank = @banking_mode == 1 ? @ram_bank.to_i32 : 0
      ram_address = (bank * 0x2000) + (address - 0xA000)

      if ram_address >= 0 && ram_address < @external_ram.size
        @external_ram[ram_address] = value
      end
    end

    private def read_rom_byte(address : Int32) : UInt8
      if address >= 0 && address < @rom.bytes.size
        @rom.bytes[address]
      else
        0xFFu8
      end
    end
  end
end
