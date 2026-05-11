module comparator(
  input [31:0] i_start_range,
  input [31:0] i_end_range,
  input [31:0] i_Ingredient,
  input i_is_last,
  output o_is_last,
  output reg o_is_fresh
);

    always@(*) begin 
        o_is_fresh=0;

        if (i_Ingredient >= i_start_range && i_Ingredient <= i_end_range) begin 
            o_is_fresh = 1;
        end  
    end 

    assign o_is_last = i_is_last;
  
endmodule
