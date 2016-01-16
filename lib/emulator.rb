CPU_SPEED = 4194304

class Emulator
  def initialize(rom_path)
    @rom_path = rom_path
  end

  def run!
    rom = Rom.new(File.binread(@rom_path))

    Registers.pc = 0x100

    loop do
      instruction = Instruction[Registers.pc]
      Registers.pc += 1
      old_pc = Registers.pc
      instruction.run
      Registers.pc += (instruction.size - 1) if old_pc == Registers.pc # Skip if the instruction has specifically set the PC.

      # sleep
      # interrupts
    end

    # loop do
    # Read opcode pointed by PC
    # Get opcode info: Number of cycles, bytes taken by the current instruction (1, 2 or 3 bytes)
    # Increment PC by 1. Do this before execution so any program reads PC with the expected value, since this is the default behaviour in the hardware.
    # Tell CPU to execute the opcode.
    # Increment PC +1 or +2 depending on the length of the instruction processed
    # Sleep to adjust to opcode cycles

    # Execute interrupts
    # end
  end


  private

  def hex_dump(value)
    value.to_s(16).upcase.rjust(2, "0")
  end
end