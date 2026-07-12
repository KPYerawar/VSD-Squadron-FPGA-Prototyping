// ============================================================
// uart_rx.v
// Simple 8N1 UART receiver
// CLK_FREQ / BAUD must give a clean-ish integer divisor
// Default: 12,000,000 / 9600 = 1250 clocks per bit
// ============================================================
module uart_rx #(
    parameter CLK_FREQ = 12_000_000,
    parameter BAUD     = 9600
)(
    input  wire       clk,
    input  wire       rst_n,      // active-low reset
    input  wire       rx,         // serial input pin
    output reg  [7:0] data_out,   // received byte
    output reg        data_valid  // pulses high for 1 clk when data_out is fresh
);

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD;

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0]  state = IDLE;
    reg [10:0] clk_count = 0;   // wide enough for CLKS_PER_BIT (1250 fits in 11 bits)
    reg [2:0]  bit_index = 0;
    reg [7:0]  rx_shift  = 0;

    // 2-flop synchronizer to avoid metastability on the async rx pin
    reg rx_d1 = 1'b1, rx_d2 = 1'b1;
    always @(posedge clk) begin
        rx_d1 <= rx;
        rx_d2 <= rx_d1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            clk_count  <= 0;
            bit_index  <= 0;
            data_valid <= 1'b0;
            data_out   <= 8'd0;
        end else begin
            data_valid <= 1'b0; // default: only pulses in STOP state

            case (state)

                IDLE: begin
                    clk_count <= 0;
                    bit_index <= 0;
                    if (rx_d2 == 1'b0)          // falling edge -> possible start bit
                        state <= START;
                end

                // Verify it's a real start bit by sampling at the middle of it
                START: begin
                    if (clk_count == (CLKS_PER_BIT - 1) >> 1) begin
                        if (rx_d2 == 1'b0) begin
                            clk_count <= 0;
                            state     <= DATA;
                        end else begin
                            state <= IDLE;      // glitch, not a real start bit
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                // Sample each data bit at the middle of its bit period, LSB first
                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count          <= 0;
                        rx_shift[bit_index] <= rx_d2;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1'b1;
                        end else begin
                            bit_index <= 0;
                            state     <= STOP;
                        end
                    end
                end

                STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count  <= 0;
                        data_out   <= rx_shift;
                        data_valid <= 1'b1;
                        state      <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
