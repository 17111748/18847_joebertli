`default_nettype none 

module test(); 
    logic clk, reset_n, valid, ready; 
    logic [3:0] a; 
    logic [3:0] b; 
    logic [3:0] c; 
    logic [7:0] out; 

  
    unary_binary_MAC #(4) dut(.clk(clk), .reset_n(reset_n), .valid(valid), .a(a), .b(b), .c(c), .ready(ready), .out(out));

 
    initial begin
        reset_n = 0; 
        reset_n <= 1; 
        clk = 0; 
        forever #5 clk = ~clk;  
    end 
 
    initial begin 
        $monitor($time,, "a_reg = %b, b_reg = %b, c_reg = %b, counter_out = %d, unary = %b, unary_out = %b, ready = %b, out = %d",
             dut.a_reg, dut.b_reg, dut.c_reg, dut.counter_out, dut.unary, dut.unary_out, ready, out); 
    end 
 
    initial begin 
 
        a <= 4'd15; 
        b <= 4'd15; 
        c <= 4'd15; 
        valid <= 1'b1; 
        @(posedge clk); 
        valid <= 1'b0; 
        @(posedge clk); 
        @(posedge clk);
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk);
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk);
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk);
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk);
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk);
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk);

        $finish; 
    end 


endmodule: test 
