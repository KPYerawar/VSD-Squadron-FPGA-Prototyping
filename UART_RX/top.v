// ============================================================
// top.v
// VSDSquadron FM (iCE40UP5K) - UART receiver -> 4 LED decoder
// 00 -> led[0], 01 -> led[1], 10 -> led[2], 11 -> led[3]
// ============================================================
module top (
    input  wire       uart_rx_pin,   // connect to UART-TTL module TX line
    output wire [3:0] led            // 4 LEDs, wired to GPIO later
);

    // ---------------- 12 MHz internal oscillator ----------------
    wire clk;
    SB_HFOSC osc_int (
        .CLKHFPU (1'b1),
        .CLKHFEN (1'b1),
        .CLKHF   (clk)
    );
    defparam osc_int.CLKHF_DIV = "0b00";   // divide-by-1 -> 12 MHz

    // ---------------- UART receiver ----------------
    wire [7:0] rx_data;
    wire       rx_valid;

    uart_rx #(
        .CLK_FREQ (12_000_000),
        .BAUD     (9600)
    ) u_rx (
        .clk        (clk),
        .rst_n      (1'b1),     // no external reset button used; always enabled
        .rx         (uart_rx_pin),
        .data_out   (rx_data),
        .data_valid (rx_valid)
    );

    // ---------------- Decode 2-bit code -> 2-second one-shot LED pulse ----------------
    // ASCII '0'-'3' = 0x30-0x33, so rx_data[1:0] IS the 2-bit code directly
    localparam integer PULSE_CYCLES = 12_000_000 * 2;   // 2 seconds @ 12 MHz

    reg [24:0] pulse_cnt    = 0;   // 25 bits covers 24,000,000
    reg        pulse_active = 1'b0;
    reg [1:0]  active_code  = 2'b00;

    always @(posedge clk) begin
        if (rx_valid) begin
            // new byte arrived -> latch its code and (re)start the 2s timer,
            // even if a previous pulse was still running
            active_code  <= rx_data[1:0];
            pulse_cnt    <= 0;
            pulse_active <= 1'b1;
        end else if (pulse_active) begin
            if (pulse_cnt < PULSE_CYCLES - 1)
                pulse_cnt <= pulse_cnt + 1'b1;
            else begin
                pulse_cnt    <= 0;
                pulse_active <= 1'b0;   // pulse finished, LED goes off
            end
        end
    end

    assign led = pulse_active ? (4'b0001 << active_code) : 4'b0000;

endmodule
