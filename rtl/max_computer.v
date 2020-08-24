module max_computer
#(
   parameter INP_BW = 8
)
(
   input wire               i_clk            ,
   input wire               reset_n          ,
   input wire               i_start_p        ,
   input wire               i_rdy            ,
   input wire [INP_BW-1:0]  i_rdata          ,

   output wire              o_rd             ,
   output reg               o_vld_p          ,
   output reg [INP_BW-1:0] o_max_val
);

wire  end_of_max_comp; 


wire              input_val          ;
wire              enable_max_comp    ;
wire              wait_for_i_start_p ;
wire [7:0]        next_inp_counter   ;
wire [INP_BW-1:0] max_w;
wire              compare_out;
reg               input_val_dly;
reg [7:0]         input_counter;
reg [INP_BW-1:0]  input_reg;
reg [INP_BW-1:0]  input_curr;
reg [INP_BW-1:0]  input_prev;



assign end_of_max_comp  = (input_counter == 8'd255);
assign next_inp_counter = end_of_max_comp ? 8'd0: input_counter +8'd1;

assign o_rd = enable_max_comp;

always @(posedge i_clk or negedge reset_n)begin
   if(!reset_n)begin
      input_val          <= 1'b0;
      enable_max_comp    <= 1'b0;
      wait_for_i_start_p <= 1'b1;
      input_reg          <= {{INP_BW}{1'b0}};
   end else begin
      if(i_start_p & (wait_for_i_start_p)) begin
	 enable_max_comp    <= 1'b1;
         wait_for_i_start_p <= 1'b0;
      end
      if(end_of_max_comp)begin
	 enable_max_comp    <= 1'b0;
	 wait_for_i_start_p <= 1'b1;
      end
      if(i_rdy) begin
	 input_reg <= i_rdata;
      end
      input_val <= i_rdy;
   end
end

//MAX COMPUTATION logic

assign compare_out = (input_curr > input_prev);
assign max_w       = compare_out ? input_curr : 
                                   input_prev ;

always @(posedge i_clk or negedge reset_n)begin
   if(!reset_n)begin
      input_counter <= 8'd0 ;
      input_curr    <= {{INP_BW}{1'b0}};
      input_prev    <= {{INP_BW}{1'b0}};
   end else begin
      input_val_dly <= input_val;
      o_vld_p       <= input_val_dly & end_of_max_comp & enable_max_comp;
      if(i_start_p) begin
	 input_counter <= 8'd0 ;
	 input_curr    <= {{INP_BW}{1'b0}};
	 input_prev    <= {{INP_BW}{1'b0}};
      end

      if(input_val) begin
	 input_counter <= next_inp_counter ;
	 input_curr <= input_reg;
	 input_prev <= input_curr;
      end
      if(input_val_dly)begin
	 o_max_val <= max_w;
      end
   end
end
endmodule 
