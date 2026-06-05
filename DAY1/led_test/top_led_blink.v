module top_led_blink(

output led );

wire clk ;

SB_HFOSC osc_int(
.CLKHFPU(1'b1),
.CLKHFEN(1'b1),
.CLKHF(clk));
defparam osc_int.CLKHF_DIV = "0b11";

led_blink l1(
.led(led),.clk(clk));

endmodule 

