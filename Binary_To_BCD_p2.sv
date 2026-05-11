module Binary_to_BCD #(
    parameter INPUT_WIDTH    = 54,
    parameter DECIMAL_DIGITS = 16
)(
    input                         i_Clock,
    input                         reset,
    input  [INPUT_WIDTH-1:0]      i_Binary,
    input                         i_Start,

    output [DECIMAL_DIGITS*4-1:0] o_BCD,
    output                        o_DV
);

    localparam s_IDLE              = 3'b000;
    localparam s_SHIFT             = 3'b001;
    localparam s_CHECK_SHIFT_INDEX = 3'b010;
    localparam s_ADD               = 3'b011;
    localparam s_CHECK_DIGIT_INDEX = 3'b100;
    localparam s_BCD_DONE          = 3'b101;

    reg [2:0] r_SM_Main;
    reg [DECIMAL_DIGITS*4-1:0] r_BCD;
    reg [INPUT_WIDTH-1:0] r_Binary;
    reg [$clog2(DECIMAL_DIGITS)-1:0] r_Digit_Index;
    reg [$clog2(INPUT_WIDTH+1)-1:0] r_Loop_Count;
    reg r_DV;

    wire [3:0] w_BCD_Digit;

    always @(posedge i_Clock or posedge reset) begin
        if (reset) begin
            r_SM_Main     <= s_IDLE;
            r_BCD         <= 0;
            r_Binary      <= 0;
            r_Digit_Index <= 0;
            r_Loop_Count  <= 0;
            r_DV          <= 1'b0;
        end else begin
            case (r_SM_Main)

                s_IDLE: begin
                    r_DV <= 1'b0;

                    if (i_Start) begin
                        r_Binary      <= i_Binary;
                        r_BCD         <= 0;
                        r_Digit_Index <= 0;
                        r_Loop_Count  <= 0;
                        r_SM_Main     <= s_SHIFT;
                    end
                end

                s_SHIFT: begin
                    r_BCD     <= r_BCD << 1;
                    r_BCD[0]  <= r_Binary[INPUT_WIDTH-1];
                    r_Binary  <= r_Binary << 1;
                    r_SM_Main <= s_CHECK_SHIFT_INDEX;
                end

                s_CHECK_SHIFT_INDEX: begin
                    if (r_Loop_Count == INPUT_WIDTH-1) begin
                        r_Loop_Count <= 0;
                        r_SM_Main    <= s_BCD_DONE;
                    end else begin
                        r_Loop_Count  <= r_Loop_Count + 1;
                        r_Digit_Index <= 0;
                        r_SM_Main     <= s_ADD;
                    end
                end

                s_ADD: begin
                    if (w_BCD_Digit > 4)
                        r_BCD[(r_Digit_Index*4) +: 4] <= w_BCD_Digit + 3;

                    r_SM_Main <= s_CHECK_DIGIT_INDEX;
                end

                s_CHECK_DIGIT_INDEX: begin
                    if (r_Digit_Index == DECIMAL_DIGITS-1) begin
                        r_Digit_Index <= 0;
                        r_SM_Main     <= s_SHIFT;
                    end else begin
                        r_Digit_Index <= r_Digit_Index + 1;
                        r_SM_Main     <= s_ADD;
                    end
                end

                s_BCD_DONE: begin
                    r_DV      <= 1'b1;
                    r_SM_Main <= s_IDLE;
                end

                default: begin
                    r_SM_Main <= s_IDLE;
                end

            endcase
        end
    end

    assign w_BCD_Digit = r_BCD[(r_Digit_Index*4) +: 4];

    assign o_BCD = r_BCD;
    assign o_DV  = r_DV;

endmodule