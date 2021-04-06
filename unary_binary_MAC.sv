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

module ShiftRegister 
  #(parameter WIDTH = 4) 
  (input  logic en, left, clk, load, 
   input  logic D, 
   output logic [WIDTH-1:0] Q); 

  always_ff @(posedge clk) 
   if(load) 
    Q <= 0; 
   else if(en & left) 
    Q <= ((Q << 1) + D); 
   else if(en & ~left)
    Q <= Q >> 1; 

endmodule: ShiftRegister

// Performs out = a*b + c 
module unary_binary_MAC_4
    #(parameter SIZE = 4)
    (input  logic clk, 
     input  logic reset_n, 
     input  logic valid, // Start of when the input signal should be grabbed 
     input  logic [SIZE-1:0] a, 
     input  logic [SIZE-1:0] b, 
     input  logic [SIZE-1:0] c, 
     output logic [(SIZE<<1)-1:0] out); 

    logic unary [(1<<SIZE)-1:0]; // Includes the c at the MSB
    logic unary_out [(1<<SIZE)-1:0]; // Includes the c at the MSB

    logic [SIZE-1:0] a_reg; 
    logic [SIZE-1:0] b_reg; 
    logic [SIZE-1:0] c_reg; 

    logic [SIZE:0] counter_out; 

    // Stores the original binary input into a register 
    always_ff@(posedge clk) 
        if(valid)
            a_reg <= a; 
            b_reg <= b; 
            c_reg <= c; 
    
    // Turn binary input into unary input 
    Counter #(WIDTH=SIZE) counter(.en(1'b1), .clear(valid), .clk(clk), .Q(counter_out)); 
    always_ff@(posedge clk, negedge reset_n) 
        if(~reset_n)
            unary[(1<<SIZE)-1:0] <= 0; 
        else begin 
            if(counter_out <= a_reg) 
                unary[(1<<SIZE)-2:0] <= 15'h7FFF; // Change this to arbitrary size 
            else 
                unary[(1<<SIZE)-2:0] <= 15'b0; 
            if(counter_out <= c_reg) 
                unary[(1<<SIZE)-1] <= 1'b1; 
            else 
                unary[(1<<SIZE)-1] <= 1'b0; 
        end 

    // //###############################################################################################
    // // ANOTHER METHOD: 

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

    // Mask the Fanned Out unary inputs with the bits of a binary number 
    genvar i; 
    generate 
        for(i = 1; i < (1<<SIZE); i = i + 1)
        begin : loop 
            assign unary_out[i-1] = unary[i-1] & b_reg[$clog2(i+1)-1]; // Masking it with the second input
        end: loop 
    endgenerate    

    // Accumulator 


endmodule: unary_binary_MAC_4
   
// // Performs out = a*b + c 
// module unary_binary_MAC
//     #(parameter SIZE = 4)
//     (input  logic clk, 
//      input  logic reset_n, 
//      input  logic valid, // Start of when the input signal should be grabbed 
//      input  logic [SIZE-1:0] a, 
//      input  logic [SIZE-1:0] b, 
//      input  logic [SIZE-1:0] c, 
//      output logic [(SIZE<<1)-1:0] out); 

//     logic unary [(1<<SIZE)-1:0]; // Includes the c at the MSB
//     logic unary_out [(1<<SIZE)-1:0]; // Includes the c at the MSB

//     logic [SIZE-1:0] a_reg; 
//     logic [SIZE-1:0] b_reg; 
//     logic [SIZE-1:0] c_reg; 

//     logic [SIZE:0] counter_out; 

//     // Stores the original binary input into a register 
//     always_ff@(posedge clk) 
//         if(valid)
//             a_reg <= a; 
//             b_reg <= b; 
//             c_reg <= c; 
    
//     // Turn binary input into unary input 
//     Counter #(WIDTH=SIZE) counter(.en(1'b1), .clear(valid), .clk(clk), .Q(counter_out)); 
//     always_ff@(posedge clk, negedge reset_n) 
//         if(~reset_n)
//             unary[(1<<SIZE)-1:0] <= 0; 
//         else begin 
//             if(counter_out <= a_reg) 
//                 unary[(1<<SIZE)-2:0] <= 15'h7FFF; // Change this to arbitrary size 
//             else 
//                 unary[(1<<SIZE)-2:0] <= 15'b0; 
//             if(counter_out <= c_reg) 
//                 unary[(1<<SIZE)-1] <= 1'b1; 
//             else 
//                 unary[(1<<SIZE)-1] <= 1'b0; 
//         end 

//     // //###############################################################################################
//     // // ANOTHER METHOD: 

//     // // Stores the original binary input into a register 
//     // always_ff@(posedge clk) 
//     //     if(valid)
//     //         b_reg <= b; 
    
//     // logic zero_a, zero_c;  

//     // logic [SIZE:0] counter_out_a; 
//     // logic [SIZE:0] counter_out_c; 

//     // // Turn binary input into unary input 
//     // Counter_Down #(WIDTH=SIZE) counter(.en(zero_a), .load(valid), .clk(clk), .D(a), .Q(counter_out_a)); 
//     // Counter_Down #(WIDTH=SIZE) counter(.en(zero_c), .load(valid), .clk(clk), .D(c), .Q(counter_out_a)); 
//     // always_ff@(posedge clk, negedge reset_n) 
//     //     if(~reset_n) begin 
//     //         unary[(1<<SIZE)-1:0] <= 0; 
//     //         zero_a <= 1'b1; 
//     //         zero_c <= 1'b1; 
//     //     end 
//     //     else begin 
//     //         if(valid) begin
//     //             zero_a <= 1'b1; 
//     //             zero_c <= 1'b1; 
//     //         end 
//     //         if((counter_out_a >= 0) && (counter_out_a[SIZE] != 1'b1)) begin 
//     //             unary[(1<<SIZE)-2:0] <= 15'h7FFF; // Change this to arbitrary size 
//     //         end 
//     //         else begin
//     //             unary[(1<<SIZE)-2:0] <= 15'b0; 
//     //             zero_a <= 1'b0;
//     //         end 
//     //         if((counter_out_c >= 0) && (counter_out_c[SIZE] != 1'b1)) begin 
//     //             unary[(1<<SIZE)-1] <= 1'b1; 
//     //         end 
//     //         else begin 
//     //             unary[(1<<SIZE)-1] <= 1'b0; 
//     //             zero_c <= 1'b0;
//     //         end 
//     //     end 
//     // //###############################################################################################

//     // Mask the Fanned Out unary inputs with the bits of a binary number 
//     genvar i; 
//     generate 
//         for(i = 1; i < (1<<SIZE); i = i + 1)
//         begin : loop 
//             assign unary_out[i-1] = unary[i-1] & b_reg[$clog2(i+1)-1]; // Masking it with the second input
//         end: loop 
//     endgenerate    

//     // Accumulator 


// endmodule: unary_binary_MAC