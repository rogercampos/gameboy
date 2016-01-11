# http://gbdev.gg8.se/wiki/articles/The_Cartridge_Header
class Rom
  def initialize(data)
    @data = data
  end

  def bytes
    @bytes ||= @data.unpack("C*")
  end

  def valid_header_checksum?
    x = 0
    bytes[0x134..0x14c].each {|y| x = x + y + 1 }

    x = ~x + 1 # convert to negative by two's complement

    # only 8 lower bits of the result
    7.downto(0).map {|i| x[i]}.join.to_i(2) == header_checksum
  end

  def entry_point
    bytes[0x100..0x103]
  end

  def nintendo_logo
    bytes[0x104..0x133]
  end

  def title
    bytes[0x134..0x143]
  end

  def manufacturer_code
    bytes[0x13F..0x142]
  end

  def cgb_flag
    bytes[0x143]
  end

  def new_license_code
    bytes[0x144..0x145]
  end

  def sgb_flag
    bytes[0x146]
  end

  def cartridge_type
    bytes[0x147]
  end

  def rom_size
    bytes[0x148]
  end

  def ram_size
    bytes[0x149]
  end

  def destination_code
    bytes[0x14a]
  end

  def old_license_code
    bytes[0x14b]
  end

  def mask_rom_version_number
    bytes[0x14c]
  end

  def header_checksum
    bytes[0x14d]
  end

  def global_checksum
    bytes[0x14e..0x14f]
  end
end