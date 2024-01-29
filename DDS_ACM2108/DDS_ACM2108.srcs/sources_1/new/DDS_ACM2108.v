`timescale 1ns / 1ps

module DDS_ACM2108(
		input			clk				,
		input			rst_n           ,
		input[1:0]		Mod_SelA        ,//更换波形--0sine,1square,2triangular,triangular
		input[1:0]		Mod_SelB        ,
		input[3:0]		Key				,
		output[7:0]		DataA           ,
		output[7:0]		DataB           ,
		output			clk_a			,
		output			clk_b           
);
	
	assign	clk_a	=	clk;
	assign	clk_b	=	clk;

	reg[31:0]FwordA;
	reg[31:0]FwordB;
	reg[11:0]PwordA;
	reg[11:0]PwordB;
	
	DDS	DDSA( 
		.clk        (clk)		,
		.rst_n      (rst_n)		,
		.Mod_Sel	(Mod_SelA)	,
		.Fword      (FwordA)	,
		.Pword      (PwordA)	,
		.Data		(DataA)
    );
	
	DDS	DDSB(
		.clk        (clk)		,
		.rst_n      (rst_n)		,
		.Mod_Sel	(Mod_SelB)	,
		.Fword      (FwordB)	,
		.Pword      (PwordB)	,
		.Data		(DataB)
    );
	
 	wire[3:0]Key_flag;
//	wire[3:0]Key_state; */
	
/* 	key_filter(
	input	wire	Clk,
	input	wire	Reset_n,
	input	wire	key_in,
	output	reg 	key_flag		//滤波后的信号（脉冲信号）
    ); */
	
	key_filter key_filter0(
		.Clk		(clk)			,
		.Reset_n	(rst_n)			,
		.key_in		(Key[0])		,
		.key_flag	(Key_flag[0])			//滤波后的信号（脉冲信号）
	//	.Key_state	(Key_state[0])
    );
	
	key_filter key_filter1(
		.Clk		(clk)			,
		.Reset_n	(rst_n)			,
		.key_in		(Key[1])		,
		.key_flag	(Key_flag[1])			//滤波后的信号（脉冲信号）
	//	.Key_state	(Key_state[1])
    );
	
	key_filter key_filter2(
		.Clk		(clk)			,
		.Reset_n	(rst_n)			,
		.key_in		(Key[2])		,
		.key_flag	(Key_flag[2])			//滤波后的信号（脉冲信号）
	//	.Key_state	(Key_state[2])
    );
	
	key_filter key_filter3(
		.Clk		(clk)			,
		.Reset_n	(rst_n)			,
		.key_in		(Key[3])		,
		.key_flag	(Key_flag[3])			//滤波后的信号（脉冲信号）
	//	.Key_state	(Key_state[3])
    );
	
	reg[2:0]CHA_Fword_Sel;
	reg[2:0]CHB_Fword_Sel;
	reg[2:0]CHA_Pword_Sel;
	reg[2:0]CHB_Pword_Sel;
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			CHA_Fword_Sel	<=	0;
		else if(Key_flag[0])
			CHA_Fword_Sel	<=	CHA_Fword_Sel	+	1;
	end 
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			CHB_Fword_Sel	<=	0;
		else if(Key_flag[1])
			CHB_Fword_Sel	<=	CHB_Fword_Sel	+	1;
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			CHA_Pword_Sel	<=	0;
		else if(Key_flag[2])
			CHA_Pword_Sel	<=	CHA_Pword_Sel	+	1;
	end 
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			CHB_Pword_Sel	<=	0;
		else if(Key_flag[3])
			CHB_Pword_Sel	<=	CHB_Pword_Sel	+	1;
	end
	
	always@(*)begin
		case(CHA_Fword_Sel)
			0:FwordA	=	86			;//	2**32/50_000_000;	 1
			1:FwordA	=	859			;//	2**32/5_000_000;     10
			2:FwordA	=	8590		;//	2**32/500_000;       100
			3:FwordA	=	85899		;//	2**32/50_000;        1000
			4:FwordA	=	858993		;//	2**32/5_000;         1000_0
			5:FwordA	=	8589935		;//	2**32/500;           1000_00
			6:FwordA	=	85589345	;//	2**32/50;            1000_000
			7:FwordA	=	429496730	;//	2**32/10;            5000_000 
		endcase
	end
	
	always@(*)begin
		case(CHB_Fword_Sel)
			0:FwordB	=	86			;		//2**32/50_000_000;		85.89934592
			1:FwordB	=	859			;		//2**32/5_000_000;
			2:FwordB	=	8590		;		//2**32/500_000;
			3:FwordB	=	85899		;		//2**32/50_000;
			4:FwordB	=	858993		;		//2**32/5_000;
			5:FwordB	=	8589935		;		//2**32/500;
			6:FwordB	=	85589345	;		//2**32/50;
			7:FwordB	=	429496730	;		//2**32/10;
		endcase
	end
	
	always@(*)begin
		case(CHA_Pword_Sel)
			0:PwordA	=	0;			 //	0
			1:PwordA	=	341;         //	1/12
			2:PwordA	=	683;         //	1/6
			3:PwordA	=	1024;        //	1/4
			4:PwordA	=	1365;        //	1/3
			5:PwordA	=	2048;        //	1/2
			6:PwordA	=	2731;        //	2/3
			7:PwordA	=	3072;        //	3/4
		endcase
	end
	
	always@(*)begin
		case(CHB_Pword_Sel)
			0:PwordB	=	0;			
			1:PwordB	=	341;         
			2:PwordB	=	683;         
			3:PwordB	=	1024;        
			4:PwordB	=	1365;        
			5:PwordB	=	2048;        
			6:PwordB	=	2731;        
			7:PwordB	=	3072;        
		endcase
	end 
	
	
	
endmodule
