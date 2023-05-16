require 'irb'

require 'rubygems'
require 'bundler/setup'

require 'sdl2'
require 'pry'

Dir["lib/gameboy/*.rb"].each { |x| require_relative "../#{x}" }

IRB.start