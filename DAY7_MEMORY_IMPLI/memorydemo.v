module memorydemo (
input [1:0] mem_seclect ,
output reg [3:0] mem_data );

reg [3:0] mem [3:0];

wire clk ;
SB_HFOSC osc_int(
       .CLKHFPU(1'b1),
      .CLKHFEN(1'b1),
       .CLKHF(clk)
    );
   defparam osc_int.CLKHF_DIV = "0b10"; //12MHZ
   
   always @(posedge clk) begin 
         mem[0] <= 4'b1010;
         mem[1] <= 4'b1100;
         mem[2] <= 4'b0011;
         mem[3] <= 4'b0101;
         
         case (mem_seclect) 
             2'b00 : mem_data <= mem[0] ;
             2'b01 : mem_data <= mem[1] ;
             2'b10 : mem_data <= mem[2] ;
             2'b11 : mem_data <= mem[3] ;
             endcase 
             end 
             endmodule 
             
         
         
