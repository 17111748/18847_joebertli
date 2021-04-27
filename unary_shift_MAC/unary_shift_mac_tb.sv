`default_nettype none

module unary_shift_mult_tb ();
    localparam BIN_BITS = 4;
    localparam U_BITS   = 1 << BIN_BITS;

    logic clk;
    logic reset_n;
    logic a;
    logic b;
    logic c;
    logic out;

    logic [BIN_BITS - 1:0] a_bin;
    logic [BIN_BITS - 1:0] b_bin;
    logic [BIN_BITS - 1:0] c_bin;
    logic [BIN_BITS - 1:0] out_bin;

    unary_shift_mac dut (
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
    int t0, t1, t2;
    task send_input();
        t0 = a_bin;
        t1 = b_bin;
        t2 = c_bin;

        in_valid <= 1;
        for(i = 0; i < U_BITS; i++) begin
            a <= a_bin > 0;
            b <= b_bin > 0;
            c <= c_bin > 0;

            if(a_bin > 0) begin
                a_bin--;
            end

            if(b_bin > 0) begin
                b_bin--;
            end

            if(c_bin > 0) begin
                c_bin--;
            end

            @(posedge clk);
        end

        @(posedge clk);
        
        a_bin = t0;
        b_bin = t1;
        c_bin = t2;
    endtask

    task test_case(
            logic [BIN_BITS - 1:0] a_in,
            logic [BIN_BITS - 1:0] b_in,
            logic [BIN_BITS - 1:0] c_in
    );
        a_bin = a_in;
        b_bin = b_in;
        c_bin = c_in;
        out_bin = 4'd0;

        send_input();

        for(i = 0; i < 260; i++) begin
            if(out) begin
                out_bin++;
            end

            @(posedge clk);
        end

        if(out_bin != a_bin * b_bin + c_bin) begin
            $display("Incorrect; a = %d, b = %d, c = %d, output = %d", 
                        a_bin, b_bin, c_bin, out_bin);
            $fatal("Aborting");
        end
    endtask

    initial begin
        in_valid = 1'b0;
        a_bin    = 4'd0;
        b_bin    = 4'd0;
        c_bin    = 4'd0;
        out_bin  = 4'd0;

        reset();

        test_case(3, 2, 6);
        test_case(4, 15, 3);
        test_case(3, 0, 1);
        test_case(0, 5, 3);
        test_case(15, 15, 0);
        test_case(10, 9, 10);

        $display("All tests passed.");
        $finish();
    end
endmodule: unary_shift_mult_tb
