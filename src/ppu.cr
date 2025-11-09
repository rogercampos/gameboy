require "./mmu"
require "./interrupt"

module Gameboy
  module PPU
    extend self

    # LCD Register addresses
    LCDC = 0xFF40
    STAT = 0xFF41
    SCY = 0xFF42
    SCX = 0xFF43
    LY = 0xFF44
    LYC = 0xFF45
    DMA = 0xFF46
    BGP = 0xFF47
    OBP0 = 0xFF48
    OBP1 = 0xFF49
    WY = 0xFF4A
    WX = 0xFF4B

    # PPU Modes
    MODE_HBLANK = 0
    MODE_VBLANK = 1
    MODE_OAM = 2
    MODE_VRAM = 3

    # Timing (in CPU cycles)
    OAM_CYCLES = 80
    VRAM_CYCLES = 172
    HBLANK_CYCLES = 204
    SCANLINE_CYCLES = 456  # 80 + 172 + 204
    VBLANK_LINES = 10
    SCREEN_HEIGHT = 144
    SCREEN_WIDTH = 160
    TOTAL_LINES = 154  # 144 visible + 10 vblank

    # Sprite data structure
    struct Sprite
      property x : Int32
      property y : Int32
      property tile : Int32
      property attrs : Int32
      property oam_index : Int32

      def initialize(@x, @y, @tile, @attrs, @oam_index)
      end
    end

    @@mode : Int32 = MODE_OAM
    @@mode_cycles : Int32 = 0
    @@framebuffer : Array(Array(Int32)) = Array.new(SCREEN_HEIGHT) { Array.new(SCREEN_WIDTH, 0) }
    @@render_count : Int32 = 0  # Debug counter
    @@scanline_count : Int32 = 0  # Debug counter for render_scanline calls
    @@lcd_was_enabled : Bool = false  # Track LCD state to detect transitions
    @@sprite_debug_count : Int32 = 0  # Debug counter for sprite rendering

    def reset!
      @@mode_cycles = 0
      @@render_count = 0  # Reset debug counter
      @@scanline_count = 0  # Reset debug counter
      @@lcd_was_enabled = false  # Reset LCD state tracking
      @@sprite_debug_count = 0  # Reset sprite debug counter

      # Initialize hardware registers FIRST
      # NOTE: Starting with LCD OFF (0x00) instead of ON (0x91) to allow games
      # to initialize VRAM. Games cannot write to VRAM when LCD is on.
      # The boot ROM normally sets LCDC=0x91 at the end, but for compatibility
      # with games that need to initialize VRAM first, we start with LCD off.
      MMU.bwrite(LCDC, 0x00)  # LCD off - allows VRAM initialization
      MMU.bwrite(SCY, 0x00)   # Scroll Y
      MMU.bwrite(SCX, 0x00)   # Scroll X
      MMU.bwrite(LY, 0x00)    # Current scanline
      MMU.bwrite(LYC, 0x00)   # LY compare
      MMU.bwrite(BGP, 0xE4)   # Background palette (11 10 01 00 - proper greyscale)
      MMU.bwrite(OBP0, 0xE4)  # Sprite palette 0 (11 10 01 00 - proper greyscale)
      MMU.bwrite(OBP1, 0xE4)  # Sprite palette 1 (11 10 01 00 - proper greyscale)
      MMU.bwrite(WY, 0x00)    # Window Y
      MMU.bwrite(WX, 0x00)    # Window X

      # Set mode using set_mode to sync @@mode and STAT register
      set_mode(MODE_OAM)

      @@framebuffer = Array.new(SCREEN_HEIGHT) { Array.new(SCREEN_WIDTH, 0) }
    end

    def framebuffer
      @@framebuffer
    end

    def tick(cycles : Int32)
      lcd_now_enabled = lcd_enabled?

      # Handle LCD enable/disable transitions
      if lcd_now_enabled && !@@lcd_was_enabled
        # LCD was just turned ON - reset PPU state
        MMU.bwrite(LY, 0)
        @@mode_cycles = 0
        set_mode(MODE_OAM)
      elsif !lcd_now_enabled && @@lcd_was_enabled
        # LCD was just turned OFF - reset LY to 0
        MMU.bwrite(LY, 0)
        @@mode_cycles = 0
      end

      @@lcd_was_enabled = lcd_now_enabled

      # When LCD is off, PPU does not run at all
      return unless lcd_now_enabled

      @@mode_cycles += cycles

      # Process all cycles, handling mode transitions
      # Loop until cycles are fully consumed across mode changes
      loop do
        mode_changed = false

        case @@mode
        when MODE_OAM
          if @@mode_cycles >= OAM_CYCLES
            @@mode_cycles -= OAM_CYCLES
            set_mode(MODE_VRAM)
            mode_changed = true
          end

        when MODE_VRAM
          if @@mode_cycles >= VRAM_CYCLES
            @@mode_cycles -= VRAM_CYCLES
            set_mode(MODE_HBLANK)
            render_scanline
            mode_changed = true
          end

        when MODE_HBLANK
          if @@mode_cycles >= HBLANK_CYCLES
            @@mode_cycles -= HBLANK_CYCLES
            increment_ly

            if current_line >= SCREEN_HEIGHT
              set_mode(MODE_VBLANK)
              Interrupt.if_vblank = 1
            else
              set_mode(MODE_OAM)
            end
            mode_changed = true
          end

        when MODE_VBLANK
          if @@mode_cycles >= SCANLINE_CYCLES
            @@mode_cycles -= SCANLINE_CYCLES

            # Check if VBlank is complete BEFORE incrementing (LY goes 144-153, then wraps to 0)
            if current_line == (TOTAL_LINES - 1)  # LY = 153
              MMU.bwrite(LY, 0)
              set_mode(MODE_OAM)
              mode_changed = true
            else
              increment_ly
            end
          end
        end

        # Exit loop if no mode change occurred (cycles fully consumed)
        break unless mode_changed
      end

      check_lyc_coincidence
    end

    def current_line : Int32
      MMU.bread(LY)
    end

    def increment_ly
      ly = current_line
      MMU.bwrite(LY, (ly + 1) % TOTAL_LINES)
    end

    def set_mode(new_mode : Int32)
      @@mode = new_mode
      stat = MMU.bread(STAT)
      stat = (stat & 0xFC) | new_mode
      # Write directly to bypass MMU's STAT protection (which blocks CPU writes but not PPU writes)
      MMU.data[STAT] = stat.to_u8

      # Trigger STAT interrupts based on mode
      case new_mode
      when MODE_HBLANK
        Interrupt.if_lcd_stat = 1 if (stat & 0x08) != 0
      when MODE_VBLANK
        Interrupt.if_lcd_stat = 1 if (stat & 0x10) != 0
      when MODE_OAM
        Interrupt.if_lcd_stat = 1 if (stat & 0x20) != 0
      end
    end

    def check_lyc_coincidence
      ly = current_line
      lyc = MMU.bread(LYC)
      stat = MMU.bread(STAT)

      if ly == lyc
        stat |= 0x04  # Set coincidence flag
        Interrupt.if_lcd_stat = 1 if (stat & 0x40) != 0
      else
        stat &= 0xFB  # Clear coincidence flag
      end

      MMU.bwrite(STAT, stat)
    end

    def lcd_enabled? : Bool
      # Direct array access for performance
      (MMU.data[LCDC] & 0x80) != 0
    end

    def bg_enabled? : Bool
      (MMU.data[LCDC] & 0x01) != 0
    end

    def window_enabled? : Bool
      (MMU.data[LCDC] & 0x20) != 0
    end

    def sprites_enabled? : Bool
      (MMU.data[LCDC] & 0x02) != 0
    end

    def bg_tile_map_area : Int32
      (MMU.data[LCDC] & 0x08) != 0 ? 0x9C00 : 0x9800
    end

    def window_tile_map_area : Int32
      (MMU.data[LCDC] & 0x40) != 0 ? 0x9C00 : 0x9800
    end

    def bg_window_tile_data_area : Int32
      (MMU.data[LCDC] & 0x10) != 0 ? 0x8000 : 0x8800
    end

    def render_scanline
      @@scanline_count += 1  # Debug: track calls

      ly = current_line
      return if ly >= SCREEN_HEIGHT

      # Clear scanline
      SCREEN_WIDTH.times { |x| @@framebuffer[ly][x] = 0 }

      # Render background
      render_background(ly) if bg_enabled?

      # Render window
      render_window(ly) if window_enabled?

      # Render sprites
      render_sprites(ly) if sprites_enabled?
    end

    def render_background(ly : Int32)
      @@render_count += 1  # Debug: track calls

      # Direct array access for performance
      mmu_data = MMU.data
      scx = mmu_data[SCX].to_i32
      scy = mmu_data[SCY].to_i32
      palette = mmu_data[BGP].to_i32
      tile_map_base = bg_tile_map_area
      tile_data_base = bg_window_tile_data_area
      use_signed = tile_data_base == 0x8800

      # Calculate which background row to render
      y = (ly + scy) & 0xFF
      tile_y = y // 8
      pixel_y = y % 8

      SCREEN_WIDTH.times do |x|
        # Calculate which background column to render
        bg_x = (x + scx) & 0xFF
        tile_x = bg_x // 8
        pixel_x = bg_x % 8

        # Get tile number from tile map (direct array access)
        tile_map_addr = tile_map_base + tile_y * 32 + tile_x
        tile_num = mmu_data[tile_map_addr].to_i32

        # Get tile data address
        tile_data_addr = if use_signed
          # Signed tile number
          signed_tile = tile_num < 128 ? tile_num : tile_num - 256
          0x9000 + signed_tile * 16
        else
          0x8000 + tile_num * 16
        end

        # Get pixel color from tile (direct array access for performance)
        byte1 = mmu_data[tile_data_addr + pixel_y * 2].to_i32
        byte2 = mmu_data[tile_data_addr + pixel_y * 2 + 1].to_i32
        bit = 7 - pixel_x
        low_bit = (byte1 >> bit) & 1
        high_bit = (byte2 >> bit) & 1
        color = (high_bit << 1) | low_bit

        # Apply palette (inlined)
        @@framebuffer[ly][x] = (palette >> (color * 2)) & 0x03
      end
    end

    def render_window(ly : Int32)
      # Direct array access for performance
      mmu_data = MMU.data
      wy = mmu_data[WY].to_i32
      wx = mmu_data[WX].to_i32

      # Window is not visible on this scanline
      return if ly < wy

      palette = mmu_data[BGP].to_i32
      tile_map_base = window_tile_map_area
      tile_data_base = bg_window_tile_data_area
      use_signed = tile_data_base == 0x8800

      window_y = ly - wy
      tile_y = window_y // 8
      pixel_y = window_y % 8

      SCREEN_WIDTH.times do |x|
        # Window X is offset by 7
        window_x = x - (wx - 7)
        next if window_x < 0

        tile_x = window_x // 8
        pixel_x = window_x % 8

        # Get tile number from tile map (direct array access)
        tile_map_addr = tile_map_base + tile_y * 32 + tile_x
        tile_num = mmu_data[tile_map_addr].to_i32

        # Get tile data address
        tile_data_addr = if use_signed
          signed_tile = tile_num < 128 ? tile_num : tile_num - 256
          0x9000 + signed_tile * 16
        else
          0x8000 + tile_num * 16
        end

        # Get pixel color from tile (direct array access)
        byte1 = mmu_data[tile_data_addr + pixel_y * 2].to_i32
        byte2 = mmu_data[tile_data_addr + pixel_y * 2 + 1].to_i32
        bit = 7 - pixel_x
        low_bit = (byte1 >> bit) & 1
        high_bit = (byte2 >> bit) & 1
        color = (high_bit << 1) | low_bit

        # Apply palette (inlined)
        @@framebuffer[ly][x] = (palette >> (color * 2)) & 0x03
      end
    end

    def render_sprites(ly : Int32)
      # Direct array access for performance
      mmu_data = MMU.data
      sprite_height = (mmu_data[LCDC] & 0x04) != 0 ? 16 : 8

      # Scan OAM for sprites on this scanline
      sprites = [] of Sprite
      40.times do |i|
        oam_addr = 0xFE00 + i * 4
        sprite_y = mmu_data[oam_addr].to_i32 - 16
        sprite_x = mmu_data[oam_addr + 1].to_i32 - 8
        tile_num = mmu_data[oam_addr + 2].to_i32
        attributes = mmu_data[oam_addr + 3].to_i32

        # Check if sprite is on this scanline
        if ly >= sprite_y && ly < sprite_y + sprite_height
          sprites << Sprite.new(sprite_x, sprite_y, tile_num, attributes, i)
        end
      end

      # Sort by X position (right-most sprites have priority)
      sprites.sort_by! { |s| [-s.x, -s.oam_index] }
      sprites = sprites[0...10] if sprites.size > 10  # Max 10 sprites per scanline

      sprites.each do |sprite|
        pixel_y = ly - sprite.y
        pixel_y = sprite_height - 1 - pixel_y if (sprite.attrs & 0x40) != 0  # Y flip

        tile_addr = 0x8000 + sprite.tile * 16
        palette_addr = (sprite.attrs & 0x10) != 0 ? OBP1 : OBP0
        palette = mmu_data[palette_addr].to_i32
        x_flip = (sprite.attrs & 0x20) != 0

        # Read tile line data once (direct array access)
        byte1 = mmu_data[tile_addr + pixel_y * 2].to_i32
        byte2 = mmu_data[tile_addr + pixel_y * 2 + 1].to_i32

        8.times do |pixel_x|
          screen_x = sprite.x + pixel_x
          next if screen_x < 0 || screen_x >= SCREEN_WIDTH

          px = x_flip ? (7 - pixel_x) : pixel_x

          # Get pixel color (inlined)
          bit = 7 - px
          low_bit = (byte1 >> bit) & 1
          high_bit = (byte2 >> bit) & 1
          color = (high_bit << 1) | low_bit

          next if color == 0  # Transparent

          # Apply palette (inlined)
          @@framebuffer[ly][screen_x] = (palette >> (color * 2)) & 0x03
        end
      end
    end

    def framebuffer
      @@framebuffer
    end

    def render_count  # Debug method
      @@render_count
    end

    def scanline_count  # Debug method
      @@scanline_count
    end

    def current_mode  # Debug method
      @@mode
    end

    def mode_cycles_count  # Debug method
      @@mode_cycles
    end

    # Screen inspection methods for automated testing
    def has_non_white_pixels? : Bool
      @@framebuffer.any? { |row| row.any? { |pixel| pixel != 0 } }
    end

    def count_non_white_pixels : Int32
      @@framebuffer.sum { |row| row.count { |pixel| pixel != 0 } }
    end

    # Check if a specific region has pixels (for detecting game elements)
    def has_pixels_in_region?(x_start : Int32, x_end : Int32, y_start : Int32, y_end : Int32) : Bool
      (y_start...y_end).each do |y|
        next if y < 0 || y >= SCREEN_HEIGHT
        (x_start...x_end).each do |x|
          next if x < 0 || x >= SCREEN_WIDTH
          return true if @@framebuffer[y][x] != 0
        end
      end
      false
    end

    # Get a sample of pixels from a region (for debugging)
    def sample_region(x_start : Int32, x_end : Int32, y_start : Int32, y_end : Int32) : String
      result = [] of String
      (y_start...y_end).each do |y|
        next if y < 0 || y >= SCREEN_HEIGHT
        row_sample = [] of Int32
        (x_start...x_end).each do |x|
          next if x < 0 || x >= SCREEN_WIDTH
          row_sample << @@framebuffer[y][x]
        end
        result << row_sample.join(",") unless row_sample.empty?
      end
      result.join("\n")
    end

    # Detect if we're likely on the credits screen
    # Credits screen usually has text in the center region
    def looks_like_credits_screen? : Bool
      # Check if there are pixels in the center-top region (where "PUSH START" text appears)
      center_has_pixels = has_pixels_in_region?(40, 120, 50, 80)

      # Check total pixel count - credits screen has moderate pixel count
      pixel_count = count_non_white_pixels

      center_has_pixels && pixel_count > 100 && pixel_count < 8000
    end

    # Detect if we're likely in the menu
    # Menu has more pixels spread across the screen
    def looks_like_menu? : Bool
      pixel_count = count_non_white_pixels

      # Menu should have text across different regions
      top_has_pixels = has_pixels_in_region?(20, 140, 20, 60)
      middle_has_pixels = has_pixels_in_region?(20, 140, 60, 100)

      pixel_count > 500 && (top_has_pixels || middle_has_pixels)
    end

    # Detect if we're in active gameplay
    # Gameplay has the playfield on left side with pieces
    def looks_like_gameplay? : Bool
      pixel_count = count_non_white_pixels

      # Gameplay has significant pixels (playfield + pieces + UI)
      # Playfield is typically on the left side
      left_has_pixels = has_pixels_in_region?(30, 110, 10, 130)

      pixel_count > 1000 && left_has_pixels
    end
  end
end
