`default_nettype none

// module comb_binary_tb; 
//     parameter SIZE = 8;
    
//     logic [SIZE-1:0] a; 
//     logic [SIZE-1:0] b; 
//     logic [(SIZE<<1)-1:0] out; 
//     logic ready, valid; 

//     logic [(SIZE<<1)-1:0] expected; 

//     comb_binary_sub #(.SIZE(SIZE)) cb(.valid(valid), .a(a), .b(b), .out(out), .ready(ready)); 

//     // initial begin 
//     //     $monitor($time,, "and_gates[0]: %b, and_gates[1]: %b, adder_wires: %b, a: %d, b: %d, out: %d", 
//     //     cb.and_gates[0], cb.and_gates[1], cb.adder_wires[0], a, b, out); 
//     // end 
    
//     task runDirectedTest(logic [SIZE-1:0] a_in, logic [SIZE-1:0] b_in); 
        
//         a = a_in; 
//         b = b_in; 

//         #10; 
//         expected = a_in * b_in;

//         if(out != expected) begin 
//             $display("TEST_FAILED: Expected: %d, Actual %d", expected, out); 
//         end 
//         else begin 
//             $display("TEST_PASSED! %d == %d", expected, out); 
//         end 

//     endtask

//     task runRandomTest(); 
//         std::randomize(a); 
//         std::randomize(b); 
//         #10;
//         expected = a * b; 
        
        
//         if(out != expected) begin 
//             $display("TEST_FAILED: a: %d, b: %d, Expected: %d, Actual %d", a, b, expected, out); 
//         end 
//         else begin 
//             $display("TEST_PASSED! %d == %d", expected, out); 
//         end 
//     endtask 

//     initial begin 
//         runDirectedTest(3, 2); 
        
//         // for(int i = 0; i < 10; i++) begin 
//         //     runRandomTest(); 
//         // end 
//         $display("\n\nAll Test Passed.\n"); 
//         $finish; 
//     end 

// endmodule: comb_binary_tb



module comb_binary_set_tb; 
    parameter SIZE = 4;
    parameter SETS = 4; 

    logic valid, ready;
    logic [(SETS*SIZE)-1:0] a; 
    logic [(SETS*SIZE)-1:0] b; 
    logic [(SIZE<<1)+SETS-1:0] out; 

    initial begin 
        $monitor($time,, "temp_out: %b, a: %d, b: %d, out: %d", 
        cb.temp_out, a, b, out); 
    end 
    

    task runDirectedTest(logic [SETS*SIZE-1:0] a_in, logic [SETS*SIZE-1:0] b_in, logic [(SIZE<<1)+SETS-1:0] expected); 
        a = a_in; 
        b = b_in; 
        #10; 

        if(out != expected) begin 
            $display("TEST_FAILED: a: %d, b: %d, Expected: %d, Actual %d", a, b, expected, out); 
        end 
        else begin 
            $display("TEST_PASSED! %d == %d", expected, out); 
        end 

    endtask 

    comb_binary #(.SIZE(SIZE), .SETS(SETS)) cb (.valid(1'b1), .ready(ready), .a(a), .b(b), .out(out)); 

    initial begin 
        runDirectedTest((SIZE*SETS)'('h8088),
                        (SIZE*SETS)'('h8808), 
                        ((SIZE<<1)+SETS)'('d128)); 

        $finish; 
    end 

endmodule: comb_binary_set_tb