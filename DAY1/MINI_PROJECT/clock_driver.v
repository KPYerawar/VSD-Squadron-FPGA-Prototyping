module clock_driver(

input clk,
input rst,

output reg clock_div

);

reg [22:0] count;


always @(posedge clk)
begin

    if(!rst)
    begin
        count <= 0;
        clock_div <= 0;
    end

    else
    begin

        if(count == 23'd5_999_999)
        begin
            count <= 0;
            clock_div <= ~clock_div;
        end

        else
            count <= count + 1;

    end

end

endmodule
