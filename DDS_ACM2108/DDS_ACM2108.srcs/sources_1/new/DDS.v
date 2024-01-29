`timescale 1ns / 1ps

module DDS(
	input				clk         ,
	input				rst_n       ,
	input		[1:0]	Mod_Sel		,
	input		[31:0]	Fword       ,
	input		[11:0]	Pword       ,
	output	reg	[7:0]	Data		
    );
	
	reg[31:0]r_Fword;
	reg[11:0]r_Pword;
	
	
	//频率控制字同步寄存器
	always@(posedge clk)begin
		r_Fword	<=	Fword;
	end 
	//相位控制字同步寄存器
	always@(posedge clk)begin
		r_Pword	<=	Pword;
	end
	
	//相位累加器
	reg[31:0]Freq_ACC;
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			Freq_ACC	<=	0;
		else
			Freq_ACC	<=	Freq_ACC	+	r_Fword;	
	end

	
	//波形数据表地址
	wire[11:0]Rom_Addr;
	assign	Rom_Addr	=	Freq_ACC[31:20]	+	r_Pword;
	
	
	wire[7:0]Data_sine;
	wire[7:0]Data_square;
	wire[7:0]Data_triangular;
	
	//正弦波
	rom_sine rom_sine(
		.clka		(clk)			,
		.addra		(Rom_Addr)		,		
		.douta      (Data_sine)
);	

	//方波
	rom_square rom_square(
		.clka		(clk)			,
		.addra		(Rom_Addr)		,		
		.douta      (Data_square)
);	
	
 	//三角波
	rom_triangular rom_triangular(
		.clka		(clk)			,
		.addra		(Rom_Addr)		,		
		.douta      (Data_triangular)
); 

	always@(*)begin
		case(Mod_Sel)
			0:Data	=	Data_sine;
			1:Data	=	Data_square;
			2:Data	=	Data_triangular;
			3:Data	=	256;
		endcase
	end
	
	
	
endmodule
