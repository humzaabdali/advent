//FIFO after Ranger and before BCD converter
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

	invert inst1 ( .in(in) );   // Sub-modules work too.

endmodule

module FIFO(input clk, input rst,
            input [31:0] i_data, output [31:0] o_data,
           output o_full, output o_empty
           input i_valid, input i_enable);
    
    localparam datasize = 32;
    localparam addrsize = 256;
    
    //4 bytes and 256 addresses 
    reg[datasize-1:0] memory[addrsize-1:0];
    //pointers for reading and writing 
    reg [addrsize-1:0] read_addr, write_addr;

    always@(posedge clk) begin 
        
    end 
    
endmodule

