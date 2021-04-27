`default_nettype none

// Q0 is the initial value that was loaded in
// (Remembering this value allows us to loop through x repeatedly on
//  every iteration of the w Down_Counter)
// When recycle goes high, Down_Counter resets to Q0
module Down_Counter
    #(parameter WIDTH = 4)
    (input  logic en, load, recycle, clk,
     input  logic [WIDTH-1:0] D,
     output logic [WIDTH-1:0] Q0, Q);

   always_ff @(posedge clk)
    if (load) begin
      Q  <= D;
      Q0 <= D;
    end
    else if (recycle) begin
      Q  <= Q0;
      Q0 <= Q0;
    end
    else if (en) begin
      Q  <= Q - 1;
      Q0 <= Q0;
    end

endmodule: Down_Counter

// Computes product of binary inputs w and x, and outputs in unary
module Product_Block
    #(parameter WIDTH = 4)
    (input  logic             in_rdy, clk, reset_n,
     input  logic [WIDTH-1:0] w, x,
     output logic             done, out);

    logic [WIDTH-1:0] top_count;
    logic top_en, top_ld, top_done;

    logic [WIDTH-1:0] bot_count;
    logic bot_en, bot_ld, bot_done, bot_recycle;

    enum logic [1:0] {INIT, COMP, DONE} curr_state, next_state;

    // Instantiate counter modules
    Down_Counter #(WIDTH) top(.en(top_en), .load(top_ld), .recycle(1'b0),
                              .clk(clk), .D(w), .Q0(), .Q(top_count));
    Down_Counter #(WIDTH) bot(.en(bot_en), .load(bot_ld), .recycle(bot_recycle),
                              .clk(clk), .D(x), .Q0(), .Q(bot_count));

    assign top_done = (top_count == 4'd1);
    assign bot_done = (bot_count == 4'd0);

    always_ff @(posedge clk, negedge reset_n)
    if (~reset_n) curr_state <= INIT;
    else          curr_state <= next_state;

    //Next state and output generation
    always_comb begin
        top_en      = 1'b0;
        top_ld      = 1'b0;
        bot_en      = 1'b0;
        bot_ld      = 1'b0;
        bot_recycle = 1'b0;
        done        = 1'b0;
        out         = 1'b0;
        case (curr_state)
            INIT: begin
                // Once inputs have arrived, we can load them into counters
                if (in_rdy) begin
                    top_ld = 1'b1;
                    bot_ld = 1'b1;
                end
                next_state = (in_rdy) ? COMP : INIT;
            end
            COMP: begin
                // If bottom counter isn't done, keep it going
                if (~bot_done) begin
                    bot_en = 1'b1;
                    out    = 1'b1;
                    next_state = COMP;
                end
                else if (bot_done) begin
                    // If top and bottom counter are done, finished
                    if (top_done) begin
                        done       = 1'b1;
                        next_state = DONE;
                    end
                    // If only bottom counter is done, decrement top counter
                    // and start the next loop of the bottom counter
                    else begin
                        top_en      = 1'b1;
                        bot_recycle = 1'b1;
                        next_state  = COMP;
                    end
                end
            end
            DONE: begin
                if (in_rdy) begin
                    top_ld = 1'b1;
                    bot_ld = 1'b1;
                end
                else done = 1'b1;
                next_state = (in_rdy) ? COMP : DONE;
            end

        endcase
    end

endmodule: Product_Block

// Full adder
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

// Half adder
module HA
  (input  logic A, 
   input  logic B,
   output logic sum, 
   output logic Cout); 

    xor G1 (sum, A, B); 
    and G2 (Cout, A, B); 

endmodule: HA

// Parallel accumulator for 4-bit inputs
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

module Top
    (input  logic             clk, reset_n,
     input  logic [15:0]      in_rdy,
     input  logic [15:0][3:0] w, x,
     output logic             result_rdy,
     output logic [ 7:0]      result);

    logic [15:0] PB_done;
    logic [15:0] PAC_in;

    assign result_rdy = |PB_done; // OR of all the PBs' done signals

    genvar i;
    generate
        for (i = 0; i < 16; i++) begin: prod_blocks
            Product_Block p(.in_rdy(in_rdy[i]), .clk(clk), .reset_n(reset_n),
                            .w(w[i]), .x(x[i]), .done(PB_done[i]), .out(PAC_in[i]));
        end
    endgenerate

    Parallel_Accum_4 pac(.in(PAC_in), .clk(clk), .reset_n(reset_n), .out(result));

endmodule: Top