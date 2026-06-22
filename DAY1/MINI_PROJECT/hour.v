module hour(
input rst , 
input [5:0] minute ,
input  driver ,
output reg [4:0]hours // to count till 0-23
);

always @(posedge driver) begin
  if (!rst) begin 
      hours <= 0 ;
      end
    else if (minute >= 59 ) 
              hour  <= hour  + 1 ;
        else begin 
              if (hour >= 23 ) 
                 hour <= 0 ;
              end 
         
                 
    end 
    endmodule  
