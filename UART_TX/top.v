// ============================================================
//  top.v  —  Send 4 × 32-bit numbers over UART (8N1, 9600 baud)
//  Target : VSDSquadron FM Mini  (12 MHz oscillator)
//
//  What gets printed on your PC terminal:
//    DEADBEEF
//    CAFEBABE
//    12345678
//    AABBCCDD
//
//  Each 32-bit number → 8 hex ASCII characters + newline = 9 bytes
//  Total bytes sent = 4 × 9 = 36 bytes, then it stops.
//
//  FIXES applied vs original:
//  [1] CLKHF_DIV changed from "0b10" (÷4 = 3 MHz) to "0b00" (÷1 = 12 MHz)
//      so CLKS_PER_BIT=1250 now correctly gives 9600 baud.
//  [2] S_WAIT race fixed: added S_WAITDONE state so FSM waits for tx_busy
//      to actually assert before checking for de-assertion.
//  [3] Variable part-select in S_PREP replaced with explicit case statement
//      for clean Yosys/iCE40 synthesis.
// ============================================================

module top (
    input  wire rst_n,    // active-low reset (push button)
    output wire uart_txd  // connect to USB-TTL RX pin
);

    // ---- 12 MHz internal oscillator ----
    wire clk;
    SB_HFOSC osc_int (
        .CLKHFPU (1'b1),
        .CLKHFEN (1'b1),
        .CLKHF   (clk)
    );
    defparam osc_int.CLKHF_DIV = "0b00";   // FIX 1: divide-by-1 → 12 MHz
                                            // "0b10" was divide-by-4 → 3 MHz (WRONG)

    // ---- The 4 numbers to transmit ----
    wire [31:0] numbers [0:3];
    assign numbers[0] = 32'hDEAD_BEEF;
    assign numbers[1] = 32'hCAFE_BABE;
    assign numbers[2] = 32'h1234_5678;
    assign numbers[3] = 32'hAABB_CCDD;

    // ---- Internal signals ----
    wire       tx_busy;
    reg        tx_start;
    reg  [7:0] tx_byte;

    // ---- FSM registers ----
    reg [2:0]  num_idx;      // which number we are sending (0-3)
    reg [3:0]  byte_idx;     // which byte within the number (0=MSN .. 7=LSN, 8='\n')
    reg [31:0] current_num;  // latched copy of the current 32-bit value

    // ---- FSM state encoding ----
    localparam S_LOAD     = 3'd0;   // latch next number
    localparam S_PREP     = 3'd1;   // prepare byte to send
    localparam S_START    = 3'd2;   // pulse tx_start for 1 clock
    localparam S_WAIT     = 3'd3;   // wait for tx_busy to assert   ← FIX 2
    localparam S_WAITDONE = 3'd4;   // wait for tx_busy to de-assert ← FIX 2
    localparam S_NEXT     = 3'd5;   // advance byte / number counter
    localparam S_DONE     = 3'd6;   // all done, sit idle

    reg [2:0] state;

    wire rst = ~rst_n;

    // ---- Instantiate UART TX ----
    uart_tx #(.CLKS_PER_BIT(1250)) u_tx (
        .clk      (clk),
        .rst      (rst),
        .tx_start (tx_start),
        .tx_byte  (tx_byte),
        .tx_pin   (uart_txd),
        .tx_busy  (tx_busy)
    );

    // ---- Helper: convert 4-bit nibble to ASCII hex character ----
    function [7:0] nibble_to_ascii;
        input [3:0] n;
        begin
            nibble_to_ascii = (n < 4'd10) ? (8'h30 + n) : (8'h41 + n - 4'd10);
            // '0'..'9' = 0x30..0x39,  'A'..'F' = 0x41..0x46
        end
    endfunction

    // ---- Main FSM ----
    always @(posedge clk) begin
        if (rst) begin
            state       <= S_LOAD;
            num_idx     <= 0;
            byte_idx    <= 0;
            current_num <= 0;
            tx_start    <= 1'b0;
            tx_byte     <= 8'h00;
        end else begin
            tx_start <= 1'b0;   // default: no pulse

            case (state)

                // --------------------------------------------------
                // Latch the current 32-bit number, then go prepare bytes
                // --------------------------------------------------
                S_LOAD: begin
                    if (num_idx < 3'd4) begin
                        case (num_idx)
                            3'd0: current_num <= numbers[0];
                            3'd1: current_num <= numbers[1];
                            3'd2: current_num <= numbers[2];
                            3'd3: current_num <= numbers[3];
                            default: current_num <= 32'h0;
                        endcase
                        byte_idx <= 4'd0;
                        state    <= S_PREP;
                    end else begin
                        state <= S_DONE;
                    end
                end

                // --------------------------------------------------
                // Decide which byte to send next.
                // byte_idx 0..7 → hex ASCII digits (MSN first)
                // byte_idx 8    → newline 0x0A
                //
                // FIX 3: explicit case instead of variable part-select
                //         current_num[31 - byte_idx*4 -: 4]  ← Yosys unfriendly
                // --------------------------------------------------
                S_PREP: begin
                    if (byte_idx == 4'd8) begin
                        tx_byte <= 8'h0A;           // '\n'
                    end else begin
                        case (byte_idx)
                            4'd0: tx_byte <= nibble_to_ascii(current_num[31:28]);
                            4'd1: tx_byte <= nibble_to_ascii(current_num[27:24]);
                            4'd2: tx_byte <= nibble_to_ascii(current_num[23:20]);
                            4'd3: tx_byte <= nibble_to_ascii(current_num[19:16]);
                            4'd4: tx_byte <= nibble_to_ascii(current_num[15:12]);
                            4'd5: tx_byte <= nibble_to_ascii(current_num[11:8]);
                            4'd6: tx_byte <= nibble_to_ascii(current_num[7:4]);
                            4'd7: tx_byte <= nibble_to_ascii(current_num[3:0]);
                            default: tx_byte <= 8'h3F;  // '?' safety
                        endcase
                    end
                    state <= S_START;
                end

                // --------------------------------------------------
                // Pulse tx_start for exactly 1 clock (only when UART is free)
                // --------------------------------------------------
                S_START: begin
                    if (!tx_busy) begin
                        tx_start <= 1'b1;
                        state    <= S_WAIT;
                    end
                end

                // --------------------------------------------------
                // FIX 2a: wait for tx_busy to go HIGH (UART has started)
                // Without this the FSM races through S_WAITDONE immediately
                // because tx_busy is still 0 on the very next clock after
                // the tx_start pulse.
                // --------------------------------------------------
                S_WAIT: begin
                    if (tx_busy) begin
                        state <= S_WAITDONE;
                    end
                end

                // --------------------------------------------------
                // FIX 2b: now wait for tx_busy to go LOW (byte fully sent)
                // --------------------------------------------------
                S_WAITDONE: begin
                    if (!tx_busy) begin
                        state <= S_NEXT;
                    end
                end

                // --------------------------------------------------
                // Advance counters: next byte, or next number
                // --------------------------------------------------
                S_NEXT: begin
                    if (byte_idx == 4'd8) begin
                        // finished all 9 bytes of this number
                        num_idx  <= num_idx + 1'b1;
                        byte_idx <= 4'd0;
                        state    <= S_LOAD;
                    end else begin
                        byte_idx <= byte_idx + 1'b1;
                        state    <= S_PREP;
                    end
                end

                // --------------------------------------------------
                // All 4 numbers sent — idle forever, reset to replay
                // --------------------------------------------------
                S_DONE: begin
                    // Do nothing. Press reset button to re-send.
                end

                default: state <= S_LOAD;

            endcase
        end
    end

endmodule
