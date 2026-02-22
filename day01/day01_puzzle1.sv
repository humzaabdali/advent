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
module day01_puzzle1(   input bit direction, 
                        input bit [31:0] num,
                        input bit valid,
                        input bit last,
                        output bit [31:0] count,
                        ouptut bit valid 
                        );
    // Probes for all module ports
	
	// Member variables for module

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
                accum = 32'd50;
        end
    end

    assign o_sum = accum;
endmodule

module rounder( input bit [31:0] num,
                input bit i_valid,
                input bit i_last,
                output bit i_ready,
                output bit [31:0] rounded_value,
                ouptut bit o_valid,
                output bit o_last 
                );
    // Probes for all module ports
	
	// Member variables for module

	// Probes for select internal registers

	// Instantiations of submodules

	// Procedural code
	
endmodule

module zero_counter(    input bit [31:0] num,
                        input bit i_valid,
                        input bit i_last,
                        output bit [31:0] rounded_value,
                        ouptut bit o_valid
                        );
    // Probes for all module ports
	
	// Member variables for module

	// Probes for select internal registers

	// Instantiations of submodules

	// Procedural code
	
endmodule