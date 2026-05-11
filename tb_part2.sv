module max_state #(
    parameter DECIMAL_DIGITS = 16
)(
    input  [DECIMAL_DIGITS*4-1:0] i_BCD_vector,
    input  [4:0]                  i_left_index,
    input  [4:0]                  i_right_index,

    output reg [4:0]              max_index,
    output reg [3:0]              max_digit
);

    integer i;

    always @(*) begin
        max_digit = 4'd0;
        max_index = i_right_index;

        for (i = 0; i < DECIMAL_DIGITS; i = i + 1) begin
            if (i >= i_right_index && i <= i_left_index) begin
                if (i_BCD_vector[i*4 +: 4] >= max_digit) begin
                    max_digit = i_BCD_vector[i*4 +: 4];
                    max_index = i[4:0];
                end
            end
        end
    end

endmodule


module max_finder #(
    parameter DECIMAL_DIGITS = 16,
    parameter SEQ_DIGITS     = 12
)(
    input clk,
    input rst,

    input  [DECIMAL_DIGITS*4-1:0] i_BCD_vector,
    input                         i_valid,

    output reg [SEQ_DIGITS*4-1:0] o_max_vector,
    output reg                    o_valid
);

    reg [4:0] left_index;
    reg [4:0] right_index;
    reg [3:0] digits_left;

    wire [4:0] max_index;
    wire [3:0] max_digit;

    reg [2:0] state;

    localparam IDLE  = 3'd0;
    localparam FIND  = 3'd1;
    localparam STORE = 3'd2;
    localparam DONE  = 3'd3;

    max_state #(
        .DECIMAL_DIGITS(DECIMAL_DIGITS)
    ) u_max_state (
        .i_BCD_vector(i_BCD_vector),
        .i_left_index(left_index),
        .i_right_index(right_index),
        .max_index(max_index),
        .max_digit(max_digit)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            o_valid      <= 1'b0;
            o_max_vector <= 0;
            left_index   <= 0;
            right_index  <= 0;
            digits_left  <= 0;
        end else begin
            case (state)

                IDLE: begin
                    o_valid <= 1'b0;

                    if (i_valid) begin
                        o_max_vector <= 0;
                        digits_left  <= SEQ_DIGITS;

                        left_index   <= DECIMAL_DIGITS - 1;
                        right_index  <= SEQ_DIGITS - 1;

                        state <= FIND;
                    end
                end

                FIND: begin
                    state <= STORE;
                end

                STORE: begin
                    o_max_vector[(digits_left-1)*4 +: 4] <= max_digit;

                    if (digits_left == 1) begin
                        state <= DONE;
                    end else begin
                        left_index  <= max_index - 1;
                        right_index <= digits_left - 2;
                        digits_left <= digits_left - 1;
                        state       <= FIND;
                    end
                end

                DONE: begin
                    o_valid <= 1'b1;
                    state   <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule


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


module BCD_accum #(
    parameter SEQ_DIGITS = 12
)(
    input  [SEQ_DIGITS*4-1:0] i_max_vector,
    input                     i_valid,
    input                     clk,
    input                     rst,

    output reg [63:0]         o_accumulated_sum
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            o_accumulated_sum <= 64'd0;
        else if (i_valid)
            o_accumulated_sum <= o_accumulated_sum + i_max_vector;
    end

endmodule

module top_module ();

    localparam INPUT_WIDTH    = 54;
    localparam DECIMAL_DIGITS = 16;
    localparam SEQ_DIGITS     = 12;

    reg clk = 0;
    always #5 clk = ~clk;

    initial `probe_start;
    `probe(clk);

    reg rst = 0;
    reg [INPUT_WIDTH-1:0] i_binary = 0;
    reg i_start = 0;

    wire [DECIMAL_DIGITS*4-1:0] bcd_out;
    wire bcd_valid;

    wire [SEQ_DIGITS*4-1:0] max_vector;
    wire max_valid;

    wire [63:0] accumulated_sum;

    `probe(rst);
    `probe(i_binary);
    `probe(i_start);
    `probe(bcd_out);
    `probe(bcd_valid);
    `probe(max_vector);
    `probe(max_valid);
    `probe(accumulated_sum);

    Binary_to_BCD #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .DECIMAL_DIGITS(DECIMAL_DIGITS)
    ) dut_bcd (
        .i_Clock(clk),
        .reset(rst),
        .i_Binary(i_binary),
        .i_Start(i_start),
        .o_BCD(bcd_out),
        .o_DV(bcd_valid)
    );

    max_finder #(
        .DECIMAL_DIGITS(DECIMAL_DIGITS),
        .SEQ_DIGITS(SEQ_DIGITS)
    ) dut_max_finder (
        .clk(clk),
        .rst(rst),
        .i_BCD_vector(bcd_out),
        .i_valid(bcd_valid),
        .o_max_vector(max_vector),
        .o_valid(max_valid)
    );

    BCD_accum #(
        .SEQ_DIGITS(SEQ_DIGITS)
    ) dut_accum (
        .i_max_vector(max_vector),
        .i_valid(max_valid),
        .clk(clk),
        .rst(rst),
        .o_accumulated_sum(accumulated_sum)
    );

    task run_number;
        input [INPUT_WIDTH-1:0] value;
        begin
            @(negedge clk);
            i_binary <= value;
            i_start  <= 1'b1;

            @(negedge clk);
            i_start <= 1'b0;

            wait (max_valid == 1'b1);

            @(posedge clk);

            $display("binary=%0d bcd=%h max12=%h accum=%0d",
                     value, bcd_out, max_vector, accumulated_sum);
        end
    endtask

    initial begin
        rst = 1'b1;
        repeat (4) @(posedge clk);
        rst = 1'b0;

        run_number(54'd987654321111111);
        run_number(54'd811111111111119);
        run_number(54'd234234234234278);
        run_number(54'd818181911112111);

        #100;
        $finish;
    end

endmodule