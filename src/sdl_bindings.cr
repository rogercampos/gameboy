@[Link("SDL2")]
lib LibSDL
  INIT_VIDEO = 0x00000020_u32
  INIT_AUDIO = 0x00000010_u32
  WINDOWPOS_CENTERED = 0x2FFF0000_u32

  AUDIO_S16LSB = 0x8010_u16  # Signed 16-bit samples, little-endian

  # Event types
  QUIT = 0x100_u32
  KEYDOWN = 0x300_u32
  KEYUP = 0x301_u32

  # Scancodes for keys
  SCANCODE_UP = 82
  SCANCODE_DOWN = 81
  SCANCODE_LEFT = 80
  SCANCODE_RIGHT = 79
  SCANCODE_Z = 29
  SCANCODE_X = 27
  SCANCODE_A = 4
  SCANCODE_S = 22
  SCANCODE_RETURN = 40
  SCANCODE_RSHIFT = 229
  SCANCODE_LSHIFT = 225
  SCANCODE_ESCAPE = 41

  enum WindowFlags : UInt32
    SHOWN = 0x00000004
  end

  enum RendererFlags : UInt32
    ACCELERATED = 0x00000002
    PRESENTVSYNC = 0x00000004
  end

  struct Rect
    x : Int32
    y : Int32
    w : Int32
    h : Int32
  end

  # SDL_KeyboardEvent structure (simplified)
  struct KeyboardEvent
    type : UInt32
    timestamp : UInt32
    window_id : UInt32
    state : UInt8
    repeat : UInt8
    padding2 : UInt8
    padding3 : UInt8
    scancode : Int32
    sym : Int32
    mod : UInt16
    unused : UInt32
  end

  type Window = Void*
  type Renderer = Void*
  type AudioDeviceID = UInt32

  alias AudioCallback = (Void*, UInt8*, Int32) ->

  struct AudioSpec
    freq : Int32
    format : UInt16
    channels : UInt8
    silence : UInt8
    samples : UInt16
    padding : UInt16
    size : UInt32
    callback : AudioCallback
    userdata : Void*
  end

  fun init = SDL_Init(flags : UInt32) : Int32
  fun quit = SDL_Quit
  fun create_window = SDL_CreateWindow(
    title : UInt8*,
    x : Int32,
    y : Int32,
    w : Int32,
    h : Int32,
    flags : UInt32
  ) : Window
  fun destroy_window = SDL_DestroyWindow(window : Window)
  fun create_renderer = SDL_CreateRenderer(
    window : Window,
    index : Int32,
    flags : UInt32
  ) : Renderer
  fun destroy_renderer = SDL_DestroyRenderer(renderer : Renderer)
  fun set_render_draw_color = SDL_SetRenderDrawColor(
    renderer : Renderer,
    r : UInt8,
    g : UInt8,
    b : UInt8,
    a : UInt8
  ) : Int32
  fun render_clear = SDL_RenderClear(renderer : Renderer) : Int32
  fun render_fill_rect = SDL_RenderFillRect(renderer : Renderer, rect : Rect*) : Int32
  fun render_present = SDL_RenderPresent(renderer : Renderer)
  fun poll_event = SDL_PollEvent(event : UInt8*) : Int32
  fun delay = SDL_Delay(ms : UInt32)
  fun get_ticks = SDL_GetTicks : UInt32

  # Audio functions
  fun open_audio_device = SDL_OpenAudioDevice(
    device : UInt8*,
    iscapture : Int32,
    desired : AudioSpec*,
    obtained : AudioSpec*,
    allowed_changes : Int32
  ) : AudioDeviceID
  fun close_audio_device = SDL_CloseAudioDevice(dev : AudioDeviceID)
  fun pause_audio_device = SDL_PauseAudioDevice(dev : AudioDeviceID, pause_on : Int32)
  fun queue_audio = SDL_QueueAudio(dev : AudioDeviceID, data : Void*, len : UInt32) : Int32
  fun get_queued_audio_size = SDL_GetQueuedAudioSize(dev : AudioDeviceID) : UInt32
end
