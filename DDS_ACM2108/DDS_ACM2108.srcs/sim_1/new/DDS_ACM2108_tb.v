`timescale 1ns / 1ps

module DDS_ACM2108_tb();
		reg					clk				;
		reg					rst_n           ;
		reg		[1:0]		Mod_SelA        ;//更换波形--0sine,1square,2triangular,triangular
		reg		[1:0]		Mod_SelB        ;
		reg		[3:0]		Key				;
		wire	[7:0]		DataA           ;
		wire	[7:0]		DataB           ;
		wire				clk_a			;
		wire				clk_b           ;
	DDS_ACM2108 DDS_ACM2108(
		.clk			(clk			),
		.rst_n          (rst_n          ),
		.Mod_SelA       (Mod_SelA       ),//更换波形--0sine,1square,2triangular,triangular
		.Mod_SelB       (Mod_SelB       ),
		.Key			(Key			),
		.DataA          (DataA          ),
		.DataB          (DataB          ),
		.clk_a			(clk_a			),
		.clk_b          (clk_b          ) 
);
	
	
	parameter PERIOD = 20;
	always begin
	#(PERIOD/2) clk	=	1;
	#(PERIOD/2) clk	=	0;
	end 
	
	initial begin
		rst_n	=	0;
		#201;
		rst_n	=	1;
		#1000;
		Mod_SelA	=	2'b00;
		Mod_SelB    =	2'b00;
		Key		    =	4'b0001;
		#1000_0000;
		$stop;
	end 
	

endmodule
