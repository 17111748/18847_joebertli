`default_nettype none

module Counter 
  #(parameter WIDTH = 4) 
  (input  logic en, clear, clk, 
   output logic [WIDTH-1:0] Q);

   always_ff @(posedge clk) 
    if(clear)
      Q <= 0; 
    else if (en)
      Q <= Q + 1; 

endmodule: Counter

module Counter_Down
  #(parameter WIDTH = 4) 
  (input  logic en, load, clk, 
   input  logic [WIDTH-1:0] D, 
   output logic [WIDTH-1:0] Q);

   always_ff @(posedge clk) 
    if(load)
      Q <= D; 
    else if (en)
      Q <= Q - 1; 

endmodule: Counter_Down

module FA 
  (input  logic A, 
   input  logic B,
   input  logic Cin, 
   output logic sum, 
   output logic Cout);

    logic temp_1; 
    logic temp_2; 
    logic temp_3; 

    xor G1(temp_1, A, B); 
    xor G2(sum, temp_1, Cin); 
    and G3(temp_2, Cin, temp_1); 
    and G4(temp_3, A, B); 
    or  G5(Cout, temp_2, temp_3); 

endmodule: FA

module HA
  (input  logic A, 
   input  logic B,
   output logic sum, 
   output logic Cout); 

    xor G1 (sum, A, B); 
    and G2 (Cout, A, B); 

endmodule: HA
module Parallel_Accum_3
    (input  logic [7:0] in,
     input  logic       clk,  
     input  logic       reset_n, 
     output logic [5:0] out); 

    logic [5:0] saved_value; 

    logic sum_f1, sum_f2, sum_f3, sum_f4, sum_f5, sum_f6, sum_f7;
    logic cout_f1, cout_f2, cout_f3, cout_f4, cout_f5, cout_f6, cout_f7;

    logic sum_h1, sum_h2, sum_h3, cout_h1, cout_h2, cout_h3; 

    FA f1  (.A(in[7]), .B(in[6]), .Cin(in[5]), .sum(sum_f1), .Cout(cout_f1)); 
    FA f2  (.A(in[4]), .B(in[3]), .Cin(in[2]), .sum(sum_f2), .Cout(cout_f2)); 
    
    FA f3  (.A(cout_f1), .B(cout_f2), .Cin(cout_f4), .sum(sum_f3), .Cout(cout_f3)); 
    FA f4  (.A( sum_f1), .B( sum_f2), .Cin(  in[1]), .sum(sum_f4), .Cout(cout_f4)); 
   
    FA f5  (.A(cout_f3), .B(saved_value[2]), .Cin(cout_f6), .sum(sum_f5), .Cout(cout_f5));
    FA f6  (.A( sum_f3), .B(saved_value[1]), .Cin(cout_f7), .sum(sum_f6), .Cout(cout_f6));
    FA f7  (.A( sum_f4), .B(saved_value[0]), .Cin(  in[0]), .sum(sum_f7), .Cout(cout_f7));
    
    HA h1 (.A(cout_h2),  .B(saved_value[5]), .sum(sum_h1), .Cout(cout_h1)); 
    HA h2 (.A(cout_h3),  .B(saved_value[4]), .sum(sum_h2), .Cout(cout_h2)); 
    HA h3 (.A(cout_f5),  .B(saved_value[3]), .sum(sum_h3), .Cout(cout_h3)); 

    always_ff @(posedge clk, negedge reset_n)  
        if (~reset_n) 
            saved_value <= 6'b0; 
        else 
            saved_value <= {sum_h1, sum_h2, sum_h3, sum_f5, sum_f6, sum_f7}; 
    
    assign out = saved_value; 
    
endmodule: Parallel_Accum_3

module Parallel_Accum_4
    (input  logic [15:0] in,
     input  logic        clk,  
     input  logic        reset_n, 
     output logic  [7:0] out); 

    logic [7:0] saved_value; 

    logic sum_f1, sum_f2, sum_f3, sum_f4, sum_f5, sum_f6, sum_f7, sum_f8, sum_f9, sum_f10, 
          sum_f11, sum_f12, sum_f13, sum_f14, sum_f15;
    logic cout_f1, cout_f2, cout_f3, cout_f4, cout_f5, cout_f6, cout_f7, cout_f8, cout_f9, 
          cout_f10, cout_f11, cout_f12, cout_f13, cout_f14, cout_f15; 

    logic sum_h1, sum_h2, sum_h3, sum_h4, 
          cout_h1, cout_h2, cout_h3, cout_h4; 

    FA f1  (.A(in[15]), .B(in[14]), .Cin(in[13]), .sum(sum_f1), .Cout(cout_f1)); 
    FA f2  (.A(in[12]), .B(in[11]), .Cin(in[10]), .sum(sum_f2), .Cout(cout_f2)); 
    FA f3  (.A( in[8]), .B( in[7]), .Cin( in[6]), .sum(sum_f3), .Cout(cout_f3)); 
    FA f4  (.A( in[5]), .B( in[4]), .Cin( in[3]), .sum(sum_f4), .Cout(cout_f4)); 
   
    FA f5  (.A(cout_f1), .B(cout_f2), .Cin(cout_f6), .sum(sum_f5), .Cout(cout_f5));
    FA f6  (.A( sum_f1), .B( sum_f2), .Cin(  in[9]), .sum(sum_f6), .Cout(cout_f6));
    FA f7  (.A(cout_f3), .B(cout_f4), .Cin(cout_f8), .sum(sum_f7), .Cout(cout_f7));
    FA f8  (.A( sum_f3), .B( sum_f4), .Cin(  in[2]), .sum(sum_f8), .Cout(cout_f8));

    FA f9  (.A(cout_f5), .B(cout_f7), .Cin(cout_f10), .sum(sum_f9),  .Cout(cout_f9)); 
    FA f10 (.A( sum_f5), .B( sum_f7), .Cin(cout_f11), .sum(sum_f10), .Cout(cout_f10));
    FA f11 (.A( sum_f6), .B( sum_f8), .Cin(   in[1]), .sum(sum_f11), .Cout(cout_f11)); 

    FA f12 (.A(cout_f9),  .B(saved_value[3]), .Cin(cout_f13), .sum(sum_f12), .Cout(cout_f12)); 
    FA f13 (.A( sum_f9),  .B(saved_value[2]), .Cin(cout_f14), .sum(sum_f13), .Cout(cout_f13)); 
    FA f14 (.A( sum_f10), .B(saved_value[1]), .Cin(cout_f15), .sum(sum_f14), .Cout(cout_f14)); 
    FA f15 (.A( sum_f11), .B(saved_value[0]), .Cin(   in[0]), .sum(sum_f15), .Cout(cout_f15)); 

    HA h1 (.A(cout_h2),  .B(saved_value[7]), .sum(sum_h1), .Cout(cout_h1)); 
    HA h2 (.A(cout_h3),  .B(saved_value[6]), .sum(sum_h2), .Cout(cout_h2)); 
    HA h3 (.A(cout_h4),  .B(saved_value[5]), .sum(sum_h3), .Cout(cout_h3)); 
    HA h4 (.A(cout_f12), .B(saved_value[4]), .sum(sum_h4), .Cout(cout_h4)); 

    always_ff @(posedge clk, negedge reset_n)  
        if (~reset_n) 
            saved_value <= 8'b0; 
        else 
            saved_value <= {sum_h1, sum_h2, sum_h3, sum_h4, sum_f12, sum_f13, sum_f14, sum_f15}; 
    
    assign out = saved_value; 

    
endmodule: Parallel_Accum_4


// Performs out = a*b + c 
module unary_binary_MAC
    #(parameter SIZE = 4)
    (input  logic clk, 
     input  logic reset_n, 
     input  logic valid, // Start of when the input signal should be grabbed.
     input  logic [SIZE-1:0] a, 
     input  logic [SIZE-1:0] b, 
     input  logic [SIZE-1:0] c, 
     output logic ready, // Asserted when the output is ready to be read. 
     output logic [(SIZE<<1)-1:0] out); 

    logic [(1<<SIZE)-1:0] unary; // Includes the c at the MSB
    logic [(1<<SIZE)-1:0] unary_out; // Includes the c at the MSB

    logic ready_flag; // Flag to reset the ready signal 

    logic [SIZE-1:0] a_reg; 
    logic [SIZE-1:0] b_reg; 
    logic [SIZE-1:0] c_reg; 

    logic [SIZE:0] counter_out; 

    // Stores the original binary input into a register 
    always_ff@(posedge clk) 
        if(valid) begin 
            a_reg <= a; 
            b_reg <= b; 
            c_reg <= c; 
        end 

    // Turn binary input into unary input 
    Counter #(SIZE+1) counter(.en(1'b1), .clear(valid), .clk(clk), .Q(counter_out)); 
    always_ff@(posedge clk, negedge reset_n) 
        if(~reset_n) begin 
            unary[(1<<SIZE)-1:0]     <= (1<<SIZE)'('b0); 
            ready                    <= 1'b0; 
            ready_flag               <= 1'b0; 
        end 
        else begin 
            ready                    <= 1'b0; 
            if(valid) 
                ready_flag           <= 1'b0; 
            if(counter_out < a_reg) 
                unary[(1<<SIZE)-2:0] <= ~(((1<<SIZE)-1)'('b0)); // Change this to arbitrary size 
            else 
                unary[(1<<SIZE)-2:0] <= ((1<<SIZE)-1)'('b0); 
            if(counter_out < c_reg) 
                unary[(1<<SIZE)-1]   <= 1'b1; 
            else 
                unary[(1<<SIZE)-1]   <= 1'b0; 
            if(counter_out >= a_reg && counter_out >= c_reg && ready_flag == 1'b0) begin 
                ready                <= 1'b1; 
                ready_flag           <= 1'b1; 
            end 
        end 

    // Mask the Fanned Out unary inputs with the bits of a binary number 
    genvar i; 
    generate 
        for(i = 1; i < (1<<SIZE); i = i + 1)
        begin : loop 
            assign unary_out[i-1] = unary[i-1] & b_reg[$clog2(i+1)-1]; // Masking it with the second input
        end: loop 
    endgenerate    

    // Accumulator 
    assign unary_out[(1<<SIZE)-1] = unary[(1<<SIZE)-1]; // Propogate the c value 
    
    Parallel_Accum_3 pa(.in(unary_out), .clk(clk), .reset_n(reset_n), .out(out)); 


endmodule: unary_binary_MAC


// // Performs out = a*b + c 
// module unary_binary_MAC
//     #(parameter SIZE = 4)
//     (input  logic clk, 
//      input  logic reset_n, 
//      input  logic valid, // Start of when the input signal should be grabbed.
//      input  logic [SIZE-1:0] a, 
//      input  logic [SIZE-1:0] b, 
//      input  logic [SIZE-1:0] c, 
//      output logic ready, // Asserted when the output is ready to be read. 
//      output logic [(SIZE<<1)-1:0] out); 

//     logic [(1<<SIZE)-1:0] unary; // Includes the c at the MSB
//     logic [(1<<SIZE)-1:0] unary_out; // Includes the c at the MSB

//     logic ready_flag; // Flag to reset the ready signal 

//     logic [SIZE-1:0] a_reg; 
//     logic [SIZE-1:0] b_reg; 
//     logic [SIZE-1:0] c_reg; 

//     logic [SIZE:0] counter_out; 

//     // Stores the original binary input into a register 
//     always_ff@(posedge clk) 
//         if(valid) begin 
//             a_reg <= a; 
//             b_reg <= b; 
//             c_reg <= c; 
//         end 

//     // Turn binary input into unary input 
//     Counter #(SIZE+1) counter(.en(1'b1), .clear(valid), .clk(clk), .Q(counter_out)); 
//     always_ff@(posedge clk, negedge reset_n) 
//         if(~reset_n) begin 
//             unary[(1<<SIZE)-1:0]     <= (1<<SIZE)'('b0); 
//             ready                    <= 1'b0; 
//             ready_flag               <= 1'b0; 
//         end 
//         else begin 
//             ready                    <= 1'b0; 
//             if(valid) 
//                 temp_ready           <= 1'b0; 
//             if(counter_out < a_reg) 
//                 unary[(1<<SIZE)-2:0] <= ~(((1<<SIZE)-1)'('b0)); // Change this to arbitrary size 
//             else 
//                 unary[(1<<SIZE)-2:0] <= ((1<<SIZE)-1)'('b0); 
//             if(counter_out < c_reg) 
//                 unary[(1<<SIZE)-1]   <= 1'b1; 
//             else 
//                 unary[(1<<SIZE)-1]   <= 1'b0; 
//             if(counter_out >= a_reg && counter_out >= c_reg && ready_flag == 1'b0) begin 
//                 ready                <= 1'b1; 
//                 ready_flag           <= 1'b1; 
//             end 
//         end 

//     // Mask the Fanned Out unary inputs with the bits of a binary number 
//     genvar i; 
//     generate 
//         for(i = 1; i < (1<<SIZE); i = i + 1)
//         begin : loop 
//             assign unary_out[i-1] = unary[i-1] & b_reg[$clog2(i+1)-1]; // Masking it with the second input
//         end: loop 
//     endgenerate    

//     // Accumulator 
//     assign unary_out[(1<<SIZE)-1] = unary[(1<<SIZE)-1]; // Propogate the c value 
    
//     always_ff@(posedge clk, negedge reset_n) 
//         if(~reset_n)
//             out <= 0; 
//         else if(ready == 1'b1)
//             out <= 0; 
//         else
//             out <= out + $countones(unary_out); 


// endmodule: unary_binary_MAC



// //###############################################################################################
// // ANOTHER METHOD: It might be slightly faster 

// // Stores the original binary input into a register 
// always_ff@(posedge clk) 
//     if(valid)
//         b_reg <= b; 

// logic zero_a, zero_c;  

// logic [SIZE:0] counter_out_a; 
// logic [SIZE:0] counter_out_c; 

// // Turn binary input into unary input 
// Counter_Down #(WIDTH=SIZE) counter(.en(zero_a), .load(valid), .clk(clk), .D(a), .Q(counter_out_a)); 
// Counter_Down #(WIDTH=SIZE) counter(.en(zero_c), .load(valid), .clk(clk), .D(c), .Q(counter_out_a)); 
// always_ff@(posedge clk, negedge reset_n) 
//     if(~reset_n) begin 
//         unary[(1<<SIZE)-1:0] <= 0; 
//         zero_a <= 1'b1; 
//         zero_c <= 1'b1; 
//     end 
//     else begin 
//         if(valid) begin
//             zero_a <= 1'b1; 
//             zero_c <= 1'b1; 
//         end 
//         if((counter_out_a >= 0) && (counter_out_a[SIZE] != 1'b1)) begin 
//             unary[(1<<SIZE)-2:0] <= 15'h7FFF; // Change this to arbitrary size 
//         end 
//         else begin
//             unary[(1<<SIZE)-2:0] <= 15'b0; 
//             zero_a <= 1'b0;
//         end 
//         if((counter_out_c >= 0) && (counter_out_c[SIZE] != 1'b1)) begin 
//             unary[(1<<SIZE)-1] <= 1'b1; 
//         end 
//         else begin 
//             unary[(1<<SIZE)-1] <= 1'b0; 
//             zero_c <= 1'b0;
//         end 
//     end 
// //###############################################################################################

