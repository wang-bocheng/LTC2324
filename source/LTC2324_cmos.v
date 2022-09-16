// 本驱动实现100MHz时钟下 0.5Msps采样率
// 可以通过调整sync信号来修改采样率
// 使用CLKOUT下降沿采集信号
`timescale 1ps / 1ps
module LTC2324_cmos
(	
	CLKIN,                            
	SCK,
	CLKOUT,
	CNV_EN,
	SDO1,SDO2,SDO3,SDO4,//输入4通道数据
         
         data1,data2,data3,data4
);

input CLKIN;												//Clock in from user @ 50 MHz
input	CLKOUT;												//CLKOUT signal from the ADC
input	SDO1,SDO2,SDO3,SDO4;						//Data out Chs 1,2,3,4 from ADC
											//Latch signal from FPGA to DC890 on falling edge
output CNV_EN;												//Convert start on falling edge							
output SCK;									//SCK from FPGA to ADC @ 100 MHz SDR
output data1,data2,data3,data4;

wire CNV_EN;
wire sck_gate,sync,rx_start,data_latch;						
wire CLKOUT;
wire rx_clk_100,clk_100;
wire SDO1,SDO2,SDO3,SDO4;


pll  pll_inst(
	.clkin1(CLKIN),
	.clkout0(rx_clk_100),
	.clkout1(clk_100),
	.clkout2(clk_10)
);

fenp fenp_inst(
     .clk_10m(clk_10),
     .rst_n(rst_n),
     .sync(sync)
);
//generate the 'SCK' signal因为紫光FPGA没有双速率IP核所以要自己生成SCK信号在pulse_generator中
/* altddioout	sckddr 
( 
	.datain_h(sck_gate),
	.datain_l(1'b0),
	.outclock(clk),
	.dataout(SCK)
); */
	
//generate the timing pulses 'sck_gate', 'CNV_EN'
pulse_generator pulses
(
	.clk(clk_100),
	.sync(sync),
    .rst_n(rst_n),
	.cnv_en(CNV_EN),
	.sck_gate(sck_gate),
	.rx_start(rx_start),
	.data_latch(data_latch),
    .sck(SCK)

);

parameter channel1 = 4'b0001;
parameter channel2 = 4'b0010;
parameter channel3 = 4'b0011;
parameter channel4 = 4'b0100;

wire[31:0] data1,data2,data3,data4;//最终采集的32位数据（16位数据加8位时间戳，两个4位通道号）
// Receive serial data from ADC ch 1 and converts it to parallel format
deserializer rx1
(
	.rx_start(rx_start),
	.reset(rst_n),
	.clk_sdr(CLKOUT),
	.sdo(SDO1),
	.parallel_data(data1),
	.data_latch(data_latch),
	.channel(channel1)
);
// Receive serial data from ADC ch 2 and converts it to parallel format
deserializer rx2
(
	.rx_start(rx_start),
	.reset(rst_n),
	.clk_sdr(CLKOUT),
	.sdo(SDO2),
	.parallel_data(data2),
	.data_latch(data_latch),
	.channel(channel2)
);

// Receive serial data from ADC ch 3 and converts it to parallel format
deserializer rx3
(
	.rx_start(rx_start),
	.reset(rst_n),
	.clk_sdr(CLKOUT),
	.sdo(SDO3),
	.parallel_data(data3),
	.data_latch(data_latch),
	.channel(channel3)
);

// Receive serial data from ADC ch 4 and converts it to parallel format
deserializer rx4
(
	.rx_start(rx_start),
	.reset(rst_n),
	.clk_sdr(CLKOUT),
	.sdo(SDO4),
	.parallel_data(data4),
	.data_latch(data_latch),
	.channel(channel4)
);

endmodule

