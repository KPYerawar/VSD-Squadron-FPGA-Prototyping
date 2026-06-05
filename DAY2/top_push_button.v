module top_push_button(
input button , 
output led );
wire clk ;

SB_HFOSC H1 (
.CLKHFPU(1'b1),
.CLKHFEN(1'b1),
.CLKHF(clk));

push_button p1 (
.led(led ),.button(button),.clk(clk));

endmodule 
