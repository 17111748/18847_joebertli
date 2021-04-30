`default_nettype none

module pipo_shift #(
    parameter N        = 16,
    parameter OUT_BITS = N,
    parameter RIGHT    = 1
) (
    input  logic                  clk,
    input  logic                  reset_n,

    input  logic [N - 1:0]        in,
    input  logic                  load_in,
    input  logic                  clear,
    input  logic                  shift,
    output logic [OUT_BITS - 1:0] out
);

    logic [N - 1:0] out_c;
    logic [N - 1:0] out_q;
    
    generate
        if(RIGHT) begin
            always_comb begin
                out_c = out_q;

                if(clear) begin
                    out_c = 'b0;
                end

                else if(load_in) begin
                    out_c = in;
                end

                else if(shift) begin
                    out_c = {1'b0, out_q[N - 1:1]};
                end
            end

            assign out = out_q[OUT_BITS - 1:0];

        end

        else begin
            always_comb begin
                out_c = out_q;

                if(clear) begin
                    out_c = 'b0;
                end

                else if(load_in) begin
                    out_c = in;
                end

                else if(shift) begin
                    out_c = {out_q[N - 2:0], 1'b0};
                end
            end

            assign out = out_q[N - 1:N - OUT_BITS];

        end
    endgenerate

    always_ff @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            out_q <= 'b0;
        end

        else begin
            out_q <= out_c;
        end
    end
    

endmodule: pipo_shift
