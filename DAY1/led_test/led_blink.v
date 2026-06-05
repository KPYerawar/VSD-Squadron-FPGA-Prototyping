module led_blink(
input clk , 
output led );

reg [25:0] count = 0 ;
always @(posedge clk )begin 
  count <= count +1 ;
  end 
assign led = count [24];
endmodule 
