module max_finder(
    input[39:0] i_BCD_vector,
    output reg [7:0] o_max_vector,
    input i_valid,
    output o_valid,
);

always @(*) begin
    running_max = i_BCD_vector[3:0];  // seed with rightmost digit
    best_pair   = 8'd0;

    for (i = 1; i <= 9; i = i + 1) begin
        if ({i_BCD_vector[i*4 +: 4], running_max} > best_pair)
            best_pair = {i_BCD_vector[i*4 +: 4], running_max};
        if (i_BCD_vector[i*4 +: 4] > running_max)
            running_max = i_BCD_vector[i*4 +: 4];
    end

    o_max_vector = best_pair;
end


endmodule