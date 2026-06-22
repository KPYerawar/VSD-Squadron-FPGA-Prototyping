module minute_counter(

input divider,
input rst,
input [5:0] second,

output reg [5:0] minute

);


always @(posedge divider)
begin

    if(!rst)
        minute <=0;


    else if(second==59)
    begin

        if(minute==59)
            minute<=0;

        else
            minute<=minute+1;

    end

end


endmodule
