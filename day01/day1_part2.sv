// Testbench code
module top_module ();
	reg clk=0;
	always #5 clk = ~clk;  // Create clock with period=10
	initial `probe_start;   // Start the timing diagram

	`probe(clk);        // Probe signal "clk"

	// A testbench
	reg in=0;
	initial begin
		#10 in <= 1;
		#10 in <= 0;
		#20 in <= 1;
		#20 in <= 0;
		$display ("Hello world! The current time is (%0d ps)", $time);
		#50 $finish;            // Quit the simulation
	end

	template inst1 ( .in(in) );   // Sub-modules work too.

endmodule

// Solution code
module day01_puzzle1(   input bit clk, 
                        input bit rst,
                        input bit direction, 
                        input bit [31:0] num,
                        input bit valid,
                        input bit last,
                        output bit [31:0] count,
                        output bit o_valid 
                        );
    // Probes for all module ports
	
	// Member variables for module

    wire valid0, last0, valid1, last1;
    wire [31:0] sum0, round1;

    ALU ALU1(.clk(clk), .rst(rst), .i_direction(direction), .i_num(num), .i_valid(valid), .i_last(last), .o_sum(sum0), .o_valid(valid0), .o_last(last0));
    rounder Rounder1(.i_num(sum0), .i_valid(valid0), .i_last(last0), .o_rounded_value(round1), .o_valid(valid1), .o_last(last1));
    zero_counter ZeroCounter1(.clk(clk), .rst(rst), .i_num(round1), .i_valid(valid1), .i_last(last1), .o_count(count), .o_valid(o_valid));

	// Probes for select internal registers

	// Instantiations of submodules

	// Procedural code
	
endmodule

module ALU( input bit clk,
            input bit rst,
            input bit i_direction, 
            input bit [31:0] i_num,
            input bit i_valid,
            input bit i_last,
            output bit [31:0] o_sum,
            output bit o_valid,
            output bit o_last 
            );
    // Probes for all module ports
	
	// Member variables for module
    bit [31:0] accum;

	// Probes for select internal registers

	// Instantiations of submodules

	// Procedural code
    always_ff @(posedge clk) begin
        if(rst) begin
            accum <= 32'd50;
        end else begin
            if(i_valid) begin
                if(i_direction) 
                    accum <= accum + i_num;
                else
                    accum <= accum - i_num;
            end
            o_valid <= i_valid;
            o_last <= i_last;
            if(o_last)
                accum <= 32'd50;
        end
    end

    assign o_sum = accum;
endmodule

//handle over/underflow (going below 0 or above 99)

module rounder(
    input  logic signed [31:0] i_num,
    input  logic               i_valid,
    input  logic               i_last,
    output logic [31:0]        o_rounded_value,
    output logic               o_valid,
    output logic               o_last
);

    always_comb begin
        // wrap to range [0,99]
        o_rounded_value = ((i_num % 100) + 100) % 100;
    end

    assign o_valid = i_valid;
    assign o_last  = i_last;

endmodule

module zero_counter(    input bit [31:0] i_num,
                        input bit clk, 
                        input bit rst, 
                        input bit i_valid,
                        input bit i_last,
                        output bit [31:0] o_count,
                        output bit o_valid
                        );
    // Probes for all module ports
	
	// Member variables for module

	// Probes for select internal registers

	// Instantiations of submodules

	// Procedural code

    always@(posedge clk) begin 
        if (rst) begin 
            o_count <= 32'd0;
            o_valid <= 1'b0;
        end 
        else begin 
            if (i_valid) begin 
                if (i_num==0) begin  
                    o_count <= o_count+1;
                    //o_valid goes high after full stream arrives, when i_last goes 1
                end 
            end
            o_valid<=i_last;
            //setting o_count to zero 
            //if output 
            if (o_valid) begin 
                o_count<=1'b0;
            end 
        end
    end 
endmodule
