module max_finder #(
    parameter DECIMAL_DIGITS = 16,
    parameter SEQ_DIGITS     = 12
)(
    input clk,
    input rst,

    input  [DECIMAL_DIGITS*4-1:0] i_BCD_vector,
    input                         i_valid,

    output reg [SEQ_DIGITS*4-1:0] o_max_vector,
    output reg                    o_valid
);

    reg [4:0] left_index;
    reg [4:0] right_index;
    reg [3:0] digits_left;

    wire [4:0] max_index;
    wire [3:0] max_digit;

    reg [2:0] state;

    localparam IDLE  = 3'd0;
    localparam FIND  = 3'd1;
    localparam STORE = 3'd2;
    localparam DONE  = 3'd3;

    max_state #(
        .DECIMAL_DIGITS(DECIMAL_DIGITS)
    ) u_max_state (
        .i_BCD_vector(i_BCD_vector),
        .i_left_index(left_index),
        .i_right_index(right_index),
        .max_index(max_index),
        .max_digit(max_digit)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            o_valid      <= 1'b0;
            o_max_vector <= 0;
            left_index   <= 0;
            right_index  <= 0;
            digits_left  <= 0;
        end else begin
            case (state)

                IDLE: begin
                    o_valid <= 1'b0;

                    if (i_valid) begin
                        o_max_vector <= 0;
                        digits_left  <= SEQ_DIGITS;

                        left_index   <= DECIMAL_DIGITS - 1;
                        right_index  <= SEQ_DIGITS - 1;

                        state <= FIND;
                    end
                end

                FIND: begin
                    state <= STORE;
                end

                STORE: begin
                    o_max_vector[(digits_left-1)*4 +: 4] <= max_digit;

                    if (digits_left == 1) begin
                        state <= DONE;
                    end else begin
                        left_index  <= max_index - 1;
                        right_index <= digits_left - 2;
                        digits_left <= digits_left - 1;
                        state       <= FIND;
                    end
                end

                DONE: begin
                    o_valid <= 1'b1;
                    state   <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule