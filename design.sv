`timescale 1ns / 1ps

module fifo_sync #(
    parameter FIFO_DEPTH = 8,
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  reset_n,  // Active low reset
    input  wire                  cs,       // Chip select
    input  wire                  wr_en,    // Write enable
    input  wire                  rd_en,    // Read enable
    input  wire [DATA_WIDTH-1:0] data_in,  // Data input
    output reg  [DATA_WIDTH-1:0] data_out, // Data output
    output wire                  empty,    // FIFO empty flag
    output wire                  full      // FIFO full flag
);

    // Calculate the number of bits needed for the memory address
    localparam FIFO_DEPTH_LOG = $clog2(FIFO_DEPTH);

    // Memory array declaration
    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];

    // Pointers with 1 extra bit (MSB) for full/empty condition checking
    // E.g., for depth 8, $clog2(8) = 3. Pointer size is [3:0] (4 bits total)
    reg [FIFO_DEPTH_LOG:0] wr_ptr;
    reg [FIFO_DEPTH_LOG:0] rd_ptr;

    // ---------------------------------------------------------
    // WRITE OPERATION
    // ---------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wr_ptr <= 0;
        end else begin
            if (cs && wr_en && !full) begin
                // Write data to the location pointed to by the lower bits of wr_ptr
                fifo_mem[wr_ptr[FIFO_DEPTH_LOG-1:0]] <= data_in;
                // Increment write pointer
                wr_ptr <= wr_ptr + 1;
            end
        end
    end

    // ---------------------------------------------------------
    // READ OPERATION
    // ---------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rd_ptr <= 0;
            data_out <= 0; // Optional: clear output on reset
        end else begin
            if (cs && rd_en && !empty) begin
                // Read data from the location pointed to by the lower bits of rd_ptr
                data_out <= fifo_mem[rd_ptr[FIFO_DEPTH_LOG-1:0]];
                // Increment read pointer
                rd_ptr <= rd_ptr + 1;
            end
        end
    end

    // ---------------------------------------------------------
    // EMPTY AND FULL FLAG LOGIC
    // ---------------------------------------------------------
    
    // Empty: True when both pointers are exactly equal
    assign empty = (wr_ptr == rd_ptr);

    // Full: True when lower bits match, but the extra MSB is inverted
    assign full = (wr_ptr == {~rd_ptr[FIFO_DEPTH_LOG], rd_ptr[FIFO_DEPTH_LOG-1:0]});

endmodule