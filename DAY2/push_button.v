module push_button(
    input button,
    output led
);

assign led = ~button;

endmodule
