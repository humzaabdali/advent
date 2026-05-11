module top_module ();
    reg clk = 0;
    always #5 clk = ~clk;

    initial `probe_start;
    `probe(clk);

    reg rst = 0;
    reg [31:0] start_range = 0;
    reg [31:0] end_range = 0;
    reg [31:0] ingredient = 0;
    reg is_last_in = 0;

    wire is_last_mid;
    wire is_fresh;

    wire [31:0] accumulated;
    wire [31:0] final_count;
    wire valid;

    `probe(rst);
    `probe(start_range);
    `probe(end_range);
    `probe(ingredient);
    `probe(is_last_in);
    `probe(is_fresh);
    `probe(is_last_mid);
    `probe(accumulated);
    `probe(final_count);
    `probe(valid);

    comparator comp (
        .i_start_range(start_range),
        .i_end_range(end_range),
        .i_Ingredient(ingredient),
        .i_is_last(is_last_in),
        .o_is_last(is_last_mid),
        .o_is_fresh(is_fresh)
    );

    accumulator acc (
        .i_is_last(is_last_mid),
        .i_is_fresh(is_fresh),
        .o_accumulated(accumulated),
        .o_final_count(final_count),
        .clk(clk),
        .rst(rst),
        .o_valid(valid)
    );

    initial begin
        start_range <= 32'd10;
        end_range   <= 32'd20;

        rst <= 1;
        #10;
        rst <= 0;

        // Fresh: 12 is inside [10,20]
        ingredient <= 32'd12;
        is_last_in <= 0;
        #10;

        // Fresh: 10 is inside because comparator is inclusive
        ingredient <= 32'd10;
        is_last_in <= 0;
        #10;

        // Not fresh: 25 is outside
        ingredient <= 32'd25;
        is_last_in <= 0;
        #10;

        // Fresh and last: 18 is inside, final_count should become 3
        ingredient <= 32'd18;
        is_last_in <= 1;
        #10;

        // New group starts after reset from is_last
        is_last_in <= 0;
        ingredient <= 32'd5;
        #10;

        // Fresh
        ingredient <= 32'd20;
        #10;

        // Last but not fresh: final_count should become 1
        ingredient <= 32'd30;
        is_last_in <= 1;
        #10;

        is_last_in <= 0;
        #20;

        $finish;
    end

endmodule

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
