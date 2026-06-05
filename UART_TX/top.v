// ============================================================
//  top.v  —  Send 4 × 32-bit numbers over UART (8N1, 9600 baud)
//  Target : VSDSquadron FM Mini  (12 MHz oscillator)
//
//  What gets printed on your PC terminal:
//    DEADBEEF\n
//    CAFEBABE\n
//    12345678\n
//    AABBCCDD\n
//
//  Each 32-bit number → 8 hex ASCII characters + newline = 9 bytes
//  Total bytes sent = 4 × 9 = 36 bytes, then it stops.
// ============================================================

module top (
          // 12 MHz
    input  wire rst_n,    // active-low reset (button or tie high)
    output wire uart_txd  // connect to USB-TTL RX pin
);

    // ---- The 4 numbers you want to send (change these freely) ----
    // Stored as an array of 32-bit values
    wire clk ;
    SB_HFOSC osc_int(
.CLKHFPU(1'b1),
.CLKHFEN(1'b1),
.CLKHF(clk));
defparam osc_int.CLKHF_DIV = "0b10";
    wire [31:0] numbers [0:3];
    assign numbers[0] = 32'hDEAD_BEEF;
    assign numbers[1] = 32'hCAFE_BABE;
    assign numbers[2] = 32'h1234_5678;
    assign numbers[3] = 32'hAABB_CCDD;

    // ---- Internal signals ----
    wire       tx_busy;
    reg        tx_start;
    reg  [7:0] tx_byte;

    // ---- FSM to walk through numbers → nibbles → ASCII bytes → newline ----
    // Each 32-bit number = 8 hex nibbles (4 bits each)
    // We send: nibble7 nibble6 ... nibble0  then '\n' (0x0A)
    //
    // State machine registers:
    reg [2:0]  num_idx;      // which number (0-3)
    reg [3:0]  byte_idx;     // which byte within the number (0=MSN .. 8=newline)
    reg [31:0] current_num;  // latched copy of the current 32-bit value

    // Top-level FSM states
    localparam S_LOAD    = 3'd0;   // latch next number
    localparam S_PREP    = 3'd1;   // prepare byte to send
    localparam S_START   = 3'd2;   // pulse tx_start
    localparam S_WAIT    = 3'd3;   // wait for UART to finish
    localparam S_NEXT    = 3'd4;   // advance byte/number counter
    localparam S_DONE    = 3'd5;   // all done, sit idle

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
            nibble_to_ascii = (n < 10) ? (8'h30 + n) : (8'h41 + n - 10);
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
            tx_start    <= 0;
            tx_byte     <= 0;
        end else begin
            tx_start <= 1'b0;   // default: no pulse

            case (state)

                // ---- Latch the current 32-bit number ----
                S_LOAD: begin
                    if (num_idx < 4) begin
                        // Latch using a case since arrays of wires
                        // can't be indexed dynamically in all tools
                        case (num_idx)
                            3'd0: current_num <= numbers[0];
                            3'd1: current_num <= numbers[1];
                            3'd2: current_num <= numbers[2];
                            3'd3: current_num <= numbers[3];
                            default: current_num <= 0;
                        endcase
                        byte_idx <= 0;
                        state    <= S_PREP;
                    end else begin
                        state <= S_DONE;
                    end
                end

                // ---- Pick the right byte to send ----
                S_PREP: begin
                    if (byte_idx == 4'd8) begin
                        // Send newline after 8 hex digits
                        tx_byte <= 8'h0A;   // '\n'
                    end else begin
                        // Send hex digit: MSN first (nibble 7 downto 0)
                        // byte_idx=0 → bits[31:28], byte_idx=7 → bits[3:0]
                        tx_byte <= nibble_to_ascii(
                            current_num[31 - byte_idx*4 -: 4]
                        );
                    end
                    state <= S_START;
                end

                // ---- Pulse tx_start for exactly 1 clock ----
                S_START: begin
                    if (!tx_busy) begin
                        tx_start <= 1'b1;
                        state    <= S_WAIT;
                    end
                end

                // ---- Wait until UART finishes sending ----
                S_WAIT: begin
                    if (!tx_busy) begin
                        state <= S_NEXT;
                    end
                end

                // ---- Advance counters ----
                S_NEXT: begin
                    if (byte_idx == 4'd8) begin
                        // Finished this number → move to next
                        num_idx  <= num_idx + 1;
                        byte_idx <= 0;
                        state    <= S_LOAD;
                    end else begin
                        byte_idx <= byte_idx + 1;
                        state    <= S_PREP;
                    end
                end

                // ---- All 4 numbers sent — do nothing ----
                S_DONE: begin
                    // Idle forever. Reset to re-send.
                end

                default: state <= S_LOAD;

            endcase
        end
    end

endmodule
