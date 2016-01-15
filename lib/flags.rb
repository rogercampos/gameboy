module Flags
  extend self

  def z
    Registers.f[7]
  end

  def n
    Registers.f[6]
  end

  def h
    Registers.f[5]
  end

  def c
    Registers.f[4]
  end
end