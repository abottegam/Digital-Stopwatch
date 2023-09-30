//This is my DFlip-Flop
module DFF0(data_in,clock,reset, data_out);
input data_in;
input clock,reset;

output reg data_out;

always@(posedge clock)
	begin
		if(reset)
			data_out<=1'b0;
		else
			data_out<=data_in;
	end	

endmodule

//This is my clock divider
module clk_divider(clock, rst, clk_out);
input clock, rst;
output clk_out;
 
wire [18:0] din;
wire [18:0] clkdiv;
 
DFF0 dff_inst0(
    .data_in(din[0]),
	 .clock(clock),
	 .reset(rst),
    .data_out(clkdiv[0])
);
 
genvar i;
generate
for (i = 1; i < 19; i=i+1) 
	begin : dff_gen_label
		 DFF0 dff_inst (
			  .data_in (din[i]),
			  .clock(clkdiv[i-1]),
			  .reset(rst),
			  .data_out(clkdiv[i])
		 );
		 end
endgenerate
 
assign din = ~clkdiv;
 
assign clk_out = clkdiv[18];
 
endmodule

//This is my Half Adder
module HalfAdder(A,B,Sum,Carry);
//Input ports
input A;
input B;
//Output port
output Sum;
output Carry;
//Expression
assign Sum = A^B;
assign Carry = A&B;
endmodule 

//This is my RCA
module RCA(A,Cin,Sum,Cout);
//Input ports
input [3:0]A;
input Cin;
//Output port
output [3:0]Sum;
output Cout;
//Wires
wire [2:0]C;
//Expression
HalfAdder HA1(.A (A[0]), .B (Cin), .Sum (Sum[0]), .Carry(C[0]));
HalfAdder HA2(.A (A[1]), .B (C[0]), .Sum (Sum[1]), .Carry(C[1]));
HalfAdder HA3(.A (A[2]), .B (C[1]), .Sum (Sum[2]), .Carry(C[2]));
HalfAdder HA4(.A (A[3]), .B (C[2]), .Sum (Sum[3]), .Carry(Cout));
endmodule

//4DFlip-Flop
module DFF4(A, clock, reset, Count);
input clock;
input reset;
input [3:0]A;

output [3:0]Count;

DFF0 DF1(.data_in (A[0]), .clock (clock), .reset (reset), .data_out(Count[0]));
DFF0 DF2(.data_in (A[1]), .clock (clock), .reset (reset), .data_out(Count[1]));
DFF0 DF3(.data_in (A[2]), .clock (clock), .reset (reset), .data_out(Count[2]));
DFF0 DF4(.data_in (A[3]), .clock (clock), .reset (reset), .data_out(Count[3]));
endmodule

//This is my Count 10 module using the RCA and DFF4 component
module Count10(clk, inc, rst, Count, count_eq_9);
input clk;
input rst;//global
input inc;

output [3:0]Count;
output count_eq_9;

wire dummy;
wire [3:0]RCAout;
wire a;
wire reset;

assign count_eq_9 = (Count == 4'b1001)? 1 : 0;
assign a = count_eq_9&inc;
assign reset = a|rst;

RCA RCA1(.A (Count), .Cin (inc), .Sum (RCAout), .Cout(dummy));
DFF4 DF1(.A (RCAout), .clock (clk), .reset (reset), .Count(Count));

endmodule

//This is my BCD_Display
module BCDto7seg(A ,B, C, D, a, b, c, d, e, f, g);
//Input ports
input A;
input B;
input C;
input D;
//Output port
output a;
output b;
output c;
output d;
output e;
output f;
output g;
//Expression
assign a = ~A&~C&(B^D);
assign b = B&(C^D);
assign c = C&~D&~B;
assign d = ~A&(B|D)&(~C|D)&(B|~C)&(~B|C|~D);
assign e = (B|D)&(~C|D);
assign f = ~A&(~B|C)&(~B|D)&(C|D);
assign g = ~A&~(B^C)&(~B|D);
endmodule


//This is my count6 module
module Count6(clk, inc, rst, Count);
input clk;
input rst;//global
input inc;
//assign rs;

output [3:0]Count;

wire [3:0]RCAout;
wire a;
wire and1;
wire reset;
wire dummy;

assign F = (Count == 4'b0101)? 1 : 0;
assign and1 = F&inc;
assign reset = and1|rst;

RCA RCA1(.A (Count), .Cin (inc), .Sum (RCAout), .Cout(dummy));
DFF4 DF1(.A (RCAout), .clock (clk), .reset (reset), .Count(Count));

endmodule

//This is my TFFs
module TFF0 (
data  , // Data Input
clk   , // Clock Input
reset , // Reset input
q       // Q output
);
//-----------Input Ports---------------
input data, clk, reset ; 
//-----------Output Ports---------------
output q;
//------------Internal Variables--------
reg q;
//-------------Code Starts Here---------
always @ ( posedge clk or posedge reset)
if (reset) begin
  q <= 1'b0;
end else if (data) begin
  q <= !q;
end
endmodule

//This is my final Counter using one instance of the CLK_divider, 3 instances of the count10 module, and one instance of the count6 module
module Counter(clock, reset, start, a1, b1, c1, d1, e1, f1, g1, a2, b2, c2, d2, e2, f2, g2, a3, b3, c3, d3, e3, f3, g3, a4, b4, c4, d4, e4, f4, g4);
input clock;
input reset;
input start;
output a1,b1,c1,d1,e1,f1,g1,a2,b2,c2,d2,e2,f2,g2,a3,b3,c3,d3,e3,f3,g3,a4,b4,c4,d4,e4,f4,g4;
wire clk_out;
wire [3:0]O1;
wire [3:0]O2;
wire [3:0]O3;
wire [3:0]O4;
wire count_eq_91;//ask
wire count_eq_92;
wire count_eq_93;
wire q;
wire and1;
wire and2;
wire and3;

TFF0 TFF1(.data(1), .clk(start), .reset(0), .q(q));

clk_divider clk_dvider1(.clock (clock), .rst (0), .clk_out (clk_out));

Count10 Count101(.clk (clk_out), .inc (q), .rst (reset), .Count(O1), .count_eq_9(count_eq_91));

BCDto7seg BCD27Seg1(.A (O1[3]), .B (O1[2]), .C (O1[1]), .D(O1[0]), .a(a1), .b(b1), .c(c1), .d(d1), .e(e1), .f(f1), .g(g1));

assign and1 = count_eq_91&q;
Count10 Count102(.clk (clk_out), .inc (and1), .rst (reset), .Count(O2), .count_eq_9(count_eq_92));

BCDto7seg BCD27Seg2(.A(O2[3]), .B(O2[2]), .C(O2[1]), .D(O2[0]), .a(a2), .b(b2), .c(c2), .d(d2), .e(e2), .f(f2), .g(g2));

assign and2 = count_eq_92&and1;
Count10 Count103(.clk (clk_out), .inc (and2), .rst (reset), .Count(O3), .count_eq_9(count_eq_93));

BCDto7seg BCD27Seg3(.A(O3[3]), .B(O3[2]), .C(O3[1]), .D(O3[0]), .a(a3), .b(b3), .c(c3), .d(d3), .e(e3), .f(f3), .g(g3));

assign and3 = count_eq_93&and2;
Count6 Count64(.clk (clk_out), .inc (and3), .rst (reset), .Count(O4));

BCDto7seg BCD27Seg4(.A (O4[3]), .B (O4[2]), .C (O4[1]), .D(O4[0]), .a(a4), .b(b4), .c(c4), .d(d4), .e(e4), .f(f4), .g(g4));


endmodule
