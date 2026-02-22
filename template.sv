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

module template(input in, output out);
    // Probes for all module ports
    `probe(in);
    `probe(out);
	
	// Member variables for module

	// Probes for select internal registers

	// Instantiations of submodules

	// Procedural code
	assign out = ~in;

endmodule