require "./sdl_bindings"
require "./apu"

module Gameboy
  class AudioOutput
    SAMPLE_RATE = 48000
    BUFFER_SIZE = 2048_u16
    CHANNELS = 2_u8  # Stereo

    @audio_device : LibSDL::AudioDeviceID
    @sample_counter : Float64 = 0.0
    @enabled : Bool = true
    @last_nr52 : UInt8 = 0u8

    # Channel state for synthesis
    @ch1_freq : Float64 = 0.0
    @ch1_phase : Float64 = 0.0
    @ch1_duty : Int32 = 0
    @ch1_volume : Int32 = 0
    @ch1_dac_enabled : Bool = false
    @ch1_last_trigger : Bool = false

    @ch2_freq : Float64 = 0.0
    @ch2_phase : Float64 = 0.0
    @ch2_duty : Int32 = 0
    @ch2_volume : Int32 = 0
    @ch2_dac_enabled : Bool = false
    @ch2_last_trigger : Bool = false

    def initialize
      # Initialize SDL audio
      if LibSDL.init(LibSDL::INIT_AUDIO) < 0
        puts "Failed to initialize SDL audio"
        @enabled = false
        @audio_device = uninitialized LibSDL::AudioDeviceID
        return
      end

      # Set up audio spec
      desired = LibSDL::AudioSpec.new
      desired.freq = SAMPLE_RATE
      desired.format = LibSDL::AUDIO_S16LSB
      desired.channels = CHANNELS
      desired.samples = BUFFER_SIZE
      desired.callback = nil  # We'll use SDL_QueueAudio instead
      desired.userdata = nil

      # Open audio device
      @audio_device = LibSDL.open_audio_device(nil, 0, pointerof(desired), nil, 0)

      if @audio_device == 0
        puts "Failed to open audio device"
        @enabled = false
        return
      end

      # Start audio playback
      LibSDL.pause_audio_device(@audio_device, 0)

      puts "Audio initialized: #{SAMPLE_RATE}Hz, #{CHANNELS} channels"
    end

    def close
      return unless @enabled
      LibSDL.close_audio_device(@audio_device)
    end

    # Generate audio samples for one frame
    def generate_frame_audio
      return unless @enabled

      # Generate samples for one frame (70224 CPU cycles at 4.194304 MHz)
      # Frame rate is 59.73 Hz, so samples per frame = 48000 / 59.73 ≈ 803 samples
      samples_per_frame = (SAMPLE_RATE / Gameboy::TARGET_FPS).to_i32

      # Read current APU state
      nr52 = APU.read_register(0xFF26)
      master_enabled = (nr52 & 0x80) != 0

      # Debug: Print when APU state changes
      if nr52 != @last_nr52
        puts "APU: NR52=0x#{nr52.to_s(16)} master=#{master_enabled}"
        @last_nr52 = nr52
      end

      return unless master_enabled

      ch1_enabled = (nr52 & 0x01) != 0
      ch2_enabled = (nr52 & 0x02) != 0

      # Read channel 1 registers
      if ch1_enabled
        nr11 = APU.read_register_internal(0xFF11)
        nr12 = APU.read_register_internal(0xFF12)
        nr13 = APU.read_register_internal(0xFF13)
        nr14 = APU.read_register_internal(0xFF14)

        # Check if DAC is enabled (NR12 bits 3-7 must not be all zero)
        dac_enabled = (nr12 & 0xF8) != 0
        @ch1_dac_enabled = dac_enabled

        # Calculate frequency: f = 131072/(2048-x) Hz where x is 11-bit frequency value
        freq_bits = ((nr14.to_i32 & 0x07) << 8) | nr13.to_i32
        new_freq = 131072.0 / (2048.0 - freq_bits.to_f64)

        # Duty cycle (bits 6-7 of NR11)
        new_duty = (nr11.to_i32 >> 6) & 0x03

        # Volume envelope (NR12)
        # Bits 4-7: initial volume
        # Bit 3: envelope direction (0=decrease, 1=increase)
        # Bits 0-2: envelope sweep pace
        initial_volume = (nr12.to_i32 >> 4) & 0x0F
        envelope_increase = (nr12.to_i32 & 0x08) != 0
        envelope_pace = nr12.to_i32 & 0x07

        # Simple envelope emulation: if envelope is enabled and volume is 0,
        # use a reasonable default volume (simplified, not cycle-accurate)
        new_volume = if initial_volume == 0 && envelope_increase && envelope_pace > 0
                       8  # Use mid-volume when envelope increase is enabled
                     else
                       initial_volume
                     end

        @ch1_freq = new_freq
        @ch1_duty = new_duty
        @ch1_volume = new_volume

        # Check trigger bit (bit 7 of NR14) and reset phase on new notes
        trigger = (nr14 & 0x80) != 0
        if trigger && !@ch1_last_trigger
          @ch1_phase = 0.0  # Reset phase on trigger to avoid clicks
        end
        @ch1_last_trigger = trigger
      else
        @ch1_dac_enabled = false
        @ch1_volume = 0
      end

      # Read channel 2 registers
      if ch2_enabled
        nr21 = APU.read_register_internal(0xFF16)
        nr22 = APU.read_register_internal(0xFF17)
        nr23 = APU.read_register_internal(0xFF18)
        nr24 = APU.read_register_internal(0xFF19)

        # Check if DAC is enabled (NR22 bits 3-7 must not be all zero)
        dac_enabled = (nr22 & 0xF8) != 0
        @ch2_dac_enabled = dac_enabled

        freq_bits = ((nr24.to_i32 & 0x07) << 8) | nr23.to_i32
        new_freq = 131072.0 / (2048.0 - freq_bits.to_f64)

        new_duty = (nr21.to_i32 >> 6) & 0x03

        # Volume envelope (NR22) - same as NR12
        initial_volume = (nr22.to_i32 >> 4) & 0x0F
        envelope_increase = (nr22.to_i32 & 0x08) != 0
        envelope_pace = nr22.to_i32 & 0x07

        new_volume = if initial_volume == 0 && envelope_increase && envelope_pace > 0
                       8  # Use mid-volume when envelope increase is enabled
                     else
                       initial_volume
                     end

        @ch2_freq = new_freq
        @ch2_duty = new_duty
        @ch2_volume = new_volume

        # Check trigger bit (bit 7 of NR24) and reset phase on new notes
        trigger = (nr24 & 0x80) != 0
        if trigger && !@ch2_last_trigger
          @ch2_phase = 0.0  # Reset phase on trigger to avoid clicks
        end
        @ch2_last_trigger = trigger
      else
        @ch2_dac_enabled = false
        @ch2_volume = 0
      end

      # Generate samples
      buffer = Bytes.new(samples_per_frame * 2 * 2)  # 2 channels, 2 bytes per sample
      buffer_ptr = buffer.to_unsafe.as(Int16*)

      samples_per_frame.times do |i|
        # Mix channels
        sample = 0_i32

        # Channel 1 - Square wave (only if DAC is enabled)
        if @ch1_dac_enabled && @ch1_volume > 0
          sample += generate_square_sample(@ch1_phase, @ch1_duty, @ch1_volume)
          @ch1_phase += @ch1_freq / SAMPLE_RATE
          @ch1_phase -= @ch1_phase.floor
        end

        # Channel 2 - Square wave (only if DAC is enabled)
        if @ch2_dac_enabled && @ch2_volume > 0
          sample += generate_square_sample(@ch2_phase, @ch2_duty, @ch2_volume)
          @ch2_phase += @ch2_freq / SAMPLE_RATE
          @ch2_phase -= @ch2_phase.floor
        end

        # Clamp and scale
        sample = sample.clamp(-32768, 32767)
        sample_i16 = sample.to_i16

        # Write stereo samples (same for both channels for now)
        buffer_ptr[i * 2] = sample_i16      # Left
        buffer_ptr[i * 2 + 1] = sample_i16  # Right
      end

      # Queue audio data
      # Don't queue if buffer is too full (prevents lag)
      queued_size = LibSDL.get_queued_audio_size(@audio_device)
      max_queued = SAMPLE_RATE * 2 * 2 / 10  # Max 100ms of audio queued

      if queued_size < max_queued
        LibSDL.queue_audio(@audio_device, buffer.to_unsafe.as(Void*), buffer.size.to_u32)
      end
    end

    private def generate_square_sample(phase : Float64, duty : Int32, volume : Int32) : Int32
      # Duty cycles: 12.5%, 25%, 50%, 75%
      duty_threshold = case duty
                       when 0 then 0.125  # 12.5%
                       when 1 then 0.25   # 25%
                       when 2 then 0.5    # 50%
                       when 3 then 0.75   # 75%
                       else 0.5
                       end

      # Generate square wave
      wave_value = phase < duty_threshold ? 1 : -1

      # Scale by volume (0-15 maps to full amplitude range)
      # Using ~1500 per volume level gives good loudness without clipping when mixed
      (wave_value * volume * 1500).to_i32
    end
  end
end
