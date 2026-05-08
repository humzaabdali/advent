module BCD_accum(
input [7:0] i_max_vector,
input i_valid,
output reg [32:0] o_accumulated_sum
);

always@(*) begin 
if (i_valid)
    o_accumulated_sum = o_accumulated_sum+i_max_vector;
    else 
    o_accumulated_sum = o_accumulated_sum;
end 


endmodule