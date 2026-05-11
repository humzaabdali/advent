module max_state #(
    parameter DECIMAL_DIGITS = 16
)(
    input  [DECIMAL_DIGITS*4-1:0] i_BCD_vector,
    input  [4:0]                  i_left_index,
    input  [4:0]                  i_right_index,

    output reg [4:0]              max_index,
    output reg [3:0]              max_digit
);

    integer i;

    always @(*) begin
        max_digit = 4'd0;
        max_index = i_right_index;

        for (i = 0; i < DECIMAL_DIGITS; i = i + 1) begin
            if (i >= i_right_index && i <= i_left_index) begin
                if (i_BCD_vector[i*4 +: 4] >= max_digit) begin
                    max_digit = i_BCD_vector[i*4 +: 4];
                    max_index = i[4:0];
                end
            end
        end
    end

endmodule