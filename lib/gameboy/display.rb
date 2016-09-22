module Gameboy
  class Display
    WIDTH = 160
    HEIGHT = 144
    HSYNC = 9198000 # Hz
    VSYNC = 59.73 # Hz

    def initialize
      @fb = Array.new(WIDTH * HEIGHT) { 0 }
    end

    def draw(x, y, color)
      @fb[x + y * WIDTH] = color
    end

    def render
      # Clear screen
      # Redraw screen
    end
  end
end