module button_test(
    input button,
    output led
);

assign led = ~button;

endmodule

