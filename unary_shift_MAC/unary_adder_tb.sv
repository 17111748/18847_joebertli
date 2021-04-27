`default_nettype none

module unary_adder_tb ();
    logic clk;
    logic reset_n;
    logic a, b, out;

    unary_adder #(16) dut (
        .*
    );

    logic [3:0] out_counter;
    logic clear;
    always_ff @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            out_counter <= 'b0;
        end

        else if(clear) begin
            out_counter <= 'b0;
        end

        else if(out) begin
            out_counter <= out_counter + 1;
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
    task test_case(
        int in_a,
        int in_b
    );
        clear <= 1'b1;
        @(posedge clk);
        clear <= 1'b0;
        @(posedge clk);

        /* Send inputs */
        i = 0;
        while(i < in_a && i < in_b) begin
            a <= 1'b1;
            b <= 1'b1;
            @(posedge clk);
            i++;
        end

        while(i < in_a) begin
            a <= 1'b1;
            b <= 1'b0;
            @(posedge clk);
            i++;
        end

        while(i < in_b) begin
            a <= 1'b0;
            b <= 1'b1;
            @(posedge clk);
            i++;
        end

        while(i < in_a + in_b + 10) begin
            a <= 1'b0;
            b <= 1'b0;
            @(posedge clk);
            i++;
        end

        if(out_counter != in_a + in_b) begin
            $display("Error: gave %d + %d == %d", in_a, in_b, out_counter);
            $fatal();
        end
    endtask

    initial begin
        reset();
        a = 'b0;
        b = 'b0;

        test_case(3, 3);
        test_case(7, 7);
        test_case(0, 0);

        test_case(3, 2);
        test_case(8, 7);
        test_case(5, 0);

        test_case(2, 3);
        test_case(7, 8);
        test_case(0, 6);
        

        @(posedge clk);
        $display("All tests passed!");
        $finish();
    end
endmodule: unary_adder_tb
