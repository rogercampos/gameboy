require 'rubygems'
require 'bundler/setup'

require 'sdl2'
require 'pry'

Dir["lib/gameboy/*.rb"].each { |x| require_relative "../#{x}" }

# Gameboy::Emulator.new("resources/tetris_v1.1.gb", debug: true).run!
Gameboy::Emulator.new("resources/tetris_v1.1.gb", debug: true).run!(30000)
# Gameboy::Emulator.new("resources/tetris_v1.1.gb").run!