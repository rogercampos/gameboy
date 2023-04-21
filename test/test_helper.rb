require 'minitest/rg'
require 'minitest/autorun'

Dir["lib/gameboy/*.rb"].each { |x| require_relative "../#{x}" }

class BaseTest < Minitest::Test
  def set_arg_1(value)
    Gameboy::MMU.bwrite(Gameboy::Registers.pc, value)
  end
end