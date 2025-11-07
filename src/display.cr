require "./sdl_bindings"
require "./ppu"
require "./joypad"

module Gameboy
  class Display
    WIDTH = 160
    HEIGHT = 144
    SCALE = 4

    # Game Boy color palette (grayscale)
    COLORS = [
      {255_u8, 255_u8, 255_u8, 255_u8},  # Color 0: White
      {192_u8, 192_u8, 192_u8, 255_u8},  # Color 1: Light gray
      {96_u8, 96_u8, 96_u8, 255_u8},      # Color 2: Dark gray
      {0_u8, 0_u8, 0_u8, 255_u8}         # Color 3: Black
    ]

    @window : LibSDL::Window
    @renderer : LibSDL::Renderer
    @running : Bool = true

    def initialize
      # Initialize SDL
      if LibSDL.init(LibSDL::INIT_VIDEO) < 0
        raise "Failed to initialize SDL"
      end

      # Create window
      @window = LibSDL.create_window(
        "Game Boy Emulator - Crystal".to_unsafe,
        LibSDL::WINDOWPOS_CENTERED.to_i32,
        LibSDL::WINDOWPOS_CENTERED.to_i32,
        WIDTH * SCALE,
        HEIGHT * SCALE,
        LibSDL::WindowFlags::SHOWN.value
      )

      if @window.null?
        raise "Failed to create window"
      end

      # Create renderer
      @renderer = LibSDL.create_renderer(
        @window,
        -1,
        (LibSDL::RendererFlags::ACCELERATED | LibSDL::RendererFlags::PRESENTVSYNC).value
      )

      if @renderer.null?
        LibSDL.destroy_window(@window)
        raise "Failed to create renderer"
      end

      puts "SDL2 window created successfully!"
      puts "Window size: #{WIDTH * SCALE}x#{HEIGHT * SCALE}"
    end

    def render_frame
      # Clear screen to white
      LibSDL.set_render_draw_color(@renderer, 255_u8, 255_u8, 255_u8, 255_u8)
      LibSDL.render_clear(@renderer)

      # Get framebuffer from PPU
      framebuffer = PPU.framebuffer

      # Render each pixel
      # Optimize by batching consecutive pixels of the same color
      HEIGHT.times do |y|
        x = 0
        while x < WIDTH
          color_value = framebuffer[y][x]

          # Find consecutive pixels with same color
          start_x = x
          while x < WIDTH && framebuffer[y][x] == color_value
            x += 1
          end
          width = x - start_x

          # Set color
          color = COLORS[color_value]
          LibSDL.set_render_draw_color(@renderer, color[0], color[1], color[2], color[3])

          # Draw rectangle for all consecutive pixels
          rect = LibSDL::Rect.new(
            x: (start_x * SCALE).to_i32,
            y: (y * SCALE).to_i32,
            w: (width * SCALE).to_i32,
            h: SCALE.to_i32
          )
          LibSDL.render_fill_rect(@renderer, pointerof(rect))
        end
      end

      # Present the rendered frame
      LibSDL.render_present(@renderer)
    end

    def poll_events
      # Event buffer to hold SDL_Event (typically ~56 bytes)
      event_buffer = StaticArray(UInt8, 64).new(0_u8)

      while LibSDL.poll_event(event_buffer.to_unsafe) != 0
        # Cast to keyboard event to read the structure
        event = event_buffer.to_unsafe.as(LibSDL::KeyboardEvent*)

        case event.value.type
        when LibSDL::QUIT
          @running = false

        when LibSDL::KEYDOWN
          handle_key_press(event.value.scancode)

        when LibSDL::KEYUP
          handle_key_release(event.value.scancode)
        end
      end
    end

    private def handle_key_press(scancode : Int32)
      case scancode
      when LibSDL::SCANCODE_UP
        Joypad.press(:up)
      when LibSDL::SCANCODE_DOWN
        Joypad.press(:down)
      when LibSDL::SCANCODE_LEFT
        Joypad.press(:left)
      when LibSDL::SCANCODE_RIGHT
        Joypad.press(:right)
      when LibSDL::SCANCODE_Z
        Joypad.press(:a)
      when LibSDL::SCANCODE_X
        Joypad.press(:b)
      when LibSDL::SCANCODE_RETURN
        Joypad.press(:start)
      when LibSDL::SCANCODE_RSHIFT, LibSDL::SCANCODE_LSHIFT
        Joypad.press(:select)
      when LibSDL::SCANCODE_ESCAPE
        @running = false
      end
    end

    private def handle_key_release(scancode : Int32)
      case scancode
      when LibSDL::SCANCODE_UP
        Joypad.release(:up)
      when LibSDL::SCANCODE_DOWN
        Joypad.release(:down)
      when LibSDL::SCANCODE_LEFT
        Joypad.release(:left)
      when LibSDL::SCANCODE_RIGHT
        Joypad.release(:right)
      when LibSDL::SCANCODE_Z
        Joypad.release(:a)
      when LibSDL::SCANCODE_X
        Joypad.release(:b)
      when LibSDL::SCANCODE_RETURN
        Joypad.release(:start)
      when LibSDL::SCANCODE_RSHIFT, LibSDL::SCANCODE_LSHIFT
        Joypad.release(:select)
      end
    end

    def running?
      @running
    end

    def close
      LibSDL.destroy_renderer(@renderer)
      LibSDL.destroy_window(@window)
      LibSDL.quit
      puts "\nSDL2 cleaned up"
    end

    def delay(ms : Int32)
      LibSDL.delay(ms.to_u32)
    end

    def self.get_ticks : UInt32
      LibSDL.get_ticks
    end
  end
end
