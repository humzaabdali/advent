module comparator_p2(
  input [39:0] i_bcd_vector,
    input [3:0]  leading_zeros,
    input        i_valid,
    output reg   is_invalid_id,
    output reg   o_valid,
    output reg [39:0]   o_bcd_vector,
    input [31:0] i_binary,
    output reg [31:0] p_binary
);

always @(*) begin
    case (leading_zeros)

        // 10 digits: pattern sizes 1, 2, 5
        4'd0: is_invalid_id =
            // 5 + 5
            (i_bcd_vector[39:20] == i_bcd_vector[19:0]) ||

            // 2 repeated 5 times
            ((i_bcd_vector[39:32] == i_bcd_vector[31:24]) &&
             (i_bcd_vector[39:32] == i_bcd_vector[23:16]) &&
             (i_bcd_vector[39:32] == i_bcd_vector[15:8])  &&
             (i_bcd_vector[39:32] == i_bcd_vector[7:0])) ||

            // 1 repeated 10 times
            ((i_bcd_vector[39:36] == i_bcd_vector[35:32]) &&
             (i_bcd_vector[39:36] == i_bcd_vector[31:28]) &&
             (i_bcd_vector[39:36] == i_bcd_vector[27:24]) &&
             (i_bcd_vector[39:36] == i_bcd_vector[23:20]) &&
             (i_bcd_vector[39:36] == i_bcd_vector[19:16]) &&
             (i_bcd_vector[39:36] == i_bcd_vector[15:12]) &&
             (i_bcd_vector[39:36] == i_bcd_vector[11:8])  &&
             (i_bcd_vector[39:36] == i_bcd_vector[7:4])   &&
             (i_bcd_vector[39:36] == i_bcd_vector[3:0]));

        // 9 digits: pattern sizes 1, 3
        4'd1: is_invalid_id =
            (i_bcd_vector[35:24] == i_bcd_vector[23:12] &&
             i_bcd_vector[35:24] == i_bcd_vector[11:0]) ||

            ((i_bcd_vector[35:32] == i_bcd_vector[31:28]) &&
             (i_bcd_vector[35:32] == i_bcd_vector[27:24]) &&
             (i_bcd_vector[35:32] == i_bcd_vector[23:20]) &&
             (i_bcd_vector[35:32] == i_bcd_vector[19:16]) &&
             (i_bcd_vector[35:32] == i_bcd_vector[15:12]) &&
             (i_bcd_vector[35:32] == i_bcd_vector[11:8])  &&
             (i_bcd_vector[35:32] == i_bcd_vector[7:4])   &&
             (i_bcd_vector[35:32] == i_bcd_vector[3:0]));

        // 8 digits: pattern sizes 1, 2, 4
        4'd2: is_invalid_id =
            (i_bcd_vector[31:16] == i_bcd_vector[15:0]) ||

            ((i_bcd_vector[31:24] == i_bcd_vector[23:16]) &&
             (i_bcd_vector[31:24] == i_bcd_vector[15:8])  &&
             (i_bcd_vector[31:24] == i_bcd_vector[7:0])) ||

            ((i_bcd_vector[31:28] == i_bcd_vector[27:24]) &&
             (i_bcd_vector[31:28] == i_bcd_vector[23:20]) &&
             (i_bcd_vector[31:28] == i_bcd_vector[19:16]) &&
             (i_bcd_vector[31:28] == i_bcd_vector[15:12]) &&
             (i_bcd_vector[31:28] == i_bcd_vector[11:8])  &&
             (i_bcd_vector[31:28] == i_bcd_vector[7:4])   &&
             (i_bcd_vector[31:28] == i_bcd_vector[3:0]));

        // 7 digits: pattern size 1 only
        4'd3: is_invalid_id =
            ((i_bcd_vector[27:24] == i_bcd_vector[23:20]) &&
             (i_bcd_vector[27:24] == i_bcd_vector[19:16]) &&
             (i_bcd_vector[27:24] == i_bcd_vector[15:12]) &&
             (i_bcd_vector[27:24] == i_bcd_vector[11:8])  &&
             (i_bcd_vector[27:24] == i_bcd_vector[7:4])   &&
             (i_bcd_vector[27:24] == i_bcd_vector[3:0]));

        // 6 digits: pattern sizes 1, 2, 3
        4'd4: is_invalid_id =
            (i_bcd_vector[23:12] == i_bcd_vector[11:0]) ||

            ((i_bcd_vector[23:16] == i_bcd_vector[15:8]) &&
             (i_bcd_vector[23:16] == i_bcd_vector[7:0])) ||

            ((i_bcd_vector[23:20] == i_bcd_vector[19:16]) &&
             (i_bcd_vector[23:20] == i_bcd_vector[15:12]) &&
             (i_bcd_vector[23:20] == i_bcd_vector[11:8])  &&
             (i_bcd_vector[23:20] == i_bcd_vector[7:4])   &&
             (i_bcd_vector[23:20] == i_bcd_vector[3:0]));

        // 5 digits: pattern size 1 only
        4'd5: is_invalid_id =
            ((i_bcd_vector[19:16] == i_bcd_vector[15:12]) &&
             (i_bcd_vector[19:16] == i_bcd_vector[11:8])  &&
             (i_bcd_vector[19:16] == i_bcd_vector[7:4])   &&
             (i_bcd_vector[19:16] == i_bcd_vector[3:0]));

        // 4 digits: pattern sizes 1, 2
        4'd6: is_invalid_id =
            (i_bcd_vector[15:8] == i_bcd_vector[7:0]) ||

            ((i_bcd_vector[15:12] == i_bcd_vector[11:8]) &&
             (i_bcd_vector[15:12] == i_bcd_vector[7:4])  &&
             (i_bcd_vector[15:12] == i_bcd_vector[3:0]));

        // 3 digits: pattern size 1 only
        4'd7: is_invalid_id =
            ((i_bcd_vector[11:8] == i_bcd_vector[7:4]) &&
             (i_bcd_vector[11:8] == i_bcd_vector[3:0]));

        // 2 digits: pattern size 1
        4'd8: is_invalid_id =
            (i_bcd_vector[7:4] == i_bcd_vector[3:0]);

        default: is_invalid_id = 1'b0;
    endcase
end

        o_valid = i_valid;
        o_bcd_vector = i_bcd_vector;
        assign p_binary = i_binary;
    end

    endmodule
