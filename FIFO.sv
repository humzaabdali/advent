module top_module();

    // ── Clock ──────────────────────────────────────────────────────────
    reg clk = 0;
    always #5 clk = ~clk;  // 10ns period

    initial `probe_start;
    `probe(clk);

    // ── DUT signals ────────────────────────────────────────────────────
    reg  [31:0] i_data;
    reg         i_write_enable, i_rd_enable, rst;
    wire [31:0] o_data;
    wire        o_full, o_empty;

    `probe(i_data);
    `probe(i_write_enable);
    `probe(i_rd_enable);
    `probe(rst);
    `probe(o_data);
    `probe(o_full);
    `probe(o_empty);
    `probe(dut.read_ptr);
    `probe(dut.write_ptr);
    `probe(dut.can_write);
    `probe(dut.can_read);

    // ── DUT instantiation ──────────────────────────────────────────────
    FIFO dut (
        .clk            (clk),
        .rst            (rst),
        .i_data         (i_data),
        .o_data         (o_data),
        .o_full         (o_full),
        .o_empty        (o_empty),
        .i_write_enable (i_write_enable),
        .i_rd_enable    (i_rd_enable)
    );

    // ── Stimulus ───────────────────────────────────────────────────────
    initial begin

        i_data         = 0;
        i_write_enable = 0;
        i_rd_enable    = 0;

        // ── RESET ──────────────────────────────────────────────────────
        rst = 1;
        repeat(4) @(posedge clk);
        rst = 0;
        @(posedge clk);

        // ──────────────────────────────────────────────────────────────
        // TEST 1: write a few values, check o_empty drops
        // ──────────────────────────────────────────────────────────────
        $display("=== TEST 1: write 5 values ===");
        i_write_enable = 1;
        i_data = 32'd10; @(posedge clk);
        i_data = 32'd20; @(posedge clk);
        i_data = 32'd30; @(posedge clk);
        i_data = 32'd40; @(posedge clk);
        i_data = 32'd50; @(posedge clk);
        i_write_enable = 0;
        @(posedge clk);
        $display("  o_empty should be 0: %b", o_empty);
        $display("  o_data should be 10: %0d", o_data);

        // ──────────────────────────────────────────────────────────────
        // TEST 2: read back all 5 values
        // ──────────────────────────────────────────────────────────────
        i_rd_enable = 1;
		$display("  o_data: %0d (expect 10)", o_data);  // sample before first edge
		@(posedge clk); $display("  o_data: %0d (expect 20)", o_data);
		@(posedge clk); $display("  o_data: %0d (expect 30)", o_data);
		@(posedge clk); $display("  o_data: %0d (expect 40)", o_data);
		@(posedge clk); $display("  o_data: %0d (expect 50)", o_data);
		i_rd_enable = 0;

        // ──────────────────────────────────────────────────────────────
        // TEST 3: simultaneous read and write
        // ──────────────────────────────────────────────────────────────
        $display("=== TEST 3: simultaneous read and write ===");
        // pre-load one value
        i_write_enable = 1;
        i_data = 32'd100; @(posedge clk);
        i_write_enable = 0;
        @(posedge clk);

        // now read and write at the same time
        i_write_enable = 1;
        i_rd_enable    = 1;
        i_data = 32'd200; @(posedge clk);
        i_data = 32'd300; @(posedge clk);
        i_write_enable = 0;
        i_rd_enable    = 0;
        @(posedge clk);
        $display("  (check waveform: read and write pointers advancing together)");

        // ──────────────────────────────────────────────────────────────
        // TEST 4: read from empty FIFO — should do nothing
        // ──────────────────────────────────────────────────────────────
        $display("=== TEST 4: read from empty FIFO ===");
        // drain whatever is left first
        i_rd_enable = 1;
        repeat(10) @(posedge clk);
        i_rd_enable = 0;
        @(posedge clk);
        $display("  o_empty should be 1: %b", o_empty);
        $display("  read_ptr should not have moved past write_ptr");

        $display("=== All tests done ===");
        #50 $finish;
    end

endmodule

module FIFO(input clk, input rst,
            input [31:0] i_data, output [31:0] o_data,
           output o_full, output o_empty,
           input i_write_enable, input i_rd_enable);
    
    localparam datasize = 32;
    localparam addrsize = 512;
    localparam addrexp=9;
    
    //4 bytes and 256 addresses 
    reg[datasize-1:0] memory[addrsize-1:0];
    //pointers for reading and writing 
    reg [addrexp:0] read_ptr, write_ptr;
    
    wire is_empty, is_full;
    wire can_write, can_read;
    
    assign can_write = (i_write_enable && (~is_full));
    assign can_read = (~(is_empty)&&(i_rd_enable));
    
    assign is_empty = (read_ptr == write_ptr);
    assign is_full =(read_ptr[9]!=write_ptr[9]) && (read_ptr[addrexp-1:0]==write_ptr[addrexp-1:0]);
    
    
    //reset handling
    always@(posedge clk) begin 
        if (rst) begin 
            read_ptr<=0;
            write_ptr<=0;
        end 
    end 
    
    //write occurs if valid ==1 (from Ranger) and (full == 0)
    always@(posedge clk) begin 
        if (can_write) begin 
            memory[write_ptr[addrexp-1:0]]<=i_data;
            write_ptr<=write_ptr+1;
        end 
    end 
    
    assign o_data = memory[read_ptr[addrexp-1:0]];
    
    //read and write 
    //2'b00: no read or write 
    //2'b01
    //2'b10
    //2'b11 
    always@(posedge clk) begin 
        case({can_write,can_read})
            2'b00: begin // do nothing teehee
            end 
            2'b01: begin 
            // read only 
                read_ptr<=read_ptr+1;
            end 
            2'b10:begin 
                //write only
                
            end 
            2'b11: begin 
                read_ptr<=read_ptr+1;
            end 
        endcase
    end 
    
    assign o_full = is_full;
    assign o_empty = is_empty;
    
endmodule