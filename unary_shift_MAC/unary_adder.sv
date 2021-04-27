`default_nettype none

/*
 * unary_adder
 * ____________
 *
 * Adds two unary signals, a and b, and outputs in unary. a and b should 
 * start on the same cycle, and new inputs should not be provided until 
 * after the output goes low for correct results.
 *
 * Inputs:
 *   - a                          Input signal a, in unary                       
 *   - b                          Input signal b, in unary
 *
 * Outputs:
 *   - out                        a + b, in unary. Output starts as soon 
 *                                as either of the inputs goes high.
 */
module unary_adder #(
    parameter U_BITS = 16
)(
    input  logic clk,
    input  logic reset_n,

    input  logic a,
    input  logic b,

    output logic out
);

    logic lifo_push;
    logic lifo_pop;
    logic lifo_out;

    /*
     * Store b in a lifo, start popping once a is done being high
     */
    serial_stack #(U_BITS) lifo (
        .clk      (clk),
        .reset_n  (reset_n),

        .in       (b),

        .push     (lifo_push),
        .pop      (lifo_pop),

        .out      (lifo_out)
    );


    always_comb begin
        lifo_push = a;
        lifo_pop = ~b & ~a;
    end

    assign out = a | b | lifo_out;

endmodule: unary_adder
