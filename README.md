# Tetris-in-VHDL-on-Basys-3-FPGA

This project is a simple implementation of the classic Tetris game written in VHDL for the Nexys A7 FPGA development board.

The project was developed as part of a university assignment and served as my first larger FPGA/VHDL project. The main goal was to learn digital design, hardware description languages, FPGA development workflows, and VGA graphics generation.

## Features

* VGA video output
* Playable Tetris implementation
* Custom graphics rendering in VHDL
* Score, level, and timer display
* Next-piece preview
* Arcade controller support / Breadboard controller support
* Audio output via piezo buzzer
* Runs directly on FPGA hardware

## Hardware

* Digilent Nexys A7 (Artix-7 FPGA, 100Tcsg324) 
* VGA monitor
* Arcade controller / joystick / Breadboard controller
* Piezo buzzer (optional)

## Development Environment

* Vivado Design Suite
* VHDL
* Artix-7 FPGA

## Project Status

The game is fully functional and can be synthesized and programmed onto the target FPGA.

Please note that this was my first FPGA project. As a result, the code is not heavily optimized and some design decisions were made with learning and experimentation in mind rather than efficiency or best practices.

## Disclaimer

This repository represents a learning project and should not be considered production-quality FPGA code.

There are likely many opportunities for:

* Code cleanup
* Refactoring
* Resource optimization
* Timing improvements
* Better modularization

This project is published for educational purposes.

Feel free to explore, modify, and learn from the code.
