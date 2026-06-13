module sevenseg (
    input rst,
    output reg [7:0] out
);

    wire clk;
    SB_HFOSC osc_int (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk)
    );
    defparam osc_int.CLKHF_DIV = "0b10";

    reg bit21_delay = 0;
    reg [24:0] counter = 0;
    reg [3:0] sevenseg1 = 0;

    always @(posedge clk) begin 
        if (rst == 0) begin 
            counter <= 0;
            bit21_delay <= 0;
            sevenseg1 <= 0;
            out <= 8'b11111111;
        end else begin
            counter <= counter + 1;
            bit21_delay <= counter[21];
            
            if (counter[21] == 1'b1 && bit21_delay == 1'b0) begin 
                if (sevenseg1 == 4'hF) begin 
                    sevenseg1 <= 0;
                end else begin 
                    sevenseg1 <= sevenseg1 + 1;
                end
            end
            
            case (sevenseg1)
                4'h0: out <= 8'b00000011; 
                4'h1: out <= 8'b10011111; 
                4'h2: out <= 8'b00100101; 
                4'h3: out <= 8'b00001101; 
                4'h4: out <= 8'b10011001; 
                4'h5: out <= 8'b01001001; 
                4'h6: out <= 8'b01000001; 
                4'h7: out <= 8'b00011111; 
                4'h8: out <= 8'b00000001; 
                4'h9: out <= 8'b00001001; 
                4'hA: out <= 8'b00010001; 
                4'hB: out <= 8'b11000001; 
                4'hC: out <= 8'b01100011; 
                4'hD: out <= 8'b10000101; 
                4'hE: out <= 8'b01100001; 
                4'hF: out <= 8'b01110001; 
                default: out <= 8'b11111111; 
            endcase
        end
    end

endmodule
