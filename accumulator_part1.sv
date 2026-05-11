module accumulator(
    input i_is_last,
    input i_is_fresh,
    output reg [31:0] o_accumulated,
    output reg [31:0] o_final_count,
    input clk,
    input rst,
    output reg o_valid
);

always@(posedge clk) begin 
    if (rst) begin 
        o_accumulated<=32'd0;
        o_final_count<=32'd0;
        o_valid<=1'd0;
    end 

    else begin 
    o_valid<=1'd0;

        if (i_is_last==1) begin 
            o_final_count<=o_accumulated+i_is_fresh;
            o_accumulated<=32'd0;
            o_valid<=1'd1;
        end 
        else begin 
            if (i_is_fresh==1) begin 
                o_accumulated<= o_accumulated+1;
            end 
        end 
    end 
end 

endmodule