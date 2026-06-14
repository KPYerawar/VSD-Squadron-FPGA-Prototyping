module ALU (
input [2:0] opcode ,
output [7:0] out );

wire clk ;
SB_HFOSC osc_int(
       .CLKHFPU(1'b1),
      .CLKHFEN(1'b1),
       .CLKHF(clk)
    );
   defparam osc_int.CLKHF_DIV = "0b10"; //12MHZ
   
   reg [7:0] a = 8'b10101010 ;
   reg [7:0] b = 8'b11110000 ;
   
   always @(posedge clk ) begin 
   case (opcode ) 
        3'b000: out <= ~a ;
        3'b001: out <= a | b ;
        3'b010: out <= a ^ b;
        3'b011: out <= a & b  ;
        3'b100: out <= a * b  ;
        3'b101: out <= a + b ;
        3'b110: out <= a - b  ;
        
       default : out <= a ^ b ; //default for xor case 
       endcase 
       end 
       endmodule 
        
        
