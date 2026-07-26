# degen

`degen` is FPGA-based programmable delay/pulse generator (hence the name `degen`) for photoacoustic imaging, synchronized to a portable ultrasound system's (us4r) `TrigOut` signal. Generates two (soon three) independently-timed pulse outputs per trigger, driving separate laser wavelength channels, with register configuration over SPI from an MCU. ***Based on the DG535 digital pulse generator***

## Motivation
I'm building this to a). **_reduce hardware footprint for my research project_** and b). _to increase my understading of different types of hardware and how they work at a fundamental level_.

### FPGA vs. MCU in this case
This task can easily be done using a standard MCU, like an STM32 or an Arduino, but, _in this case_, **using an FPGA guarantees minimal jitter** (on the order of picoseconds) vs MCUs (which can range up to high microseconds territory if using software interrupts). _(That being said, a bare-metal implementation of the interrupts in software would suffice and be much easier to program and maintain.)_

But the main motivator was that I thought it would be cooler to implement it on an FPGA. When I first got to work with the DG535, the first thought I had was to replicate this using an FPGA, so here we are!

## Completed

- [x] Identified and fixed the core single-FSM trigger-drop bug (channel `t_cycle` exceeding the trigger period caused every-other trigger to be silently ignored)
- [x] Implemented parity-based channel routing (`sel` toggle gating `is_posedge` per channel) so AB fires on even triggers and CD fires on odd triggers, without the two channels' `RUNNING` states colliding
- [x] **Add a second top module (or extend the existing one) for a third pulse lane (tE/tF).** Decide whether this stays a hand-wired third channel (matching the current AB/CD style).
- [x] **Add bitmask trigger functionality.** Generalize the parity routing into a programmable accept/drop pattern per channel (`bitmask`/`bitmask_AB`/`bitmask_CD` over a configurable period N), so trigger-acceptance schemes can be reconfigured without resynthesizing.

The core delay logic is complete as of this writing. ***The communication logic remains.*** 

## TODO

- [ ] **Add CDC for MCU–FPGA communication, and verify it.** Communication is over the SPI protocol -> data over SPI is written into a regfile with crucial timing information (in the process of verification)
- [ ] **Write pin assignments and constraints.**
- [ ] **Write an explanation in `README.md` as to how the triggers are generated**