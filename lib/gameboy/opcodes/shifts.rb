module Gameboy
  Instruction.define do
    def reset_flags(value)
      Flags.z = 1 if value == 0
      Flags.n = 0
      Flags.h = 0
    end

    # SLA
    opcode(0xcb27, 8, 1) { Flags.c = Registers.a[7]; Registers.a = Registers.a << 1; reset_flags(Registers.a) }
    opcode(0xcb20, 8, 1) { Flags.c = Registers.b[7]; Registers.b = Registers.b << 1; reset_flags(Registers.b) }
    opcode(0xcb21, 8, 1) { Flags.c = Registers.c[7]; Registers.c = Registers.c << 1; reset_flags(Registers.c) }
    opcode(0xcb22, 8, 1) { Flags.c = Registers.d[7]; Registers.d = Registers.d << 1; reset_flags(Registers.d) }
    opcode(0xcb23, 8, 1) { Flags.c = Registers.e[7]; Registers.e = Registers.e << 1; reset_flags(Registers.e) }
    opcode(0xcb24, 8, 1) { Flags.c = Registers.h[7]; Registers.h = Registers.h << 1; reset_flags(Registers.h) }
    opcode(0xcb25, 8, 1) { Flags.c = Registers.l[7]; Registers.l = Registers.l << 1; reset_flags(Registers.l) }
    opcode(0xcb26, 16, 1) { foo = MMU.bread(Registers.hl); Flags.c = foo[7]; result = foo << 1; MMU.bwrite(Registers.hl, result); reset_flags(result) }

    # SRA
    opcode(0xcb2f, 8, 1) { Flags.c = Registers.a[0]; msb = Registers.a[7]; Registers.a = (Registers.a >> 1) + 255 * msb; reset_flags(Registers.a) }
    opcode(0xcb28, 8, 1) { Flags.c = Registers.b[0]; msb = Registers.b[7]; Registers.b = (Registers.b >> 1) + 255 * msb; reset_flags(Registers.b) }
    opcode(0xcb29, 8, 1) { Flags.c = Registers.c[0]; msb = Registers.c[7]; Registers.c = (Registers.c >> 1) + 255 * msb; reset_flags(Registers.c) }
    opcode(0xcb2a, 8, 1) { Flags.c = Registers.d[0]; msb = Registers.d[7]; Registers.d = (Registers.d >> 1) + 255 * msb; reset_flags(Registers.d) }
    opcode(0xcb2b, 8, 1) { Flags.c = Registers.e[0]; msb = Registers.e[7]; Registers.e = (Registers.e >> 1) + 255 * msb; reset_flags(Registers.e) }
    opcode(0xcb2c, 8, 1) { Flags.c = Registers.h[0]; msb = Registers.h[7]; Registers.h = (Registers.h >> 1) + 255 * msb; reset_flags(Registers.h) }
    opcode(0xcb2d, 8, 1) { Flags.c = Registers.l[0]; msb = Registers.l[7]; Registers.l = (Registers.l >> 1) + 255 * msb; reset_flags(Registers.l) }
    opcode(0xcb2e, 16, 1) { foo = MMU.bread(Registers.hl); Flags.c = foo[0]; msb = foo[7]; result = (foo >> 1) + 255 * msb; MMU.bwrite(Registers.hl, result); reset_flags(result) }

    # SRL
    opcode(0xcb3f, 8, 1) { Flags.c = Registers.a[0]; Registers.a = Registers.a >> 1; reset_flags(Registers.a) }
    opcode(0xcb38, 8, 1) { Flags.c = Registers.b[0]; Registers.b = Registers.b >> 1; reset_flags(Registers.b) }
    opcode(0xcb39, 8, 1) { Flags.c = Registers.c[0]; Registers.c = Registers.c >> 1; reset_flags(Registers.c) }
    opcode(0xcb3a, 8, 1) { Flags.c = Registers.d[0]; Registers.d = Registers.d >> 1; reset_flags(Registers.d) }
    opcode(0xcb3b, 8, 1) { Flags.c = Registers.e[0]; Registers.e = Registers.e >> 1; reset_flags(Registers.e) }
    opcode(0xcb3c, 8, 1) { Flags.c = Registers.h[0]; Registers.h = Registers.h >> 1; reset_flags(Registers.h) }
    opcode(0xcb3d, 8, 1) { Flags.c = Registers.l[0]; Registers.l = Registers.l >> 1; reset_flags(Registers.l) }
    opcode(0xcb3e, 16, 1) { foo = MMU.bread(Registers.hl); Flags.c = foo[0]; result = foo >> 1; MMU.bwrite(Registers.hl, result); reset_flags(result) }
  end
end