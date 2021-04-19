`default_nettype none

module prod_block_tb();
    logic clk, reset_n, in_rdy, out;
    logic [3:0] w, x;

    Product_Block dut(.*);

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

    initial begin
        $monitor("clk: %d | w: %d | x: %d", clk, w, x);
           w = 4'd2;
           x = 4'd1;
        #1 w = 4'd3;
           x = 4'd2;
        #1 $finish;
    end


endmodule: prod_block_tb