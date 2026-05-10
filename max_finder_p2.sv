
module max_finder (
    //12 digits 
    input  [63:0]    i_BCD_vector,
    input            i_valid,
    output reg [47:0] o_max_vector,
    output reg       o_valid
);

    integer i;
    reg [47:0] best_twelve;

    always @(*) begin
        running_max = i_BCD_vector[3:0];   // seed with digit 0
        best_twelve   = 12'd0;

        for (i = 1; i <= 15; i = i + 1) begin
            if ({i_BCD_vector[i*4 +: 4], running_max} > best_twelve)
                best_twelve = {i_BCD_vector[i*4 +: 4], running_max};
            if (i_BCD_vector[i*4 +: 4] > running_max)
                running_max = i_BCD_vector[i*4 +: 4];
        end

        o_max_vector = best_twelve;
        o_valid      = i_valid;
    end

endmodule