`timescale 1ns / 1ns

module tb_fifo_sync;

    // Parameters
    parameter FIFO_DEPTH = 8;
    parameter DATA_WIDTH = 32;

    // Testbench Signals
    reg                   clk;
    reg                   reset_n;
    reg                   cs;
    reg                   wr_en;
    reg                   rd_en;
    reg  [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire                  empty;
    wire                  full;

    integer i;

    // Instantiate the Device Under Test (DUT)
    fifo_sync #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .cs(cs),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .empty(empty),
        .full(full)
    );

    // ---------------------------------------------------------
    // CLOCK GENERATION (10ns Period)
    // ---------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---------------------------------------------------------
    // WRITE DATA TASK
    // ---------------------------------------------------------
    task write_data(input [DATA_WIDTH-1:0] d_in);
        begin
            @(posedge clk);
            cs = 1;
            wr_en = 1;
            data_in = d_in;
            $display("Writing Data: %d", d_in);
            
            @(posedge clk);
            wr_en = 0; // Drop enable after 1 clock cycle
        end
    endtask

    // ---------------------------------------------------------
    // READ DATA TASK
    // ---------------------------------------------------------
    task read_data();
        begin
            @(posedge clk);
            cs = 1;
            rd_en = 1;
            
            @(posedge clk);
            rd_en = 0; // Drop enable after 1 clock cycle
            $display("Read Data: %d", data_out);
        end
    endtask

    // ---------------------------------------------------------
    // TEST SCENARIOS
    // ---------------------------------------------------------
    initial begin
        // Initialize Inputs
      $dumpfile("dump.vcd"); $dumpvars;
        reset_n = 0;
        cs = 0;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        // Release reset
        #15 reset_n = 1;

        // -----------------------------------------------------
        $display("\n--- SCENARIO 1: Write 3 values, Read 3 values ---");
        write_data(1);
        write_data(10);
        write_data(100);
        
        #20; // Small delay
        
        read_data();
        read_data();
        read_data();

        // -----------------------------------------------------
        $display("\n--- SCENARIO 2: Back-to-Back Write and Read ---");
        // Verify that the FIFO handles continuous throughput without triggering FULL
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            write_data(2 ** i); // 1, 2, 4, 8...
            read_data();
        end

        // -----------------------------------------------------
        $display("\n--- SCENARIO 3: Fill FIFO to max depth to trigger FULL ---");
        // Write until depth is reached
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            write_data(i * 10);
        end
        
        // Attempt to write ONE MORE value to verify it gets rejected due to FULL condition
        $display("Attempting to write 999 into FULL FIFO...");
        write_data(999); 

        #20;

        $display("\n--- SCENARIO 4: Read until EMPTY is triggered ---");
        // Read out all data to verify sequence and empty flag
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            read_data();
        end
        
        // Attempt to read one more time when empty
        $display("Attempting to read from EMPTY FIFO...");
        read_data();

        #50;
        $display("\n--- Simulation Complete ---");
        $finish;
    end

endmodule