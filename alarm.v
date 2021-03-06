module alarm(CLK50, LEDR, LEDG, HEX0, HEX1, HEX2, HEX3, PB, SW);
	output reg [9:0] LEDR;
	output reg [7:0] LEDG;
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	input [3:0] PB;
	input [9:0] SW;
	input CLK50;
	
	
	reg [7:0] hour, min, sec, ahour, amin, asec, blink_time;
	reg [6:0] time0, time1, time2, time3;
	reg [3:0] canPressPB;

parameter N = 50_000_000;
//-------function bcdto7seg ------
function [6:0] bcdto7seg; //(bcd -> g,f,e,d,c,b,a);
input [4:0] bcd;
	
  case (bcd)
  0 :  bcdto7seg = 7'b1000000; 
  1 :  bcdto7seg = 7'b1111001; 
  2 :  bcdto7seg = 7'b0100100; 
  3 :  bcdto7seg = 7'b0110000; 
  4 :  bcdto7seg = 7'b0011001; 
  5 :  bcdto7seg = 7'b0010010; 
  6 :  bcdto7seg = 7'b0000011; 
  7 :  bcdto7seg = 7'b1111000; 
  8 :  bcdto7seg = 7'b0000000; 
  9 :  bcdto7seg = 7'b0010000; 
  default:  bcdto7seg = 7'b0000000; 						
 endcase
endfunction

initial begin
	sec = 50;
	min = 59;
	hour = 5;
	asec = 0;
	amin = 0;
	ahour = 6;
	blink_time = 0;
	canPressPB = 4'b1111;
end

wire [25:0] cnt1M;
mycnter #26 M1(CLK50, PB[0], 1, N, cnt1M); //(CLK, RESET, N, q)

//Display time
assign HEX0 = time0;
assign HEX1 = time1;
assign HEX2 = time2;
assign HEX3 = time3;


always @(posedge CLK50)
	if(SW[0] == 0 && SW[3] == 0 && SW[4] == 0 && SW[1] == 0) begin
		//display time hh:mm
		time0 <= bcdto7seg(min % 10);
		time1 <= bcdto7seg((min / 10) %10);
		time2 <= bcdto7seg(hour % 10);
		time3 <= bcdto7seg((hour / 10) %10);
		
		//////////////////////////////////////////////////////////
		if (cnt1M == N) begin
			sec <= sec + 1;
			if(sec == 59) begin
				min <= min + 1;
				sec <= 0;
				if(min == 59 && sec == 59) begin
					hour <= hour + 1;
					min <= 0;
					if(hour == 12 && min == 59 && sec == 59) begin
						hour <= 1;
						min <= 0;
						sec <= 0;
					end
				end
			end
		end
		//////////////////////////////////////////////////////////
	end
	else if(SW[0] == 0 && SW[3] == 0 && SW[4] == 0 && SW[1] == 1) begin
		//display time mm:ss
		time0 <= bcdto7seg(sec % 10);
		time1 <= bcdto7seg((sec / 10) %10);
		time2 <= bcdto7seg(min % 10);
		time3 <= bcdto7seg((min / 10) %10);
		
		//////////////////////////////////////////////////////////
		if (cnt1M == N) begin
			sec <= sec + 1;
			if(sec == 59) begin
				min <= min + 1;
				sec <= 0;
				if(min == 59 && sec == 59) begin
					hour <= hour + 1;
					min <= 0;
					if(hour == 12 && min == 59 && sec == 59) begin
						hour <= 1;
						min <= 0;
						sec <= 0;
					end
				end
			end
		end
		//////////////////////////////////////////////////////////
	end
	//SET TIME
 	else if(SW[0] == 0 && SW[1] == 0 && SW[3] == 0 && SW[4] == 1) begin
		//display time hh:mm
		time0 <= bcdto7seg(min % 10);
		time1 <= bcdto7seg((min / 10) %10);
		time2 <= bcdto7seg(hour % 10);
		time3 <= bcdto7seg((hour / 10) %10);
		
		if(!PB[0]) begin
			//reset
			hour <= 12;
			min <= 0;
			sec <= 0;
		end
		
		if (PB[1]) begin
			canPressPB[1] <= 1;
		end
		else if(!PB[1]) begin
			if (canPressPB[1] == 1) begin
				if (min > 0) min <= min - 1; //down min
				else min <= 59;
				canPressPB[1] <= 0;
			end
		end
		
		if (PB[2]) begin
			canPressPB[2] <= 1;
		end
		else if (!PB[2]) begin
			if (canPressPB[2] == 1) begin
				if (min < 59) min <= min + 1; //up min
				else min <= 0;
				canPressPB[2] <= 0;
			end
		end
		
		if (PB[3]) begin
			canPressPB[3] <= 1;
		end
		else if(!PB[3]) begin
			if (canPressPB[3] == 1) begin
				//up hour
				if (hour < 12) hour <= hour + 1;
				else hour <= 0;
				canPressPB[3] <= 0;
			end
		end
	end
 	//SET ALARM
	else if(SW[0] == 0 && SW[1] == 0 && SW[3] == 1 && SW[4] == 0) begin
		//display time hh:mm
		time0 <= bcdto7seg(amin % 10);
		time1 <= bcdto7seg((amin / 10) %10);
		time2 <= bcdto7seg(ahour % 10);
		time3 <= bcdto7seg((ahour / 10) %10);
	
		if(!PB[0]) begin
			//reset
			ahour <= 12;
			amin <= 0;
			asec <= 0;
		end
		else if (PB[2]) begin
			canPressPB[2] <= 1;
		end
		else if (!PB[2]) begin
			if (canPressPB[2] == 1) begin
				if (amin < 59) amin <= amin + 1; //up min
				else amin <= 0;
				canPressPB[2] <= 0;
			end
		end
		if (PB[1]) begin
			canPressPB[1] <= 1;
		end
		else if(!PB[1]) begin
			if (canPressPB[1] == 1) begin
				if (amin > 0) amin <= amin - 1; //down min
				else amin <= 59;
				canPressPB[1] <= 0;
			end
		end
		
		if (PB[3]) begin
			canPressPB[3] <= 1;
		end
		else if(!PB[3]) begin
			if (canPressPB[3] == 1) begin
				//up hour
				if (ahour < 12) ahour <= ahour + 1;
				else ahour <= 0;
				canPressPB[3] <= 0;
			end
		end
	end
 	
 	//ALARM 
 always @(posedge CLK50)
 	if(SW[2] == 1)begin
		if(hour == ahour && min == amin) begin
			if (cnt1M < 25_000_000) begin
				// cool mode
				//LEDR <= ~LEDR;
				//LEDG <= ~LEDG;
				LEDR <= 10'b1111111111;
				LEDG <= 8'b11111111;
			end
			// comment these for cool mode
			// vv
			else begin
				LEDR <= 0;
				LEDG <= 0;
			end
			// ^^
		end
	end
	
	else if (SW[2] == 0) begin
		LEDR <= 0;
		LEDG <= 0;
	end
endmodule

module mycnter(clk, rst, startn, stopn, q);
parameter N = 3;
input clk, rst;
input [N-1:0] startn, stopn;
output [N-1:0] q;
reg [N-1:0] q;

initial q = startn;
always @(posedge clk)
  if (!rst) q <= startn;
  else 
	begin
	  if (q == stopn) q <= startn;
	  else			q <= q + 1;
	end
	  
endmodule

