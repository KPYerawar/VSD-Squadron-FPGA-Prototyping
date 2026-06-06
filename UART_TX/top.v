module top (
    input  wire rst_n,    
    output wire uart_txd  
);

    wire clk ;
    SB_HFOSC osc_int(
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk)
    );
    defparam osc_int.CLKHF_DIV = "0b10";

    wire [31:0] numbers [0:3];
    assign numbers[0] = 32'hDEAD_BEEF;
    assign numbers[1] = 32'hCAFE_BABE;
    assign numbers[2] = 32'h1234_5678;
    assign numbers[3] = 32'hAABB_CCDD;

    wire        tx_busy;
    reg         tx_start;
    reg  [7:0] tx_byte;

    reg [2:0]  num_idx;      
    reg [3:0]  byte_idx;     
    reg [31:0] current_num;  

    localparam S_LOAD   = 3'd0;   
    localparam S_PREP   = 3'd1;   
    localparam S_START  = 3'd2;   
    localparam S_WAIT   = 3'd3;   
    localparam S_NEXT   = 3'd4;   
    localparam S_DONE   = 3'd5;   

    reg [2:0] state;

    wire rst = ~rst_n;

    uart_tx #(.CLKS_PER_BIT(1250)) u_tx (
        .clk      (clk),
        .rst      (rst),
        .tx_start (tx_start),
        .tx_byte  (tx_byte),
        .tx_pin   (uart_txd),
        .tx_busy  (tx_busy)
    );

    function [7:0] nibble_to_ascii;
        input [3:0] n;
        begin
            nibble_to_ascii = (n < 10) ? (8'h30 + n) : (8'h41 + n - 10);
        end
    endfunction

    always @(posedge clk) begin
        if (rst) begin
            state       <= S_LOAD;
            num_idx     <= 0;
            byte_idx    <= 0;
            current_num <= 0;
            tx_start    <= 0;
            tx_byte     <= 0;
        end else begin
            tx_start <= 1'b0;   

            case (state)

                S_LOAD: begin
                    if (num_idx < 4) begin
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

                S_PREP: begin
                    if (byte_idx == 4'd8) begin
                        tx_byte <= 8'h0A;   
                    end else begin
                        tx_byte <= nibble_to_ascii(
                            current_num[31 - byte_idx*4 -: 4]
                        );
                    end
                    state <= S_START;
                end

                S_START: begin
                    if (!tx_busy) begin
                        tx_start <= 1'b1;
                        state    <= S_WAIT;
                    end
                end

                S_WAIT: begin
                    if (!tx_busy) begin
                        state <= S_NEXT;
                    end
                end

                S_NEXT: begin
                    if (byte_idx == 4'd8) begin
                        num_idx  <= num_idx + 1;
                        byte_idx <= 0;
                        state    <= S_LOAD;
                    end else begin
                        byte_idx <= byte_idx + 1;
                        state    <= S_PREP;
                    end
                end

                S_DONE: begin
                end

                default: state <= S_LOAD;

            endcase
        end
    end

endmodule
