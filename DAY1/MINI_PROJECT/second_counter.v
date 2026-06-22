module second_counter(

input clock_div,
input rst,

output reg [5:0] second

);


always @(posedge clock_div)
begin

    if(!rst)
        second <=0;


    else if(second==59)
        second<=0;


    else
        second<=second+1;

end

endmodule
