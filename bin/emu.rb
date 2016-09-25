require 'rubygems'
require 'bundler/setup'

require 'sdl2'
require 'pry'

Dir["lib/gameboy/*.rb"].each { |x| require_relative "../#{x}" }

Gameboy::Emulator.new(File.expand_path("~/Tetris-v1.1.gb")).run!