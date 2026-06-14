module mux4x1(
input [1:0] sel,
output y );


reg [3:0] data = 0101;
always @(*) begin 
case (sel)
   2'b00 : y = data[0];
    2'b01 : y = data[1];
    2'b10 : y = data[2];
    2'b11 : y = data[3];
    endcase 
    end 
    endmodule 
   
