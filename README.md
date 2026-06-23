# Tetris-in-VHDL-on-Digilent-Nexys-A7-FPGA

This project is a simple implementation of the classic Tetris game written in VHDL for the Nexys A7 FPGA development board.

The project was developed as part of a university assignment and served as my first larger FPGA/VHDL project. The main goal was to learn digital design, hardware description languages, FPGA development workflows, and VGA graphics generation.

<img width="8160" height="3768" alt="20260623_133131" src="https://github.com/user-attachments/assets/28c67cc1-1e96-463c-8a81-412b19dab9c2" />
<img width="881" height="400" alt="Tetris_Controller" src="https://github.com/user-attachments/assets/6afcdc48-466a-4f4f-b482-eca15e732485" />


## Features

* VGA video output (640x480, 60Hz)
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
