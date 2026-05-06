module accumulator(input clk, 
input rst, 
input [39:0] vector, 
input i_invalid, 
output reg [63:0] accumulated_id,
input [31:0] i_binary
);
    
    always@(posedge clk) begin 
        if (rst) begin 
            accumulated_id <= 64'd0;
        end 
        else begin 
            if (i_invalid) begin 
                accumulated_id <= accumulated_id+i_binary;
            end 
        end 
    end 
endmodule
