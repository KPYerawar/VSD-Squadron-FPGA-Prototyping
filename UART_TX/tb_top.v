// ============================================================
//  tb_top.v  —  Simulation testbench
//  Run with: iverilog -o sim tb_top.v top.v uart_tx.v && vvp sim
// ============================================================
`timescale 1ns/1ps

module tb_top;

    reg  clk;
    reg  rst_n;
    wire uart_txd;

    // 12 MHz clock → period = 83.33 ns
    initial clk = 0;
    always #41 clk = ~clk;

    top dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .uart_txd(uart_txd)
    );

    // Monitor the TX line and decode bytes
    // At 9600 baud, bit period = 1250 * 83ns ≈ 104166 ns
    real BIT_PERIOD = 104166.0;

    task decode_byte;
        output [7:0] rxbyte;
        integer i;
        reg [7:0] b;
        begin
            // Wait for start bit (falling edge)
            @(negedge uart_txd);
            // Sample in middle of start bit
            #(BIT_PERIOD * 1.5);
            b = 0;
            for (i = 0; i < 8; i = i + 1) begin
                b[i] = uart_txd;
                if (i < 7) #(BIT_PERIOD);
            end
            rxbyte = b;
            // Wait past stop bit
            #(BIT_PERIOD);
        end
    endtask

    integer j;
    reg [7:0] rx;

    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0, tb_top);

        rst_n = 0;
        #500;
        rst_n = 1;

        $display("--- UART RX output ---");
        // Receive 4 numbers × 9 bytes each = 36 bytes
        for (j = 0; j < 36; j = j + 1) begin
            decode_byte(rx);
            $write("%c", rx);
        end
        $display("\n--- Done ---");
        $finish;
    end

endmodule
