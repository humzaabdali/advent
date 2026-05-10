
module max_finder 
#(PARAMETER decimal_digits)(
    //12 digits 
    //16 bit decimal (decimal_digits)
    //64 bits for BCD vector
    input  [decimal_digits*4-1]:0]    i_BCD_vector,
    input clk,
    input rst,
    input            i_valid,
    output reg [47:0] o_max_vector,
    //max_vector always 48 BCD bits long 48/12 =4
    output reg       o_valid
);

    reg [3:0] window_size = 0;
    reg [3:0] loop_left = 0;
    reg [47:0] best_twelve;
    reg[4:0] right_index;
    reg[4:0] left_index;
    reg [3:0] current_max = 4'd0;
    reg [$clog2(decimal_digits)-1:0] current_max_index;

    reg [2:0] state;
    parameter idle =3'b000, check_space=3'b001, find_max=3'b010,loop_count=3'b011, done=3'b100;

    always@(posedge clk) begin 
        case (state)
            idle: begin 
            if (i_valid) begin 
                    window_size<=4'd12;
                    loop_left<=4'd12;
                    left_index <= decimal_digits
                    right_index  <= decimal_digits - 5'd11;
                    state<=check_loop;
                end 
            else begin 
                    state<=idle;
                end 
            end 
            check_loop: begin 
                if (loop_left > 0)
                    state<=find_max;
                else 
                    state <= done;
            end 
            find_max: begin
                for (integer i = left_index; i >= right_index; i--) begin 
                    if ( i_BCD_vector[i*4 +: 4]) begin 
                    end 
                    else begin 
                    end 
                end 
            end 
            check_space: begin 
            end 
            done: begin 
            end
        endcase
    end 

endmodule