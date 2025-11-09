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
- **Audio Processing Unit (APU)**: Accurate sound synthesis with proper timing
  - Channel 1: Square wave with frequency sweep, volume envelope, and length counter (fully implemented)
  - Channel 2: Square wave with volume envelope and length counter (fully implemented)
  - Channel 3: Wave pattern RAM (register handling only, synthesis pending)
  - Channel 4: Noise generator (register handling only, synthesis pending)
  - Frame sequencer running at 512 Hz for accurate timing (length/envelope/sweep)
  - DAC enable/disable handling for clean audio output
  - SDL audio output at 48kHz with proper mixing
- **Timer**: Divider and timer registers with interrupts
- **Joypad**: Input handling
- **Interrupts**: VBlank, LCD STAT, Timer, and Joypad interrupts
- **Display**: SDL-based rendering with accurate 59.73 FPS frame rate limiting

**Tested with**: Tetris v1.1

## Known Limitations

- **Audio**: Only channels 1 and 2 (square waves) produce sound. Channels 3 (wave) and 4 (noise) need synthesis implementation
- **Save states**: No save state support
- **Battery RAM**: No battery-backed RAM persistence (games with saves won't persist between sessions)
- **GameBoy Color**: No Game Boy Color support
- **RTC**: Real-time clock in MBC3 not yet ticking (registers implemented but static)

## Logical Next Steps

### Short Term
1. ✅ **Remove remaining test files** - Completed (no test files found)
2. ✅ **Frame rate limiting** - Completed (accurate 59.73 FPS timing)
3. ✅ **Memory Bank Controllers** - Completed (MBC1, MBC3, MBC5 implemented)
4. ✅ **APU register handling** - Completed (all channels and registers implemented)
5. ✅ **Basic audio synthesis** - Completed (channels 1 & 2 working with SDL audio output)
6. ✅ **Audio enhancements** - Completed (frequency sweep, length counters, volume envelopes, DAC control)
7. **Complete audio synthesis**: Implement channels 3 (wave) and 4 (noise)
8. **Test with more ROMs**: Validate with games beyond Tetris (Super Mario Land, Pokemon, Zelda, etc.)
9. **Battery-backed RAM**: Implement save file persistence for MBC1/MBC3/MBC5
10. **RTC implementation**: Add real-time clock ticking for MBC3 games

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
- `src/emulator.cr` - Main emulation loop with frame rate limiting and audio generation
- `src/cpu.cr` / `src/instructions.cr` - CPU implementation
- `src/ppu.cr` - Graphics rendering
- `src/mmu.cr` - Memory management with cartridge and APU routing
- `src/cartridge.cr` - Base cartridge interface
- `src/cartridge_none.cr` - Simple ROM-only cartridges
- `src/cartridge_mbc1.cr` - MBC1 implementation
- `src/cartridge_mbc3.cr` - MBC3 with RTC support
- `src/cartridge_mbc5.cr` - MBC5 implementation
- `src/apu.cr` - Audio Processing Unit (register handling)
- `src/audio_output.cr` - Audio synthesis and SDL audio output
- `src/timer.cr` - Timer and divider registers
- `src/joypad.cr` - Input handling
- `src/display.cr` - SDL display and rendering
- `src/sdl_bindings.cr` - SDL2 library bindings (video and audio)
- `src/rom.cr` / `src/rom_loader.cr` - ROM loading and cartridge detection

## Testing

To compile and test the emulator:

```bash
# Build in release mode
crystal build src/main.cr -o gameboy --release

# Run with Tetris (should have graphics AND sound!)
./gameboy resources/tetris_v1.1.gb
```

**Expected behavior:**
- Window opens showing Tetris gameplay
- Sound plays from channels 1 and 2 (square waves)
- Game runs at proper speed (59.73 FPS)
- Input works (arrow keys for movement, Z/X for A/B buttons)

**Testing audio specifically:**
- Tetris uses channels 1 and 2 extensively for music and sound effects
- You should hear the iconic Tetris theme playing with accurate note lengths and volume fading
- Sound effects should play when moving/rotating pieces and clearing lines
- Audio features working: frequency sweep (pitch bending), volume envelopes (fade in/out), and length counters (note duration)
- If you only see graphics without sound, check that SDL2 audio is working on your system

## Resources

- [Pan Docs](https://gbdev.io/pandocs/) - Comprehensive Game Boy technical reference
- `resources/gbcpuman.pdf` - Game Boy CPU manual
