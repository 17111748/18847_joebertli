`default_nettype none

module serial_stack #(
    parameter NUM_BITS = 16
)(
    input  logic clk,
    input  logic reset_n,
    input  logic in,

    input  logic push,
    input  logic pop,

    input  logic clear,

    output logic out
);
    
    logic [NUM_BITS - 1:0] lifo_q;
    logic [NUM_BITS - 1:0] lifo_d;

    always_comb begin
        lifo_d = lifo_q;

        if(push) begin
            lifo_d = (lifo_q << 1) | in;
        end

        if(pop) begin
            lifo_d = lifo_q >> 1;
        end
    end

    assign out = lifo_q[0];

    always_ff @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            lifo_q <= 'b0;
        end

        else if(clear) begin
            lifo_q <= 'b0;
        end

        else begin
            lifo_q <= lifo_d;
        end
    end



    

endmodule: serial_stack
