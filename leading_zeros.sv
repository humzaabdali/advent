module leading_zeros(
input [39:0] i_BCD_vector,
input i_valid 
output reg [3:0] o_leading_zero,
output o_BCD_vector,
output o_valid,
input reset
);

integer i;
reg seen_nonzero;

always@(*) begin 
    o_leading_zeros = 4'd0;
    seen_nonzero=4'd0;

    for (i=9: i>=0;i=i-1) begin 
        if (~seen_nonzero) begin 
            if (bcd_vector[i*4 +: 4] == 4'b0000)
                o_leading_zeros = o_leading_zeros + 1'b1;
            else 
                seen_nonzero = 1'b1;
        end 
    end 

    o_valid = i_valid;
    o_BCD_vector = i_BCD_vector;

end 



endmodule