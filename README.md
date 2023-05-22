## Status

This emulator is still in a non functional state. CPU instruction set should be complete and correct, but
video system and i/o, among other subsystems, are pending to be complete. This is the list of next todo things:

- Display: The first thing to do to be able to see something in the screen is implementing the LCD in-memory 
  registers. The display is supposed to work independently, drawing the screen line by line based on the memory 
  VRAM contents, and while doing so also updating specific memory regions that represent virtual registers 
  (like 0xff40). This must be done correctly because the program relies on those values as a way to synchronize
  status. This goes in hand with having a way to correctly simulate the timing of the hardware.
- Video: Sprites and background / foreground must be supported. Besides virtual registers to control scroll 
  positioning.
- Performance and cycle count: The emulator needs to run at the same speed as the original gameboy. For this, 
  we need to ensure a certain number of cycles executed per second. We have the cycle count per each cpu 
  instruction, but we miss the cycles of memory and register access, which is dynamic.
- Interrupts: The CPU must be able to handle interrupts. This is a very important part of the gameboy, as it 
  is the way the hardware communicates with the CPU. The CPU must be able to handle interrupts, and the 
  hardware must be able to trigger them.
- I/O: Virtual registers for i/o must be implemented and matched with SDL events.


## Resources

- https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
- http://gbdev.gg8.se/files/docs/mirrors/pandocs.html
- http://www.pastraiser.com/cpu/gameboy/gameboy_opcodes.html
- http://imrannazar.com/content/files/jsgb.z80.js
- Z80 CPU user manual (UM0080.pdf): http://www.zilog.com/appnotes_download.php?FromPage=DirectLink&dn=UM0080&ft=User%20Manual&f=YUhSMGNEb3ZMM2QzZHk1NmFXeHZaeTVqYjIwdlpHOWpjeTk2T0RBdlZVMHdNRGd3TG5Ca1pnPT0=
- [GBEmu](https://github.com/DanB91/GBEmu) useful in debug mode to verify this implementation of the CPU