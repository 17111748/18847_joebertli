`default_nettype none 

module test(); 
    localparam SIZE = 3;
    logic clk, reset_n, valid, ready; 
    logic [SIZE-1:0] a; 
    logic [SIZE-1:0] b; 
    logic [SIZE-1:0] c; 
    logic [(SIZE<<1)-1:0] out; 

  
    unary_binary_MAC #(SIZE) dut(.clk(clk), .reset_n(reset_n), .valid(valid), .a(a), .b(b), .c(c), .ready(ready), .out(out));

 
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
 
        a <= SIZE'('d7); 
        b <= SIZE'('d7); 
        c <= SIZE'('d7); 
        valid <= 1'b1; 
        @(posedge clk); 
        valid <= 1'b0; 
        while (ready != 1'b1)
            @(posedge clk); 

        $finish; 
    end 


endmodule: test 
