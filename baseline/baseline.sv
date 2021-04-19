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
     output logic             out);

    logic [WIDTH-1:0] top_count;
    logic top_en, top_ld, top_done;

    logic [WIDTH-1:0] bot_count, bot_init; // bot_init = x throughout counting
    logic bot_en, bot_ld, bot_done, bot_recycle;

    enum logic [2:0] {INIT, COMP} curr_state, next_state;

    // Instantiate counter modules
    Down_Counter #(WIDTH) top(.en(top_en), .load(top_ld), .recycle(1'b0),
                              .clk(clk), .D(w), .Q0(), .Q(top_count));
    Down_Counter #(WIDTH) bot(.en(bot_en), .load(bot_ld), .recycle(bot_recycle),
                              .clk(clk), .D(x), .Q0(bot_init), .Q(bot_count));

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
                    if (top_done)
                        next_state = INIT;
                    // If only bottom counter is done, decrement top counter
                    // and start the next loop of the bottom counter
                    else begin
                        top_en      = 1'b1;
                        bot_recycle = 1'b1;
                        next_state  = COMP;
                    end
                end
            end

        endcase
    end

endmodule: Product_Block
