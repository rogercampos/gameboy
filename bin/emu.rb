Dir["lib/*.rb"].each { |x| require_relative "../#{x}" }

Emulator.new(File.expand_path("~/Tetris-v1.1.gb")).run!