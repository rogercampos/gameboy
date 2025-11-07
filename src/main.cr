require "./emulator"

if ARGV.empty?
  puts "Usage: crystal run src/main.cr <rom_file>"
  puts "Example: crystal run src/main.cr ../roms/tetris.gb"
  exit 1
end

rom_file = ARGV[0]

unless File.exists?(rom_file)
  puts "Error: ROM file '#{rom_file}' not found"
  exit 1
end

puts "Loading ROM: #{rom_file}"
emulator = Gameboy::Emulator.from_file(rom_file, debug: false)

# Run the emulator (will run until Ctrl+C)
emulator.run!
