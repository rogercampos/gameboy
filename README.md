# Game Boy Emulator

A Game Boy emulator written in Crystal, capable of running simple Game Boy ROMs like Tetris.

## Requirements

- Crystal (latest version)
- SDL2 library

## Building

```bash
crystal build src/main.cr -o gameboy --release
```

## Running

```bash
./gameboy path/to/rom.gb
```

Example with included Tetris ROM:
```bash
./gameboy resources/tetris_v1.1.gb
```

## Current State

This emulator implements the core Game Boy components:
- **CPU**: Full Z80-like instruction set with proper timing
- **Memory Management Unit (MMU)**: Complete memory mapping
- **Picture Processing Unit (PPU)**: Background and sprite rendering
- **Timer**: Divider and timer registers with interrupts
- **Joypad**: Input handling
- **Interrupts**: VBlank, LCD STAT, Timer, and Joypad interrupts
- **Display**: SDL-based rendering

**Tested with**: Tetris v1.1

## Known Limitations

- No sound (APU not implemented)
- No save state support
- Limited cartridge support (MBC1/MBC3/MBC5 not fully implemented)
- No Game Boy Color support
- Frame timing may not be perfectly accurate

## Logical Next Steps

### Short Term
1. **Remove remaining test files**: Clean up `src/test_*.cr` and `src/benchmark_*.cr` files
2. **Frame rate limiting**: Implement proper timing to run at 59.7 FPS
3. **Performance profiling**: Identify and optimize CPU hotspots
4. **Test with more ROMs**: Validate with games beyond Tetris

### Medium Term
5. **Memory Bank Controllers**: Implement MBC1, MBC3, and MBC5 for broader ROM compatibility
6. **Save state support**: Serialize and restore emulator state
7. **Audio Processing Unit (APU)**: Implement all 4 sound channels
8. **Debugger interface**: Add breakpoints, memory viewer, and step execution
9. **Input mapping**: Allow keyboard remapping

### Long Term
10. **Game Boy Color support**: Extend PPU for color palettes and double-speed mode
11. **Link cable emulation**: Support for multiplayer games
12. **Enhanced PPU accuracy**: Fix any remaining rendering glitches
13. **Automated testing**: ROM test suite integration (Blargg's tests, etc.)
14. **Cross-platform builds**: Package for macOS, Linux, and Windows

## Architecture

- `src/main.cr` - Entry point
- `src/emulator.cr` - Main emulation loop
- `src/cpu.cr` / `src/instructions.cr` - CPU implementation
- `src/ppu.cr` - Graphics rendering
- `src/mmu.cr` - Memory management
- `src/timer.cr` - Timer and divider registers
- `src/joypad.cr` - Input handling
- `src/display.cr` - SDL bindings and display

## Resources

- [Pan Docs](https://gbdev.io/pandocs/) - Comprehensive Game Boy technical reference
- `resources/gbcpuman.pdf` - Game Boy CPU manual
