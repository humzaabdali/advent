module accumulator(input clk, input rst, input [39:0] vector, input i_invalid, output reg [63:0] accumulated_id);
    
    always@(posedge clk) begin 
        if (rst) begin 
            accumulated_id <= 64'd0;
        end 
        else begin 
            if (i_invalid) begin 
                accumulated_id <= accumulated_id+vector;
            end 
        end 
    end 
endmodule
