CPU_SPEED = 4194304

class Emulator
  def initialize(rom_path)
    @rom_path = rom_path
  end

  def run!
    rom = Rom.new(File.binread(@rom_path))

    Registers.pc = 0x100

    loop do
      opcode = MMU.read(Registers.pc, 1)
      extended_opcode = [0xcb, 0xed].include?(opcode)
      opcode = (0xcb << 8) + MMU.read(Registers.pc + 1, 1) if extended_opcode

      instruction = Instruction[opcode]
      Registers.pc += 1
      Registers.pc += 1 if extended_opcode # +1 if the current opcode is 2 bytes long

      old_pc = Registers.pc

      instruction.run

      if old_pc == Registers.pc # Skip if the instruction has specifically set the PC.
        # Increment by the number of bytes used for the instruction so we leave PC pointing to the next instruction
        Registers.pc += (instruction.size - 1)
      end

      # sleep
      # interrupts
    end
  end


  private

  def hex_dump(value)
    value.to_s(16).upcase.rjust(2, "0")
  end
end