class RomLoader
  def initialize(rom)
    @rom = rom
  end

  def load!
    @rom.bytes.each.with_index do |x, i|
      MMU.bwrite(i, x)
    end
  end
end