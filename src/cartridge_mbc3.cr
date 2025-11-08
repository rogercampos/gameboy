require "./cartridge"

module Gameboy
  # MBC3 - Used in games with RTC (Real-Time Clock) like Pokemon Gold/Silver
  # Supports up to 2MB ROM (128 banks) and 64KB RAM (8 banks)
  class CartridgeMBC3 < Cartridge
    @ram_rtc_enabled : Bool = false
    @rom_bank : UInt8 = 1u8      # Current ROM bank (1-127)
    @ram_bank : UInt8 = 0u8      # Current RAM/RTC bank (0-3 for RAM, 0x08-0x0C for RTC)

    # RTC registers
    @rtc_s : UInt8 = 0u8   # Seconds (0-59)
    @rtc_m : UInt8 = 0u8   # Minutes (0-59)
    @rtc_h : UInt8 = 0u8   # Hours (0-23)
    @rtc_dl : UInt8 = 0u8  # Lower 8 bits of day counter
    @rtc_dh : UInt8 = 0u8  # Upper 1 bit of day counter + carry + halt

    @rtc_latch : UInt8 = 0u8  # Latch state

    def read_rom(address : Int32) : UInt8
      case address
      when 0x0000..0x3FFF
        # Bank 0 (fixed)
        read_rom_byte(address)
      when 0x4000..0x7FFF
        # Switchable ROM bank
        bank = @rom_bank.to_i32
        bank = 1 if bank == 0  # Bank 0 maps to bank 1
        rom_address = (bank * 0x4000) + (address - 0x4000)
        read_rom_byte(rom_address)
      else
        0xFF
      end
    end

    def write_rom(address : Int32, value : UInt8) : Nil
      case address
      when 0x0000..0x1FFF
        # RAM/RTC Enable
        @ram_rtc_enabled = (value & 0x0F) == 0x0A
      when 0x2000..0x3FFF
        # ROM Bank Number (7 bits)
        @rom_bank = (value & 0x7F).to_u8
        @rom_bank = 1u8 if @rom_bank == 0u8  # Bank 0 maps to bank 1
      when 0x4000..0x5FFF
        # RAM Bank Number or RTC Register Select
        @ram_bank = value.to_u8
      when 0x6000..0x7FFF
        # Latch Clock Data
        # Writing 0x00 then 0x01 latches current time into RTC registers
        if @rtc_latch == 0x00 && value == 0x01
          # Latch current time
          # For now, we don't implement actual RTC timing
          # Games will read zeros or latched values
        end
        @rtc_latch = value.to_u8
      end
    end

    def read_ram(address : Int32) : UInt8
      return 0xFF unless @ram_rtc_enabled

      case @ram_bank
      when 0x00..0x03
        # RAM bank
        return 0xFF if @external_ram.size == 0
        ram_address = (@ram_bank.to_i32 * 0x2000) + (address - 0xA000)
        if ram_address >= 0 && ram_address < @external_ram.size
          @external_ram[ram_address]
        else
          0xFF
        end
      when 0x08
        @rtc_s
      when 0x09
        @rtc_m
      when 0x0A
        @rtc_h
      when 0x0B
        @rtc_dl
      when 0x0C
        @rtc_dh
      else
        0xFF
      end
    end

    def write_ram(address : Int32, value : UInt8) : Nil
      return unless @ram_rtc_enabled

      case @ram_bank
      when 0x00..0x03
        # RAM bank
        return if @external_ram.size == 0
        ram_address = (@ram_bank.to_i32 * 0x2000) + (address - 0xA000)
        if ram_address >= 0 && ram_address < @external_ram.size
          @external_ram[ram_address] = value
        end
      when 0x08
        @rtc_s = value & 0x3F  # 0-59
      when 0x09
        @rtc_m = value & 0x3F  # 0-59
      when 0x0A
        @rtc_h = value & 0x1F  # 0-23
      when 0x0B
        @rtc_dl = value
      when 0x0C
        @rtc_dh = value & 0xC1  # Bit 0 (day counter MSB), bit 6 (halt), bit 7 (carry)
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
