module Binary_to_BCD
  #(parameter INPUT_WIDTH,
    parameter DECIMAL_DIGITS)
  (
   input                         i_Clock,
   input [INPUT_WIDTH-1:0]       i_Binary,
   input                         i_Start,
   //
   output [DECIMAL_DIGITS*4-1:0] o_BCD,
   output                        o_DV,
   input reset
   );
   
  parameter s_IDLE              = 3'b000;
  parameter s_SHIFT             = 3'b001;
  parameter s_CHECK_SHIFT_INDEX = 3'b010;
  parameter s_ADD               = 3'b011;
  parameter s_CHECK_DIGIT_INDEX = 3'b100;
  parameter s_BCD_DONE          = 3'b101;
   
  reg [2:0] r_SM_Main = s_IDLE;
   
  // The vector that contains the output BCD
  reg [DECIMAL_DIGITS*4-1:0] r_BCD = 0;
    
  // The vector that contains the input binary value being shifted.
  reg [INPUT_WIDTH-1:0]      r_Binary = 0;
      
  // Keeps track of which Decimal Digit we are indexing
  reg [DECIMAL_DIGITS-1:0]   r_Digit_Index = 0;
    
  // Keeps track of which loop iteration we are on.
  // Number of loops performed = INPUT_WIDTH
  reg [7:0]                  r_Loop_Count = 0;
 
  wire [3:0]                 w_BCD_Digit;
  reg                        r_DV = 1'b0;                       
    
  always @(posedge i_Clock)
    begin
 
      case (r_SM_Main) 
  
        // Stay in this state until i_Start comes along
        s_IDLE :
          begin
            r_DV <= 1'b0;
             
            if (i_Start == 1'b1)
              begin
                r_Binary  <= i_Binary;
                r_SM_Main <= s_SHIFT;
                r_BCD     <= 0;
              end
            else
              r_SM_Main <= s_IDLE;
          end                 
  
        // Always shift the BCD Vector until we have shifted all bits through
        // Shift the most significant bit of r_Binary into r_BCD lowest bit.
        s_SHIFT :
          begin
            r_BCD     <= r_BCD << 1;
            r_BCD[0]  <= r_Binary[INPUT_WIDTH-1];
            r_Binary  <= r_Binary << 1;
            r_SM_Main <= s_CHECK_SHIFT_INDEX;
          end                   
  
        // Check if we are done with shifting in r_Binary vector
        s_CHECK_SHIFT_INDEX :
          begin
            if (r_Loop_Count == INPUT_WIDTH-1)
              begin
                r_Loop_Count <= 0;
                r_SM_Main    <= s_BCD_DONE;
              end
            else
              begin
                r_Loop_Count <= r_Loop_Count + 1;
                r_SM_Main    <= s_ADD; 
              end
          end
 
        // Break down each BCD Digit individually. Check them one-by-one to 
        // see if they are greater than 4. If they are, increment by 3. 
        // Put the result back into r_BCD Vector. 
        s_ADD : 
          begin
            if (w_BCD_Digit > 4)
              begin                                     
                r_BCD[(r_Digit_Index*4)+:4] <= w_BCD_Digit + 3;  
              end
             
            r_SM_Main <= s_CHECK_DIGIT_INDEX; 
          end       
         
        // Check if we are done incrementing all of the BCD Digits
        s_CHECK_DIGIT_INDEX :
          begin
            if (r_Digit_Index == DECIMAL_DIGITS-1)
              begin
                r_Digit_Index <= 0;
                r_SM_Main     <= s_SHIFT;
              end
            else
              begin
                r_Digit_Index <= r_Digit_Index + 1;
                r_SM_Main     <= s_ADD;
              end
          end
  
        s_BCD_DONE :
          begin
            r_DV      <= 1'b1;
            r_SM_Main <= s_IDLE;
          end
                  
        default :
          r_SM_Main <= s_IDLE;
            
      endcase
    end // always @ (posedge i_Clock)  
 
  assign w_BCD_Digit = r_BCD[r_Digit_Index*4 +: 4];
       
  assign o_BCD = r_BCD;
  assign o_DV  = r_DV;
      
endmodule // Binary_to_BCD

module max_finder (
    input  [39:0]    i_BCD_vector,
    input            i_valid,
    output reg [7:0] o_max_vector,
    output reg       o_valid
);

    integer i;
    reg [3:0] running_max;
    reg [7:0] best_pair;

    always @(*) begin
        running_max = i_BCD_vector[3:0];   // seed with digit 0
        best_pair   = 8'd0;

        for (i = 1; i <= 9; i = i + 1) begin
            if ({i_BCD_vector[i*4 +: 4], running_max} >= best_pair)
                best_pair = {i_BCD_vector[i*4 +: 4], running_max};
            if (i_BCD_vector[i*4 +: 4] >= running_max)
                running_max = i_BCD_vector[i*4 +: 4];
        end

        o_max_vector = best_pair;
        o_valid      = i_valid;
    end

endmodule



module BCD_accum(
input [7:0] i_max_vector,
input i_valid,
output reg [31:0] o_accumulated_sum,
input clk,
input rst
);

    always @(posedge clk) begin
        if (rst)
            o_accumulated_sum <= 32'd0;
        else if (i_valid)
            o_accumulated_sum <= o_accumulated_sum + i_max_vector;
    end


endmodule

`timescale 1ns/1ps

module top_module();

    // ── Clock & reset ────────────────────────────────────────────
    reg clk = 0;
    reg rst = 1;
    always #5 clk = ~clk;          // 100 MHz

    // ── DUT-to-DUT wires ─────────────────────────────────────────
    // Binary_to_BCD → max_finder
    wire [39:0] bcd_out;           // o_BCD  (10 digits × 4 bits)
    wire        bcd_dv;            // o_DV   (data valid pulse)

    // max_finder → BCD_accum
    wire [7:0]  max_vec;           // o_max_vector
    wire        max_valid;         // o_valid (tied to bcd_dv below)

    // Accumulator result
    wire [31:0] accum_sum;

    // ── Binary_to_BCD stimulus ports ─────────────────────────────
    reg [31:0]  bin_in  = 0;
    reg         start   = 0;

    // ── Instantiate Binary_to_BCD ─────────────────────────────────
    // 32-bit binary → 10 BCD digits (10 × 4 = 40 bits)
    Binary_to_BCD #(
        .INPUT_WIDTH    (32),
        .DECIMAL_DIGITS (10)
    ) u_b2bcd (
        .i_Clock  (clk),
        .i_Binary (bin_in),
        .i_Start  (start),
        .o_BCD    (bcd_out),
        .o_DV     (bcd_dv),
        .reset    (rst)
    );

    // ── Instantiate max_finder ────────────────────────────────────
    // o_valid is purely combinational in the source; drive it from bcd_dv
    max_finder u_max (
        .i_BCD_vector (bcd_out),
        .i_valid      (bcd_dv),
        .o_max_vector (max_vec),
        .o_valid      (max_valid)   // combinational — valid same cycle as bcd_dv
    );

    // ── Instantiate BCD_accum ─────────────────────────────────────
    BCD_accum u_accum (
        .clk              (clk),
        .rst              (rst),          // NOTE: add rst to BCD_accum port list
        .i_valid          (max_valid),
        .i_max_vector     (max_vec),
        .o_accumulated_sum(accum_sum)
    );

    // ── Task: submit one binary value and wait for DV ─────────────
    task automatic submit;
        input [31:0] val;
        input [63:0] label;       // just for display — pass a string literal
        begin
            @(negedge clk);
            bin_in = val;
            start  = 1;
            @(negedge clk);
            start  = 0;
            // Wait until the converter asserts o_DV
            @(posedge bcd_dv);
            @(posedge clk);       // let accum latch
            #1;
            $display("[%0t] val=%0d  BCD=%010h  max_pair=0x%02h  accum=%0d",
                     $time, val, bcd_out, max_vec, accum_sum);
        end
    endtask

    // ── Stimulus ──────────────────────────────────────────────────
    integer i;
    initial begin
        $dumpfile("tb_pipeline.vcd");
        $dumpvars(0, top_module);

        // Release reset after a few clocks
        repeat (4) @(posedge clk);
        rst = 0;
        repeat (2) @(posedge clk);

        // ── Test 1: zero
        submit(32'd0,          "zero           ");

        // ── Test 2: single digit boundaries
        submit(32'd9,          "nine           ");
        submit(32'd10,         "ten            ");
        submit(32'd99,         "ninety-nine    ");

        // ── Test 3: known values — easy to verify by hand
        submit(32'd1234,       "1234           ");
        submit(32'd5678,       "5678           ");
        submit(32'd9999,       "9999           ");

        // ── Test 4: larger values
        submit(32'd123456789,  "123456789      ");
        submit(32'd999999999,  "999999999      ");
        submit(32'd1000000000, "1000000000     ");

        // ── Test 5: max 32-bit value
        submit(32'hFFFFFFFF,   "0xFFFFFFFF     ");

        // ── Test 6: rapid-fire — check no values are dropped
        for (i = 1; i <= 5; i = i + 1)
            submit(i * 32'd111111111, "burst          ");

        // Final accumulator readout
        repeat (4) @(posedge clk);
        $display("[%0t] ── Final accumulated sum = %0d ──", $time, accum_sum);

        $finish;
    end

    // ── Timeout watchdog ─────────────────────────────────────────
    initial begin
        #2_000_000;
        $display("TIMEOUT — simulation did not finish");
        $finish;
    end

endmodule
