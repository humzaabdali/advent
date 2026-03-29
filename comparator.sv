module comparator(
  input [39:0] i_bcd_vector,
    input [3:0]  leading_zeros,
    input        i_valid,
    output reg   is_invalid_id,
    output reg   o_valid,
    output reg [39:0]   o_bcd_vector
);

    always @(*) begin
        case (leading_zeros)
            4'd0: is_invalid_id = (i_bcd_vector[39:20] == i_bcd_vector[19:0]);
            4'd2: is_invalid_id = (i_bcd_vector[31:16] == i_bcd_vector[15:0]);
            4'd4: is_invalid_id = (i_bcd_vector[23:12] == i_bcd_vector[11:0]);
            4'd6: is_invalid_id = (i_bcd_vector[15:8]  == i_bcd_vector[7:0]);
            4'd8: is_invalid_id = (i_bcd_vector[7:4]   == i_bcd_vector[3:0]);
            default: is_invalid_id = 1'b0;
        endcase

        o_valid = i_valid;
        o_bcd_vector = i_bcd_vector;
    end

    endmodule
