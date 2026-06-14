module jsoncount (
input rst ,
output [3:0] out );

  wire clk ;
  SB_HFOSC osc_int(
       .CLKHFPU(1'b1),
      .CLKHFEN(1'b1),
       .CLKHF(clk)
    );
   defparam osc_int.CLKHF_DIV = "0b10"; //12MHZ
   reg [22:0] bitcount = 0 ; 
   reg bitno21 =  0 ;
   always @(posedge clk ) begin
       if (!rst ) begin 
         bitcount <= 0 ;
         bitno <= 0 ;
         out<= 4'b0000;
         end 
     else begin 
           bitcount <= bitcount + 1 ;
          bitno <= bitcount [21] ;
                    if (bitno == 0 && bitcount[21] == 1'b1 ) begin 
                      out <= {~out[0], out[3:1]};
                      
                      end 
                      
               end 
          end 
     endmodule 
                             
     
     
       
   
