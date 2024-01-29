/* `timescale 1ns / 1ps
module key_filter(
	Clk,
	Reset_n,
	Key,
	Key_Flag,
	Key_state
);
	input		Clk;
	input		Reset_n;
	input		Key;
	output		Key_Flag;
	output	reg	Key_state;
	
	reg	[1:0]	r_key;
	always@(posedge Clk)
		r_key	<=	{r_key[0],Key};

	reg		Key_P_Flag;
	reg		Key_R_Flag;
	assign	Key_Flag	=	Key_P_Flag	|	Key_R_Flag;
	wire	pedge_key;
	assign	pedge_key	=	r_key	==	2'b01;
	wire	nedge_key;
	assign	nedge_key	=	r_key	==	2'b10;
	
	reg	[19:0]	cnt;
	reg	[1:0]	state;
	
	always@(posedge Clk or negedge Reset_n)
	if(!Reset_n)begin
		state	<=	0;
		Key_P_Flag	<=	1'b0;
		Key_R_Flag	<=	1'b0;
		cnt			<=	0;
		Key_state	<=	1;
	end
	else begin
		case(state)
			0:
				begin
					Key_R_Flag	<=	1'b0;
					if(nedge_key)
						state	<=	1;
					else
						state	<=	0;
				end
					
			1:
				if((pedge_key)&&(cnt<1_000_000-1))
					state		<=	0;
				else if(cnt>=1_000_000-1)begin
					state		<=	2;
					cnt			<=	0;
					Key_P_Flag	<=	1'b1;
					Key_state	<=	0;
				end
				else begin
					cnt		<=	cnt 	+	1'b1;
					state	<=	1;
				end
				
			2:
				begin 
					Key_P_Flag	<=	1'b0;
					if(pedge_key)
						state	<=	3;
					else
						state	<=	2;
				end
				
			3:
				if((nedge_key)&&(cnt<1_000_000-1))
					state		<=	2;
				else if(cnt>=1_000_000-1)begin 
					state		<=	0;
					cnt			<=	0;
					Key_R_Flag	<=	1'b1;
					Key_state	<=	1;
				end 
				else begin
					cnt		<=	cnt 	+	1'b1;
					state	<=	3;
				end
		endcase
	end			
endmodule
 */
 `timescale 1ns/1ns 
module key_filter(
	input	wire	Clk,
	input	wire	Reset_n,
	input	wire	key_in,
	output	reg 	key_flag		//滤波后的信号（脉冲信号）
    );
	
		localparam
		IDEL	= 4'b0001,
		FILTER0	= 4'b0010,
		DOWN	= 4'b0100,
		FILTER1	= 4'b1000;
		
	reg [3:0] state;
	
	reg 	key_tem0;
	reg 	key_tem1;
	
	wire 	nedge;
	wire 	pedge;
	
	reg [19:0]	cnt;	//二十毫秒计数器
	reg			en_cnt;	//计数器使能信号
	reg 		cnt_full;//计数器记满信号
	
//边沿检测	
	always@(posedge Clk or negedge Reset_n) begin
		if(!Reset_n) begin
			key_tem0<=0;
			key_tem1<=0;
		end
		else begin
			key_tem0 <= key_in;
			key_tem1 <= key_tem0;
		end
	end
	
	assign	nedge = !key_tem0 & key_tem1;		//下降沿
	assign	pedge =  key_tem0 & (!key_tem1);	//上升沿
	
//一段式状态机
	always@(posedge Clk or negedge Reset_n )begin
	if(!Reset_n)  begin
		state <= IDEL;
		en_cnt <= 1'b0;
		key_flag<=1'd0;
	end
	else 
		case(state)
			IDEL:
				begin
					key_flag<=1'b0;
					if(nedge) begin
						state <=	FILTER0;
						en_cnt <= 1'b1; //计数器记数
					end
					else	
						state <=	IDEL;
				end
			FILTER0:
				if(cnt_full) begin
					state<= DOWN;
					en_cnt<=1'b0;
					key_flag<=1'b1;
				end
				else if(pedge) begin
					state<= IDEL;
					en_cnt <= 1'b0;
				end
				else
					state<= FILTER0;
			DOWN:
				begin
					key_flag<=1'b0;
					if(pedge)	begin
						state<=FILTER1;
						en_cnt<=1'b1;
					end
					else
						state<= DOWN;
				end
			FILTER1:
				if(cnt_full) begin
					state<= IDEL;
					en_cnt<=1'b0;
					key_flag<=1'b0;
				end
				else if(nedge) begin
					state<= DOWN;
					en_cnt <= 1'b0;
				end
				else
					state<= FILTER1;
			default: begin
				state<=IDEL;
				en_cnt<=1'b0;
				key_flag<=1'b0;
			end
		endcase		
	end
	
//二十毫秒计数器
	always@(posedge Clk or negedge Reset_n) begin
		if(!Reset_n)
			cnt <= 20'd0;
		else if(en_cnt)
			cnt <= cnt + 1'b1;
		else
			cnt<= 20'd0;
	end
	always@(posedge Clk or negedge Reset_n) begin
		if(!Reset_n)
			cnt_full <= 1'b0;
		else if(cnt == 'd999_999)
			cnt_full <= 1'b1;
		else
			cnt_full <= 1'b0;
	end
endmodule