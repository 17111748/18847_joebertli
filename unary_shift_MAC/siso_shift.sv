`default_nettype none

module siso_shift #(
    parameter N        = 16,
    parameter RIGHT    = 1
) (
    input  logic clk,
    input  logic reset_n,

    input  logic in,
    input  logic shift,

    output logic out
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

        else begin
            if(shift) begin
                out_q <= out_c;
            end
        end
    end
    
    assign out = out_q[0];

endmodule: siso_shift
