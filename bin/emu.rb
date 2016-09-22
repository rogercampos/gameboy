require 'rubygems'
require 'bundler/setup'

require 'gosu'

Dir["lib/gameboy/*.rb"].each { |x| require_relative "../#{x}" }

Gameboy::Emulator.new(File.expand_path("~/Tetris-v1.1.gb")).run!