`default_nettype none

module unary_shift_mult_tb ();
    localparam BIN_BITS = 4;
    localparam U_BITS   = 1 << BIN_BITS;

    logic clk;
    logic reset_n;
    logic in_a;
    logic in_b;
    logic in_valid;
    logic out;
    logic out_valid;

    logic [BIN_BITS - 1:0] a_bin;
    logic [BIN_BITS - 1:0] b_bin;
    logic [BIN_BITS - 1:0] out_bin;

    unary_shift_multiplier dut (
        .*
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task reset();
        reset_n  = 1'b1;
        reset_n <= 1'b0;
        @(posedge clk);
        reset_n <= 1'b1;
    endtask

    int i;
    int t0, t1;
    task send_input();
        t0 = a_bin;
        t1 = b_bin;

        in_valid <= 1;
        for(i = 0; i < U_BITS; i++) begin
            in_a <= a_bin > 0;
            in_b <= b_bin > 0;

            if(a_bin > 0) begin
                a_bin--;
            end

            if(b_bin > 0) begin
                b_bin--;
            end

            @(posedge clk);

            if(i == U_BITS - 1) begin
                in_valid <= 1'b0;
            end
        end

        @(posedge clk);
        
        a_bin = t0;
        b_bin = t1;
    endtask

    task test_case(
            logic [BIN_BITS - 1:0] a,
            logic [BIN_BITS - 1:0] b
    );
        a_bin = a;
        b_bin = b;
        out_bin = 4'd0;

        send_input();

        for(i = 0; i < 260; i++) begin
            if(out) begin
                out_bin++;
            end

            @(posedge clk);
        end

        if(out_bin != a_bin * b_bin) begin
            $display("Incorrect; a = %d, b = %d, output = %d", 
                        a_bin, b_bin, out_bin);
            $fatal("Aborting");
        end
    endtask

    initial begin
        in_valid = 1'b0;
        a_bin    = 4'd0;
        b_bin    = 4'd0;
        out_bin  = 4'd0;

        reset();

        test_case(3, 2);
        test_case(4, 15);
        test_case(3, 0);
        test_case(0, 5);
        test_case(15, 15);
        test_case(10, 9);

        $display("All tests passed.");
        $finish();
    end
endmodule: unary_shift_mult_tb
