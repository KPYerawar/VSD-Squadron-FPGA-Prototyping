module encoder4x2(
input switchcase,
output reg [1:0] led );

reg [3:0] variable1 = 4'b0100 ;
reg [3:0] variable2 = 4'b0010 ;


always @(*)begin 
if (switchcase == 1 ) begin 
led[0] = variable1[1] | variable1[3] ;
led[1] = variable1[2] | variable1[3] ;  end 

else begin 


led[0] = variable2[1] | variable2[3] ;
led[1] = variable2[2] | variable2[3] ;  end 
end 
endmodule 


