require 'minitest/rg'
require 'minitest/autorun'

Dir["lib/gameboy/*.rb"].each { |x| require_relative "../#{x}" }
