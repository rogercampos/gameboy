module Gameboy
  class Display
    WIDTH = 160
    HEIGHT = 144
    HSYNC = 9198000 # Hz
    VSYNC = 59.73 # Hz

    def initialize
      SDL2.init(SDL2::INIT_VIDEO)
      @window = SDL2::Window.create "Gameboy emulator", 0, 0, 256, 256, 0
      @renderer = @window.create_renderer(-1, 0)
    end

    def render
      # Clear screen
      # Redraw screen
      # Draw tile map #0

      # 1024 bytes = 32x32 tiles
      tiles = []

      background_set = bit(MMU.bread(0xff40), 3)
      tile_set = bit(MMU.bread(0xff40), 4)

      range = background_set == 0 ? (0x9800..0x9bff) : (0x9c00..0x9fff)

      range.each do |map_byte|
        if tile_set == 1
          tile_address = MMU.bread(map_byte) + 0x8000
        else
          tile_address = TwosComplement.convert(MMU.bread(map_byte)) + 0x9000
        end

        tile_data = 16.times.map { |i| MMU.bread(tile_address + i) }
        tiles << Tile.new(tile_data).to_pixels
      end

      pixels = []
      tiles.each_slice(32) do |tiles_group|
        8.times do |y|
          pixels += tiles_group.map { |x| x[y] }
        end
      end

      pixels.flatten!

      pixels.each.with_index do |pixel, i|
        x = i % 256
        y = (i / 256)

        @renderer.draw_color = pixel_color pixel
        @renderer.draw_point x, y
      end

      puts "Rendered...."
      @renderer.present
    end

    def pixel_color(value)
      case value
        when 0
          [255, 255, 255]
        when 1
          [192, 192, 192]
        when 2
          [96, 96, 96]
        when 3
          [0, 0, 0]
        else
          raise "unsupported color! #{value}"
      end
    end

    def bit(byte, k)
      (byte & (1 << k)) >> k
    end
  end
end