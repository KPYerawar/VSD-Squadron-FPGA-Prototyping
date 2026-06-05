# VSD-Squadron-FPGA-Prototyping
# VSD Squadron FPGA Prototyping

This repository documents my hands-on FPGA prototyping journey using the **VSD Squadron FM FPGA Board** based on the **Lattice iCE40UP5K FPGA**.

The objective of this repository is to learn FPGA development from the ground up by implementing, testing, and documenting digital hardware designs using **Verilog HDL** and the open-source FPGA toolchain.

---

## About This Repository

This is a day-by-day FPGA development log where each folder contains:

* Verilog source code
* Constraint (PCF) files
* Build flow and commands
* Experimental notes
* Hardware setup images
* Working demonstration videos
* Observations and learnings

The repository is intended to track my FPGA learning progress while building a strong foundation in digital design, hardware verification, and FPGA prototyping.

---

## FPGA Board

**Board:** VSD Squadron FM

**FPGA:** Lattice iCE40UP5K

**Toolchain:**

* Yosys (Synthesis)
* NextPNR (Place and Route)
* IcePack (Bitstream Generation)
* IceProg (Programming)

**Development Environment:**

* Ubuntu Linux
* Verilog HDL

---

## Learning Objectives

* FPGA Bring-up
* GPIO Interfacing
* Push Button Inputs
* LED Control
* Counters and Timers
* Finite State Machines (FSM)
* UART Communication
* SPI Communication
* I2C Communication
* Memory Design
* FIFO Design
* RISC-V Integration
* Hardware Accelerator Development

---

## Repository Structure

```text
VSD-Squadron-FPGA-Prototyping
│
├── Day_01
├── Day_02
├── Day_03
├── Day_04
├── Day_05
│
├── docs
├── images
├── videos
│
└── README.md
```

Each day's work is organized into separate folders containing source code, documentation, images, and hardware demonstrations.

---

## Development Flow

```text
Verilog RTL
      ↓
Synthesis (Yosys)
      ↓
JSON Netlist
      ↓
Place & Route (NextPNR)
      ↓
ASC File
      ↓
Bitstream Generation (IcePack)
      ↓
BIN File
      ↓
Programming (IceProg)
      ↓
FPGA Hardware
```

---

## Documentation

Every experiment includes:

* Objective
* Verilog Source Code
* Constraint Files
* Build Commands
* Hardware Images
* Working Videos
* Results and Observations

This allows complete reproducibility of the FPGA implementation process.

---

## Current Progress

* FPGA Toolchain Setup
* FPGA Bring-up
* Internal Oscillator Configuration
* LED Blink Design
* GPIO Output Verification
* Push Button Input Testing

More experiments and projects will be added continuously.

---

## Future Work

* LED Toggle using Push Button
* Debouncing
* UART Transmitter
* UART Receiver
* SPI Master
* I2C Master
* FIFO Design
* RISC-V Peripherals
* FPGA-Based Hardware Accelerators

---

## Goal

The long-term goal of this repository is to develop strong FPGA design skills and build a foundation for advanced projects involving custom processors, digital communication systems, and AI hardware acceleration.

This repository serves as a practical record of my FPGA prototyping and learning journey.
