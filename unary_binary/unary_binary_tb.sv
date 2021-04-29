`default_nettype none 
`timescale 1ns/10ps

module unary_binary_tb(); 
    localparam SIZE_PARAM = 4;
    localparam SET_PARAM = 8; 

    logic clk, reset_n, valid, ready;
    logic [(SET_PARAM*SIZE_PARAM)-1:0] a; 
    logic [(SET_PARAM*SIZE_PARAM)-1:0] b; 
    logic [(SET_PARAM*SIZE_PARAM)-1:0] c; 
    logic [(SIZE_PARAM<<1)+SET_PARAM-1:0] out; 
  
    unary_binary_MAC #(.SIZE(SIZE_PARAM), .SETS(SET_PARAM)) dut(.clk(clk), .reset_n(reset_n), .valid(valid), 
                        .a(a), .b(b), .c(c), .ready(ready), .out(out));

    logic [(SIZE_PARAM<<1)+SET_PARAM-1:0] out_correct; 
    logic [SIZE_PARAM*SET_PARAM-1:0] a_in; 
    logic [SIZE_PARAM*SET_PARAM-1:0] b_in; 
    logic [SIZE_PARAM*SET_PARAM-1:0] c_in; 

    initial begin
        clk = 0; 
        forever #5 clk = ~clk;  
    end 

    task reset(); 
        reset_n = 1'b1; 
        reset_n <= 1'b0; 
        @(posedge clk); 
        reset_n <= 1'b1; 
    endtask 

    int i, j; 
    int temp, temp1; 
    int SIZE; 
    task test_case(
        logic [SIZE_PARAM*SET_PARAM-1:0] in_a, 
        logic [SIZE_PARAM*SET_PARAM-1:0] in_b, 
        logic [SIZE_PARAM*SET_PARAM-1:0] in_c, 
        logic [(SIZE_PARAM<<1)+SET_PARAM-1:0] answer
    ); 

        a_in = in_a; 
        b_in = in_b; 
        c_in = in_c; 
        a = in_a; 
        b = in_b; 
        c = in_c; 

        out_correct = answer; 

    endtask 

    
    task verifyOutput(); 
        if(out_correct != out) begin 
            $display("Incorrect: a = %h, b = %h, c = %h, output = %d, correct = %d", a_in, b_in, c_in, out, out_correct); 
            $fatal("Aborting"); 
        end 
    endtask 
    
    initial begin 
        $dumpfile("unary_binary.vcd"); // Change this name as required
        $dumpvars(0, unary_binary_tb);

        reset(); 

        test_case((SIZE_PARAM*SET_PARAM)'('h88888888), 
                  (SIZE_PARAM*SET_PARAM)'('h88888888), 
                  (SIZE_PARAM*SET_PARAM)'('h88888888), 
                  ((SIZE_PARAM<<1)+SET_PARAM)'('d576)); 
        
        valid <= 1'b1; 
        @(posedge clk); 
        valid <= 1'b0; 

        while (ready != 1'b1)
            @(posedge clk); 
        
        verifyOutput(); 
        $display("\n\nAll Test Passed.\n"); 
        $finish; 
    end 

    initial begin 
        $sdf_annotate("../../synth/unary_binary_outputs/unary_binary_MAC_m.sdf", unary_binary_MAC); 
    end 

endmodule: unary_binary_tb 

// `default_nettype none 

// module test; 
//     localparam SIZE = 3;
//     logic clk, reset_n, valid, ready; 
//     logic [SIZE-1:0] a; 
//     logic [SIZE-1:0] b; 
//     logic [SIZE-1:0] c; 
//     logic [(SIZE<<1)-1:0] out; 

  
//     unary_binary_MAC #(SIZE) dut(.clk(clk), .reset_n(reset_n), .valid(valid), .a(a), .b(b), .c(c), .ready(ready), .out(out));

 
//     initial begin
//         reset_n = 0; 
//         reset_n <= 1; 
//         clk = 0; 
//         forever #5 clk = ~clk;  
//     end 
 
//     initial begin 
//         $monitor($time,, "a_reg = %b, b_reg = %b, c_reg = %b, counter_out = %d, unary = %b, unary_out = %b, ready = %b, out = %d, at_out = %d",
//              dut.a_reg, dut.b_reg, dut.c_reg, dut.counter_out, dut.unary, dut.unary_out, ready, out, dut.at_out); 
//     end 
 
//     initial begin 
//         a <= SIZE'('d7); 
//         b <= SIZE'('d7); 
//         c <= SIZE'('d7); 
//         valid <= 1'b1; 
//         @(posedge clk); 
//         valid <= 1'b0; 
//         while (ready != 1'b1)
//             @(posedge clk); 

//         $finish; 
//     end 


// endmodule: test 

