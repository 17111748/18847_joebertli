`default_nettype none

module binary
    #(parameter SIZE = 3)
    (input  logic clk, 
     input  logic reset_n, 
     input  logic valid, // Start of when the input signal should be grabbed.
     input  logic [SIZE-1:0] a, 
     input  logic [SIZE-1:0] b, 
     input  logic [SIZE-1:0] c, 
     output logic ready, // Asserted when the output is ready to be read. 
     output logic [(SIZE<<1)-1:0] out); 

    
    assign ready = 1'b1; 
    assign out = a * b + c; 
    

endmodule: binary
