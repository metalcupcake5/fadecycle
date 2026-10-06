`include "fade.sv"
`include "pwm.sv"
`include "red.sv"
`include "test.sv"
`include "green.sv"
`include "blue.sv"

// Fade top level module

module top #(
    parameter PWM_INTERVAL = 1200       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic     clk, 
    output logic    LED,
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);
    parameter COLOR_INTERVAL = 12_000_000 / 2;
    parameter PWM_INC = 2'b00;
    parameter PWM_DEC = 2'b01;
    parameter PWM_STABLE = 2'b10;

    logic [$clog2(COLOR_INTERVAL) - 1:0] count = 0;

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_r;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_g;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_b;
    logic pwm_out_r;
    logic pwm_out_g;
    logic pwm_out_b;


    // fade #(
    //     .PWM_INTERVAL   (PWM_INTERVAL)
    // ) u1 (
    //     .clk            (clk), 
    //     .pwm_value      (pwm_value)
    // );
    red #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) led_red (
        .clk            (clk), 
        .pwm_value      (pwm_value_r)
        // .change_state   (state_r),
        // .LED            (LED)
    );

    green #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) led_green (
        .clk            (clk), 
        .pwm_value      (pwm_value_g)
    );
    blue #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) led_blue (
        .clk            (clk), 
        .pwm_value      (pwm_value_b)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) pwm_r (
        .clk            (clk), 
        .pwm_value      (pwm_value_r), 
        .pwm_out        (pwm_out_r)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) pwm_g (
        .clk            (clk), 
        .pwm_value      (pwm_value_g), 
        .pwm_out        (pwm_out_g)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) pwm_b (
        .clk            (clk), 
        .pwm_value      (pwm_value_b), 
        .pwm_out        (pwm_out_b)
    );

    assign RGB_R = ~pwm_out_r;
    assign RGB_G = ~pwm_out_g;
    assign RGB_B = ~pwm_out_b;

endmodule
