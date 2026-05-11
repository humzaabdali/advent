module BCD_accum #(
    parameter SEQ_DIGITS = 12
)(
    input  [SEQ_DIGITS*4-1:0] i_max_vector,
    input                     i_valid,
    input                     clk,
    input                     rst,

    output reg [63:0]         o_accumulated_sum
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            o_accumulated_sum <= 64'd0;
        else if (i_valid)
            o_accumulated_sum <= o_accumulated_sum + i_max_vector;
    end

endmodule