`default_nettype none 
`timescale 1ns/10ps

module serial_tb(); 
    localparam SIZE_PARAM = 4;
    localparam SET_PARAM = 1; 

    logic clk, reset_n, valid, ready;
    logic [(SET_PARAM*SIZE_PARAM)-1:0] a; 
    logic [(SET_PARAM*SIZE_PARAM)-1:0] b; 
    logic [(SIZE_PARAM<<1)+SET_PARAM-1:0] out; 
  
    serial #(.SIZE(SIZE_PARAM), .SETS(SET_PARAM)) dut(.clk(clk), .reset_n(reset_n), .valid(valid), 
                        .a(a), .b(b), .ready(ready), .out(out));

    logic [(SIZE_PARAM<<1)+SET_PARAM-1:0] out_correct; 
    logic [SIZE_PARAM*SET_PARAM-1:0] a_in; 
    logic [SIZE_PARAM*SET_PARAM-1:0] b_in; 

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

    // initial begin 
    //     $monitor($time,, "a_reg = %b, b_reg = %b, counter_out = %d, unary_out = %b, ready = %b, out = %d, at_out = %d",
    //          dut.a_reg, dut.b_reg, dut.counter_out, dut.unary_out, ready, out, dut.at_out); 
    // end 

    int i, j; 
    int temp, temp1; 
    int SIZE; 
    task test_case(
        logic [SIZE_PARAM*SET_PARAM-1:0] in_a, 
        logic [SIZE_PARAM*SET_PARAM-1:0] in_b, 
        logic [(SIZE_PARAM<<1)+SET_PARAM-1:0] answer
    ); 

        a_in = in_a; 
        b_in = in_b; 
        a = in_a; 
        b = in_b; 

        out_correct = answer; 

        
        valid <= 1'b1; 
        @(posedge clk); 
        valid <= 1'b0; 

        while (ready != 1'b1)
            @(posedge clk); 
        
        verifyOutput(); 

    endtask 

    
    task verifyOutput(); 
        if(out_correct != out) begin 
            $display("Incorrect: a = %h, b = %h, output = %d, correct = %d", a_in, b_in, out, out_correct); 
            $fatal("Aborting\n"); 
        end 
    endtask 
    
    initial begin 
        $dumpfile("serial.vcd"); // Change this name as required
        $dumpvars(0, serial_tb);

        reset(); 
        $display("\n\nStart Testing.\n"); 

        test_case((SIZE_PARAM*SET_PARAM)'('h1), 
                  (SIZE_PARAM*SET_PARAM)'('h2), 
                  ((SIZE_PARAM<<1)+SET_PARAM)'('d2)); 

        // test_case((SIZE_PARAM*SET_PARAM)'('h88), 
        //           (SIZE_PARAM*SET_PARAM)'('h88), 
        //           ((SIZE_PARAM<<1)+SET_PARAM)'('d128)); 

        // test_case((SIZE_PARAM*SET_PARAM)'('h11), 
        //           (SIZE_PARAM*SET_PARAM)'('h11), 
        //           ((SIZE_PARAM<<1)+SET_PARAM)'('d2)); 

        // test_case((SIZE_PARAM*SET_PARAM)'('h88888888), 
        //           (SIZE_PARAM*SET_PARAM)'('h88888888), 
        //           ((SIZE_PARAM<<1)+SET_PARAM)'('d512)); 

        // test_case((SIZE_PARAM*SET_PARAM)'('hffffffff), 
        //           (SIZE_PARAM*SET_PARAM)'('hffffffff), 
        //           ((SIZE_PARAM<<1)+SET_PARAM)'('d1800));
        

        // test_case((SIZE_PARAM*SET_PARAM)'('h22221111), 
        //           (SIZE_PARAM*SET_PARAM)'('h75757575), 
        //           ((SIZE_PARAM<<1)+SET_PARAM)'('d72));

        // test_case((SIZE_PARAM*SET_PARAM)'('h11111111), 
        //           (SIZE_PARAM*SET_PARAM)'('h11111111), 
        //           ((SIZE_PARAM<<1)+SET_PARAM)'('d8)); 
        
        $display("\n\nAll Test Passed.\n"); 
        $finish; 
    end 

    // initial begin 
    //     $sdf_annotate("../../synth/unary_binary_outputs/unary_binary_MAC_m.sdf", unary_binary_MAC); 
    // end 

endmodule: serial_tb 
