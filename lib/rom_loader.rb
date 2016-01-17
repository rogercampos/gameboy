class RomLoader
  def initialize(rom)
    @rom = rom
  end

  def load!
    @rom.bytes.each.with_index do |x, i|
      MMU.write(i, x)
    end
  end
end