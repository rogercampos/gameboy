module MMU
  extend self

  @data = Array.new(2 ** 16) { 0 }

  # Reads the given amount of bytes requested from memory
  # opts[:as] controls the representation of the bytes
  #   * unsigned: by default
  #   * signed: readed as two's complement
  def read(address, bytes_to_read = 1, opts = {})
    value = value_at(address, bytes_to_read)
    type = opts.fetch(:as, :unsigned)

    case type
      when :unsigned
        value
      when :signed
        (value % 2**7) - 128
      else
        raise "Cannot evaluate byte as #{type}"
    end
  end

  # Writes into memory at address the value provided.
  # Value is truncated to fit in 1 byte.
  def write(address, value)
    @data[address] = value % 256
  end


  private

  def value_at(address, bytes_to_read)
    data = @data[address..address+bytes_to_read-1]
    value = 0

    data.reverse.each.with_index do |x, i|
      value += (x << i * 8)
    end

    value
  end
end