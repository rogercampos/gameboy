require "./registers"
require "./flags"
require "./mmu"
require "./alu_helpers"
require "./ime"

module Gameboy
  # Instruction execution proc type
  alias InstructionProc = Proc(Nil)

  struct Instruction
    property opcode : UInt16
    property cycles : Int32
    property size : Int32
    property family : String
    property impl : InstructionProc

    def initialize(@opcode : UInt16, @cycles : Int32, @size : Int32, @family : String, @impl : InstructionProc)
    end

    def run
      @impl.call
    end
  end

  module Instructions
    extend self

    @@instructions = {} of UInt16 => Instruction

    def register(opcode : Int32, cycles : Int32, size : Int32, family : String, &block : -> Nil)
      @@instructions[opcode.to_u16] = Instruction.new(
        opcode.to_u16,
        cycles,
        size,
        family,
        block
      )
    end

    def [](opcode : Int32) : Instruction
      @@instructions[opcode.to_u16]? || raise "Undefined instruction with opcode 0x#{opcode.to_s(16)} at PC=0x#{Registers.pc.to_s(16)}"
    end

    def []?(opcode : Int32) : Instruction?
      @@instructions[opcode.to_u16]?
    end

    # Initialize all instructions
    def self.init_all
      init_load_8bit
      init_load_16bit
      init_alu_8bit
      init_alu_16bit
      init_bit
      init_jumps
      init_calls
      init_returns
      init_restarts
      init_rotations
      init_shifts
      init_misc
    end

    # Load 8-bit instructions
    private def self.init_load_8bit
      # LD B,n
      register(0x06, 8, 2, "LD B,n") { Registers.b = MMU.bread(Registers.pc); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }
      register(0x0e, 8, 2, "LD C,n") { Registers.c = MMU.bread(Registers.pc); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }
      register(0x16, 8, 2, "LD D,n") { Registers.d = MMU.bread(Registers.pc); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }
      register(0x1e, 8, 2, "LD E,n") { Registers.e = MMU.bread(Registers.pc); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }
      register(0x26, 8, 2, "LD H,n") { Registers.h = MMU.bread(Registers.pc); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }
      register(0x2e, 8, 2, "LD L,n") { Registers.l = MMU.bread(Registers.pc); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }

      # LD (HL),n
      register(0x36, 12, 2, "LD (HL),n") { MMU.bwrite(Registers.hl, MMU.bread(Registers.pc)); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }

      # LD r1,r2 - A register
      register(0x7f, 4, 1, "LD A,A") { Registers.a = Registers.a }
      register(0x78, 4, 1, "LD A,B") { Registers.a = Registers.b }
      register(0x79, 4, 1, "LD A,C") { Registers.a = Registers.c }
      register(0x7a, 4, 1, "LD A,D") { Registers.a = Registers.d }
      register(0x7b, 4, 1, "LD A,E") { Registers.a = Registers.e }
      register(0x7c, 4, 1, "LD A,H") { Registers.a = Registers.h }
      register(0x7d, 4, 1, "LD A,L") { Registers.a = Registers.l }

      # LD r1,r2 - B register
      register(0x40, 4, 1, "LD B,B") { Registers.b = Registers.b }
      register(0x41, 4, 1, "LD B,C") { Registers.b = Registers.c }
      register(0x42, 4, 1, "LD B,D") { Registers.b = Registers.d }
      register(0x43, 4, 1, "LD B,E") { Registers.b = Registers.e }
      register(0x44, 4, 1, "LD B,H") { Registers.b = Registers.h }
      register(0x45, 4, 1, "LD B,L") { Registers.b = Registers.l }
      register(0x46, 8, 1, "LD B,(HL)") { Registers.b = MMU.bread(Registers.hl) }

      # LD r1,r2 - C register
      register(0x48, 4, 1, "LD C,B") { Registers.c = Registers.b }
      register(0x49, 4, 1, "LD C,C") { Registers.c = Registers.c }
      register(0x4a, 4, 1, "LD C,D") { Registers.c = Registers.d }
      register(0x4b, 4, 1, "LD C,E") { Registers.c = Registers.e }
      register(0x4c, 4, 1, "LD C,H") { Registers.c = Registers.h }
      register(0x4d, 4, 1, "LD C,L") { Registers.c = Registers.l }
      register(0x4e, 8, 1, "LD C,(HL)") { Registers.c = MMU.bread(Registers.hl) }

      # LD r1,r2 - D register
      register(0x50, 4, 1, "LD D,B") { Registers.d = Registers.b }
      register(0x51, 4, 1, "LD D,C") { Registers.d = Registers.c }
      register(0x52, 4, 1, "LD D,D") { Registers.d = Registers.d }
      register(0x53, 4, 1, "LD D,E") { Registers.d = Registers.e }
      register(0x54, 4, 1, "LD D,H") { Registers.d = Registers.h }
      register(0x55, 4, 1, "LD D,L") { Registers.d = Registers.l }
      register(0x56, 8, 1, "LD D,(HL)") { Registers.d = MMU.bread(Registers.hl) }

      # LD r1,r2 - E register
      register(0x58, 4, 1, "LD E,B") { Registers.e = Registers.b }
      register(0x59, 4, 1, "LD E,C") { Registers.e = Registers.c }
      register(0x5a, 4, 1, "LD E,D") { Registers.e = Registers.d }
      register(0x5b, 4, 1, "LD E,E") { Registers.e = Registers.e }
      register(0x5c, 4, 1, "LD E,H") { Registers.e = Registers.h }
      register(0x5d, 4, 1, "LD E,L") { Registers.e = Registers.l }
      register(0x5e, 8, 1, "LD E,(HL)") { Registers.e = MMU.bread(Registers.hl) }

      # LD r1,r2 - H register
      register(0x60, 4, 1, "LD H,B") { Registers.h = Registers.b }
      register(0x61, 4, 1, "LD H,C") { Registers.h = Registers.c }
      register(0x62, 4, 1, "LD H,D") { Registers.h = Registers.d }
      register(0x63, 4, 1, "LD H,E") { Registers.h = Registers.e }
      register(0x64, 4, 1, "LD H,H") { Registers.h = Registers.h }
      register(0x65, 4, 1, "LD H,L") { Registers.h = Registers.l }
      register(0x66, 8, 1, "LD H,(HL)") { Registers.h = MMU.bread(Registers.hl) }

      # LD r1,r2 - L register
      register(0x68, 4, 1, "LD L,B") { Registers.l = Registers.b }
      register(0x69, 4, 1, "LD L,C") { Registers.l = Registers.c }
      register(0x6a, 4, 1, "LD L,D") { Registers.l = Registers.d }
      register(0x6b, 4, 1, "LD L,E") { Registers.l = Registers.e }
      register(0x6c, 4, 1, "LD L,H") { Registers.l = Registers.h }
      register(0x6d, 4, 1, "LD L,L") { Registers.l = Registers.l }
      register(0x6e, 8, 1, "LD L,(HL)") { Registers.l = MMU.bread(Registers.hl) }

      # LD (HL),r
      register(0x70, 8, 1, "LD (HL),B") { MMU.bwrite(Registers.hl, Registers.b) }
      register(0x71, 8, 1, "LD (HL),C") { MMU.bwrite(Registers.hl, Registers.c) }
      register(0x72, 8, 1, "LD (HL),D") { MMU.bwrite(Registers.hl, Registers.d) }
      register(0x73, 8, 1, "LD (HL),E") { MMU.bwrite(Registers.hl, Registers.e) }
      register(0x74, 8, 1, "LD (HL),H") { MMU.bwrite(Registers.hl, Registers.h) }
      register(0x75, 8, 1, "LD (HL),L") { MMU.bwrite(Registers.hl, Registers.l) }

      # LD A,n
      register(0x0a, 8, 1, "LD A,(BC)") { Registers.a = MMU.bread(Registers.bc) }
      register(0x1a, 8, 1, "LD A,(DE)") { Registers.a = MMU.bread(Registers.de) }
      register(0x7e, 8, 1, "LD A,(HL)") { Registers.a = MMU.bread(Registers.hl) }
      register(0xfa, 16, 3, "LD A,(nn)") { Registers.a = MMU.bread(MMU.wread(Registers.pc)); Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF) }
      register(0x3e, 8, 2, "LD A,n") { Registers.a = MMU.bread(Registers.pc); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }

      # LD n,A
      register(0x47, 4, 1, "LD B,A") { Registers.b = Registers.a }
      register(0x4f, 4, 1, "LD C,A") { Registers.c = Registers.a }
      register(0x57, 4, 1, "LD D,A") { Registers.d = Registers.a }
      register(0x5f, 4, 1, "LD E,A") { Registers.e = Registers.a }
      register(0x67, 4, 1, "LD H,A") { Registers.h = Registers.a }
      register(0x6f, 4, 1, "LD L,A") { Registers.l = Registers.a }

      register(0x02, 8, 1, "LD (BC),A") { MMU.bwrite(Registers.bc, Registers.a) }
      register(0x12, 8, 1, "LD (DE),A") { MMU.bwrite(Registers.de, Registers.a) }
      register(0x77, 8, 1, "LD (HL),A") { MMU.bwrite(Registers.hl, Registers.a) }
      register(0xea, 16, 3, "LD (nn),A") { MMU.bwrite(MMU.wread(Registers.pc), Registers.a); Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF) }

      # LD A,(C) and LD (C),A
      register(0xf2, 8, 1, "LD A,(C)") { Registers.a = MMU.bread(0xff00 + Registers.c) }
      register(0xe2, 8, 1, "LD (C),A") { MMU.bwrite(0xff00 + Registers.c, Registers.a) }

      # LDD A,(HL) and LDD (HL),A
      register(0x3a, 8, 1, "LDD A,(HL)") { Registers.a = MMU.bread(Registers.hl); Registers.hl = ((Registers.hl.to_i32 - 1) & 0xFFFF) }
      register(0x32, 8, 1, "LDD (HL),A") { MMU.bwrite(Registers.hl, Registers.a); Registers.hl = ((Registers.hl.to_i32 - 1) & 0xFFFF) }

      # LDI A,(HL) and LDI (HL),A
      register(0x2a, 8, 1, "LDI A,(HL)") { Registers.a = MMU.bread(Registers.hl); Registers.hl = ((Registers.hl.to_i32 + 1) & 0xFFFF) }
      register(0x22, 8, 1, "LDI (HL),A") { MMU.bwrite(Registers.hl, Registers.a); Registers.hl = ((Registers.hl.to_i32 + 1) & 0xFFFF) }

      # LDH (n),A and LDH A,(n)
      register(0xe0, 12, 2, "LDH (n),A") { MMU.bwrite(0xff00 + MMU.bread(Registers.pc), Registers.a); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }
      register(0xf0, 12, 2, "LDH A,(n)") { Registers.a = MMU.bread(0xff00 + MMU.bread(Registers.pc)); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }
    end

    private def self.init_load_16bit
      # LD rr,nn - Load 16-bit immediate into register pair
      register(0x01, 12, 3, "LD BC,nn") { Registers.bc = MMU.wread(Registers.pc); Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF) }
      register(0x11, 12, 3, "LD DE,nn") { Registers.de = MMU.wread(Registers.pc); Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF) }
      register(0x21, 12, 3, "LD HL,nn") { Registers.hl = MMU.wread(Registers.pc); Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF) }
      register(0x31, 12, 3, "LD SP,nn") { Registers.sp = MMU.wread(Registers.pc); Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF) }

      # LD SP,HL - Copy HL to SP
      register(0xf9, 8, 1, "LD SP,HL") { Registers.sp = Registers.hl }

      # LD (nn),SP - Store SP to memory address
      register(0x08, 20, 3, "LD (nn),SP") { MMU.wwrite(MMU.wread(Registers.pc), Registers.sp); Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF) }

      # LDHL SP,n - Load HL with SP + signed 8-bit offset (affects flags like ADD SP,n)
      register(0xf8, 12, 2, "LDHL SP,n") {
        offset = MMU.bread(Registers.pc, signed: true)
        old = Registers.sp
        Registers.hl = (old + offset) & 0xFFFF
        ALUHelpers.add_16bit_flags(old, offset, set_z_to_zero: true)
        Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF)
      }

      # PUSH rr - Push register pair onto stack
      register(0xf5, 16, 1, "PUSH AF") { Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF); MMU.wwrite(Registers.sp, Registers.af) }
      register(0xc5, 16, 1, "PUSH BC") { Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF); MMU.wwrite(Registers.sp, Registers.bc) }
      register(0xd5, 16, 1, "PUSH DE") { Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF); MMU.wwrite(Registers.sp, Registers.de) }
      register(0xe5, 16, 1, "PUSH HL") { Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF); MMU.wwrite(Registers.sp, Registers.hl) }

      # POP rr - Pop register pair from stack
      register(0xf1, 12, 1, "POP AF") { Registers.af = MMU.wread(Registers.sp); Registers.sp = ((Registers.sp.to_i32 + 2) & 0xFFFF) }
      register(0xc1, 12, 1, "POP BC") { Registers.bc = MMU.wread(Registers.sp); Registers.sp = ((Registers.sp.to_i32 + 2) & 0xFFFF) }
      register(0xd1, 12, 1, "POP DE") { Registers.de = MMU.wread(Registers.sp); Registers.sp = ((Registers.sp.to_i32 + 2) & 0xFFFF) }
      register(0xe1, 12, 1, "POP HL") { Registers.hl = MMU.wread(Registers.sp); Registers.sp = ((Registers.sp.to_i32 + 2) & 0xFFFF) }
    end

    private def self.init_alu_8bit
      # ADD A,r - Add register to A
      register(0x87, 4, 1, "ADD A,A") { Registers.a = ALUHelpers.add(Registers.a, Registers.a) }
      register(0x80, 4, 1, "ADD A,B") { Registers.a = ALUHelpers.add(Registers.a, Registers.b) }
      register(0x81, 4, 1, "ADD A,C") { Registers.a = ALUHelpers.add(Registers.a, Registers.c) }
      register(0x82, 4, 1, "ADD A,D") { Registers.a = ALUHelpers.add(Registers.a, Registers.d) }
      register(0x83, 4, 1, "ADD A,E") { Registers.a = ALUHelpers.add(Registers.a, Registers.e) }
      register(0x84, 4, 1, "ADD A,H") { Registers.a = ALUHelpers.add(Registers.a, Registers.h) }
      register(0x85, 4, 1, "ADD A,L") { Registers.a = ALUHelpers.add(Registers.a, Registers.l) }
      register(0x86, 8, 1, "ADD A,(HL)") { Registers.a = ALUHelpers.add(Registers.a, MMU.bread(Registers.hl)) }
      register(0xc6, 8, 2, "ADD A,n") { Registers.a = ALUHelpers.add(Registers.a, MMU.bread(Registers.pc)); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }

      # ADC A,r - Add register + carry to A
      register(0x8f, 4, 1, "ADC A,A") { Registers.a = ALUHelpers.add(Registers.a, Registers.a + Flags.c) }
      register(0x88, 4, 1, "ADC A,B") { Registers.a = ALUHelpers.add(Registers.a, Registers.b + Flags.c) }
      register(0x89, 4, 1, "ADC A,C") { Registers.a = ALUHelpers.add(Registers.a, Registers.c + Flags.c) }
      register(0x8a, 4, 1, "ADC A,D") { Registers.a = ALUHelpers.add(Registers.a, Registers.d + Flags.c) }
      register(0x8b, 4, 1, "ADC A,E") { Registers.a = ALUHelpers.add(Registers.a, Registers.e + Flags.c) }
      register(0x8c, 4, 1, "ADC A,H") { Registers.a = ALUHelpers.add(Registers.a, Registers.h + Flags.c) }
      register(0x8d, 4, 1, "ADC A,L") { Registers.a = ALUHelpers.add(Registers.a, Registers.l + Flags.c) }
      register(0x8e, 8, 1, "ADC A,(HL)") { Registers.a = ALUHelpers.add(Registers.a, MMU.bread(Registers.hl) + Flags.c) }
      register(0xce, 8, 2, "ADC A,n") { Registers.a = ALUHelpers.add(Registers.a, MMU.bread(Registers.pc) + Flags.c); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }

      # SUB A,r - Subtract register from A
      register(0x97, 4, 1, "SUB A,A") { Registers.a = ALUHelpers.sub(Registers.a, Registers.a) }
      register(0x90, 4, 1, "SUB A,B") { Registers.a = ALUHelpers.sub(Registers.a, Registers.b) }
      register(0x91, 4, 1, "SUB A,C") { Registers.a = ALUHelpers.sub(Registers.a, Registers.c) }
      register(0x92, 4, 1, "SUB A,D") { Registers.a = ALUHelpers.sub(Registers.a, Registers.d) }
      register(0x93, 4, 1, "SUB A,E") { Registers.a = ALUHelpers.sub(Registers.a, Registers.e) }
      register(0x94, 4, 1, "SUB A,H") { Registers.a = ALUHelpers.sub(Registers.a, Registers.h) }
      register(0x95, 4, 1, "SUB A,L") { Registers.a = ALUHelpers.sub(Registers.a, Registers.l) }
      register(0x96, 8, 1, "SUB A,(HL)") { Registers.a = ALUHelpers.sub(Registers.a, MMU.bread(Registers.hl)) }
      register(0xd6, 8, 2, "SUB A,n") { Registers.a = ALUHelpers.sub(Registers.a, MMU.bread(Registers.pc)); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }

      # SBC A,r - Subtract register + carry from A
      register(0x9f, 4, 1, "SBC A,A") { Registers.a = ALUHelpers.sub(Registers.a, Registers.a + Flags.c) }
      register(0x98, 4, 1, "SBC A,B") { Registers.a = ALUHelpers.sub(Registers.a, Registers.b + Flags.c) }
      register(0x99, 4, 1, "SBC A,C") { Registers.a = ALUHelpers.sub(Registers.a, Registers.c + Flags.c) }
      register(0x9a, 4, 1, "SBC A,D") { Registers.a = ALUHelpers.sub(Registers.a, Registers.d + Flags.c) }
      register(0x9b, 4, 1, "SBC A,E") { Registers.a = ALUHelpers.sub(Registers.a, Registers.e + Flags.c) }
      register(0x9c, 4, 1, "SBC A,H") { Registers.a = ALUHelpers.sub(Registers.a, Registers.h + Flags.c) }
      register(0x9d, 4, 1, "SBC A,L") { Registers.a = ALUHelpers.sub(Registers.a, Registers.l + Flags.c) }
      register(0x9e, 8, 1, "SBC A,(HL)") { Registers.a = ALUHelpers.sub(Registers.a, MMU.bread(Registers.hl) + Flags.c) }
      register(0xde, 8, 2, "SBC A,n") { Registers.a = ALUHelpers.sub(Registers.a, MMU.bread(Registers.pc) + Flags.c); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }

      # AND A,r - Bitwise AND with A
      register(0xa7, 4, 1, "AND A,A") { Registers.a = ALUHelpers.bit_and(Registers.a & Registers.a) }
      register(0xa0, 4, 1, "AND A,B") { Registers.a = ALUHelpers.bit_and(Registers.a & Registers.b) }
      register(0xa1, 4, 1, "AND A,C") { Registers.a = ALUHelpers.bit_and(Registers.a & Registers.c) }
      register(0xa2, 4, 1, "AND A,D") { Registers.a = ALUHelpers.bit_and(Registers.a & Registers.d) }
      register(0xa3, 4, 1, "AND A,E") { Registers.a = ALUHelpers.bit_and(Registers.a & Registers.e) }
      register(0xa4, 4, 1, "AND A,H") { Registers.a = ALUHelpers.bit_and(Registers.a & Registers.h) }
      register(0xa5, 4, 1, "AND A,L") { Registers.a = ALUHelpers.bit_and(Registers.a & Registers.l) }
      register(0xa6, 8, 1, "AND A,(HL)") { Registers.a = ALUHelpers.bit_and(Registers.a & MMU.bread(Registers.hl)) }
      register(0xe6, 8, 2, "AND A,n") { Registers.a = ALUHelpers.bit_and(Registers.a & MMU.bread(Registers.pc)); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }

      # OR A,r - Bitwise OR with A
      register(0xb7, 4, 1, "OR A,A") { Registers.a = ALUHelpers.bit_or(Registers.a | Registers.a) }
      register(0xb0, 4, 1, "OR A,B") { Registers.a = ALUHelpers.bit_or(Registers.a | Registers.b) }
      register(0xb1, 4, 1, "OR A,C") { Registers.a = ALUHelpers.bit_or(Registers.a | Registers.c) }
      register(0xb2, 4, 1, "OR A,D") { Registers.a = ALUHelpers.bit_or(Registers.a | Registers.d) }
      register(0xb3, 4, 1, "OR A,E") { Registers.a = ALUHelpers.bit_or(Registers.a | Registers.e) }
      register(0xb4, 4, 1, "OR A,H") { Registers.a = ALUHelpers.bit_or(Registers.a | Registers.h) }
      register(0xb5, 4, 1, "OR A,L") { Registers.a = ALUHelpers.bit_or(Registers.a | Registers.l) }
      register(0xb6, 8, 1, "OR A,(HL)") { Registers.a = ALUHelpers.bit_or(Registers.a | MMU.bread(Registers.hl)) }
      register(0xf6, 8, 2, "OR A,n") { Registers.a = ALUHelpers.bit_or(Registers.a | MMU.bread(Registers.pc)); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }

      # XOR A,r - Bitwise XOR with A
      register(0xaf, 4, 1, "XOR A,A") { Registers.a = ALUHelpers.bit_xor(Registers.a ^ Registers.a) }
      register(0xa8, 4, 1, "XOR A,B") { Registers.a = ALUHelpers.bit_xor(Registers.a ^ Registers.b) }
      register(0xa9, 4, 1, "XOR A,C") { Registers.a = ALUHelpers.bit_xor(Registers.a ^ Registers.c) }
      register(0xaa, 4, 1, "XOR A,D") { Registers.a = ALUHelpers.bit_xor(Registers.a ^ Registers.d) }
      register(0xab, 4, 1, "XOR A,E") { Registers.a = ALUHelpers.bit_xor(Registers.a ^ Registers.e) }
      register(0xac, 4, 1, "XOR A,H") { Registers.a = ALUHelpers.bit_xor(Registers.a ^ Registers.h) }
      register(0xad, 4, 1, "XOR A,L") { Registers.a = ALUHelpers.bit_xor(Registers.a ^ Registers.l) }
      register(0xae, 8, 1, "XOR A,(HL)") { Registers.a = ALUHelpers.bit_xor(Registers.a ^ MMU.bread(Registers.hl)) }
      register(0xee, 8, 2, "XOR A,n") { Registers.a = ALUHelpers.bit_xor(Registers.a ^ MMU.bread(Registers.pc)); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }

      # CP A,r - Compare A with register (subtract and set flags, don't store result)
      register(0xbf, 4, 1, "CP A,A") { ALUHelpers.sub_flags(Registers.a, Registers.a) }
      register(0xb8, 4, 1, "CP A,B") { ALUHelpers.sub_flags(Registers.a, Registers.b) }
      register(0xb9, 4, 1, "CP A,C") { ALUHelpers.sub_flags(Registers.a, Registers.c) }
      register(0xba, 4, 1, "CP A,D") { ALUHelpers.sub_flags(Registers.a, Registers.d) }
      register(0xbb, 4, 1, "CP A,E") { ALUHelpers.sub_flags(Registers.a, Registers.e) }
      register(0xbc, 4, 1, "CP A,H") { ALUHelpers.sub_flags(Registers.a, Registers.h) }
      register(0xbd, 4, 1, "CP A,L") { ALUHelpers.sub_flags(Registers.a, Registers.l) }
      register(0xbe, 8, 1, "CP A,(HL)") { ALUHelpers.sub_flags(Registers.a, MMU.bread(Registers.hl)) }
      register(0xfe, 8, 2, "CP A,n") { ALUHelpers.sub_flags(Registers.a, MMU.bread(Registers.pc)); Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }

      # INC r - Increment register (with wrapping)
      register(0x3c, 4, 1, "INC A") { old = Registers.a; Registers.a = (old.to_i32 + 1) & 0xFF; ALUHelpers.inc_flags(old, Registers.a) }
      register(0x04, 4, 1, "INC B") { old = Registers.b; Registers.b = (old.to_i32 + 1) & 0xFF; ALUHelpers.inc_flags(old, Registers.b) }
      register(0x0c, 4, 1, "INC C") { old = Registers.c; Registers.c = (old.to_i32 + 1) & 0xFF; ALUHelpers.inc_flags(old, Registers.c) }
      register(0x14, 4, 1, "INC D") { old = Registers.d; Registers.d = (old.to_i32 + 1) & 0xFF; ALUHelpers.inc_flags(old, Registers.d) }
      register(0x1c, 4, 1, "INC E") { old = Registers.e; Registers.e = (old.to_i32 + 1) & 0xFF; ALUHelpers.inc_flags(old, Registers.e) }
      register(0x24, 4, 1, "INC H") { old = Registers.h; Registers.h = (old.to_i32 + 1) & 0xFF; ALUHelpers.inc_flags(old, Registers.h) }
      register(0x2c, 4, 1, "INC L") { old = Registers.l; Registers.l = (old.to_i32 + 1) & 0xFF; ALUHelpers.inc_flags(old, Registers.l) }
      register(0x34, 12, 1, "INC (HL)") { old = MMU.bread(Registers.hl); MMU.bwrite(Registers.hl, old + 1); ALUHelpers.inc_flags(old, MMU.bread(Registers.hl)) }

      # DEC r - Decrement register (with wrapping)
      register(0x3d, 4, 1, "DEC A") { old = Registers.a; Registers.a = (old.to_i32 - 1) & 0xFF; ALUHelpers.dec_flags(old, Registers.a) }
      register(0x05, 4, 1, "DEC B") { old = Registers.b; Registers.b = (old.to_i32 - 1) & 0xFF; ALUHelpers.dec_flags(old, Registers.b) }
      register(0x0d, 4, 1, "DEC C") { old = Registers.c; Registers.c = (old.to_i32 - 1) & 0xFF; ALUHelpers.dec_flags(old, Registers.c) }
      register(0x15, 4, 1, "DEC D") { old = Registers.d; Registers.d = (old.to_i32 - 1) & 0xFF; ALUHelpers.dec_flags(old, Registers.d) }
      register(0x1d, 4, 1, "DEC E") { old = Registers.e; Registers.e = (old.to_i32 - 1) & 0xFF; ALUHelpers.dec_flags(old, Registers.e) }
      register(0x25, 4, 1, "DEC H") { old = Registers.h; Registers.h = (old.to_i32 - 1) & 0xFF; ALUHelpers.dec_flags(old, Registers.h) }
      register(0x2d, 4, 1, "DEC L") { old = Registers.l; Registers.l = (old.to_i32 - 1) & 0xFF; ALUHelpers.dec_flags(old, Registers.l) }
      register(0x35, 12, 1, "DEC (HL)") { old = MMU.bread(Registers.hl); MMU.bwrite(Registers.hl, old - 1); ALUHelpers.dec_flags(old, MMU.bread(Registers.hl)) }
    end

    private def self.init_alu_16bit
      # ADD HL,rr - Add 16-bit register pair to HL (affects N, H, C flags, NOT Z)
      register(0x09, 8, 1, "ADD HL,BC") { old = Registers.hl; Registers.hl = ((old.to_u32 + Registers.bc.to_u32) & 0xFFFF).to_u16!; ALUHelpers.add_16bit_flags(old, Registers.bc) }
      register(0x19, 8, 1, "ADD HL,DE") { old = Registers.hl; Registers.hl = ((old.to_u32 + Registers.de.to_u32) & 0xFFFF).to_u16!; ALUHelpers.add_16bit_flags(old, Registers.de) }
      register(0x29, 8, 1, "ADD HL,HL") { old = Registers.hl; Registers.hl = ((old.to_u32 + old.to_u32) & 0xFFFF).to_u16!; ALUHelpers.add_16bit_flags(old, old) }
      register(0x39, 8, 1, "ADD HL,SP") { old = Registers.hl; Registers.hl = ((old.to_u32 + Registers.sp.to_u32) & 0xFFFF).to_u16!; ALUHelpers.add_16bit_flags(old, Registers.sp) }

      # ADD SP,n - Add signed 8-bit immediate to SP (sets Z=0, affects N, H, C)
      register(0xe8, 16, 2, "ADD SP,n") {
        offset = MMU.bread(Registers.pc, signed: true)
        old = Registers.sp
        Registers.sp = (old + offset) & 0xFFFF
        ALUHelpers.add_16bit_flags(old, offset, set_z_to_zero: true)
        Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF)
      }

      # INC rr - Increment 16-bit register pair (NO flags affected)
      register(0x03, 8, 1, "INC BC") { Registers.bc = ((Registers.bc.to_i32 + 1) & 0xFFFF) }
      register(0x13, 8, 1, "INC DE") { Registers.de = ((Registers.de.to_i32 + 1) & 0xFFFF) }
      register(0x23, 8, 1, "INC HL") { Registers.hl = ((Registers.hl.to_i32 + 1) & 0xFFFF) }
      register(0x33, 8, 1, "INC SP") { Registers.sp = ((Registers.sp.to_i32 + 1) & 0xFFFF) }

      # DEC rr - Decrement 16-bit register pair (NO flags affected)
      register(0x0b, 8, 1, "DEC BC") { Registers.bc = ((Registers.bc.to_i32 - 1) & 0xFFFF) }
      register(0x1b, 8, 1, "DEC DE") { Registers.de = ((Registers.de.to_i32 - 1) & 0xFFFF) }
      register(0x2b, 8, 1, "DEC HL") { Registers.hl = ((Registers.hl.to_i32 - 1) & 0xFFFF) }
      register(0x3b, 8, 1, "DEC SP") { Registers.sp = ((Registers.sp.to_i32 - 1) & 0xFFFF) }
    end

    private def self.init_bit
      # BIT b,r - Test bit b in register r (sets Z flag based on bit value)
      # 8 bits × 8 targets = 64 opcodes (0xcb40-0xcb7f)
      {% for bit in 0..7 %}
        # BIT {{bit}},r
        register(0xcb40 + {{bit}} * 8 + 0, 8, 1, "BIT {{bit}},B") { Flags.z = ((Registers.b >> {{bit}}) & 1) == 0 ? 1 : 0; Flags.n = 0; Flags.h = 1 }
        register(0xcb40 + {{bit}} * 8 + 1, 8, 1, "BIT {{bit}},C") { Flags.z = ((Registers.c >> {{bit}}) & 1) == 0 ? 1 : 0; Flags.n = 0; Flags.h = 1 }
        register(0xcb40 + {{bit}} * 8 + 2, 8, 1, "BIT {{bit}},D") { Flags.z = ((Registers.d >> {{bit}}) & 1) == 0 ? 1 : 0; Flags.n = 0; Flags.h = 1 }
        register(0xcb40 + {{bit}} * 8 + 3, 8, 1, "BIT {{bit}},E") { Flags.z = ((Registers.e >> {{bit}}) & 1) == 0 ? 1 : 0; Flags.n = 0; Flags.h = 1 }
        register(0xcb40 + {{bit}} * 8 + 4, 8, 1, "BIT {{bit}},H") { Flags.z = ((Registers.h >> {{bit}}) & 1) == 0 ? 1 : 0; Flags.n = 0; Flags.h = 1 }
        register(0xcb40 + {{bit}} * 8 + 5, 8, 1, "BIT {{bit}},L") { Flags.z = ((Registers.l >> {{bit}}) & 1) == 0 ? 1 : 0; Flags.n = 0; Flags.h = 1 }
        register(0xcb40 + {{bit}} * 8 + 6, 16, 1, "BIT {{bit}},(HL)") { val = MMU.bread(Registers.hl); Flags.z = ((val >> {{bit}}) & 1) == 0 ? 1 : 0; Flags.n = 0; Flags.h = 1 }
        register(0xcb40 + {{bit}} * 8 + 7, 8, 1, "BIT {{bit}},A") { Flags.z = ((Registers.a >> {{bit}}) & 1) == 0 ? 1 : 0; Flags.n = 0; Flags.h = 1 }
      {% end %}

      # RES b,r - Reset (clear) bit b in register r
      # 8 bits × 8 targets = 64 opcodes (0xcb80-0xcbbf)
      {% for bit in 0..7 %}
        # RES {{bit}},r
        register(0xcb80 + {{bit}} * 8 + 0, 8, 1, "RES {{bit}},B") { Registers.b = Registers.b & (0xFF ^ (1 << {{bit}})) }
        register(0xcb80 + {{bit}} * 8 + 1, 8, 1, "RES {{bit}},C") { Registers.c = Registers.c & (0xFF ^ (1 << {{bit}})) }
        register(0xcb80 + {{bit}} * 8 + 2, 8, 1, "RES {{bit}},D") { Registers.d = Registers.d & (0xFF ^ (1 << {{bit}})) }
        register(0xcb80 + {{bit}} * 8 + 3, 8, 1, "RES {{bit}},E") { Registers.e = Registers.e & (0xFF ^ (1 << {{bit}})) }
        register(0xcb80 + {{bit}} * 8 + 4, 8, 1, "RES {{bit}},H") { Registers.h = Registers.h & (0xFF ^ (1 << {{bit}})) }
        register(0xcb80 + {{bit}} * 8 + 5, 8, 1, "RES {{bit}},L") { Registers.l = Registers.l & (0xFF ^ (1 << {{bit}})) }
        register(0xcb80 + {{bit}} * 8 + 6, 16, 1, "RES {{bit}},(HL)") { val = MMU.bread(Registers.hl); MMU.bwrite(Registers.hl, val & (0xFF ^ (1 << {{bit}}))) }
        register(0xcb80 + {{bit}} * 8 + 7, 8, 1, "RES {{bit}},A") { Registers.a = Registers.a & (0xFF ^ (1 << {{bit}})) }
      {% end %}

      # SET b,r - Set bit b in register r
      # 8 bits × 8 targets = 64 opcodes (0xcbc0-0xcbff)
      {% for bit in 0..7 %}
        # SET {{bit}},r
        register(0xcbc0 + {{bit}} * 8 + 0, 8, 1, "SET {{bit}},B") { Registers.b = Registers.b | (1 << {{bit}}) }
        register(0xcbc0 + {{bit}} * 8 + 1, 8, 1, "SET {{bit}},C") { Registers.c = Registers.c | (1 << {{bit}}) }
        register(0xcbc0 + {{bit}} * 8 + 2, 8, 1, "SET {{bit}},D") { Registers.d = Registers.d | (1 << {{bit}}) }
        register(0xcbc0 + {{bit}} * 8 + 3, 8, 1, "SET {{bit}},E") { Registers.e = Registers.e | (1 << {{bit}}) }
        register(0xcbc0 + {{bit}} * 8 + 4, 8, 1, "SET {{bit}},H") { Registers.h = Registers.h | (1 << {{bit}}) }
        register(0xcbc0 + {{bit}} * 8 + 5, 8, 1, "SET {{bit}},L") { Registers.l = Registers.l | (1 << {{bit}}) }
        register(0xcbc0 + {{bit}} * 8 + 6, 16, 1, "SET {{bit}},(HL)") { val = MMU.bread(Registers.hl); MMU.bwrite(Registers.hl, val | (1 << {{bit}})) }
        register(0xcbc0 + {{bit}} * 8 + 7, 8, 1, "SET {{bit}},A") { Registers.a = Registers.a | (1 << {{bit}}) }
      {% end %}
    end

    private def self.init_jumps
      # JP nn - Unconditional jump to 16-bit address
      register(0xc3, 12, 3, "JP nn") { Registers.pc = MMU.wread(Registers.pc) }

      # JP (HL) - Jump to address in HL
      register(0xe9, 4, 1, "JP (HL)") { Registers.pc = Registers.hl }

      # JP cc,nn - Conditional jump based on flags
      register(0xc2, 12, 3, "JP NZ,nn") { Flags.z == 0 ? Registers.pc = MMU.wread(Registers.pc) : Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF) }
      register(0xca, 12, 3, "JP Z,nn") { Flags.z == 1 ? Registers.pc = MMU.wread(Registers.pc) : Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF) }
      register(0xd2, 12, 3, "JP NC,nn") { Flags.c == 0 ? Registers.pc = MMU.wread(Registers.pc) : Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF) }
      register(0xda, 12, 3, "JP C,nn") { Flags.c == 1 ? Registers.pc = MMU.wread(Registers.pc) : Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF) }

      # JR n - Relative jump with signed 8-bit offset
      register(0x18, 8, 2, "JR n") { Registers.pc = (Registers.pc.to_i32 + MMU.bread(Registers.pc, signed: true) + 1) & 0xFFFF }

      # JR cc,n - Conditional relative jump
      register(0x20, 8, 2, "JR NZ,n") { Flags.z == 0 ? Registers.pc = (Registers.pc.to_i32 + MMU.bread(Registers.pc, signed: true) + 1) & 0xFFFF : Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }
      register(0x28, 8, 2, "JR Z,n") { Flags.z == 1 ? Registers.pc = (Registers.pc.to_i32 + MMU.bread(Registers.pc, signed: true) + 1) & 0xFFFF : Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }
      register(0x30, 8, 2, "JR NC,n") { Flags.c == 0 ? Registers.pc = (Registers.pc.to_i32 + MMU.bread(Registers.pc, signed: true) + 1) & 0xFFFF : Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }
      register(0x38, 8, 2, "JR C,n") { Flags.c == 1 ? Registers.pc = (Registers.pc.to_i32 + MMU.bread(Registers.pc, signed: true) + 1) & 0xFFFF : Registers.pc = ((Registers.pc.to_i32 + 1) & 0xFFFF) }
    end

    private def self.init_calls
      # CALL nn - Push PC+2 onto stack, jump to address
      register(0xcd, 12, 3, "CALL nn") {
        Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF)
        MMU.wwrite(Registers.sp, (Registers.pc.to_i32 + 2) & 0xFFFF)
        Registers.pc = MMU.wread(Registers.pc)
      }

      # CALL cc,nn - Conditional call based on flags
      register(0xc4, 12, 3, "CALL NZ,nn") {
        if Flags.z == 0
          Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF)
          MMU.wwrite(Registers.sp, (Registers.pc.to_i32 + 2) & 0xFFFF)
          Registers.pc = MMU.wread(Registers.pc)
        else
          Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF)
        end
      }
      register(0xcc, 12, 3, "CALL Z,nn") {
        if Flags.z == 1
          Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF)
          MMU.wwrite(Registers.sp, (Registers.pc.to_i32 + 2) & 0xFFFF)
          Registers.pc = MMU.wread(Registers.pc)
        else
          Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF)
        end
      }
      register(0xd4, 12, 3, "CALL NC,nn") {
        if Flags.c == 0
          Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF)
          MMU.wwrite(Registers.sp, (Registers.pc.to_i32 + 2) & 0xFFFF)
          Registers.pc = MMU.wread(Registers.pc)
        else
          Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF)
        end
      }
      register(0xdc, 12, 3, "CALL C,nn") {
        if Flags.c == 1
          Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF)
          MMU.wwrite(Registers.sp, (Registers.pc.to_i32 + 2) & 0xFFFF)
          Registers.pc = MMU.wread(Registers.pc)
        else
          Registers.pc = ((Registers.pc.to_i32 + 2) & 0xFFFF)
        end
      }
    end

    private def self.init_returns
      # RET - Pop address from stack and jump to it
      register(0xc9, 8, 1, "RET") {
        destination = MMU.wread(Registers.sp)
        Registers.sp = ((Registers.sp.to_i32 + 2) & 0xFFFF)
        Registers.pc = destination
      }

      # RET cc - Conditional return based on flags
      register(0xc0, 8, 1, "RET NZ") {
        if Flags.z == 0
          destination = MMU.wread(Registers.sp)
          Registers.sp = ((Registers.sp.to_i32 + 2) & 0xFFFF)
          Registers.pc = destination
        end
      }
      register(0xc8, 8, 1, "RET Z") {
        if Flags.z == 1
          destination = MMU.wread(Registers.sp)
          Registers.sp = ((Registers.sp.to_i32 + 2) & 0xFFFF)
          Registers.pc = destination
        end
      }
      register(0xd0, 8, 1, "RET NC") {
        if Flags.c == 0
          destination = MMU.wread(Registers.sp)
          Registers.sp = ((Registers.sp.to_i32 + 2) & 0xFFFF)
          Registers.pc = destination
        end
      }
      register(0xd8, 8, 1, "RET C") {
        if Flags.c == 1
          destination = MMU.wread(Registers.sp)
          Registers.sp = ((Registers.sp.to_i32 + 2) & 0xFFFF)
          Registers.pc = destination
        end
      }

      # RETI - Return and enable interrupts (immediate, no delay)
      register(0xd9, 8, 1, "RETI") {
        destination = MMU.wread(Registers.sp)
        Registers.sp = ((Registers.sp.to_i32 + 2) & 0xFFFF)
        Registers.pc = destination
        IME.enable!  # RETI enables interrupts immediately
      }
    end

    private def self.init_restarts
      # RST n - Push PC onto stack, jump to fixed address
      register(0xc7, 32, 1, "RST 0x00") { Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF); MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x00 }
      register(0xcf, 32, 1, "RST 0x08") { Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF); MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x08 }
      register(0xd7, 32, 1, "RST 0x10") { Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF); MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x10 }
      register(0xdf, 32, 1, "RST 0x18") { Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF); MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x18 }
      register(0xe7, 32, 1, "RST 0x20") { Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF); MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x20 }
      register(0xef, 32, 1, "RST 0x28") { Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF); MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x28 }
      register(0xf7, 32, 1, "RST 0x30") { Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF); MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x30 }
      register(0xff, 32, 1, "RST 0x38") { Registers.sp = ((Registers.sp.to_i32 - 2) & 0xFFFF); MMU.wwrite(Registers.sp, Registers.pc); Registers.pc = 0x38 }
    end

    private def self.init_rotations
      # RLCA - Rotate A left circular (non-CB, special: Z flag always 0)
      register(0x07, 4, 1, "RLCA") {
        bit7 = (Registers.a >> 7) & 1
        Flags.c = bit7
        Registers.a = ((Registers.a << 1) | bit7) & 0xFF
        Flags.z = 0  # Special: RLCA always sets Z=0
        Flags.n = 0
        Flags.h = 0
      }

      # RLA - Rotate A left through carry (non-CB, special: Z flag always 0)
      register(0x17, 4, 1, "RLA") {
        old_c = Flags.c
        Flags.c = (Registers.a >> 7) & 1
        Registers.a = ((Registers.a << 1) | old_c) & 0xFF
        Flags.z = 0  # Special: RLA always sets Z=0
        Flags.n = 0
        Flags.h = 0
      }

      # RRCA - Rotate A right circular (non-CB, special: Z flag always 0)
      register(0x0f, 4, 1, "RRCA") {
        bit0 = Registers.a & 1
        Flags.c = bit0
        Registers.a = ((Registers.a >> 1) | (bit0 << 7)) & 0xFF
        Flags.z = 0  # Special: RRCA always sets Z=0
        Flags.n = 0
        Flags.h = 0
      }

      # RRA - Rotate A right through carry (non-CB, special: Z flag always 0)
      register(0x1f, 4, 1, "RRA") {
        old_c = Flags.c
        Flags.c = Registers.a & 1
        Registers.a = ((Registers.a >> 1) | (old_c << 7)) & 0xFF
        Flags.z = 0  # Special: RRA always sets Z=0
        Flags.n = 0
        Flags.h = 0
      }

      # RLC - Rotate left circular (CB-prefixed, sets Z flag normally)
      register(0xcb07, 8, 1, "RLC A") { bit7 = (Registers.a >> 7) & 1; Flags.c = bit7; Registers.a = ((Registers.a << 1) | bit7) & 0xFF; ALUHelpers.set_zero_flag(Registers.a); Flags.n = 0; Flags.h = 0 }
      register(0xcb00, 8, 1, "RLC B") { bit7 = (Registers.b >> 7) & 1; Flags.c = bit7; Registers.b = ((Registers.b << 1) | bit7) & 0xFF; ALUHelpers.set_zero_flag(Registers.b); Flags.n = 0; Flags.h = 0 }
      register(0xcb01, 8, 1, "RLC C") { bit7 = (Registers.c >> 7) & 1; Flags.c = bit7; Registers.c = ((Registers.c << 1) | bit7) & 0xFF; ALUHelpers.set_zero_flag(Registers.c); Flags.n = 0; Flags.h = 0 }
      register(0xcb02, 8, 1, "RLC D") { bit7 = (Registers.d >> 7) & 1; Flags.c = bit7; Registers.d = ((Registers.d << 1) | bit7) & 0xFF; ALUHelpers.set_zero_flag(Registers.d); Flags.n = 0; Flags.h = 0 }
      register(0xcb03, 8, 1, "RLC E") { bit7 = (Registers.e >> 7) & 1; Flags.c = bit7; Registers.e = ((Registers.e << 1) | bit7) & 0xFF; ALUHelpers.set_zero_flag(Registers.e); Flags.n = 0; Flags.h = 0 }
      register(0xcb04, 8, 1, "RLC H") { bit7 = (Registers.h >> 7) & 1; Flags.c = bit7; Registers.h = ((Registers.h << 1) | bit7) & 0xFF; ALUHelpers.set_zero_flag(Registers.h); Flags.n = 0; Flags.h = 0 }
      register(0xcb05, 8, 1, "RLC L") { bit7 = (Registers.l >> 7) & 1; Flags.c = bit7; Registers.l = ((Registers.l << 1) | bit7) & 0xFF; ALUHelpers.set_zero_flag(Registers.l); Flags.n = 0; Flags.h = 0 }
      register(0xcb06, 16, 1, "RLC (HL)") { val = MMU.bread(Registers.hl); bit7 = (val >> 7) & 1; Flags.c = bit7; result = ((val << 1) | bit7) & 0xFF; MMU.bwrite(Registers.hl, result); ALUHelpers.set_zero_flag(result); Flags.n = 0; Flags.h = 0 }

      # RL - Rotate left through carry (CB-prefixed)
      register(0xcb17, 8, 1, "RL A") { old_c = Flags.c; Flags.c = (Registers.a >> 7) & 1; Registers.a = ((Registers.a << 1) | old_c) & 0xFF; ALUHelpers.set_zero_flag(Registers.a); Flags.n = 0; Flags.h = 0 }
      register(0xcb10, 8, 1, "RL B") { old_c = Flags.c; Flags.c = (Registers.b >> 7) & 1; Registers.b = ((Registers.b << 1) | old_c) & 0xFF; ALUHelpers.set_zero_flag(Registers.b); Flags.n = 0; Flags.h = 0 }
      register(0xcb11, 8, 1, "RL C") { old_c = Flags.c; Flags.c = (Registers.c >> 7) & 1; Registers.c = ((Registers.c << 1) | old_c) & 0xFF; ALUHelpers.set_zero_flag(Registers.c); Flags.n = 0; Flags.h = 0 }
      register(0xcb12, 8, 1, "RL D") { old_c = Flags.c; Flags.c = (Registers.d >> 7) & 1; Registers.d = ((Registers.d << 1) | old_c) & 0xFF; ALUHelpers.set_zero_flag(Registers.d); Flags.n = 0; Flags.h = 0 }
      register(0xcb13, 8, 1, "RL E") { old_c = Flags.c; Flags.c = (Registers.e >> 7) & 1; Registers.e = ((Registers.e << 1) | old_c) & 0xFF; ALUHelpers.set_zero_flag(Registers.e); Flags.n = 0; Flags.h = 0 }
      register(0xcb14, 8, 1, "RL H") { old_c = Flags.c; Flags.c = (Registers.h >> 7) & 1; Registers.h = ((Registers.h << 1) | old_c) & 0xFF; ALUHelpers.set_zero_flag(Registers.h); Flags.n = 0; Flags.h = 0 }
      register(0xcb15, 8, 1, "RL L") { old_c = Flags.c; Flags.c = (Registers.l >> 7) & 1; Registers.l = ((Registers.l << 1) | old_c) & 0xFF; ALUHelpers.set_zero_flag(Registers.l); Flags.n = 0; Flags.h = 0 }
      register(0xcb16, 16, 1, "RL (HL)") { old_c = Flags.c; val = MMU.bread(Registers.hl); Flags.c = (val >> 7) & 1; result = ((val << 1) | old_c) & 0xFF; MMU.bwrite(Registers.hl, result); ALUHelpers.set_zero_flag(result); Flags.n = 0; Flags.h = 0 }

      # RRC - Rotate right circular (CB-prefixed)
      register(0xcb0f, 8, 1, "RRC A") { bit0 = Registers.a & 1; Flags.c = bit0; Registers.a = ((Registers.a >> 1) | (bit0 << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.a); Flags.n = 0; Flags.h = 0 }
      register(0xcb08, 8, 1, "RRC B") { bit0 = Registers.b & 1; Flags.c = bit0; Registers.b = ((Registers.b >> 1) | (bit0 << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.b); Flags.n = 0; Flags.h = 0 }
      register(0xcb09, 8, 1, "RRC C") { bit0 = Registers.c & 1; Flags.c = bit0; Registers.c = ((Registers.c >> 1) | (bit0 << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.c); Flags.n = 0; Flags.h = 0 }
      register(0xcb0a, 8, 1, "RRC D") { bit0 = Registers.d & 1; Flags.c = bit0; Registers.d = ((Registers.d >> 1) | (bit0 << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.d); Flags.n = 0; Flags.h = 0 }
      register(0xcb0b, 8, 1, "RRC E") { bit0 = Registers.e & 1; Flags.c = bit0; Registers.e = ((Registers.e >> 1) | (bit0 << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.e); Flags.n = 0; Flags.h = 0 }
      register(0xcb0c, 8, 1, "RRC H") { bit0 = Registers.h & 1; Flags.c = bit0; Registers.h = ((Registers.h >> 1) | (bit0 << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.h); Flags.n = 0; Flags.h = 0 }
      register(0xcb0d, 8, 1, "RRC L") { bit0 = Registers.l & 1; Flags.c = bit0; Registers.l = ((Registers.l >> 1) | (bit0 << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.l); Flags.n = 0; Flags.h = 0 }
      register(0xcb0e, 16, 1, "RRC (HL)") { val = MMU.bread(Registers.hl); bit0 = val & 1; Flags.c = bit0; result = ((val >> 1) | (bit0 << 7)) & 0xFF; MMU.bwrite(Registers.hl, result); ALUHelpers.set_zero_flag(result); Flags.n = 0; Flags.h = 0 }

      # RR - Rotate right through carry (CB-prefixed)
      register(0xcb1f, 8, 1, "RR A") { old_c = Flags.c; Flags.c = Registers.a & 1; Registers.a = ((Registers.a >> 1) | (old_c << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.a); Flags.n = 0; Flags.h = 0 }
      register(0xcb18, 8, 1, "RR B") { old_c = Flags.c; Flags.c = Registers.b & 1; Registers.b = ((Registers.b >> 1) | (old_c << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.b); Flags.n = 0; Flags.h = 0 }
      register(0xcb19, 8, 1, "RR C") { old_c = Flags.c; Flags.c = Registers.c & 1; Registers.c = ((Registers.c >> 1) | (old_c << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.c); Flags.n = 0; Flags.h = 0 }
      register(0xcb1a, 8, 1, "RR D") { old_c = Flags.c; Flags.c = Registers.d & 1; Registers.d = ((Registers.d >> 1) | (old_c << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.d); Flags.n = 0; Flags.h = 0 }
      register(0xcb1b, 8, 1, "RR E") { old_c = Flags.c; Flags.c = Registers.e & 1; Registers.e = ((Registers.e >> 1) | (old_c << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.e); Flags.n = 0; Flags.h = 0 }
      register(0xcb1c, 8, 1, "RR H") { old_c = Flags.c; Flags.c = Registers.h & 1; Registers.h = ((Registers.h >> 1) | (old_c << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.h); Flags.n = 0; Flags.h = 0 }
      register(0xcb1d, 8, 1, "RR L") { old_c = Flags.c; Flags.c = Registers.l & 1; Registers.l = ((Registers.l >> 1) | (old_c << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.l); Flags.n = 0; Flags.h = 0 }
      register(0xcb1e, 16, 1, "RR (HL)") { old_c = Flags.c; val = MMU.bread(Registers.hl); Flags.c = val & 1; result = ((val >> 1) | (old_c << 7)) & 0xFF; MMU.bwrite(Registers.hl, result); ALUHelpers.set_zero_flag(result); Flags.n = 0; Flags.h = 0 }
    end

    private def self.init_shifts
      # SLA - Shift left arithmetic (bit 0 set to 0)
      register(0xcb27, 8, 1, "SLA A") { Flags.c = (Registers.a >> 7) & 1; Registers.a = (Registers.a << 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.a); Flags.n = 0; Flags.h = 0 }
      register(0xcb20, 8, 1, "SLA B") { Flags.c = (Registers.b >> 7) & 1; Registers.b = (Registers.b << 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.b); Flags.n = 0; Flags.h = 0 }
      register(0xcb21, 8, 1, "SLA C") { Flags.c = (Registers.c >> 7) & 1; Registers.c = (Registers.c << 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.c); Flags.n = 0; Flags.h = 0 }
      register(0xcb22, 8, 1, "SLA D") { Flags.c = (Registers.d >> 7) & 1; Registers.d = (Registers.d << 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.d); Flags.n = 0; Flags.h = 0 }
      register(0xcb23, 8, 1, "SLA E") { Flags.c = (Registers.e >> 7) & 1; Registers.e = (Registers.e << 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.e); Flags.n = 0; Flags.h = 0 }
      register(0xcb24, 8, 1, "SLA H") { Flags.c = (Registers.h >> 7) & 1; Registers.h = (Registers.h << 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.h); Flags.n = 0; Flags.h = 0 }
      register(0xcb25, 8, 1, "SLA L") { Flags.c = (Registers.l >> 7) & 1; Registers.l = (Registers.l << 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.l); Flags.n = 0; Flags.h = 0 }
      register(0xcb26, 16, 1, "SLA (HL)") { val = MMU.bread(Registers.hl); Flags.c = (val >> 7) & 1; result = (val << 1) & 0xFF; MMU.bwrite(Registers.hl, result); ALUHelpers.set_zero_flag(result); Flags.n = 0; Flags.h = 0 }

      # SRA - Shift right arithmetic (bit 7 preserved)
      register(0xcb2f, 8, 1, "SRA A") { msb = (Registers.a >> 7) & 1; Flags.c = Registers.a & 1; Registers.a = ((Registers.a >> 1) | (msb << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.a); Flags.n = 0; Flags.h = 0 }
      register(0xcb28, 8, 1, "SRA B") { msb = (Registers.b >> 7) & 1; Flags.c = Registers.b & 1; Registers.b = ((Registers.b >> 1) | (msb << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.b); Flags.n = 0; Flags.h = 0 }
      register(0xcb29, 8, 1, "SRA C") { msb = (Registers.c >> 7) & 1; Flags.c = Registers.c & 1; Registers.c = ((Registers.c >> 1) | (msb << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.c); Flags.n = 0; Flags.h = 0 }
      register(0xcb2a, 8, 1, "SRA D") { msb = (Registers.d >> 7) & 1; Flags.c = Registers.d & 1; Registers.d = ((Registers.d >> 1) | (msb << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.d); Flags.n = 0; Flags.h = 0 }
      register(0xcb2b, 8, 1, "SRA E") { msb = (Registers.e >> 7) & 1; Flags.c = Registers.e & 1; Registers.e = ((Registers.e >> 1) | (msb << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.e); Flags.n = 0; Flags.h = 0 }
      register(0xcb2c, 8, 1, "SRA H") { msb = (Registers.h >> 7) & 1; Flags.c = Registers.h & 1; Registers.h = ((Registers.h >> 1) | (msb << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.h); Flags.n = 0; Flags.h = 0 }
      register(0xcb2d, 8, 1, "SRA L") { msb = (Registers.l >> 7) & 1; Flags.c = Registers.l & 1; Registers.l = ((Registers.l >> 1) | (msb << 7)) & 0xFF; ALUHelpers.set_zero_flag(Registers.l); Flags.n = 0; Flags.h = 0 }
      register(0xcb2e, 16, 1, "SRA (HL)") { val = MMU.bread(Registers.hl); msb = (val >> 7) & 1; Flags.c = val & 1; result = ((val >> 1) | (msb << 7)) & 0xFF; MMU.bwrite(Registers.hl, result); ALUHelpers.set_zero_flag(result); Flags.n = 0; Flags.h = 0 }

      # SRL - Shift right logical (bit 7 set to 0)
      register(0xcb3f, 8, 1, "SRL A") { Flags.c = Registers.a & 1; Registers.a = (Registers.a >> 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.a); Flags.n = 0; Flags.h = 0 }
      register(0xcb38, 8, 1, "SRL B") { Flags.c = Registers.b & 1; Registers.b = (Registers.b >> 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.b); Flags.n = 0; Flags.h = 0 }
      register(0xcb39, 8, 1, "SRL C") { Flags.c = Registers.c & 1; Registers.c = (Registers.c >> 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.c); Flags.n = 0; Flags.h = 0 }
      register(0xcb3a, 8, 1, "SRL D") { Flags.c = Registers.d & 1; Registers.d = (Registers.d >> 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.d); Flags.n = 0; Flags.h = 0 }
      register(0xcb3b, 8, 1, "SRL E") { Flags.c = Registers.e & 1; Registers.e = (Registers.e >> 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.e); Flags.n = 0; Flags.h = 0 }
      register(0xcb3c, 8, 1, "SRL H") { Flags.c = Registers.h & 1; Registers.h = (Registers.h >> 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.h); Flags.n = 0; Flags.h = 0 }
      register(0xcb3d, 8, 1, "SRL L") { Flags.c = Registers.l & 1; Registers.l = (Registers.l >> 1) & 0xFF; ALUHelpers.set_zero_flag(Registers.l); Flags.n = 0; Flags.h = 0 }
      register(0xcb3e, 16, 1, "SRL (HL)") { val = MMU.bread(Registers.hl); Flags.c = val & 1; result = (val >> 1) & 0xFF; MMU.bwrite(Registers.hl, result); ALUHelpers.set_zero_flag(result); Flags.n = 0; Flags.h = 0 }
    end

    private def self.init_misc
      # NOP - No operation
      register(0x00, 4, 1, "NOP") { }

      # DAA - Decimal Adjust Accumulator (for BCD arithmetic)
      register(0x27, 4, 1, "DAA") {
        a = Registers.a

        if Flags.n == 0  # After addition
          if Flags.c == 1 || a > 0x99
            a += 0x60
            Flags.c = 1
          end
          if Flags.h == 1 || (a & 0x0F) > 0x09
            a += 0x06
          end
        else  # After subtraction
          if Flags.c == 1
            a -= 0x60
          end
          if Flags.h == 1
            a -= 0x06
          end
        end

        Registers.a = a & 0xFF
        Flags.z = Registers.a == 0 ? 1 : 0
        Flags.h = 0
      }

      # CPL - Complement A (flip all bits)
      register(0x2f, 4, 1, "CPL") {
        a_val = Registers.a.to_i32 ^ 0xFF
        Registers.a = a_val & 0xFF
        Flags.n = 1
        Flags.h = 1
      }

      # CCF - Complement Carry Flag
      register(0x3f, 4, 1, "CCF") { Flags.c = Flags.c == 1 ? 0 : 1; Flags.n = 0; Flags.h = 0 }

      # SCF - Set Carry Flag
      register(0x37, 4, 1, "SCF") { Flags.c = 1; Flags.n = 0; Flags.h = 0 }

      # HALT - Halt CPU until interrupt (TODO: implement halt state in emulator)
      register(0x76, 4, 1, "HALT") {
        # TODO: Set CPU_HALTED flag when emulator loop is implemented
      }

      # STOP - Stop CPU and LCD (TODO: implement stop state in emulator)
      register(0x10, 4, 1, "STOP") {
        # TODO: Set CPU_STOPPED flag when emulator loop is implemented
      }

      # DI - Disable interrupts (immediate)
      register(0xf3, 4, 1, "DI") {
        IME.disable!
      }

      # EI - Enable interrupts after next instruction (1-instruction delay)
      register(0xfb, 4, 1, "EI") {
        IME.schedule_enable!
      }

      # SWAP - Swap nibbles of register (CB-prefixed instructions)
      register(0xcb37, 8, 1, "SWAP A") { Registers.a = ((Registers.a & 0xF) << 4) | ((Registers.a & 0xF0) >> 4); ALUHelpers.set_zero_flag(Registers.a); Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      register(0xcb30, 8, 1, "SWAP B") { Registers.b = ((Registers.b & 0xF) << 4) | ((Registers.b & 0xF0) >> 4); ALUHelpers.set_zero_flag(Registers.b); Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      register(0xcb31, 8, 1, "SWAP C") { Registers.c = ((Registers.c & 0xF) << 4) | ((Registers.c & 0xF0) >> 4); ALUHelpers.set_zero_flag(Registers.c); Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      register(0xcb32, 8, 1, "SWAP D") { Registers.d = ((Registers.d & 0xF) << 4) | ((Registers.d & 0xF0) >> 4); ALUHelpers.set_zero_flag(Registers.d); Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      register(0xcb33, 8, 1, "SWAP E") { Registers.e = ((Registers.e & 0xF) << 4) | ((Registers.e & 0xF0) >> 4); ALUHelpers.set_zero_flag(Registers.e); Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      register(0xcb34, 8, 1, "SWAP H") { Registers.h = ((Registers.h & 0xF) << 4) | ((Registers.h & 0xF0) >> 4); ALUHelpers.set_zero_flag(Registers.h); Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      register(0xcb35, 8, 1, "SWAP L") { Registers.l = ((Registers.l & 0xF) << 4) | ((Registers.l & 0xF0) >> 4); ALUHelpers.set_zero_flag(Registers.l); Flags.n = 0; Flags.h = 0; Flags.c = 0 }
      register(0xcb36, 16, 1, "SWAP (HL)") {
        value = MMU.bread(Registers.hl)
        value = ((value & 0xF) << 4) | ((value & 0xF0) >> 4)
        MMU.bwrite(Registers.hl, value)
        ALUHelpers.set_zero_flag(value)
        Flags.n = 0
        Flags.h = 0
        Flags.c = 0
      }
    end
  end
end

# Initialize all instructions when module loads
Gameboy::Instructions.init_all
