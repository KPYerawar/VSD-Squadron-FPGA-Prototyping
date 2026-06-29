module led_test (
input rst ,
output reg [1:0] led );

always @(*) begin 
if ( rst == 0 ) begin 
  led[0] = 1 ;
  led[1] = 0 ;
  end 
  else begin 
  led[0] = 0 ;
  led[1] = 1 ;
  end 
  end 
  endmodule 
