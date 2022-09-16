//Module to deserializer
//WBC 2022_09_16

//这是接收数据的模块，在这也可以对数据进行加通道号，加时间戳等操作
module deserializer(
    rx_start,
	reset,
	clk_sdr, //100m
	sdo,
	parallel_data, //最终的32位数据
	data_latch,
	channel
   );

input rx_start,clk_sdr,sdo,data_latch,channel,reset;
output parallel_data;
wire [3:0] channel/*synthesis syn_keep= 1*/;
reg [31:0] parallel_data/*synthesis syn_preseve= 1*/;
reg [15:0] bits/*synthesis syn_preseve= 1*/;
reg [5:0] cur_state;
reg [5:0] next_state;
	
wire rx_start;

parameter bit_0 = 5'd0;
parameter bit_1 = 5'd1;
parameter bit_2 = 5'd2;
parameter bit_3 = 5'd3;
parameter bit_4 = 5'd4;
parameter bit_5 = 5'd5;
parameter bit_6 = 5'd6;
parameter bit_7 = 5'd7;
parameter bit_8 = 5'd8;
parameter bit_9 = 5'd9;
parameter bit_10 = 5'd10;
parameter bit_11 = 5'd11;
parameter bit_12 = 5'd12;
parameter bit_13 = 5'd13;
parameter bit_14 = 5'd14;
parameter bit_15 = 5'd15;

initial
begin
  next_state = bit_15;
end

	
always @(posedge clk_sdr )begin //SDR mode; load the newest bit into the serial bit array on each falling edge of 'clk'
begin
     cur_state = next_state;		 		
     case (cur_state)	
          bit_15:  //MSB first
          begin	
		if(rx_start)
                begin			
		     bits[15] <= sdo;
	             next_state <= bit_14;
                end	
                else
      next_state <= bit_15;
   end
    	
	bit_14:
	begin			
		  bits[14] <= sdo;
           next_state <= bit_13;
   end	
	
	bit_13:
   begin						
		bits[13] <= sdo;		
	 next_state <= bit_12;
   end	
  	
	bit_12:
   begin						
		bits[12] <= sdo;			
	 next_state <= bit_11;
   end	
  	
	bit_11:
   begin						
		bits[11] <= sdo;		
	 next_state <= bit_10;
   end	
  	
	bit_10:
   begin						
		bits[10] <= sdo;		
	 next_state <= bit_9;
   end	
  	
	bit_9:
   begin						
		bits[9] <= sdo;
	 next_state <= bit_8;
   end	
  	
	bit_8:
   begin						
		bits[8] <= sdo;		
	 next_state <= bit_7;
   end	
  	
	bit_7:
   begin						
		bits[7] <= sdo;		
	 next_state <= bit_6;
   end	
  	
	bit_6:
   begin						
		bits[6] <= sdo;	
	 next_state <= bit_5;
   end	
  	
	bit_5:
   begin						
		bits[5] <= sdo;		
	 next_state <= bit_4;
   end	
    	
	bit_4:
   begin						
		bits[4] <= sdo;
		next_state <= bit_3;
   end	
    	
	bit_3:
   begin					
		bits[3] <= sdo;
		next_state <= bit_2;
   end	
    	
	bit_2:
   begin		
		bits[2] <= sdo;		
		next_state <= bit_1;
   end	
    	
	bit_1:
   begin						
		bits[1] <= sdo;	
		next_state <= bit_0;
   end	
    	bit_0:  //LSB last
             begin	
		bits[0] <= sdo;
		next_state <= bit_15;
	end	
	    
default 	: next_state <= bit_15;
endcase
end
end

reg [7:0] cnt;
 
 
always @ (posedge data_latch or negedge reset)
begin
   if(!reset)begin
      cnt <= 8'b00000000;
end
	else	
		begin
		     parallel_data[31:28] = channel[3:0];
			 parallel_data[27:20] = cnt[7:0];
			 parallel_data[19] = bits[15];
			 parallel_data[18] = bits[14];    
			 parallel_data[17] = bits[13];
			 parallel_data[16] = bits[12]; 
			 parallel_data[15] =  bits[11];
			 parallel_data[14] =  bits[10];    
			 parallel_data[13] =  bits[9];
			 parallel_data[12] =  bits[8]; 
			 parallel_data[11] =  bits[7];
			 parallel_data[10] =  bits[6];    
			 parallel_data[9] =  bits[5];
			 parallel_data[8] =  bits[4]; 
			 parallel_data[7] =  bits[3];
			 parallel_data[6] =  bits[2];    
			 parallel_data[5] =  bits[1];
			 parallel_data[4] =  bits[0];//bits[0]
             parallel_data[3:0] =  channel[3:0];
			 cnt <= cnt +1'b1;
		end
end
endmodule