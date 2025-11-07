module Gameboy
  # http://gbdev.gg8.se/wiki/articles/The_Cartridge_Header
  class Rom
    @bytes : Bytes

    def initialize(data : Bytes)
      @bytes = data
    end

    def self.from_file(filename : String) : Rom
      data = File.read(filename).to_slice
      new(data)
    end

    def bytes : Bytes
      @bytes
    end

    def valid_header_checksum? : Bool
      x = 0
      @bytes[0x134..0x14c].each { |y| x = x + y.to_i32 + 1 }

      x = (~x + 1) & 0xFF  # convert to negative by two's complement and mask to 8 bits

      x == header_checksum
    end

    def entry_point : Bytes
      @bytes[0x100..0x103]
    end

    def nintendo_logo : Bytes
      @bytes[0x104..0x133]
    end

    def title : Bytes
      @bytes[0x134..0x143]
    end

    def title_string : String
      String.new(@bytes[0x134..0x143]).gsub("\0", "")
    end

    def manufacturer_code : Bytes
      @bytes[0x13F..0x142]
    end

    def cgb_flag : UInt8
      @bytes[0x143]
    end

    def new_license_code : Bytes
      @bytes[0x144..0x145]
    end

    def sgb_flag : UInt8
      @bytes[0x146]
    end

    def cartridge_type : UInt8
      @bytes[0x147]
    end

    def rom_size : UInt8
      @bytes[0x148]
    end

    def ram_size : UInt8
      @bytes[0x149]
    end

    def destination_code : UInt8
      @bytes[0x14a]
    end

    def old_license_code : UInt8
      @bytes[0x14b]
    end

    def mask_rom_version_number : UInt8
      @bytes[0x14c]
    end

    def header_checksum : UInt8
      @bytes[0x14d]
    end

    def global_checksum : Bytes
      @bytes[0x14e..0x14f]
    end

    def debug
      puts "Valid header checksum? #{valid_header_checksum?}"
      puts "Title: #{title_string}"
      puts "Cartridge type: 0x#{cartridge_type.to_s(16)}"
      puts "ROM size: 0x#{rom_size.to_s(16)}"
      puts "RAM size: 0x#{ram_size.to_s(16)}"
      puts "Header checksum: 0x#{header_checksum.to_s(16)}"
    end
  end
end
