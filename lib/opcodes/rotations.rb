Instruction.define do
  def reset_flags(value)
    Flags.z = 1 if value == 0
    Flags.n = 0
    Flags.h = 0
  end

  # RLCA
  opcode(0x07, 4, 1) { Flags.c = Registers.a[7]; Registers.a = (Registers.a << 1) + Registers.a[7]; reset_flags(Registers.a) }

  # RLA
  opcode(0x17, 4, 1) { old_c = Flags.c; Flags.c = Registers.a[7]; Registers.a = (Registers.a << 1) + old_c; reset_flags(Registers.a) }

  # RRCA
  opcode(0x0f, 4, 1) { Flags.c = Registers.a[0]; Registers.a = (Registers.a >> 1) + (Registers.a[0] << 7); reset_flags(Registers.a) }

  # RRA
  opcode(0x1f, 4, 1) { old_c = Flags.c; Flags.c = Registers.a[0]; Registers.a = (Registers.a >> 1) + (old_c << 7); reset_flags(Registers.a) }

  # RLC
  opcode(0xcb07, 8, 1) { Flags.c = Registers.a[7]; Registers.a = (Registers.a << 1) + Registers.a[7]; reset_flags(Registers.a) }
  opcode(0xcb00, 8, 1) { Flags.c = Registers.b[7]; Registers.b = (Registers.b << 1) + Registers.b[7]; reset_flags(Registers.b) }
  opcode(0xcb01, 8, 1) { Flags.c = Registers.c[7]; Registers.c = (Registers.c << 1) + Registers.c[7]; reset_flags(Registers.c) }
  opcode(0xcb02, 8, 1) { Flags.c = Registers.d[7]; Registers.d = (Registers.d << 1) + Registers.d[7]; reset_flags(Registers.d) }
  opcode(0xcb03, 8, 1) { Flags.c = Registers.e[7]; Registers.e = (Registers.e << 1) + Registers.e[7]; reset_flags(Registers.e) }
  opcode(0xcb04, 8, 1) { Flags.c = Registers.h[7]; Registers.h = (Registers.h << 1) + Registers.h[7]; reset_flags(Registers.h) }
  opcode(0xcb05, 8, 1) { Flags.c = Registers.l[7]; Registers.l = (Registers.l << 1) + Registers.l[7]; reset_flags(Registers.l) }
  opcode(0xcb06, 16, 1) { foo = MMU.read(Registers.hl, 1); Flags.c = foo[7]; result = (foo << 1) + foo[7]; MMU.write(Registers.hl, result); reset_flags(result) }

  # RL
  opcode(0xcb17, 8, 1) { old_c = Flags.c; Flags.c = Registers.a[7]; Registers.a = (Registers.a << 1) + old_c; reset_flags(Registers.a) }
  opcode(0xcb10, 8, 1) { old_c = Flags.c; Flags.c = Registers.b[7]; Registers.b = (Registers.b << 1) + old_c; reset_flags(Registers.b) }
  opcode(0xcb11, 8, 1) { old_c = Flags.c; Flags.c = Registers.c[7]; Registers.c = (Registers.c << 1) + old_c; reset_flags(Registers.c) }
  opcode(0xcb12, 8, 1) { old_c = Flags.c; Flags.c = Registers.d[7]; Registers.d = (Registers.d << 1) + old_c; reset_flags(Registers.d) }
  opcode(0xcb13, 8, 1) { old_c = Flags.c; Flags.c = Registers.e[7]; Registers.e = (Registers.e << 1) + old_c; reset_flags(Registers.e) }
  opcode(0xcb14, 8, 1) { old_c = Flags.c; Flags.c = Registers.h[7]; Registers.h = (Registers.h << 1) + old_c; reset_flags(Registers.h) }
  opcode(0xcb15, 8, 1) { old_c = Flags.c; Flags.c = Registers.l[7]; Registers.l = (Registers.l << 1) + old_c; reset_flags(Registers.l) }
  opcode(0xcb16, 16, 1) { old_c = Flags.c; foo = MMU.read(Registers.hl, 1); Flags.c = foo[7]; result = (foo << 1) + old_c; MMU.write(Registers.hl, result); reset_flags(result) }

  # RRC
  opcode(0xcb0f, 8, 1) { Flags.c = Registers.a[0]; Registers.a = (Registers.a >> 1) + (Registers.a[0] << 7); reset_flags(Registers.a) }
  opcode(0xcb08, 8, 1) { Flags.c = Registers.b[0]; Registers.b = (Registers.b >> 1) + (Registers.b[0] << 7); reset_flags(Registers.b) }
  opcode(0xcb09, 8, 1) { Flags.c = Registers.c[0]; Registers.c = (Registers.c >> 1) + (Registers.c[0] << 7); reset_flags(Registers.c) }
  opcode(0xcb0a, 8, 1) { Flags.c = Registers.d[0]; Registers.d = (Registers.d >> 1) + (Registers.d[0] << 7); reset_flags(Registers.d) }
  opcode(0xcb0b, 8, 1) { Flags.c = Registers.e[0]; Registers.e = (Registers.e >> 1) + (Registers.e[0] << 7); reset_flags(Registers.e) }
  opcode(0xcb0c, 8, 1) { Flags.c = Registers.h[0]; Registers.h = (Registers.h >> 1) + (Registers.h[0] << 7); reset_flags(Registers.h) }
  opcode(0xcb0d, 8, 1) { Flags.c = Registers.l[0]; Registers.l = (Registers.l >> 1) + (Registers.l[0] << 7); reset_flags(Registers.l) }
  opcode(0xcb0e, 16, 1) { foo = MMU.read(Registers.hl, 1); Flags.c = foo[0]; result = (foo >> 1) + (foo[0] << 7); MMU.write(Registers.hl, result); reset_flags(result) }

  # RR
  opcode(0xcb1f, 8, 1) { old_c = Flags.c; Flags.c = Registers.a[0]; Registers.a = (Registers.a >> 1) + (old_c << 7); reset_flags(Registers.a) }
  opcode(0xcb18, 8, 1) { old_c = Flags.c; Flags.c = Registers.b[0]; Registers.b = (Registers.b >> 1) + (old_c << 7); reset_flags(Registers.b) }
  opcode(0xcb19, 8, 1) { old_c = Flags.c; Flags.c = Registers.c[0]; Registers.c = (Registers.c >> 1) + (old_c << 7); reset_flags(Registers.c) }
  opcode(0xcb1a, 8, 1) { old_c = Flags.c; Flags.c = Registers.d[0]; Registers.d = (Registers.d >> 1) + (old_c << 7); reset_flags(Registers.d) }
  opcode(0xcb1b, 8, 1) { old_c = Flags.c; Flags.c = Registers.e[0]; Registers.e = (Registers.e >> 1) + (old_c << 7); reset_flags(Registers.e) }
  opcode(0xcb1c, 8, 1) { old_c = Flags.c; Flags.c = Registers.h[0]; Registers.h = (Registers.h >> 1) + (old_c << 7); reset_flags(Registers.h) }
  opcode(0xcb1d, 8, 1) { old_c = Flags.c; Flags.c = Registers.l[0]; Registers.l = (Registers.l >> 1) + (old_c << 7); reset_flags(Registers.l) }
  opcode(0xcb1e, 16, 1) { old_c = Flags.c; foo = MMU.read(Registers.hl, 1); Flags.c = foo[0]; result = (foo >> 1) + (old_c << 7); MMU.write(Registers.hl, result); reset_flags(result) }
end