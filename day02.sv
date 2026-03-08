`timescale 1ns/1ps

module top_module ();

    reg clk = 0;
    always #5 clk = ~clk;

    initial begin
        `probe_start;
    end

    // Inputs
    reg  [31:0] i_Binary;
    reg         i_Start;

    // Stage 1 outputs
    wire [39:0] o_BCD;
    wire        o_DV;

    // Stage 2 outputs
    wire [3:0] leading_zeros;
    wire       lz_valid;

    // Stage 3 outputs
    wire       is_invalid_id;
    wire       final_valid;

    // Probes: ONLY here
    `probe(clk);
    `probe(i_Binary);
    `probe(i_Start);
    `probe(o_BCD);
    `probe(o_DV);
    `probe(leading_zeros);
    `probe(lz_valid);
    `probe(is_invalid_id);
    `probe(final_valid);

    Binary_to_BCD #(
        .INPUT_WIDTH(32),
        .DECIMAL_DIGITS(10)
    ) b2bcd (
        .i_Clock(clk),
        .i_Binary(i_Binary),
        .i_Start(i_Start),
        .o_BCD(o_BCD),
        .o_DV(o_DV)
    );

    leading_zero lz (
        .bcd_vector(o_BCD),
        .i_valid(o_DV),
        .leading_zeros(leading_zeros),
        .o_valid(lz_valid)
    );

    comparator cmp (
        .bcd_vector(o_BCD),
        .leading_zeros(leading_zeros),
        .i_valid(lz_valid),
        .is_invalid_id(is_invalid_id),
        .o_valid(final_valid)
    );

    task automatic send_value(input [31:0] val);
        begin
            @(negedge clk);
            i_Binary <= val;
            i_Start  <= 1'b1;

            @(negedge clk);
            i_Start  <= 1'b0;

            wait (final_valid === 1'b1);
            @(posedge clk);

            $display("time=%0t  bin=%0d  invalid_id=%b",
                     $time, val, is_invalid_id);
        end
    endtask

    initial begin
        i_Binary = 32'd0;
        i_Start  = 1'b0;

        send_value(32'd0);
        send_value(32'd11);
        send_value(32'd42);
        send_value(32'd99);
        send_value(32'd1212);
        send_value(32'd1234);
        send_value(32'd123123);
        send_value(32'd123456);

        repeat (5) @(negedge clk);
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
  reg [DECIMAL_DIGITS*4-1:0] r_BCD = 0;
  reg [INPUT_WIDTH-1:0]      r_Binary = 0;
  reg [DECIMAL_DIGITS-1:0]   r_Digit_Index = 0;
  reg [7:0]                  r_Loop_Count = 0;
  wire [3:0]                 w_BCD_Digit;
  reg                        r_DV = 1'b0;

  always @(posedge i_Clock) begin
    case (r_SM_Main)

      s_IDLE : begin
        r_DV <= 1'b0;
        if (i_Start == 1'b1) begin
          r_Binary  <= i_Binary;
          r_SM_Main <= s_SHIFT;
          r_BCD     <= 0;
        end
      end

      s_SHIFT : begin
        r_BCD     <= r_BCD << 1;
        r_BCD[0]  <= r_Binary[INPUT_WIDTH-1];
        r_Binary  <= r_Binary << 1;
        r_SM_Main <= s_CHECK_SHIFT_INDEX;
      end

      s_CHECK_SHIFT_INDEX : begin
        if (r_Loop_Count == INPUT_WIDTH-1) begin
          r_Loop_Count <= 0;
          r_SM_Main    <= s_BCD_DONE;
        end else begin
          r_Loop_Count <= r_Loop_Count + 1;
          r_SM_Main    <= s_ADD;
        end
      end

      s_ADD : begin
        if (w_BCD_Digit > 4)
          r_BCD[(r_Digit_Index*4)+:4] <= w_BCD_Digit + 3;
        r_SM_Main <= s_CHECK_DIGIT_INDEX;
      end

      s_CHECK_DIGIT_INDEX : begin
        if (r_Digit_Index == DECIMAL_DIGITS-1) begin
          r_Digit_Index <= 0;
          r_SM_Main     <= s_SHIFT;
        end else begin
          r_Digit_Index <= r_Digit_Index + 1;
          r_SM_Main     <= s_ADD;
        end
      end

      s_BCD_DONE : begin
        r_DV      <= 1'b1;
        r_SM_Main <= s_IDLE;
      end

      default : begin
        r_SM_Main <= s_IDLE;
      end
    endcase
  end

  assign w_BCD_Digit = r_BCD[r_Digit_Index*4 +: 4];
  assign o_BCD = r_BCD;
  assign o_DV  = r_DV;

endmodule


module leading_zero(
    input  [39:0] bcd_vector,
    input         i_valid,
    output reg [3:0] leading_zeros,
    output reg    o_valid
);

    integer i;
    reg seen_nonzero;

    always @(*) begin
        leading_zeros = 4'd0;
        seen_nonzero  = 1'b0;

        for (i = 9; i >= 0; i = i - 1) begin
            if (!seen_nonzero) begin
                if (bcd_vector[i*4 +: 4] == 4'b0000)
                    leading_zeros = leading_zeros + 1'b1;
                else
                    seen_nonzero = 1'b1;
            end
        end

        o_valid = i_valid;
    end

endmodule


module comparator(
    input [39:0] bcd_vector,
    input [3:0]  leading_zeros,
    input        i_valid,
    output reg   is_invalid_id,
    output reg   o_valid
);

    always @(*) begin
        case (leading_zeros)
            4'd0: is_invalid_id = (bcd_vector[39:20] == bcd_vector[19:0]);
            4'd2: is_invalid_id = (bcd_vector[31:16] == bcd_vector[15:0]);
            4'd4: is_invalid_id = (bcd_vector[23:12] == bcd_vector[11:0]);
            4'd6: is_invalid_id = (bcd_vector[15:8]  == bcd_vector[7:0]);
            4'd8: is_invalid_id = (bcd_vector[7:4]   == bcd_vector[3:0]);
            default: is_invalid_id = 1'b0;
        endcase

        o_valid = i_valid;
    end

endmodule

