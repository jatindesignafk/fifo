This project implements a parameterized synchronous FIFO (First-In-First-Out) buffer in Verilog. The design supports configurable data width and depth, making it flexible for various digital system applications such as buffering, data streaming, and clock-domain interfacing (within a single clock domain).

The FIFO uses separate read and write pointers with an extra MSB bit to efficiently determine full and empty conditions. Data is written and read on the rising edge of the clock when enabled through control signals. The design also includes a chip select (cs) control, allowing conditional operation of the FIFO.

Key features include reliable pointer-based control logic, prevention of overflow/underflow through full and empty flags, and clean synchronous operation with an active-low reset.

🔧 Features
Parameterized DATA_WIDTH and FIFO_DEPTH
Synchronous read and write operations
Full and empty flag generation using pointer comparison
Active-low reset (reset_n)
Chip select (cs) for controlled access
Simple and efficient hardware implementation

🚀 Use Cases
Data buffering in digital systems
Communication between modules
Queue implementation in FPGA/ASIC designs
