//Module to generate timing pulses
//WBC 2022_09_16

`timescale 1ps / 1ps
module pulse_generator
(
	clk, //100MHz
	sync,
    rst_n,
	cnv_en,
	sck_gate,
	rx_start,
	data_latch,
    sck
);

input clk,sync,rst_n;
output cnv_en,sck_gate,rx_start,data_latch;
output  sck;

reg sck_gate,data_latch;
reg cnv_en/*synthesis syn_preseve= 1*/;
reg rx_start/*synthesis syn_preseve= 1*/;
wire sck;

reg [12:0] count/*synthesis syn_preseve= 1*/;						// master counter
//this register rst_ns to '0' while the 'sync' pulse from the PLL is 'high'.
//the following pulses are timed by this count: 'cnv_en', 'sck_gate', 'rx_rst_n', 'data_latch', 'cnvclk_gate'

reg [8:0] tsckgateh,sck_gate_length;	
reg [8:0] trxstart,rx_start_length;			
reg [8:0] tcnvenh,cnv_en_length;
reg [8:0] tdatalatchh; 
	
always @ (posedge clk)
begin		
	trxstart =  9'd60; 						// Time for 'rx_start' to go high
	tsckgateh = 9'd60;												// Time for 'sck_gate' to go high   	    
																//		 Yields first 'SCK' edge 477nsec after 'CNV' falls
	sck_gate_length = 9'd16;	
	tcnvenh = 9'd10;												// Time for 'cnv_en' to go high
	cnv_en_length = 9'd3;										// Yields 'CNV' pulsewidth of 32nsec
	tdatalatchh = tsckgateh + sck_gate_length + 9'd2;    //+2	// 78 Time for 'data_latch' to go high
	rx_start_length = 9'd5;//1

end


always @ (posedge clk or negedge rst_n)
    if (!rst_n)
	     count <= 11'd0;
    else if (sync)
	count <= 11'd0;	  
     else 
	count <= count + 11'd1;
    
//generate the 'cnv_en' pulse
always @ (posedge clk or negedge rst_n)
   if (!rst_n)begin
	cnv_en<= 1'b0;
	end
	else	if (count == tcnvenh) //10
	begin
		cnv_en <= 1'b1;
	end
	else if (count == tcnvenh + cnv_en_length) //17
	begin
		cnv_en <= 1'b0;
	end
	else
	begin
		cnv_en <= cnv_en;	end

//generate the 'sck_gate' pulse		
always @ (posedge clk or negedge rst_n)
   if (!rst_n)
	sck_gate <= 1'b0;
	else if (count == tsckgateh) //1
		sck_gate <= 1'b1;
	else if (count == tsckgateh + sck_gate_length) //1+32
		sck_gate <= 1'b0;
	else
		sck_gate <= sck_gate;
			
//generate the 'rx_start_p' pulse	
always @ (negedge clk or negedge rst_n)
   if (!rst_n)
	rx_start <= 1'b0;
	else if (count == trxstart)//61
		rx_start <= 1'b1;
	else if (count == trxstart + rx_start_length)//2+2
		rx_start <= 1'b0;
										
//generate the 'data_latch' pulse	
always @ (posedge clk or negedge rst_n) 
   if (!rst_n)
	   data_latch <= 1'b0;
	else if (count == tdatalatchh)//37
		data_latch <= 1'b1;
	else if (count == tdatalatchh + 9'd1) //42
		data_latch <= 1'b0;
	else
		data_latch <= data_latch;

assign sck=sck_gate ? clk:1'd0;


endmodule