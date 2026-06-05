module gpio_test (
    output gpio_out
);

wire clk;
reg [29:0] count = 0;

SB_HFOSC osc_inst (
    .CLKHFPU(1'b1),
    .CLKHFEN(1'b1),
    .CLKHF(clk)
);

defparam osc_inst.CLKHF_DIV = "0b11";

always @(posedge clk)
begin
    count <= count + 1'b1;
end

assign gpio_out = count[24];

endmodule
