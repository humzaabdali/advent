module top_module();

    // ── Clock ──────────────────────────────────────────────────────────
    reg clk = 0;
    always #5 clk = ~clk;   // 10ns period

    initial `probe_start;
    `probe(clk);

    // ── DUT signals ────────────────────────────────────────────────────
    reg  [31:0] i_start_range, i_end_range;
    reg         i_start, i_fifo_full, rst;
    wire [31:0] o_num;
    wire        o_valid;

    `probe(i_start_range);
    `probe(i_end_range);
    `probe(i_start);
    `probe(i_fifo_full);
    `probe(rst);
    `probe(o_num);
    `probe(o_valid);
    `probe(dut.state_reg);
	`probe(dut.current);

    // ── DUT instantiation ──────────────────────────────────────────────
    Ranger dut (
        .i_start_range(i_start_range),
        .i_end_range  (i_end_range),
        .o_num        (o_num),
        .i_start      (i_start),
        .i_fifo_full  (i_fifo_full),
        .o_valid      (o_valid),
        .clk          (clk),
        .rst          (rst)
    );

    // ── Stimulus ───────────────────────────────────────────────────────
    initial begin

        // initialise everything
        i_start_range = 0;
        i_end_range   = 0;
        i_start       = 0;
        i_fifo_full   = 0;

        // ── RESET ──────────────────────────────────────────────────────
        rst = 1;
        repeat(4) @(posedge clk);
        rst = 0;
        @(posedge clk);

        // ──────────────────────────────────────────────────────────────
        // TEST 1 : small range 1..5, FIFO never full
        // ──────────────────────────────────────────────────────────────
        $display("=== TEST 1: range 1..5 (FIFO always ready) ===");
        i_start_range = 32'd1;
        i_end_range   = 32'd5;
        i_start = 1;
        @(posedge clk);
        i_start = 0;

        // wait long enough for all 5 values plus idle transition
        // 5 values × 1 cycle each + generous margin = 20 cycles
        repeat(20) @(posedge clk);
        $display("  (done — check waveform: o_valid should pulse 5 times, o_num 1..5)");

        // long gap so downstream FIFO fully drains before next test
        repeat(30) @(posedge clk);

        // ──────────────────────────────────────────────────────────────
        // TEST 2 : FIFO stall mid-range (range 10..15, stall after 12)
        // ──────────────────────────────────────────────────────────────
        $display("=== TEST 2: range 10..15, FIFO stalls after value 12 ===");
        i_start_range = 32'd10;
        i_end_range   = 32'd15;
        i_start = 1;
        @(posedge clk);
        i_start = 0;

        // let it run until it has emitted 10, 11, 12
        repeat(6) @(posedge clk);

        // assert FIFO full — module should park in waiting
        i_fifo_full = 1;
        $display("  FIFO full asserted — expecting o_valid to drop");
        repeat(8) @(posedge clk);

        // drain the FIFO — module should resume stepping
        i_fifo_full = 0;
        $display("  FIFO drained — expecting o_valid to resume, 13..15 follow");
        repeat(15) @(posedge clk);
        $display("  (check waveform: o_num 10..15 with a gap at the stall)");

        // another generous drain gap
        repeat(30) @(posedge clk);

        // ──────────────────────────────────────────────────────────────
        // TEST 3 : single-value range (start == end)
        // ──────────────────────────────────────────────────────────────
        $display("=== TEST 3: single value — range 42..42 ===");
        i_start_range = 32'd42;
        i_end_range   = 32'd42;
        i_start = 1;
        @(posedge clk);
        i_start = 0;

        repeat(15) @(posedge clk);
        $display("  (check waveform: exactly one pulse — o_valid=1, o_num=42, then idle)");

        repeat(20) @(posedge clk);

        $display("=== All tests done ===");
        #50 $finish;
    end

endmodule

module Ranger(input[31:0] i_start_range, input[31:0] i_end_range, 
              output reg [31:0] o_num, input i_start, 
              input i_fifo_full, output reg o_valid,
              input clk, input rst);
    
    //state machine modeling 
    //states 
    //idle, active stepping, waiting, start
    reg [1:0] state_reg, nstate_reg;
    parameter idle =2'b00, starting =2'b01, stepping =2'b10, waiting =2'b11;
    
    reg [31:0] current, range_end;
    
    //reset handling
    always@(posedge clk) begin 
        if (rst) begin 
            state_reg<=idle;
        end 
        else begin 
            state_reg<=nstate_reg;
        end 
    end 
    
    //combinational updates before setting registers 
    always@(*) begin 
        case(state_reg)
            idle: begin 
                if (i_start) begin 
                    nstate_reg = starting;
                end 
                else begin 
                    nstate_reg = idle;
                end 
            end 
            starting: begin
                if (~i_fifo_full) begin 
                	nstate_reg=stepping;
                end 
                else begin 
                    nstate_reg = starting;
                end 
            end 
            stepping: begin
                if (~i_fifo_full) begin 
                    if(current < range_end) begin 
                        nstate_reg = stepping;
                        //keep stepping since 
                    end 
                    else begin 
                        //go to idle
                        nstate_reg = idle;
                    end 
                end 
                else begin 
                    nstate_reg = waiting;
                end 
            end
            waiting: begin
                if(~i_fifo_full) begin 
                    nstate_reg=stepping;
            	end 
                else begin 
                    nstate_reg = waiting;
                end 
            end 
        endcase
    end 
    
    //update registers/values
    always@(posedge clk) begin 
        case (state_reg)
            idle: begin 
                // literally nothing
                o_valid<=0;
                o_num<=0;
                current<=0;
                range_end<=0;
            end 
            starting: begin 
                //
                current<=i_start_range;
                range_end<=i_end_range;
                o_valid<=0;
            end 
            stepping: begin
                o_num<=current;
                o_valid<=1'b1;
                current<=current+1;
            end 
            waiting: begin 
                o_valid<=0;
            end 
        endcase 
    end 
endmodule

