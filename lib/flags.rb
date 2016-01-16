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

  def z=(value)
    Registers.f = Registers.f | ((value % 2) << 8)
  end

  def n=(value)
    Registers.f = Registers.f | ((value % 2) << 7)
  end

  def h=(value)
    Registers.f = Registers.f | ((value % 2) << 6)
  end

  def c=(value)
    Registers.f = Registers.f | ((value % 2) << 5)
  end
end