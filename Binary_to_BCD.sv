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
