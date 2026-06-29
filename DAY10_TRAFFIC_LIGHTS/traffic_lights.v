module traffic_lights (
    input rst,
    output reg [2:0] led
);

    // ---- 12 MHz internal oscillator ----
    wire clk;

    SB_HFOSC osc_int (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk)
    );

    defparam osc_int.CLKHF_DIV = "0b00";

    reg [1:0] state = 0;
    reg [26:0] counter = 0;

    parameter red = 0,
              yellow = 1, // assigned the blue on board led for yellow indication 
              green = 2;

    always @(posedge clk) begin

        if (rst == 0) begin
            state   <= red;
            counter <= 0;
            led     <= 3'b100;      
        end
        else begin

            case(state)

                red: begin
                    led <= 3'b100;
                    counter <= counter + 1;

                    if(counter[25]) begin
                        state <= yellow;
                        counter <= 0;
                    end
                end

                yellow: begin
                    led <= 3'b010;
                    counter <= counter + 1;

                    if(counter[25]) begin
                        state <= green;
                        counter <= 0;
                    end
                end

                green: begin
                    led <= 3'b001;
                    counter <= counter + 1;

                    if(counter[25]) begin
                        state <= red;
                        counter <= 0;
                    end
                end

                default: begin
                    state <= red;
                    counter <= 0;
                end

            endcase

        end

    end

endmodule
