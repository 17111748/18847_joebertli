`default_nettype none
`timescale 1ns/10ps

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

module adder_tree 
    #(parameter NUM_ELEMENTS = 16,  //Should be same number as number of voters
      parameter INDEX_W = $clog2(NUM_ELEMENTS + 1)) 
    (input  logic [NUM_ELEMENTS-1:0] in,
     output logic [INDEX_W-1:0] sum);

    generate
        if(NUM_ELEMENTS == 1) begin
            assign sum = in[0];
        end else if(NUM_ELEMENTS == 2) begin
            assign sum = in[0] + in [1];
        end else if(NUM_ELEMENTS == 3) begin
            assign sum = in[0] + in [1] + in[2];
        end else begin
            localparam LEFT_SIZE = (NUM_ELEMENTS-1)/2; // subtract one for carry in
            localparam LEFT_END_INDEX = LEFT_SIZE;
            localparam LEFT_W = $clog2(LEFT_SIZE+1);

            localparam RIGHT_SIZE = (NUM_ELEMENTS-1) - LEFT_SIZE;
            localparam RIGHT_INDEX = LEFT_SIZE + 1;
            localparam RIGHT_END_INDEX = NUM_ELEMENTS - 1;
            localparam RIGHT_W = $clog2(RIGHT_SIZE+1);

            logic [LEFT_W-1:0] left_temp;
            logic [RIGHT_W-1:0] right_temp;

            logic carry_in;
            assign carry_in = in[0];
            adder_tree #(LEFT_SIZE) lefty (
                .in(in[LEFT_END_INDEX:1]),
                .sum(left_temp)
            );

            adder_tree #(RIGHT_SIZE) righty (
                .in(in[RIGHT_END_INDEX:RIGHT_INDEX]),
                .sum(right_temp)
            );

            always_comb begin
                sum = left_temp + right_temp + carry_in;
            end
        end
    endgenerate
endmodule

// Performs out = a*b + c 
module separate
    #(parameter SIZE = 4)
    (input  logic clk, 
     input  logic reset_n, 
     input  logic valid, // Start of when the input signal should be grabbed.
     input  logic [SIZE-1:0] a, 
     input  logic [SIZE-1:0] b, 
     input  logic [SIZE-1:0] c, 
     input  logic [SIZE:0]   counter_out, 
     output logic ready, // Asserted when the output is ready to be read. 
     output logic [(1<<SIZE)-1:0] unary_out); 

    logic [(1<<SIZE)-1:0] unary; // Includes the c at the MSB

    logic ready_flag; // Flag to reset the ready signal 

    logic [SIZE-1:0] a_reg; 
    logic [SIZE-1:0] b_reg; 
    logic [SIZE-1:0] c_reg; 

    // Stores the original binary input into a register 
    always_ff@(posedge clk) 
        if(valid) begin 
            a_reg <= a; 
            b_reg <= b; 
            c_reg <= c; 
        end 

    // Turn binary input into unary input 
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



endmodule: separate


// Performs out = a*b + c 
module unary_binary_MAC
    #(parameter SIZE = 6,
      parameter SETS = 16)
    (input  logic clk, 
     input  logic reset_n, 
     input  logic valid, // Start of when the input signal should be grabbed.
     input  logic [(SETS*SIZE)-1:0] a, 
     input  logic [(SETS*SIZE)-1:0] b, 
     input  logic [(SETS*SIZE)-1:0] c, 
     output logic ready, // Asserted when the output is ready to be read. 
     output logic [(SIZE<<1)+SETS-1:0] out); 

    logic [(1<<SIZE)*SETS-1:0] unary_out; // Includes the c at the MSB

    logic ready_flag; // Flag to reset the ready signal 

    logic [(SETS*SIZE)-1:0] a_reg; 
    logic [(SETS*SIZE)-1:0] b_reg; 
    logic [(SETS*SIZE)-1:0] c_reg; 

    always_ff@(posedge clk) 
        if(valid) begin 
            a_reg <= a; 
            b_reg <= b; 
            c_reg <= c; 
        end 

    logic [SIZE:0] counter_out; 
    logic [SETS-1:0] ready_out; 

    // Turn binary input into unary input 
    Counter #(SIZE+1) counter(.en(1'b1), .clear(valid), .clk(clk), .Q(counter_out)); 

    genvar j; 
    generate
        for(j = 0; j < SETS; j++) 
        begin : loop
            separate #(SIZE) s(.clk(clk), .reset_n(reset_n), .valid(valid), 
            .a(a[(j+1)*SIZE-1:j*SIZE]), .b(b[(j+1)*SIZE-1:j*SIZE]), .c(c[(j+1)*SIZE-1:j*SIZE]), 
            .counter_out(counter_out), .ready(ready_out[j]), 
            .unary_out(unary_out[((j+1)*(1<<SIZE))-1:j*(1<<SIZE)]));
        end : loop 
    endgenerate
    
    logic [$clog2((1<<SIZE)*SETS+1)-1:0] at_out; 
    adder_tree #(.NUM_ELEMENTS((1<<SIZE)*SETS)) at (.in(unary_out), .sum(at_out)); 

    assign ready = (ready_out == ~((SETS)'('b0))); 

    always_ff@(posedge clk, negedge reset_n) 
        if(~reset_n)
            out <= 0; 
        else if(ready_out != 0)
            out <= 0; 
        else
            out <= out + at_out; 


endmodule: unary_binary_MAC

