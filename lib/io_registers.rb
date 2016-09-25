# Easy access to memory-mapped i/o registers
module IoRegisters
  extend self

  MAPPING = {
      # Joystick
      p1: 0xff00,

      # Serial data transfer
      sb: 0xff01,

      # SIO Control
      sc: 0xff02,

      # Divider register
      div: 0xff04,

      # Timer counter
      tima: 0xff05,

      scy: 0xff42,
      scx: 0xff43,

      lcdc: 0xff40
  }

  MAPPING.each do |register_name, address|
    define_method register_name do
      MMU.bread(address)
    end

    define_method "#{register_name}=" do |value|
      MMU.bwrite(address, value)
    end
  end
end


# Value at reset
IoRegisters.lcdc = 0x91