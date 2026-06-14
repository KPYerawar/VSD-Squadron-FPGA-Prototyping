module feqdiv2(
input rst ,
output feqhalf , q_bar );
 wire clk ;
  SB_HFOSC osc_int(
       .CLKHFPU(1'b1),
      .CLKHFEN(1'b1),
       .CLKHF(clk)
    );
   defparam osc_int.CLKHF_DIV = "0b10"; //12MHZ
   reg d = 0 ; 
   always @(posedge clk ) begin 
   if (rst ) begin 
   feqhalf <= 0 ;
   end 
   else begin 
       feqhalf <= d ;
         d <= q_bar ;
         q_bar <= ~feqhalf ;
         end 
         end 
         endmodule 
