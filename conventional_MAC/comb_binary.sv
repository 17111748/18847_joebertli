`default_nettype none
`timescale 1ns/10ps

module comb_binary_sub
    #(parameter SIZE = 2)
    (input logic valid, 
     output logic ready, 
     input logic [SIZE-1:0] a, 
     input logic [SIZE-1:0] b, 
     output logic [(SIZE<<1)-1:0] out); 

    assign ready = 1'b1; 

    logic [SIZE-1:0] and_gates [SIZE]; 
    logic [SIZE:0] adder_wires [SIZE-1]; 

    // Initialize the and_gate wires 
    genvar j, k;  
    generate 
        // loop through B 
        for(j = 0; j < SIZE; j = j + 1) 
        begin : B_loop
            //loop through A 
            for(k = 0; k < SIZE; k = k + 1) 
            begin : A_loop
                assign and_gates[j][k] = b[j] & a[k]; 
            end: A_loop
        end : B_loop
    endgenerate

    // Adder wires 
    genvar x; 
    generate 
        for(x = 0; x < (SIZE-1); x = x + 1) 
        begin: loop 
            if (x == 0) begin 
                assign adder_wires[x] = {1'b0, and_gates[x][SIZE-1:1]} + and_gates[x+1]; 
            end 
            else begin 
                assign adder_wires[x] = and_gates[x+1] + adder_wires[x-1][SIZE:1]; 
            end 
        end: loop 
    endgenerate

    // Assign the last half of the result 
    genvar c; 
    generate 
        for(c = 0; c < (SIZE-1); c = c + 1) 
        begin : loopc
            if(c == 0) begin 
                assign out[0] = and_gates[0][0]; 
            end 
            else begin 
                assign out[c] = adder_wires[c-1][0]; 
            end 
        end : loopc 
    endgenerate

    // Assign the front half of the result 
    assign out[(SIZE<<1)-1:(SIZE-1)] = adder_wires[SIZE-2]; 

endmodule: comb_binary_sub

module comb_binary
    #(parameter SIZE = 2, 
      parameter SETS = 2)
    (input  logic valid, // Start of when the input signal should be grabbed.
     input  logic [(SETS*SIZE)-1:0] a, 
     input  logic [(SETS*SIZE)-1:0] b, 
     output logic ready, // Asserted when the output is ready to be read. 
     output logic [(SIZE<<1)+SETS-1:0] out); 

    logic [SETS*(1<<SIZE)-1:0] temp_out; 

    assign ready = 1'b1; 

    logic temp_ready[SETS]; 

    genvar i; 
    generate 
        for(i = 0; i < SETS; i = i+1)
        begin : loop
            comb_binary_sub #(.SIZE(SIZE)) sub(.valid(valid), .ready(temp_ready[i]), .a(a[(i+1)*SIZE-1:(i)*SIZE]), 
                                .b(b[(i+1)*SIZE-1:(i)*SIZE]), .out(temp_out[((i+1)*(SIZE<<1))-1:i*(SIZE<<1)])); 
        end : loop
    endgenerate 

    assign out = temp_out[((0+1)*(SIZE<<1))-1:0*(SIZE<<1)] +
                 temp_out[((1+1)*(SIZE<<1))-1:1*(SIZE<<1)]; 
                //  temp_out[((2+1)*(SIZE<<1))-1:2*(SIZE<<1)] + 
                //  temp_out[((3+1)*(SIZE<<1))-1:3*(SIZE<<1)] + 
                //  temp_out[((4+1)*(SIZE<<1))-1:4*(SIZE<<1)] + 
                //  temp_out[((5+1)*(SIZE<<1))-1:5*(SIZE<<1)] + 
                //  temp_out[((6+1)*(SIZE<<1))-1:6*(SIZE<<1)] + 
                //  temp_out[((7+1)*(SIZE<<1))-1:7*(SIZE<<1)] + 
                //  temp_out[((8+1)*(SIZE<<1))-1:8*(SIZE<<1)] + 
                //  temp_out[((9+1)*(SIZE<<1))-1:9*(SIZE<<1)]; 


endmodule: comb_binary