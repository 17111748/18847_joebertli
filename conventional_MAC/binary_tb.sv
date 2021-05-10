`default_nettype none 

`timescale 1ns/10ps

// module binary_tb(); 
//     localparam SIZE_PARAM = 4;
//     localparam SET_PARAM = 8; 

//     logic clk, reset_n, valid, ready;
//     logic [(SET_PARAM*SIZE_PARAM)-1:0] a; 
//     logic [(SET_PARAM*SIZE_PARAM)-1:0] b; 
//     logic [(SET_PARAM*SIZE_PARAM)-1:0] c; 
//     logic [(SIZE_PARAM<<1)+SET_PARAM-1:0] out; 
  
//     binary #(.SIZE(SIZE_PARAM), .SETS(SET_PARAM)) dut(.clk(clk), .reset_n(reset_n), .valid(valid), 
//                         .a(a), .b(b), .c(c), .ready(ready), .out(out));

//     logic [(SIZE_PARAM<<1)+SET_PARAM-1:0] out_correct; 
//     logic [SIZE_PARAM*SET_PARAM-1:0] a_in; 
//     logic [SIZE_PARAM*SET_PARAM-1:0] b_in; 
//     logic [SIZE_PARAM*SET_PARAM-1:0] c_in; 

//     initial begin
//         clk = 0; 
//         forever #5 clk = ~clk;  
//     end 

//     task reset(); 
//         reset_n = 1'b1; 
//         reset_n <= 1'b0; 
//         @(posedge clk); 
//         reset_n <= 1'b1; 
//     endtask 

//     int i, j; 
//     int temp, temp1; 
//     int SIZE; 
//     task test_case(
//         logic [SIZE_PARAM*SET_PARAM-1:0] in_a, 
//         logic [SIZE_PARAM*SET_PARAM-1:0] in_b, 
//         logic [(SIZE_PARAM<<1)+SET_PARAM-1:0] answer
//     ); 

//         a_in = in_a; 
//         b_in = in_b; 
//         a = in_a; 
//         b = in_b; 

//         out_correct = answer; 

//     endtask 
    
//     task verifyOutput(); 
//         if(out_correct != out) begin 
//             $display("Incorrect: a = %h, b = %h, output = %d, correct = %d", a_in, b_in, out, out_correct); 
//             $fatal("Aborting"); 
//         end 
//     endtask 
    
//     initial begin 
//         $dumpfile("unary_binary.vcd"); // Change this name as required
//         $dumpvars(0, binary_tb);

//         reset(); 

//         test_case((SIZE_PARAM*SET_PARAM)'('h88888888), 
//                   (SIZE_PARAM*SET_PARAM)'('h88888888), 
//                   (SIZE_PARAM*SET_PARAM)'('h88888888), 
//                   ((SIZE_PARAM<<1)+SET_PARAM)'('d576)); 
        
//         valid <= 1'b1; 
//         @(posedge clk); 
//         valid <= 1'b0; 

//         while (ready != 1'b1)
//             @(posedge clk); 
        
//         verifyOutput(); 
//         $display("\n\nAll Test Passed.\n"); 
//         $finish; 
//     end 


// endmodule: binary_tb 

module binary_tb
    localparam SIZE = 2;
    
    logic [SIZE-1:0] a; 
    logic [SIZE-1:0] b; 
    logic [SIZE<<1-1:0] out; 
    logic ready, valid; 

    comb_binary cb(.valid(valid), .a(a), .b(b), .out(out), .ready(ready)); 
    
    task runDirectedTest(logic [SIZE-1:0] a_in, logic [SIZE-1:0] b_in); 
        int expected = a_in * b_in;
        a = a_in; 
        b = b_in;  
        if(out != expected) begin 
            $display("TEST_FAILED: Expected: %d, Actual %d", expected, out); 
        end 
        else begin 
            $display("TEST_PASSED!"); 
        end 

    endtask

    task runRandomTest(); 
        std::randomize(a); 
        std::randomize(b); 

        int expected = a * b; 
        
        if(out != expected) begin 
            $display("TEST_FAILED: Expected: %d, Actual %d", expected, out); 
        end 
        else begin 
            $display("TEST_PASSED! %d == %d", expected, out); 
        end 
    endtask 

    initial begin 
        runDirectedTest(3, 5); 
        
        for(int i = 0; i < 10; i++) begin 
            runRandomTest(); 
        end 
        // $display("\n\nAll Test Passed.\n"); 
        $finish; 
    end 

endmodule: binary_tb