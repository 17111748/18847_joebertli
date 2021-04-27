`default_nettype none

module unary_shift_mac #(
    parameter BIN_BITS = 4
)(
    input  logic clk,
    input  logic reset_n,

    input  logic a, 
    input  logic b, 
    input  logic c,

    output logic out
);
    localparam U_BITS = 1 << BIN_BITS;

    logic mult_out;
    unary_shift_multiplier #(BIN_BITS) multiply (
        .clk      (clk),
        .reset_n  (reset_n),
        .in_a     (a),
        .in_b     (b),
        .out      (mult_out)
    );

    /* Delay c so that the adder gets both inputs at the same time */
    logic push_c;
    logic pop_c;
    logic c_reg;
    serial_stack #(U_BITS) c_reg (
        .clk      (clk),
        .reset_n  (reset_n),
        .in       (c),
        .push     (push_c),
        .pop      (pop_c),
        .out      (c_reg)
    );

    unary_adder #(2 * BIN_BITS) add (
        .clk      (clk),
        .reset_n  (reset_n),
        .a        (add_a),
        .b        (add_b),
        .out      (add_out)
    );

    enum {
        MULT,
        ADD
    } state_c, state_q;

    always_comb begin
        state_c = state_q;
        pop_c   = 'b0;
        push_c  = 'b0;
        add_a   = 'b0;
        add_b   = 'b0;

        case(state_q)
            MULT: begin
                if(c) begin
                    push_c = 1'b1;
                end

                if(mult_out) begin
                    state_c = ADD;
                    pop_c = 1'b1;

                    add_a = mult_out;
                    add_b = c_reg;
                end
            end

            ADD: begin
                add_a = mult_out;
                add_b = c_reg;

                pop_c = 1'b1;

                if(!add_out) begin
                    state_c = MULT;
                end
            end
        endcase
    end


endmodule: unary_shift_mac
