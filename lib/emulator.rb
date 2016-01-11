class Emulator
  def initialize(rom_path)
    @rom_path = rom_path
  end

  def run!
    rom = Rom.new(File.binread(@rom_path))
  end


  private

  def hex_dump(value)
    value.to_s(16).upcase.rjust(2, "0")
  end
end