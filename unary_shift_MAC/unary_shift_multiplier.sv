`default_nettype none

/*
 * unary_shift_multiplier
 * _________________________
 *
 * This module implements the multiply function using three shift registers
 * and an FSM.
 *
 * Inputs:
 *   - clk                        The system clock.
 *   - reset_n                    Active low reset signal.
 *   - in_a                       Operand A, input serially in unary.
 *   - in_b                       Operand B, input serially in unary.
 *   - in_valid                   A valid signal that guards in_a and in_b.
 *
 * Outputs:
 *   - out                        The product of in_a and in_b, as serial unary.
 */
module unary_shift_multiplier #(
    parameter BIN_BITS = 4
) (
    input  logic clk,
    input  logic reset_n,
    input  logic in_a,
    input  logic in_b,

    output logic out
);

    localparam U_BITS = 1 << BIN_BITS;

    logic [U_BITS - 1:0] unary_a;
    logic                shift_a;

    sipo_shift #(U_BITS) shift_in_a (
        .clk      (clk),
        .reset_n  (reset_n),
        .in       (in_a),
        .shift    (shift_a),
        .out      (unary_a)
    );

    logic load_b;
    logic shift_b;
    logic empty_n;

    siso_shift #(U_BITS) shift_in_b (
        .clk      (clk),
        .reset_n  (reset_n),
        .in       (in_b & load_b),
        .shift    (shift_b),
        .out      (empty_n)
    );

    /* 
     * The number of bits to take from the out_queue; 
     * 2 to detect when we are outputting the last bit
     */
    localparam OUT_BITS = 2;

    logic load_out;
    logic last_n;
    logic shift_out;
    logic clear_out;

    pipo_shift #(U_BITS, OUT_BITS) out_queue (
        .clk      (clk),
        .reset_n  (reset_n),
        .in       (unary_a),
        .clear    (clear_out),
        .load_in  (load_out),
        .shift    (shift_out),
        .out      ({last_n, out})
    );

    localparam NUM_STATES = 2;
    enum logic [$clog2(NUM_STATES) - 1:0] {
        READ,
        OUTPUT
    } state_c, state_q;

    logic in_valid;
    logic in_valid_q;

    always_ff @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            in_valid_q <= 'b0;
        end

        else begin
            in_valid_q <= in_valid;
        end
    end

    assign in_valid = (in_a | in_b) | (in_valid_q & ~empty_n);

    assign shift_a   = in_valid;
    assign shift_b   = in_valid | (~last_n & empty_n);
    assign load_b    = in_valid;
    assign shift_out = ~load_out;

    always_comb begin
        state_c = state_q;

        load_out  = 'b0;
        clear_out = 'b0;

        case(state_q)
            READ: begin
                if(!in_valid && empty_n) begin
                    state_c = OUTPUT;
                end

                /* OR ~empty_n is to handle multiplying by 0 */
                clear_out = in_valid | ~empty_n;
                load_out  = !in_valid;
            end

            OUTPUT: begin
                if(!last_n && !empty_n) begin
                    state_c = READ;
                end

                clear_out = !last_n && !empty_n;
                load_out  = !last_n && empty_n;
            end
        endcase
    end

    always_ff @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            state_q <= READ;
        end

        else begin
            state_q <= state_c;
        end
    end

endmodule: unary_shift_multiplier
