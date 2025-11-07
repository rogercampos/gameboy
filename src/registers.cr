module Gameboy
  module Registers
    extend self

    # 8-bit registers
    @@a : UInt8 = 0u8
    @@f : UInt8 = 0u8
    @@b : UInt8 = 0u8
    @@c : UInt8 = 0u8
    @@d : UInt8 = 0u8
    @@e : UInt8 = 0u8
    @@h : UInt8 = 0u8
    @@l : UInt8 = 0u8

    # 16-bit registers
    @@sp : UInt16 = 0u16
    @@pc : UInt16 = 0u16

    # 8-bit register accessors
    def a : UInt8
      @@a
    end

    def a=(value : Int32)
      @@a = (value & 0xFF).to_u8!
    end

    def f : UInt8
      @@f
    end

    def f=(value : Int32)
      @@f = (value & 0xFF).to_u8!
    end

    def b : UInt8
      @@b
    end

    def b=(value : Int32)
      @@b = (value & 0xFF).to_u8!
    end

    def c : UInt8
      @@c
    end

    def c=(value : Int32)
      @@c = (value & 0xFF).to_u8!
    end

    def d : UInt8
      @@d
    end

    def d=(value : Int32)
      @@d = (value & 0xFF).to_u8!
    end

    def e : UInt8
      @@e
    end

    def e=(value : Int32)
      @@e = (value & 0xFF).to_u8!
    end

    def h : UInt8
      @@h
    end

    def h=(value : Int32)
      @@h = (value & 0xFF).to_u8!
    end

    def l : UInt8
      @@l
    end

    def l=(value : Int32)
      @@l = (value & 0xFF).to_u8!
    end

    # 16-bit register accessors
    def sp : UInt16
      @@sp
    end

    def sp=(value : Int32)
      @@sp = (value & 0xFFFF).to_u16!
    end

    def pc : UInt16
      @@pc
    end

    def pc=(value : Int32)
      @@pc = (value & 0xFFFF).to_u16!
    end

    # Double register accessors (AF, BC, DE, HL)
    def af : UInt16
      a_val = @@a.to_u32
      f_val = @@f.to_u32
      combined = (a_val << 8) | f_val
      masked = combined & 0xFFFF
      masked.to_u16!
    end

    def af=(value : Int32)
      val = (value & 0xFFFF).to_u16!
      @@f = (val & 0xFF).to_u8!
      @@a = ((val >> 8) & 0xFF).to_u8!
    end

    def bc : UInt16
      b_val = @@b.to_u32
      c_val = @@c.to_u32
      combined = (b_val << 8) | c_val
      masked = combined & 0xFFFF
      masked.to_u16!
    end

    def bc=(value : Int32)
      val = (value & 0xFFFF).to_u16!
      @@c = (val & 0xFF).to_u8!
      @@b = ((val >> 8) & 0xFF).to_u8!
    end

    def de : UInt16
      d_val = @@d.to_u32
      e_val = @@e.to_u32
      combined = (d_val << 8) | e_val
      masked = combined & 0xFFFF
      masked.to_u16!
    end

    def de=(value : Int32)
      val = (value & 0xFFFF).to_u16!
      @@e = (val & 0xFF).to_u8!
      @@d = ((val >> 8) & 0xFF).to_u8!
    end

    def hl : UInt16
      h_val = @@h.to_u32
      l_val = @@l.to_u32
      combined = (h_val << 8) | l_val
      masked = combined & 0xFFFF
      masked.to_u16!
    end

    def hl=(value : Int32)
      val = (value & 0xFFFF).to_u16!
      @@l = (val & 0xFF).to_u8!
      @@h = ((val >> 8) & 0xFF).to_u8!
    end

    def reset!
      # Initial register values matching Ruby emulator
      @@a = 0x01u8
      @@f = 0xB0u8
      @@b = 0x00u8
      @@c = 0x0Du8  # Match Ruby: 0x0D not 0x13
      @@d = 0x00u8
      @@e = 0xD8u8
      @@h = 0x01u8
      @@l = 0x4Du8
      @@sp = 0xFFFEu16
      @@pc = 0x0100u16
    end

    def debug : String
      "A: #{@@a.to_s(16).rjust(2, '0')}; B: #{@@b.to_s(16).rjust(2, '0')}; " \
      "C: #{@@c.to_s(16).rjust(2, '0')}; D: #{@@d.to_s(16).rjust(2, '0')}; " \
      "E: #{@@e.to_s(16).rjust(2, '0')}; F: #{@@f.to_s(16).rjust(2, '0')}; " \
      "H: #{@@h.to_s(16).rjust(2, '0')}; L: #{@@l.to_s(16).rjust(2, '0')}; " \
      "SP: #{@@sp.to_s(16).rjust(4, '0')}; PC: #{@@pc.to_s(16).rjust(4, '0')}"
    end
  end
end

# Initialize registers
Gameboy::Registers.reset!
