# VHDL 16-to-32-bit Barrel Shifter

A high-performance barrel shifter designed in VHDL that can perform arithmetic and logical shifts on a 16-bit value in a single clock cycle.
*THIS WAS DONE AS A GROUP EFFORT WITH CLASSMATES*

> The block diagram illustrating the architecture of the barrel shifter.

---

## Overview

This project implements a 16-to-32-bit barrel shifter, a crucial component in modern processor architectures used for fast bit manipulation and arithmetic operations. The design, written entirely in VHDL, can shift a 16-bit input value by a signed 8-bit offset in just a single clock cycle. The shifter's behavior is controlled by several inputs, including a control code for the shift amount, a bit to select between arithmetic and logical shifts, and a reference bit to position the output. The design was validated through simulation in ModelSim and successfully demonstrated on a DE1-SoC FPGA board.

---

## Features

- **High-Speed Shifting**: The core architecture is designed to perform a complete shift operation within a single clock cycle, making it highly efficient.

- **Arithmetic & Logical Shifts**: Supports both arithmetic shifts, which preserve the sign bit of the input, and logical shifts, which fill with zeros.

- **Flexible Control**: The shift amount and direction are determined by a signed 8-bit control code. A HI/LO reference bit controls whether the 16-bit input is treated as the upper or lower half of a 32-bit word.

- **Modular Design**: The system is built structurally from several smaller VHDL components, including registers, multiplexers, a core shift\_array, an OR/PASS logic unit, and tristate buffers.

- **Shared Bus Integration**: Uses tristate buffers to allow the final output registers to write results back onto shared data buses, a common and essential feature in processor design.

---

## How It Works

The barrel shifter's architecture routes data through several stages to perform the shift operation:

### Input Stage

A 16-bit value is loaded into an input register (SI Register).

### Mux and Shift Array

A multiplexer selects the data to be shifted, which is then fed into the core `shift_array` module. This module performs the actual bit shift based on the 8-bit signed control code and the `ar_lo` bit (for arithmetic/logical shift).

### OR/PASS Logic

The 32-bit output from the shift array is routed to an OR/PASS unit. This unit can either pass the shifted result through directly or perform a bitwise OR operation with a value from the output registers.

### Output Registers

The final 32-bit result is captured in two 16-bit output registers (`SR0` and `SR1`).

### Tristate Buffers

These buffers control access to the shared data buses (`DMD` and `R`), allowing the output registers to write their values back onto the bus when enabled.

---

## Code Snippet: OR/PASS Logic

This VHDL process from the `or_pass32` component shows how the `SROR` signal is used to select between passing the shifter's result through (PASS mode) or combining it with the existing register value (OR mode).

```vhdl
process
    variable temp_result: std_logic_vector(31 downto 0);
begin
    if SROR = '0' then
        -- OR Mode: Combine the input with the shifter result
        temp_result := A or B;
    else
        -- PASS Mode: Pass the shifter result directly
        temp_result := B;
    end if;

    upper <= temp_result(31 downto 16);
    lower <= temp_result(15 downto 0);
    wait on A, B, SROR;
end process;
```

---

## Technologies Used

- **Language**: VHDL
- **Software**: ModelSim, Quartus Prime
- **Hardware**: DE1-SoC Board
- **Core Concepts**: Barrel Shifters, Arithmetic & Logical Shifts, Processor Architecture, Modular Design, Tristate Buffers, Bus Management

---

## Getting Started

### Prerequisites

- Quartus Prime software for compiling the VHDL code
- A DE1-SoC FPGA board for hardware implementation

### Installation & Execution

1. **Clone the Repository**: Download or clone the project files.
2. **Open in Quartus**: Open the Quartus project file (`.qpf`).
3. **Compile the Design**: Run the compilation process in Quartus to synthesize the design and generate a `.sof` (SRAM Object File).
4. **Program the FPGA**: Use the Quartus Programmer to upload the generated `.sof` file to the DE1-SoC board.
5. **Test the Shifter**: Use the onboard switches to provide the input value, control code, and other select bits to observe the shifted result on the 7-segment displays and LEDs.

