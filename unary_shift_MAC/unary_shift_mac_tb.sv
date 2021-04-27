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

    logic [2 * BIN_BITS:0] out_counter;
    logic clear_counter;
    always_ff @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            out_counter <= 'b0;
        end

        else if(clear_counter) begin
            out_counter <= 'b0;
        end

        else if(out) begin
            out_counter <= out_counter + 'b1;
        end
    end

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

        while(a_bin > 0 || b_bin > 0 || c_bin > 0) begin
            if(a_bin > 0) begin
                a <= 1'b1;
                a_bin--;
            end

            else begin
                a <= 1'b0;
            end

            if(b_bin > 0) begin
                b <= 1'b1;
                b_bin--;
            end

            else begin
                b <= 1'b0;
            end

            if(c_bin > 0) begin
                c <= 1'b1;
                c_bin--;
            end

            else begin
                c <= 1'b0;
            end

            @(posedge clk);
        end
        a <= 1'b0;
        b <= 1'b0;
        c <= 1'b0;

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
        clear_counter <= 1'b1;
        @(posedge clk);
        clear_counter <= 1'b0;

        a_bin = a_in;
        b_bin = b_in;
        c_bin = c_in;

        send_input();

        for(i = 0; i < 300; i++) begin
            @(posedge clk);
        end

        if(out_counter != a_bin * b_bin + c_bin) begin
            $display("Incorrect; a = %d, b = %d, c = %d, output = %d", 
                        a_bin, b_bin, c_bin, out_counter);
            $fatal("Aborting");
        end
    endtask

    initial begin
        a_bin   = 4'd0;
        b_bin   = 4'd0;
        c_bin   = 4'd0;
        out_bin = 4'd0;
        a       = 'b0;
        b       = 'b0;
        c       = 'b0;

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
