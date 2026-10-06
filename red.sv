// Fade

module red #(
    // 
    parameter INC_DEC_INTERVAL = 10000,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms
    parameter INC_DEC_MAX = 200,            // Transition to next state after 200 increments / decrements, which is 0.2s
    // parameter INC_DEC_MAX = 500, // total cycle = x/1000 seconds
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value
);

    // Define state variable values
    // localparam PWM_1 = 3'b000;
    // localparam PWM_2 = 3'b001;
    // localparam PWM_3 = 3'b010;
    // localparam PWM_4 = 3'b010;
    // localparam PWM_5 = 3'b010;
    // localparam PWM_6 = 3'b010;
    
    localparam SEG_INTERVAL = 12_000_000 / 6;
    // localparam INC_DEC_VAL = 12_000_000 / INC_DEC_MAX;
    
    typedef enum {
        PWM_1 = 1,
        PWM_2 = 2,
        PWM_3 = 3,
        PWM_4 = 4,
        PWM_5 = 5,
        PWM_6 = 6
        } pwm_state;

    // Declare state variables
    pwm_state current_state = PWM_1;
    pwm_state next_state;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count_pwm = 0;
    logic [$clog2(SEG_INTERVAL) - 1:0] count_time = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        pwm_value = PWM_INTERVAL;
    end

    // Register the next state of the FSM
    always_ff @(posedge time_to_transition) begin
        current_state <= next_state;
    end

    // Compute the next state of the FSM
    always_comb begin
        // next_state = PWM_1;
        case (current_state)
            PWM_1:
                next_state = PWM_2;
            PWM_2:
                next_state = PWM_3;
            PWM_3:
                next_state = PWM_4;
            PWM_4:
                next_state = PWM_5;
            PWM_5:
                next_state = PWM_6;
            PWM_6:
                next_state = PWM_1;
            default:
                next_state = PWM_1;
        endcase
    end

    // Implement counter for incrementing / decrementing PWM value
    always_ff @(posedge clk) begin
        if (count_pwm == INC_DEC_INTERVAL - 1) begin
            count_pwm <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count_pwm <= count_pwm + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (count_time == SEG_INTERVAL - 1) begin
            count_time <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            count_time <= count_time + 1;
            time_to_transition <= 1'b0;
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin
        case (current_state)
            PWM_1,
            PWM_3,
            PWM_4,
            PWM_6:
                pwm_value <= pwm_value;
            PWM_2:
                if (pwm_value < INC_DEC_VAL) begin
                    pwm_value <= 0;
                end
                else begin
                    pwm_value <= pwm_value - INC_DEC_VAL;
                end
            PWM_5:
                if (pwm_value + INC_DEC_VAL < PWM_INTERVAL) begin
                    pwm_value <= pwm_value + INC_DEC_VAL;
                end
                else begin
                    pwm_value <= pwm_value;
                end
            default:
                pwm_value <= pwm_value;
        endcase
    end

    // // Implement counter for timing state transitions
    // always_ff @(posedge time_to_inc_dec) begin
    //     if (inc_dec_count == INC_DEC_MAX - 1) begin
    //         inc_dec_count <= 0;
    //         time_to_transition <= 1'b1;
    //     end
    //     else begin
    //         inc_dec_count <= inc_dec_count + 1;
    //         time_to_transition <= 1'b0;
    //     end
    // end

endmodule
