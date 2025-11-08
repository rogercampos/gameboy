module Gameboy
  # Audio Processing Unit (APU)
  # Handles the Game Boy's 4 sound channels
  module APU
    extend self

    # Channel 1 - Square wave with sweep
    @@nr10 : UInt8 = 0x80u8  # Sweep register
    @@nr11 : UInt8 = 0xBFu8  # Sound length/wave pattern duty
    @@nr12 : UInt8 = 0xF3u8  # Volume envelope
    @@nr13 : UInt8 = 0xFFu8  # Frequency low
    @@nr14 : UInt8 = 0xBFu8  # Frequency high/control

    # Channel 2 - Square wave
    @@nr21 : UInt8 = 0x3Fu8  # Sound length/wave pattern duty
    @@nr22 : UInt8 = 0x00u8  # Volume envelope
    @@nr23 : UInt8 = 0xFFu8  # Frequency low
    @@nr24 : UInt8 = 0xBFu8  # Frequency high/control

    # Channel 3 - Wave output
    @@nr30 : UInt8 = 0x7Fu8  # Sound on/off
    @@nr31 : UInt8 = 0xFFu8  # Sound length
    @@nr32 : UInt8 = 0x9Fu8  # Output level
    @@nr33 : UInt8 = 0xFFu8  # Frequency low
    @@nr34 : UInt8 = 0xBFu8  # Frequency high/control

    # Channel 4 - Noise
    @@nr41 : UInt8 = 0xFFu8  # Sound length
    @@nr42 : UInt8 = 0x00u8  # Volume envelope
    @@nr43 : UInt8 = 0x00u8  # Polynomial counter
    @@nr44 : UInt8 = 0xBFu8  # Counter/control

    # Sound control
    @@nr50 : UInt8 = 0x77u8  # Channel control/volume
    @@nr51 : UInt8 = 0xF3u8  # Sound output terminal selection
    @@nr52 : UInt8 = 0xF1u8  # Sound on/off (bit 7 = master, bits 0-3 = channel status)

    # Wave pattern RAM (0xFF30-0xFF3F) - 16 bytes
    @@wave_ram = Bytes.new(16, 0u8)

    # Internal state
    @@channel1_enabled : Bool = false
    @@channel2_enabled : Bool = false
    @@channel3_enabled : Bool = false
    @@channel4_enabled : Bool = false

    def reset!
      @@nr10 = 0x80u8
      @@nr11 = 0xBFu8
      @@nr12 = 0xF3u8
      @@nr13 = 0xFFu8
      @@nr14 = 0xBFu8

      @@nr21 = 0x3Fu8
      @@nr22 = 0x00u8
      @@nr23 = 0xFFu8
      @@nr24 = 0xBFu8

      @@nr30 = 0x7Fu8
      @@nr31 = 0xFFu8
      @@nr32 = 0x9Fu8
      @@nr33 = 0xFFu8
      @@nr34 = 0xBFu8

      @@nr41 = 0xFFu8
      @@nr42 = 0x00u8
      @@nr43 = 0x00u8
      @@nr44 = 0xBFu8

      @@nr50 = 0x77u8
      @@nr51 = 0xF3u8
      @@nr52 = 0xF1u8

      @@wave_ram.fill(0u8)

      @@channel1_enabled = false
      @@channel2_enabled = false
      @@channel3_enabled = false
      @@channel4_enabled = false
    end

    def read_register(address : Int32) : UInt8
      case address
      when 0xFF10 then @@nr10
      when 0xFF11 then @@nr11 | 0x3F  # Lower 6 bits are write-only
      when 0xFF12 then @@nr12
      when 0xFF13 then 0xFFu8        # Write-only
      when 0xFF14 then @@nr14 | 0xBF  # Bit 6 is write-only

      when 0xFF16 then @@nr21 | 0x3F  # Lower 6 bits are write-only
      when 0xFF17 then @@nr22
      when 0xFF18 then 0xFFu8        # Write-only
      when 0xFF19 then @@nr24 | 0xBF  # Bit 6 is write-only

      when 0xFF1A then @@nr30
      when 0xFF1B then 0xFFu8        # Write-only
      when 0xFF1C then @@nr32 | 0x9F
      when 0xFF1D then 0xFFu8        # Write-only
      when 0xFF1E then @@nr34 | 0xBF  # Bit 6 is write-only

      when 0xFF20 then 0xFFu8        # Write-only
      when 0xFF21 then @@nr42
      when 0xFF22 then @@nr43
      when 0xFF23 then @@nr44 | 0xBF  # Bit 6 is write-only

      when 0xFF24 then @@nr50
      when 0xFF25 then @@nr51
      when 0xFF26 then @@nr52

      when 0xFF30..0xFF3F
        @@wave_ram[address - 0xFF30]

      else
        0xFFu8
      end
    end

    def write_register(address : Int32, value : UInt8)
      # If APU is disabled (NR52 bit 7 = 0), all registers are read-only except NR52
      if address != 0xFF26 && (@@nr52 & 0x80) == 0
        return
      end

      case address
      when 0xFF10
        @@nr10 = value
      when 0xFF11
        @@nr11 = value
      when 0xFF12
        @@nr12 = value
        # If envelope initial volume is 0 and no increase, disable channel
        if (@@nr12 & 0xF8) == 0
          @@channel1_enabled = false
          update_nr52
        end
      when 0xFF13
        @@nr13 = value
      when 0xFF14
        @@nr14 = value
        # Trigger bit
        if (value & 0x80) != 0
          @@channel1_enabled = true
          update_nr52
        end

      when 0xFF16
        @@nr21 = value
      when 0xFF17
        @@nr22 = value
        # If envelope initial volume is 0 and no increase, disable channel
        if (@@nr22 & 0xF8) == 0
          @@channel2_enabled = false
          update_nr52
        end
      when 0xFF18
        @@nr23 = value
      when 0xFF19
        @@nr24 = value
        # Trigger bit
        if (value & 0x80) != 0
          @@channel2_enabled = true
          update_nr52
        end

      when 0xFF1A
        @@nr30 = value
        # DAC enable/disable
        if (value & 0x80) == 0
          @@channel3_enabled = false
          update_nr52
        end
      when 0xFF1B
        @@nr31 = value
      when 0xFF1C
        @@nr32 = value
      when 0xFF1D
        @@nr33 = value
      when 0xFF1E
        @@nr34 = value
        # Trigger bit
        if (value & 0x80) != 0 && (@@nr30 & 0x80) != 0
          @@channel3_enabled = true
          update_nr52
        end

      when 0xFF20
        @@nr41 = value
      when 0xFF21
        @@nr42 = value
        # If envelope initial volume is 0 and no increase, disable channel
        if (@@nr42 & 0xF8) == 0
          @@channel4_enabled = false
          update_nr52
        end
      when 0xFF22
        @@nr43 = value
      when 0xFF23
        @@nr44 = value
        # Trigger bit
        if (value & 0x80) != 0
          @@channel4_enabled = true
          update_nr52
        end

      when 0xFF24
        @@nr50 = value
      when 0xFF25
        @@nr51 = value
      when 0xFF26
        # Only bit 7 is writable (master enable)
        old_enabled = (@@nr52 & 0x80) != 0
        new_enabled = (value & 0x80) != 0

        if old_enabled && !new_enabled
          # APU disabled - clear all registers
          reset!
          @@nr52 = 0x00u8
        elsif !old_enabled && new_enabled
          # APU enabled
          @@nr52 = 0x80u8
        end

      when 0xFF30..0xFF3F
        @@wave_ram[address - 0xFF30] = value
      end
    end

    # Update NR52 channel status bits
    private def update_nr52
      status = (@@nr52 & 0xF0).to_u8
      status |= 0x01u8 if @@channel1_enabled
      status |= 0x02u8 if @@channel2_enabled
      status |= 0x04u8 if @@channel3_enabled
      status |= 0x08u8 if @@channel4_enabled
      @@nr52 = status
    end

    # Tick the APU (called with CPU cycles)
    def tick(cycles : Int32)
      # TODO: Implement actual sound generation
      # For now, this is a stub that just maintains register state
    end
  end
end
