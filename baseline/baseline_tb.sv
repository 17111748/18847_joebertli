`default_nettype none

module prod_block_tb();
    logic clk, reset_n, in_rdy, done, out;
    logic [3:0] w, x;

    Product_Block dut(.*);

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    task reset();
        reset_n  = 1'b1;
        reset_n <= 1'b0;
        @(posedge clk);
        reset_n <= 1'b1;
    endtask

    initial begin
        $monitor($time,, "in_rdy: %b, clk: %d | w: %d | x: %d | done: %b, out: %d", in_rdy, clk, w, x, done, out);
        reset();

        in_rdy <= 1'd1;
        w      <= 4'd2;
        x      <= 4'd3;
        @ (posedge clk);

        in_rdy <= 1'd0;
        @ (posedge clk);

        #20 in_rdy <= 1'd1;
        w <= 4'd3;
        x <= 4'd5;
        @ (posedge clk);
        @ (posedge clk);

        in_rdy <= 1'd0;
        @ (posedge clk);
        #50 $finish;

        //    in_rdy = 1'd1;
        //    w = 4'd1;
        //    x = 4'd2;
        //#10
        //    w = 4'd4;
        //    x = 4'd2;
        //#20 $finish;
    end


endmodule: prod_block_tb
