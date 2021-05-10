// `default_nettype none
// `timescale 1ns/10ps



// module binary
//     #(parameter SIZE = 4, 
//       parameter SETS = 8)
//     (input  logic clk, 
//      input  logic reset_n, 
//      input  logic valid, // Start of when the input signal should be grabbed.
//      input  logic [(SETS*SIZE)-1:0] a, 
//      input  logic [(SETS*SIZE)-1:0] b, 
//      input  logic [(SETS*SIZE)-1:0] c,
//      output logic ready, // Asserted when the output is ready to be read. 
//      output logic [(SIZE<<1)+SETS-1:0] out); 

    
//     assign ready = 1'b1; 
    

    

// endmodule: binary

module binary
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

    
    assign ready = 1'b1; 
    // assign out = a * b + c; 

    assign out = a[(0+1)*SIZE-1:0*SIZE] * b[(0+1)*SIZE-1:0*SIZE] + c[(0+1)*SIZE-1:0*SIZE] + 
    a[(1+1)*SIZE-1:1*SIZE] * b[(1+1)*SIZE-1:1*SIZE] + c[(1+1)*SIZE-1:1*SIZE] + 
    a[(2+1)*SIZE-1:2*SIZE] * b[(2+1)*SIZE-1:2*SIZE] + c[(2+1)*SIZE-1:2*SIZE] + 
    a[(3+1)*SIZE-1:3*SIZE] * b[(3+1)*SIZE-1:3*SIZE] + c[(3+1)*SIZE-1:3*SIZE] + 
    a[(4+1)*SIZE-1:4*SIZE] * b[(4+1)*SIZE-1:4*SIZE] + c[(4+1)*SIZE-1:4*SIZE] + 
    a[(5+1)*SIZE-1:5*SIZE] * b[(5+1)*SIZE-1:5*SIZE] + c[(5+1)*SIZE-1:5*SIZE] + 
    a[(6+1)*SIZE-1:6*SIZE] * b[(6+1)*SIZE-1:6*SIZE] + c[(6+1)*SIZE-1:6*SIZE] + 
    a[(7+1)*SIZE-1:7*SIZE] * b[(7+1)*SIZE-1:7*SIZE] + c[(7+1)*SIZE-1:7*SIZE] + 
    a[(8+1)*SIZE-1:8*SIZE] * b[(8+1)*SIZE-1:8*SIZE] + c[(8+1)*SIZE-1:8*SIZE] + 
    a[(9+1)*SIZE-1:9*SIZE] * b[(9+1)*SIZE-1:9*SIZE] + c[(9+1)*SIZE-1:9*SIZE] + 
    a[(10+1)*SIZE-1:10*SIZE] * b[(10+1)*SIZE-1:10*SIZE] + c[(10+1)*SIZE-1:10*SIZE] + 
    a[(11+1)*SIZE-1:11*SIZE] * b[(11+1)*SIZE-1:11*SIZE] + c[(11+1)*SIZE-1:11*SIZE] + 
    a[(12+1)*SIZE-1:12*SIZE] * b[(12+1)*SIZE-1:12*SIZE] + c[(12+1)*SIZE-1:12*SIZE] + 
    a[(13+1)*SIZE-1:13*SIZE] * b[(13+1)*SIZE-1:13*SIZE] + c[(13+1)*SIZE-1:13*SIZE] + 
    a[(14+1)*SIZE-1:14*SIZE] * b[(14+1)*SIZE-1:14*SIZE] + c[(14+1)*SIZE-1:14*SIZE] + 
    a[(15+1)*SIZE-1:15*SIZE] * b[(15+1)*SIZE-1:15*SIZE] + c[(15+1)*SIZE-1:15*SIZE]; 
    // a[(16+1)*SIZE-1:16*SIZE] * b[(16+1)*SIZE-1:16*SIZE] + c[(16+1)*SIZE-1:16*SIZE]; 

    

    

endmodule: binary
