`timescale 1ns/1ps

module top_module ();

    reg i_Clock = 0;
    always #5 i_Clock = ~i_Clock;

    initial `probe_start;

    // DUT inputs
    reg  [31:0] i_Binary;
    reg         i_Start;

    // DUT outputs
    wire [39:0] o_BCD;
    wire        o_DV;

    // Top-level probes
    `probe(i_Clock);
    `probe(i_Binary);
    `probe(i_Start);
    `probe(o_BCD);
    `probe(o_DV);

    // Instantiate DUT
    Binary_to_BCD #(
        .INPUT_WIDTH(32),
        .DECIMAL_DIGITS(10)
    ) dut (
        .i_Clock(i_Clock),
        .i_Binary(i_Binary),
        .i_Start(i_Start),
        .o_BCD(o_BCD),
        .o_DV(o_DV)
    );

    // Internal DUT probes
    `probe(dut.r_SM_Main);
    `probe(dut.r_BCD);
    `probe(dut.r_Binary);
    `probe(dut.r_Digit_Index);
    `probe(dut.r_Loop_Count);
    `probe(dut.w_BCD_Digit);
    `probe(dut.r_DV);

    task automatic send_value(input [31:0] val);
        begin
            @(negedge i_Clock);
            i_Binary <= val;
            i_Start  <= 1'b1;

            @(negedge i_Clock);
            i_Start  <= 1'b0;

            wait (o_DV == 1'b1);
            @(posedge i_Clock);

            $display("time=%0t  i_Binary=%0d  o_BCDdigit1=%h o_BCFDdigit2=%h  o_DV=%b",
                     $time, val, o_BCD[7:4], o_BCD[3:0], o_DV);
        end
    endtask

    initial begin
        i_Binary = 32'd0;
        i_Start  = 1'b0;

        send_value(32'd0);
        send_value(32'd7);
        send_value(32'd42);
        send_value(32'd99);
        send_value(32'd123);
        send_value(32'd999);
        send_value(32'd12345);
        send_value(32'd987654321);

        repeat (5) @(negedge i_Clock);
        $finish;
    end

endmodule

module Binary_to_BCD
  #(parameter INPUT_WIDTH,
    parameter DECIMAL_DIGITS)
  (
   input                         i_Clock,
   input [INPUT_WIDTH-1:0]       i_Binary,
   input                         i_Start,
   //
   output [DECIMAL_DIGITS*4-1:0] o_BCD,
   output                        o_DV
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