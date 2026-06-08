# FPGA UART Hexadecimal Number Transmitter

A Verilog-based FPGA project that reads a set of predefined 32-bit hexadecimal numbers, converts each nibble into its corresponding ASCII character representation, and transmits them sequentially over a UART interface followed by a newline (`\n`) character.

The design is optimized for Lattice iCE40 FPGAs, utilizing the internal high-frequency oscillator (`SB_HFOSC`).

## Features

* **Internal Oscillator Integration:** Utilizes the iCE40 hard IP block `SB_HFOSC` configured with a clock divider (`0b10`) to generate the system clock.
* **Dynamic ASCII Conversion:** Features a hardware function to convert 4-bit nibbles into standard ASCII characters (`0-9`, `A-F`) on the fly.
* **Robust Finite State Machine (FSM):** Orchestrates data loading, nibble slicing, UART handshaking, and index tracking.
* **Configurable UART TX Core:** A parameterized transmitter subsystem running with customizable clock cycles per bit (`CLKS_PER_BIT`).

---

## Architecture Overview

### Top Module (`top.v`)
The top-level module hosts the FSM and handles the slicing of the 32-bit values. Data is processed from the most significant nibble to the least significant nibble, totaling 8 characters per number, followed by an ASCII line feed character (`8'h0A`).

The system cycles through the following internal memory array:
* `32'hDEAD_BEEF`
* `32'hCAFE_BABE`
* `32'h1234_5678`
* `32'hAABB_CCDD`

### UART TX Module (`uart_tx.v`)
A standard serial transmitter implementing standard 8N1 UART framing (1 start bit, 8 data bits, 1 stop bit).

* **Default `CLKS_PER_BIT`**: `1250`
* **Bit Transmission Order**: Least Significant Bit (LSB) first.

---

## State Machines

### Top Controller FSM
1.  **`S_LOAD`**: Fetches the current 32-bit word from the target array index.
2.  **`S_PREP`**: Extracts the active 4-bit nibble using indexed part-select operations and maps it to ASCII, or prepares a newline character if all 8 hex digits have been transferred.
3.  **`S_START`**: Asserts the transmission start handshake signal once the UART module drops its busy flag.
4.  **`S_WAIT`**: Holds until the UART transmitter module completes processing the current byte.
5.  **`S_NEXT`**: Increments byte indices or steps forward to the next 32-bit word, routing back to `S_LOAD` or terminating at `S_DONE`.
6.  **`S_DONE`**: Idle terminal state reached after all four numbers are transmitted.

### UART Transmitter FSM
* **`IDLE`**: Awaits the assertion of `tx_start`.
* **`START`**: Pulls `tx_pin` LOW for one bit period.
* **`DATA`**: Serializes the 8-bit register payload via right-shifting over 8 successive bit periods.
* **`STOP`**: Returns `tx_pin` HIGH for one bit period to frame the completion of the payload transaction.

---

## Interface Signals

### `top` Connections

| Signal Name | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `rst_n` | Input | wire | Active-low asynchronous master system reset |
| `uart_txd` | Output | wire | Serial TX pin connected to target host/transceiver |

### `uart_tx` Parameters & Ports

| Component | Direction/Type | Description |
| :--- | :--- | :--- |
| `CLKS_PER_BIT` | Parameter | Clock cycles per serial bit width ($Clock\_Rate / Baud\_Rate$) |
| `clk` | Input | System master clock input |
| `rst` | Input | Active-high synchronous module reset |
| `tx_start` | Input | Single-cycle strobe triggering byte serialization |
| `tx_byte[7:0]` | Input | 8-bit ASCII character data value to transmit |
| `tx_pin` | Output | Serial communication line |
| `tx_busy` | Output | Status flag indicating active serial transmission |
