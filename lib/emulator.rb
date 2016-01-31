CPU_SPEED = 4194304

class Emulator
  def initialize(rom_path)
    @rom_path = rom_path
  end

  def run!
    rom = Rom.new(File.binread(@rom_path))
    RomLoader.new(rom).load!

    loop do
      opcode = MMU.bread(Registers.pc)
      extended_opcode = [0xcb, 0xed].include?(opcode)
      opcode = (0xcb << 8) + MMU.bread(Registers.pc + 1) if extended_opcode

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
end