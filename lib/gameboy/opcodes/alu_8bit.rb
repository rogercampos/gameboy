module Gameboy
  Instruction.define do
    def add_alu_flags(old_value, increment)
      new_value = (old_value + increment) % 2 ** 8
      Flags.z = 1 if new_value == 0
      Flags.n = 0
      Flags.c = 1 if old_value > new_value
      Flags.h = 1 if ((old_value ^ increment ^ new_value) & 0x10) != 0
    end

    def sub_alu_flags(old_value, decrement)
      new_value = (old_value - decrement) % 2 ** 8
      Flags.z = 1 if new_value == 0
      Flags.n = 1
      Flags.c = 1 if new_value < 0
      Flags.h = 1 if ((old_value ^ decrement ^ new_value) & 0x10) != 0
    end

    family(:alu_8_add) do
      opcode(0x87, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.a; add_alu_flags(old_value, Registers.a) } }
      opcode(0x80, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.b; add_alu_flags(old_value, Registers.b) } }
      opcode(0x81, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.c; add_alu_flags(old_value, Registers.c) } }
      opcode(0x82, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.d; add_alu_flags(old_value, Registers.d) } }
      opcode(0x83, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.e; add_alu_flags(old_value, Registers.e) } }
      opcode(0x84, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.h; add_alu_flags(old_value, Registers.h) } }
      opcode(0x85, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.l; add_alu_flags(old_value, Registers.l) } }
      opcode(0x86, 8, 1) { Registers.a.tap { |old_value| Registers.a += MMU.bread(Registers.hl); add_alu_flags(old_value, MMU.bread(Registers.hl)) } }
      opcode(0xc6, 8, 2) { i = MMU.bread(Registers.pc); Registers.a.tap { |old_value| Registers.a += i; add_alu_flags(old_value, i) }; Registers.pc += 1 }
    end

    family(:alu_8_adc) do
      opcode(0x8f, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.a + Flags.c; add_alu_flags(old_value, Registers.a + Flags.c) } }
      opcode(0x88, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.b + Flags.c; add_alu_flags(old_value, Registers.b + Flags.c) } }
      opcode(0x89, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.c + Flags.c; add_alu_flags(old_value, Registers.c + Flags.c) } }
      opcode(0x8a, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.d + Flags.c; add_alu_flags(old_value, Registers.d + Flags.c) } }
      opcode(0x8b, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.e + Flags.c; add_alu_flags(old_value, Registers.e + Flags.c) } }
      opcode(0x8c, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.h + Flags.c; add_alu_flags(old_value, Registers.h + Flags.c) } }
      opcode(0x8d, 4, 1) { Registers.a.tap { |old_value| Registers.a += Registers.l + Flags.c; add_alu_flags(old_value, Registers.l + Flags.c) } }
      opcode(0x8e, 8, 1) { Registers.a.tap { |old_value| Registers.a += MMU.bread(Registers.hl) + Flags.c; add_alu_flags(old_value, MMU.bread(Registers.hl) + Flags.c) } }
      opcode(0xce, 8, 2) { i = MMU.bread(Registers.pc); Registers.a.tap { |old_value| Registers.a += i + Flags.c; add_alu_flags(old_value, i + Flags.c) }; Registers.pc += 1 }
    end

    family(:alu_8_sub) do
      opcode(0x97, 4, 1) { Registers.a.tap { |old_value| Registers.a -= Registers.a; sub_alu_flags(old_value, Registers.a) } }
      opcode(0x90, 4, 1) { Registers.a.tap { |old_value| Registers.a -= Registers.b; sub_alu_flags(old_value, Registers.b) } }
      opcode(0x91, 4, 1) { Registers.a.tap { |old_value| Registers.a -= Registers.c; sub_alu_flags(old_value, Registers.c) } }
      opcode(0x92, 4, 1) { Registers.a.tap { |old_value| Registers.a -= Registers.d; sub_alu_flags(old_value, Registers.d) } }
      opcode(0x93, 4, 1) { Registers.a.tap { |old_value| Registers.a -= Registers.e; sub_alu_flags(old_value, Registers.e) } }
      opcode(0x94, 4, 1) { Registers.a.tap { |old_value| Registers.a -= Registers.h; sub_alu_flags(old_value, Registers.h) } }
      opcode(0x95, 4, 1) { Registers.a.tap { |old_value| Registers.a -= Registers.l; sub_alu_flags(old_value, Registers.l) } }
      opcode(0x96, 8, 1) { Registers.a.tap { |old_value| Registers.a -= MMU.bread(Registers.hl); sub_alu_flags(old_value, MMU.bread(Registers.hl)) } }
      opcode(0xd6, 8, 2) { i = MMU.bread(Registers.pc); Registers.a.tap { |old_value| Registers.a -= i; sub_alu_flags(old_value, i) }; Registers.pc += 1 }
    end

    family(:alu_8_sbc) do
      opcode(0x9f, 4, 1) { Registers.a.tap { |old_value| Registers.a -= (Registers.a + Flags.c); sub_alu_flags(old_value, Registers.a + Flags.c) } }
      opcode(0x98, 4, 1) { Registers.a.tap { |old_value| Registers.a -= (Registers.b + Flags.c); sub_alu_flags(old_value, Registers.b + Flags.c) } }
      opcode(0x99, 4, 1) { Registers.a.tap { |old_value| Registers.a -= (Registers.c + Flags.c); sub_alu_flags(old_value, Registers.c + Flags.c) } }
      opcode(0x9a, 4, 1) { Registers.a.tap { |old_value| Registers.a -= (Registers.d + Flags.c); sub_alu_flags(old_value, Registers.d + Flags.c) } }
      opcode(0x9b, 4, 1) { Registers.a.tap { |old_value| Registers.a -= (Registers.e + Flags.c); sub_alu_flags(old_value, Registers.e + Flags.c) } }
      opcode(0x9c, 4, 1) { Registers.a.tap { |old_value| Registers.a -= (Registers.h + Flags.c); sub_alu_flags(old_value, Registers.h + Flags.c) } }
      opcode(0x9d, 4, 1) { Registers.a.tap { |old_value| Registers.a -= (Registers.l + Flags.c); sub_alu_flags(old_value, Registers.l + Flags.c) } }
      opcode(0x9e, 8, 1) { Registers.a.tap { |old_value| Registers.a -= (MMU.bread(Registers.hl) + Flags.c); sub_alu_flags(old_value, MMU.bread(Registers.hl) + Flags.c) } }
      opcode(0xde, 8, 2) { i = MMU.bread(Registers.pc); Registers.a.tap { |old_value| Registers.a -= (i + Flags.c); sub_alu_flags(old_value, i + Flags.c) }; Registers.pc += 1 }
    end

    family(:alu_8_and) do
      opcode(0xa7, 4, 1) { Registers.a &= Registers.a; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 1; Flags.c = 0 }
      opcode(0xa0, 4, 1) { Registers.a &= Registers.b; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 1; Flags.c = 0 }
      opcode(0xa1, 4, 1) { Registers.a &= Registers.c; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 1; Flags.c = 0 }
      opcode(0xa2, 4, 1) { Registers.a &= Registers.d; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 1; Flags.c = 0 }
      opcode(0xa3, 4, 1) { Registers.a &= Registers.e; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 1; Flags.c = 0 }
      opcode(0xa4, 4, 1) { Registers.a &= Registers.h; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 1; Flags.c = 0 }
      opcode(0xa5, 4, 1) { Registers.a &= Registers.l; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 1; Flags.c = 0 }
      opcode(0xa6, 8, 1) { Registers.a &= MMU.bread(Registers.hl); Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 1; Flags.c = 0 }
      opcode(0xe5, 8, 2) { Registers.a &= MMU.bread(Registers.pc); Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 1; Flags.c = 0; Registers.pc += 1 }
    end

    family(:alu_8_or) do
      opcode(0xb7, 4, 1) { Registers.a |= Registers.a; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xb0, 4, 1) { Registers.a |= Registers.b; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xb1, 4, 1) { Registers.a |= Registers.c; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xb2, 4, 1) { Registers.a |= Registers.d; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xb3, 4, 1) { Registers.a |= Registers.e; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xb4, 4, 1) { Registers.a |= Registers.h; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xb5, 4, 1) { Registers.a |= Registers.l; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xb6, 8, 1) { Registers.a |= MMU.bread(Registers.hl); Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xf6, 8, 2) { Registers.a |= MMU.bread(Registers.pc); Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0; Registers.pc += 1 }
    end

    family(:alu_8_xor) do
      opcode(0xaf, 4, 1) { Registers.a ^= Registers.a; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xa8, 4, 1) { Registers.a ^= Registers.b; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xa9, 4, 1) { Registers.a ^= Registers.c; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xaa, 4, 1) { Registers.a ^= Registers.d; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xab, 4, 1) { Registers.a ^= Registers.e; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xac, 4, 1) { Registers.a ^= Registers.h; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xad, 4, 1) { Registers.a ^= Registers.l; Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xae, 8, 1) { Registers.a ^= MMU.bread(Registers.hl); Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      opcode(0xee, 8, 2) { Registers.a ^= MMU.bread(Registers.pc); Flags.z = 0 if Registers.a == 0; Flags.n = 0; Flags.h = 0; Flags.c = 0; Registers.pc += 1 }
    end

    family(:alu_8_cp) do
      opcode(0xbf, 4, 1) { sub_alu_flags(Registers.a, Registers.a) }
      opcode(0xb8, 4, 1) { sub_alu_flags(Registers.a, Registers.b) }
      opcode(0xb9, 4, 1) { sub_alu_flags(Registers.a, Registers.c) }
      opcode(0xba, 4, 1) { sub_alu_flags(Registers.a, Registers.d) }
      opcode(0xbb, 4, 1) { sub_alu_flags(Registers.a, Registers.e) }
      opcode(0xbc, 4, 1) { sub_alu_flags(Registers.a, Registers.h) }
      opcode(0xbd, 4, 1) { sub_alu_flags(Registers.a, Registers.l) }
      opcode(0xbe, 8, 1) { sub_alu_flags(Registers.a, MMU.bread(Registers.hl)) }
      opcode(0xfe, 8, 2) { sub_alu_flags(Registers.a, MMU.bread(Registers.pc)); Registers.pc += 1 }
    end

    def inc_alu_flags(value)
      Flags.z = 1 if value == 0
      Flags.n = 0
      Flags.h = 1 if ((value ^ 1 ^ (value+1)) & 0x10) != 0
    end

    family(:alu_8_inc) do
      opcode(0x3c, 4, 1) { Registers.a += 1; inc_alu_flags(Registers.a) }
      opcode(0x04, 4, 1) { Registers.b += 1; inc_alu_flags(Registers.b) }
      opcode(0x0c, 4, 1) { Registers.c += 1; inc_alu_flags(Registers.c) }
      opcode(0x14, 4, 1) { Registers.d += 1; inc_alu_flags(Registers.d) }
      opcode(0x1c, 4, 1) { Registers.e += 1; inc_alu_flags(Registers.e) }
      opcode(0x24, 4, 1) { Registers.h += 1; inc_alu_flags(Registers.h) }
      opcode(0x2c, 4, 1) { Registers.l += 1; inc_alu_flags(Registers.l) }
      opcode(0x34, 12, 1) { MMU.bwrite(Registers.hl, MMU.bread(Registers.hl) + 1); inc_alu_flags(MMU.bread(Registers.hl)) }
    end

    def dec_alu_flags(value)
      Flags.z = 1 if value == 0
      Flags.n = 1
      Flags.h = 1 if ((value ^ 1 ^ (value-1)) & 0x10) != 0
    end

    family(:alu_8_dec) do
      opcode(0x3d, 4, 1) { Registers.a -= 1; dec_alu_flags(Registers.a) }
      opcode(0x05, 4, 1) { Registers.b -= 1; dec_alu_flags(Registers.b) }
      opcode(0x0d, 4, 1) { Registers.c -= 1; dec_alu_flags(Registers.c) }
      opcode(0x15, 4, 1) { Registers.d -= 1; dec_alu_flags(Registers.d) }
      opcode(0x1d, 4, 1) { Registers.e -= 1; dec_alu_flags(Registers.e) }
      opcode(0x25, 4, 1) { Registers.h -= 1; dec_alu_flags(Registers.h) }
      opcode(0x2d, 4, 1) { Registers.l -= 1; dec_alu_flags(Registers.l) }
      opcode(0x35, 12, 1) { MMU.bwrite(Registers.hl, MMU.bread(Registers.hl) - 1); dec_alu_flags(MMU.bread(Registers.hl)) }
    end
  end
end