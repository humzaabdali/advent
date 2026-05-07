module max_finder(
    input[39:0] i_BCD_vector,
    input[3:0] i_leading_zeros,
    output reg [7:0] max_vector,
    input clk,
    input i_valid,
    output o_valid,
    output o_ready,
    input reset
);

reg[2:0] state_reg, next_state_reg;

parameter idle = 3'b000, start =3'b001, shift = 3'b010, compare = 3'b011, finish =3'b100;

always@(posedge clk or posedge) begin
    if (reset) begin 
        state_reg<=idle;
    end 
    else begin 
        state_reg<=next_state_reg;
    end 
end 

always@(*) begin 
    case (state_reg)
    idle: begin 
    end
    start: begin 
    end 
    shift: begin 
    end 
    compare: begin
    end 
    finish: begin 
    end 
    endcase
end 

assign o_valid = i_valid;

endmodule