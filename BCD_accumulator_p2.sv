module BCD_accum(
input [7:0] i_max_vector,
input i_valid,
output reg [31:0] o_accumulated_sum,
input clk,
input rst
);

    always @(posedge clk) begin
        if (rst)
            o_accumulated_sum <= 32'd0;
        else if (i_valid)
            o_accumulated_sum <= o_accumulated_sum + i_max_vector;
    end


endmodule