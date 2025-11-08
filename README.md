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
- **Memory Management Unit (MMU)**: Complete memory mapping with cartridge support
- **Memory Bank Controllers**: MBC1, MBC3, and MBC5 implementations for broader ROM compatibility
- **Picture Processing Unit (PPU)**: Background and sprite rendering with accurate timing
- **Audio Processing Unit (APU)**: All 4 sound channels with proper register handling (audio output pending)
- **Timer**: Divider and timer registers with interrupts
- **Joypad**: Input handling
- **Interrupts**: VBlank, LCD STAT, Timer, and Joypad interrupts
- **Display**: SDL-based rendering with accurate 59.73 FPS frame rate limiting

**Tested with**: Tetris v1.1

## Known Limitations

- No audio output (APU registers implemented, but sound synthesis not yet connected to audio device)
- No save state support
- No battery-backed RAM persistence (games with saves won't persist between sessions)
- No Game Boy Color support
- Real-time clock (RTC) in MBC3 not yet ticking (registers implemented but static)

## Logical Next Steps

### Short Term
1. ✅ **Remove remaining test files** - Completed (no test files found)
2. ✅ **Frame rate limiting** - Completed (accurate 59.73 FPS timing)
3. ✅ **Memory Bank Controllers** - Completed (MBC1, MBC3, MBC5 implemented)
4. ✅ **APU register handling** - Completed (all channels and registers implemented)
5. **Test with more ROMs**: Validate with games beyond Tetris (Super Mario Land, Pokemon, Zelda, etc.)
6. **Audio synthesis**: Connect APU to SDL audio for actual sound output
7. **Battery-backed RAM**: Implement save file persistence for MBC1/MBC3/MBC5
8. **RTC implementation**: Add real-time clock ticking for MBC3 games

### Medium Term
9. **Save state support**: Serialize and restore emulator state
10. **Performance profiling**: Identify and optimize CPU hotspots
11. **Debugger interface**: Add breakpoints, memory viewer, and step execution
12. **Input mapping**: Allow keyboard remapping
13. **Additional MBC types**: MBC2, MBC6, MBC7 for even broader compatibility

### Long Term
10. **Game Boy Color support**: Extend PPU for color palettes and double-speed mode
11. **Link cable emulation**: Support for multiplayer games
12. **Enhanced PPU accuracy**: Fix any remaining rendering glitches
13. **Automated testing**: ROM test suite integration (Blargg's tests, etc.)
14. **Cross-platform builds**: Package for macOS, Linux, and Windows

## Architecture

- `src/main.cr` - Entry point
- `src/emulator.cr` - Main emulation loop with frame rate limiting
- `src/cpu.cr` / `src/instructions.cr` - CPU implementation
- `src/ppu.cr` - Graphics rendering
- `src/mmu.cr` - Memory management with cartridge routing
- `src/cartridge.cr` - Base cartridge interface
- `src/cartridge_none.cr` - Simple ROM-only cartridges
- `src/cartridge_mbc1.cr` - MBC1 implementation
- `src/cartridge_mbc3.cr` - MBC3 with RTC support
- `src/cartridge_mbc5.cr` - MBC5 implementation
- `src/apu.cr` - Audio Processing Unit (register handling)
- `src/timer.cr` - Timer and divider registers
- `src/joypad.cr` - Input handling
- `src/display.cr` - SDL bindings and display
- `src/rom.cr` / `src/rom_loader.cr` - ROM loading and cartridge detection

## Resources

- [Pan Docs](https://gbdev.io/pandocs/) - Comprehensive Game Boy technical reference
- `resources/gbcpuman.pdf` - Game Boy CPU manual
