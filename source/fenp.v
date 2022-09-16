//Module to fenp
//WBC 2022_09_16

//生成sync信号，不使用PLL是因为紫光的IP核不能生成太小的时钟频率，我们需要的采样率是0.5MHz就是使用sync信号控制的，并且sync信号的占空比为12%

module fenp(
     sync,
     clk_10m,
     rst_n 
);

output sync/*synthesis syn_keep= 1*/;

input clk_10m;
input rst_n;

reg [7:0]cnt;
reg sync;

always@(posedge clk_10m or negedge rst_n)begin
     if(!rst_n)
          cnt<=8'd0;
     else if (cnt == 8'd199)
          cnt<=8'd0;
     else 
          cnt<=cnt+1;
end
always@(posedge clk_10m or negedge rst_n)begin
     if(!rst_n)
          sync<=0;
     else if(cnt<8'd24)
          sync<=1;
     else
          sync<=0;
end
endmodule