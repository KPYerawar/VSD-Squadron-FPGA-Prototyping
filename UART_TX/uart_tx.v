// ============================================================
//  uart_tx.v  —  8N1 UART Transmitter
//  Clock  : 12 MHz
//  Baud   : 9600  →  CLKS_PER_BIT = 12_000_000 / 9_600 = 1250
// ============================================================
//
//  HOW IT WORKS (from scratch explanation):
//  -----------------------------------------
//  UART 8N1 frame = 1 START bit (0) + 8 DATA bits (LSB first) + 1 STOP bit (1)
//
//  We keep a baud counter. Every 1250 clocks = one bit period.
//  A simple FSM walks through: IDLE → START → DATA(0..7) → STOP → IDLE
//
//  Ports:
//    clk       — 12 MHz system clock
//    rst       — active-high synchronous reset
//    tx_start  — pulse high for 1 clock to begin transmission
//    tx_byte   — 8-bit data to send
//    tx_pin    — connect to USB-TTL TX pin
//    tx_busy   — high while transmitting (don't load new data yet)
// ============================================================

module uart_tx (
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_byte,
    output reg        tx_pin,
    output wire       tx_busy
);

    // ---- Parameters ----
    parameter CLKS_PER_BIT = 1250;  // 12_000_000 / 9600

    // ---- FSM states ----
    localparam IDLE  = 3'd0;
    localparam START = 3'd1;
    localparam DATA  = 3'd2;
    localparam STOP  = 3'd3;
    localparam DONE  = 3'd4;

    // ---- Registers ----
    reg [2:0]  state;
    reg [10:0] baud_cnt;   // counts up to CLKS_PER_BIT-1  (needs 11 bits for 1250)
    reg [2:0]  bit_idx;    // which data bit we're sending (0-7)
    reg [7:0]  shift_reg;  // holds the byte being shifted out

    assign tx_busy = (state != IDLE);

    always @(posedge clk) begin
        if (rst) begin
            state    <= IDLE;
            tx_pin   <= 1'b1;   // UART idle line = HIGH
            baud_cnt <= 0;
            bit_idx  <= 0;
            shift_reg<= 0;
        end else begin
            case (state)

                // --------------------------------------------------
                IDLE: begin
                    tx_pin   <= 1'b1;
                    baud_cnt <= 0;
                    bit_idx  <= 0;
                    if (tx_start) begin
                        shift_reg <= tx_byte;   // latch the byte
                        state     <= START;
                    end
                end

                // --------------------------------------------------
                // START bit: pull line LOW for one full bit period
                START: begin
                    tx_pin <= 1'b0;
                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                        baud_cnt <= 0;
                        state    <= DATA;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end

                // --------------------------------------------------
                // DATA bits: send LSB first, 8 bits total
                DATA: begin
                    tx_pin <= shift_reg[0];     // drive current LSB
                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                        baud_cnt  <= 0;
                        shift_reg <= shift_reg >> 1;  // shift next bit into position
                        if (bit_idx == 3'd7) begin
                            bit_idx <= 0;
                            state   <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end

                // --------------------------------------------------
                // STOP bit: drive HIGH for one full bit period
                STOP: begin
                    tx_pin <= 1'b1;
                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                        baud_cnt <= 0;
                        state    <= IDLE;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule
