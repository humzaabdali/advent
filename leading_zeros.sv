module leading_zero(
    input  [39:0] bcd_vector,
    input         i_valid,
    output reg [3:0] leading_zeros,
    output reg    o_valid
);

    integer i;
    reg seen_nonzero;

    always @(*) begin
        leading_zeros = 4'd0;
        seen_nonzero  = 1'b0;

        for (i = 9; i >= 0; i = i - 1) begin
            if (!seen_nonzero) begin
                if (bcd_vector[i*4 +: 4] == 4'b0000)
                    leading_zeros = leading_zeros + 1'b1;
                else
                    seen_nonzero = 1'b1;
            end
        end

        o_valid = i_valid;
    end

endmodule
