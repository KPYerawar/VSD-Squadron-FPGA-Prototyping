module top_min_sec_check (
input rst ,
output reg [5:0]second ,
output  [5:0] minute,
output [4:0] hours  );

clock_driver d1 (
.rst(rst),.clock_div (divider ),.clk(clk ));

second_counter c1 (
.rst(rst),.second(second),.clock_div(divider));

wire divider ;

minute_counter m1 (
.rst(rst),.second (second),.minute(minute),.divider(divider));


reg [5:0] minute ;

hour h1 (.rst(rst),.minute(minute),.driver(driver),.hours(hours));

wire clk ;
SB_HFOSC CLK1(
    .CLKHFPU(1'b1),
    .CLKHFEN(1'b1),
    .CLKHF(clk)
);

defparam CLK1.CLKHF_DIV = "0b10"; // 12 MHz
endmodule 
