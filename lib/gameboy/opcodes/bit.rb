module Gameboy
  Instruction.define do
    # BIT
    (0..7).each.with_index do |n_bit, bit_index|
      opcode(0xcb40 + bit_index * 8, 8, 1) { Flags.n = 0; Flags.h = 1; Flags.z = 1 if Registers.b[n_bit] == 0 }
      opcode(0xcb40 + bit_index * 8 + 1, 8, 1) { Flags.n = 0; Flags.h = 1; Flags.z = 1 if Registers.c[n_bit] == 0 }
      opcode(0xcb40 + bit_index * 8 + 2, 8, 1) { Flags.n = 0; Flags.h = 1; Flags.z = 1 if Registers.d[n_bit] == 0 }
      opcode(0xcb40 + bit_index * 8 + 3, 8, 1) { Flags.n = 0; Flags.h = 1; Flags.z = 1 if Registers.e[n_bit] == 0 }
      opcode(0xcb40 + bit_index * 8 + 4, 8, 1) { Flags.n = 0; Flags.h = 1; Flags.z = 1 if Registers.h[n_bit] == 0 }
      opcode(0xcb40 + bit_index * 8 + 5, 8, 1) { Flags.n = 0; Flags.h = 1; Flags.z = 1 if Registers.l[n_bit] == 0 }
      opcode(0xcb40 + bit_index * 8 + 6, 16, 1) { Flags.n = 0; Flags.h = 1; Flags.z = 1 if MMU.bread(Registers.hl)[n_bit] == 0 }
      opcode(0xcb40 + bit_index * 8 + 7, 8, 1) { Flags.n = 0; Flags.h = 1; Flags.z = 1 if Registers.a[n_bit] == 0 }
    end

    # RES
    (0..7).each.with_index do |n_bit, bit_index|
      opcode(0xcb80 + bit_index * 8, 8, 1) { Registers.b &= (0b1111_1111 ^ (1 << n_bit)) }
      opcode(0xcb80 + bit_index * 8 + 1, 8, 1) { Registers.c &= (0b1111_1111 ^ (1 << n_bit)) }
      opcode(0xcb80 + bit_index * 8 + 2, 8, 1) { Registers.d &= (0b1111_1111 ^ (1 << n_bit)) }
      opcode(0xcb80 + bit_index * 8 + 3, 8, 1) { Registers.e &= (0b1111_1111 ^ (1 << n_bit)) }
      opcode(0xcb80 + bit_index * 8 + 4, 8, 1) { Registers.h &= (0b1111_1111 ^ (1 << n_bit)) }
      opcode(0xcb80 + bit_index * 8 + 5, 8, 1) { Registers.l &= (0b1111_1111 ^ (1 << n_bit)) }
      opcode(0xcb80 + bit_index * 8 + 6, 16, 1) { foo = MMU.bread(Registers.hl); foo &= (0b1111_1111 ^ (1 << n_bit)); MMU.bwrite(Registers.hl, foo) }
      opcode(0xcb80 + bit_index * 8 + 7, 8, 1) { Registers.a &= (0b1111_1111 ^ (1 << n_bit)) }
    end

    # SET
    (0..7).each.with_index do |n_bit, bit_index|
      opcode(0xcbc0 + bit_index * 8, 8, 1) { Registers.b |= 1 << n_bit }
      opcode(0xcbc0 + bit_index * 8 + 1, 8, 1) { Registers.c |= 1 << n_bit }
      opcode(0xcbc0 + bit_index * 8 + 2, 8, 1) { Registers.d |= 1 << n_bit }
      opcode(0xcbc0 + bit_index * 8 + 3, 8, 1) { Registers.e |= 1 << n_bit }
      opcode(0xcbc0 + bit_index * 8 + 4, 8, 1) { Registers.h |= 1 << n_bit }
      opcode(0xcbc0 + bit_index * 8 + 5, 8, 1) { Registers.l |= 1 << n_bit }
      opcode(0xcbc0 + bit_index * 8 + 6, 16, 1) { foo = MMU.bread(Registers.hl); foo |= 1 << n_bit; MMU.bwrite(Registers.hl, foo) }
      opcode(0xcbc0 + bit_index * 8 + 7, 8, 1) { Registers.a |= 1 << n_bit }
    end
  end
end