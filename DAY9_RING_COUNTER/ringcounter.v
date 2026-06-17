module ringcounter(
    input rst,
    output reg [3:0] led
);

wire clk;

SB_HFOSC osc_int(
    .CLKHFPU(1'b1),
    .CLKHFEN(1'b1),
    .CLKHF(clk)
);

defparam osc_int.CLKHF_DIV = "0b10"; // 12 MHz

reg [24:0] counter = 0;
reg clkdiv_d = 0;

always @(posedge clk) begin

    if(!rst) begin
        led <= 4'b1000;
        counter <= 0;
        clkdiv_d <= 0;
    end
    else begin
        counter <= counter + 1;
        clkdiv_d <= counter[21];


        if(~clkdiv_d && counter[21])
            led <= {led[2:0], led[3]};
    end
end

endmodule
