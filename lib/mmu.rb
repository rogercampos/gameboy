module MMU
  extend self

  @data = Array.new(2 ** 16) { 0 }

  def bread(address, opts = {})
    parse(@data[address], opts.fetch(:as, :unsigned), 1)
  end

  def wread(address, opts = {})
    value = @data[address] << 8 + @data[address + 1]
    parse(value, opts.fetch(:as, :unsigned), 2)
  end

  def wwrite(address, value)
    @data[address] = (value >> 8) % 256
    @data[address + 1] = value % 256
  end

  def bwrite(address, value)
    @data[address] = value % 256
  end


  private

  def parse(value, type, size_in_bytes)
    case type
      when :unsigned
        value
      when :signed
        (value % 2** (size_in_bytes * 8 - 1)) - (2 ** (size_in_bytes * 8) / 2)
      else
        raise "Cannot evaluate byte as #{type}"
    end
  end
end