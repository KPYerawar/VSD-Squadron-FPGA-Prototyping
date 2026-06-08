module uart_tx (
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_byte,
    output reg        tx_pin,
    output wire       tx_busy
);

    parameter CLKS_PER_BIT = 1250;  

    localparam IDLE  = 3'd0;
    localparam START = 3'd1;
    localparam DATA  = 3'd2;
    localparam STOP  = 3'd3;
    localparam DONE  = 3'd4;

    reg [2:0]  state;
    reg [10:0] baud_cnt;   
    reg [2:0]  bit_idx;    
    reg [7:0]  shift_reg;  

    assign tx_busy = (state != IDLE);

    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            tx_pin    <= 1'b1;  
            baud_cnt  <= 0;
            bit_idx   <= 0;
            shift_reg <= 0;
        end else begin
            case (state)

                IDLE: begin
                    tx_pin    <= 1'b1;
                    baud_cnt  <= 0;
                    bit_idx   <= 0;
                    if (tx_start) begin
                        shift_reg <= tx_byte;  
                        state     <= START;
                    end
                end

                START: begin
                    tx_pin <= 1'b0;
                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                        baud_cnt <= 0;
                        state    <= DATA;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end

                DATA: begin
                    tx_pin <= shift_reg[0];     
                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                        baud_cnt  <= 0;
                        shift_reg <= shift_reg >> 1;  
                        if (bit_idx == 3'd7) begin
                            bit_idx <= 0;
                            state   <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;a
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end

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
