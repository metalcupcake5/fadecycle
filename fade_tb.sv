`timescale 10ns/10ns
`include "top.sv"

module fade_tb;

    parameter PWM_INTERVAL = 1200;

    logic clk = 0;
    // logic LED;
    logic RGB_R;
    logic RGB_B;
    logic RGB_G;

    top # (
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u0 (
        .clk            (clk), 
        // .LED            (LED),
        .RGB_R          (RGB_R),
        .RGB_G          (RGB_G),
        .RGB_B          (RGB_B)
    );

    initial begin
        $dumpfile("fade.vcd");
        $dumpvars(0, fade_tb);
        #150000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule

