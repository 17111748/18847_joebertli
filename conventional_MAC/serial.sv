
`timescale 1ns/10ps


module serial_sub
#(parameter SIZE = 16)
(
	input logic [SIZE-1:0] in1,
	input logic [SIZE-1:0] in2,
	input logic start,
	input logic reset_n,
	input logic clk,

	output logic [(SIZE<<1)-1:0] out,
	output logic done
);


enum {IDLE,RUN,DONE} state, next_state;

logic load,clear;
logic [(SIZE<<1)-1:0] partial,par_out_a;
logic [SIZE-1:0] par_out_b;
logic [$clog2(SIZE):0] count;


always_ff@ (posedge clk, negedge reset_n)				//SHIFT REGISTER A 32 bit
begin 
	if (~reset_n)
		par_out_a <= ((SIZE<<1))'('d0);
	else if(load == 1'b1)
		par_out_a <= {(SIZE)'('d0),in1}; 	
	else	
		par_out_a <= {par_out_a[(SIZE<<1)-2:0],1'b0};
				
end

always_ff@ (posedge clk, negedge reset_n)				//SHIFT REGISTER B 16 bit
begin
	if (~reset_n)
		par_out_b <= (SIZE)'('d0);
	else if(load == 1'b1)
		par_out_b <= in2; 	
	else	
		par_out_b <= {1'b0, par_out_b[(SIZE-1):1]};
				
end

always @(par_out_b,par_out_a)					//MULTIPLEXER
begin
	if(par_out_b[0] == 1'b0)
		partial <= ((SIZE<<1))'('d0);
	else
		partial <= par_out_a;
end

always_ff@ (posedge clk, negedge reset_n)				//ACCUMULATOR
begin
	if (~reset_n)
		out <= ((SIZE<<1))'('d0);
	else if (clear)
		out <= ((SIZE<<1))'('d0);
	else
		out <= out+partial;
end


always@ (posedge clk, negedge reset_n)				//COUNTER
begin
	if (~reset_n)
        count <= {1'b1, ($clog2(SIZE))'('d1)};
	else if (state!=RUN)
		count <= {1'b1, ($clog2(SIZE))'('d1)};
	else 
		count <= count - ($clog2(SIZE)+1)'('d1); 
end

always_ff@ (posedge clk, negedge reset_n)				//STATE REGISTER
begin
	if (~reset_n)
		state <= IDLE;
	else
		state <= next_state;
end


always@(start,count,state)					//FSM COMB
begin
	case(state)
		IDLE:
		begin
			if(start == 1)
				next_state <= RUN;
			else
				next_state <= IDLE;
			
			load <= 0;
			clear <= 1;
			done <= 0;
		end
		
		RUN:
		begin
			if(count == ($clog2(SIZE)+1)'('d0))
				next_state <= DONE;
			else
				next_state <= RUN;
			
			if(count == {1'b1, ($clog2(SIZE))'('d0)}) 
				load <= 1;
			else
				load <= 0;
			clear <= 0;
			done <= 0;
		end

		DONE:
		begin
			next_state <= IDLE;
			load <= 0;
			clear <= 0;
			done <= 1;
		end
		
		default:
		begin
			next_state <= IDLE;
			load <= 0;
			clear <= 1;
			done <= 0;
		end
		
	endcase
end
	
endmodule: serial_sub



module serial
	#(parameter SIZE = 8,
      parameter SETS = 16)
    (input  logic clk, 
     input  logic reset_n, 
     input  logic valid, // Start of when the input signal should be grabbed.
     input  logic [(SETS*SIZE)-1:0] a, 
     input  logic [(SETS*SIZE)-1:0] b, 
     output logic ready, // Asserted when the output is ready to be read. 
     output logic [(SIZE<<1)+SETS-1:0] out); 


	logic [SETS-1:0] ready_out; 

	logic [(SIZE<<1)*SETS-1:0] binary_out; 

	genvar j; 
	generate
		for(j = 0; j < SETS; j++) 
		begin : loop 
			serial_sub #(.SIZE(SIZE)) s(.clk(clk), .reset_n(reset_n), .start(valid), 
			                   .in1(a[(j+1)*SIZE-1:j*SIZE]), .in2(b[(j+1)*SIZE-1:j*SIZE]), 
							   .done(ready_out[j]), .out(binary_out[((j+1)*(SIZE<<1))-1:j*(SIZE<<1)])); 
		end : loop 
	
	endgenerate

	assign ready = (ready_out == ~((SETS)'('b0))); 

	assign out = binary_out[((0+1)*(SIZE<<1))-1:0*(SIZE<<1)] + 
				binary_out[((1+1)*(SIZE<<1))-1:1*(SIZE<<1)] +
				binary_out[((2+1)*(SIZE<<1))-1:2*(SIZE<<1)] +
				binary_out[((3+1)*(SIZE<<1))-1:3*(SIZE<<1)] + 
				binary_out[((4+1)*(SIZE<<1))-1:4*(SIZE<<1)] +
				binary_out[((5+1)*(SIZE<<1))-1:5*(SIZE<<1)] + 
				binary_out[((6+1)*(SIZE<<1))-1:6*(SIZE<<1)] + 
				binary_out[((7+1)*(SIZE<<1))-1:7*(SIZE<<1)] +
				binary_out[((8+1)*(SIZE<<1))-1:8*(SIZE<<1)] + 
				binary_out[((9+1)*(SIZE<<1))-1:9*(SIZE<<1)] +
				binary_out[((10+1)*(SIZE<<1))-1:10*(SIZE<<1)] + 
				binary_out[((11+1)*(SIZE<<1))-1:11*(SIZE<<1)] +
				binary_out[((12+1)*(SIZE<<1))-1:12*(SIZE<<1)] + 
				binary_out[((13+1)*(SIZE<<1))-1:13*(SIZE<<1)] + 
				binary_out[((14+1)*(SIZE<<1))-1:14*(SIZE<<1)] +
				binary_out[((15+1)*(SIZE<<1))-1:15*(SIZE<<1)];

endmodule: serial