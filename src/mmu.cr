require "./twos_complement"
require "./cartridge"
require "./apu"

module Gameboy
  module MMU
    extend self

    MMU_SIZE = 65536

    @@data = Bytes.new(MMU_SIZE, 0u8)
    @@cartridge : Cartridge? = nil

    # Set the cartridge for ROM/RAM access
    def cartridge=(cart : Cartridge)
      @@cartridge = cart
    end

    def cartridge : Cartridge?
      @@cartridge
    end

    # Direct array access for performance
    def data : Bytes
      @@data
    end

    # Byte read
    def bread(address : Int32, signed : Bool = false) : Int32
      # Inline echo handling for performance
      addr = address >= 0xe000 && address < 0xfe00 ? address - 0x2000 : address

      # Route ROM reads through cartridge (0x0000-0x7FFF)
      if addr >= 0x0000 && addr <= 0x7FFF
        if cart = @@cartridge
          value = cart.read_rom(addr).to_i32
          return signed ? TwosComplement.convert(value, 8) : value
        else
          # Fallback to direct memory access if no cartridge loaded
          value = @@data[addr].to_i32
          return signed ? TwosComplement.convert(value, 8) : value
        end
      end

      # Route external RAM reads through cartridge (0xA000-0xBFFF)
      if addr >= 0xA000 && addr <= 0xBFFF
        if cart = @@cartridge
          value = cart.read_ram(addr).to_i32
          return signed ? TwosComplement.convert(value, 8) : value
        else
          # Fallback to direct memory access
          value = @@data[addr].to_i32
          return signed ? TwosComplement.convert(value, 8) : value
        end
      end

      # CRITICAL: Block VRAM reads when LCD is on and PPU mode is 3 (VRAM access)
      if addr >= 0x8000 && addr <= 0x9FFF
        lcdc = @@data[0xFF40].to_i32
        lcd_on = (lcdc & 0x80) != 0

        if lcd_on
          stat = @@data[0xFF41].to_i32
          ppu_mode = stat & 0x03

          # Mode 3 = VRAM access - block reads, return 0xFF
          if ppu_mode == 3
            return 0xFF
          end
        end
      end

      # Route APU register reads through APU module (0xFF10-0xFF3F)
      if addr >= 0xFF10 && addr <= 0xFF3F
        value = APU.read_register(addr).to_i32
        return signed ? TwosComplement.convert(value, 8) : value
      end

      value = @@data[addr].to_i32

      if signed
        TwosComplement.convert(value, 8)
      else
        value
      end
    end

    # Byte write
    def bwrite(address : Int32, value : Int32)
      # Inline echo handling for performance
      addr = address >= 0xe000 && address < 0xfe00 ? address - 0x2000 : address

      # Route ROM writes through cartridge (0x0000-0x7FFF)
      # These are actually MBC control register writes, not actual ROM writes
      if addr >= 0x0000 && addr <= 0x7FFF
        if cart = @@cartridge
          cart.write_rom(addr, value.to_u8)
        end
        return
      end

      # Route external RAM writes through cartridge (0xA000-0xBFFF)
      if addr >= 0xA000 && addr <= 0xBFFF
        if cart = @@cartridge
          cart.write_ram(addr, value.to_u8)
        else
          # Fallback to direct memory access
          @@data[addr] = (value & 0xFF).to_u8
        end
        return
      end

      # Route APU register writes through APU module (0xFF10-0xFF3F)
      if addr >= 0xFF10 && addr <= 0xFF3F
        APU.write_register(addr, value.to_u8)
        return
      end

      # CRITICAL: Block VRAM reads when LCD is on and PPU mode is 3 (VRAM access)
      # NOTE: On real Game Boy, VRAM READS return 0xFF during mode 3, but WRITES succeed
      # This is because the PPU is reading VRAM, so CPU reads conflict, but writes don't
      # VRAM includes tile data (0x8000-0x97FF) and tile maps (0x9800-0x9FFF)
      # NOTE: VRAM WRITES are NOT blocked - only reads!

      # Special handling for STAT register (0xFF41) - bits 0-1 (mode) are read-only
      # The PPU hardware controls these bits, CPU writes cannot change them
      if addr == 0xFF41
        current = @@data[addr].to_i32
        mode_bits = current & 0x03  # Preserve current mode bits (0-1)
        new_value = (value & 0xFC) | mode_bits  # Keep upper 6 bits from write, preserve mode
        @@data[addr] = new_value.to_u8
        return
      end

      # Special handling for DIV register - writing resets it to 0
      if addr == 0xFF04
        Timer.handle_div_write
        return
      end

      # Special handling for P1 (joypad) - store selection bits and update
      if addr == 0xFF00
        @@data[addr] = (value & 0x30).to_u8
        Joypad.update_p1
        return
      end

      # Special handling for DMA (0xFF46) - OAM DMA transfer
      if addr == 0xFF46
        # DMA copies 160 bytes from  XX00-XX9F to OAM (0xFE00-0xFE9F)
        # where XX is the value written to DMA register
        source_addr = (value & 0xFF) * 0x100
        160.times do |i|
          @@data[0xFE00 + i] = @@data[source_addr + i]
        end
        @@data[addr] = value.to_u8
        return
      end

      # Special handling for LCDC register (0xFF40) - LCD enable bit changes
      if addr == 0xFF40
        old_value = @@data[addr].to_i32
        if old_value != value
          # CRITICAL FIX: Update PPU state IMMEDIATELY when LCD enable bit changes
          # to avoid game reading stale PPU mode
          old_lcd_on = (old_value & 0x80) != 0
          new_lcd_on = (value & 0x80) != 0

          if new_lcd_on && !old_lcd_on
            # LCD turned ON - reset PPU to initial state
            @@data[0xFF44] = 0  # LY = 0
            # Set STAT to mode 2 (OAM search) - preserve upper bits
            stat = @@data[0xFF41].to_i32
            @@data[0xFF41] = ((stat & 0xFC) | 2).to_u8
          elsif !new_lcd_on && old_lcd_on
            # LCD turned OFF - reset LY
            @@data[0xFF44] = 0  # LY = 0
          end
        end
      end

      @@data[addr] = (value & 0xFF).to_u8
    end

    # Word read (16-bit)
    def wread(address : Int32, signed : Bool = false) : Int32
      # Inline echo handling for performance
      addr = address >= 0xe000 && address < 0xfe00 ? address - 0x2000 : address

      value = (@@data[addr + 1].to_i32 << 8) | @@data[addr].to_i32

      if signed
        TwosComplement.convert(value, 16)
      else
        value
      end
    end

    # Word write (16-bit)
    def wwrite(address : Int32, value : Int32)
      # Inline echo handling for performance
      addr = address >= 0xe000 && address < 0xfe00 ? address - 0x2000 : address

      # ROM region (0x0000-0x7FFF) is read-only
      # Block if either byte of the 16-bit write touches ROM
      if addr <= 0x7FFF
        return
      end

      @@data[addr + 1] = ((value >> 8) & 0xFF).to_u8
      @@data[addr] = (value & 0xFF).to_u8
    end

    def reset!
      @@data = Bytes.new(MMU_SIZE, 0u8)
      if cart = @@cartridge
        cart.reset!
      end
    end
  end
end
