`default_nettype none

module sipo_shift #(
    parameter N        = 16,
    parameter OUT_BITS = N,
    parameter RIGHT    = 1
) (
    input  logic                  clk,
    input  logic                  reset_n,

    input  logic                  in,
    input  logic                  shift,
    input  logic                  clear,
    output logic [OUT_BITS - 1:0] out
);

    logic [N - 1:0] out_c;
    logic [N - 1:0] out_q;
    
    generate
        if(RIGHT) begin
            assign out_c = {in, out_q[N - 1:1]};
        end

        else begin
            assign out_c = {out_q[N - 2:0], in};
        end
    endgenerate

    always_ff @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            out_q <= 'b0;
        end

        else if(clear) begin
            out_q <= 'b0;
        end

        else begin
            if(shift) begin
                out_q <= out_c;
            end
        end
    end
    
    assign out = out_q[OUT_BITS - 1:0];

endmodule: sipo_shift
