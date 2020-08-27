module clock_divider
#(
  parameter DIVIDER_BW = 24
)
(
   input wire                  ref_clock      , //10MHz clock
   input wire                  reset_n        ,

   input wire                  enable_clock_gen,
   input wire {DIVIDER_BW-1:0] divider_value  ,


   output wire                 divided_clock

);

localparam DIV_PLUS1 = DIVIDER_BW +1;

wire                  odd_divisior; 
wire [DIVIDER_BW-1:0]   count_max_limits;
wire [DIV_PLUS1-1:0]   divisor_plus_1;
wire [DIVIDER_BW-1:0] count_by_2;
wire [DIVIDER_BW-1:0]next_clock_counter;                                                                   
wire count_equals_0          ;
wire count_equals_half       ; 
wire   clear_toggle registers_p; 
wire   clear_toggle registers_n;


reg [DIVIDER_BW-1:0]   clock_counter          ;
reg                    pos_branch             ;
reg                    neg_branch_even_div    ;
reg                    enable_clock_gen_dly_p ;

reg neg_branch_odd_div    ;
reg enable_clock_gen_dly_n;
wire odd_div_clk_out     ; 
wire even_div_clk_out    ; 
wire eff_div_clk_out     ; 




assign odd_divisior     = divider_value[0];
assign count_max_limits = divider_value - 1'd1;
assign divisor_plus_1   = divider_value + 1'd1;
assign count_by_2       = odd_divisior ?  divisor_plus_1[DIV_PLUS1-1:1] : {1'b0,divider_value[DIVIDER_BW-1:1]} ;

assign next_clock_counter = (clock_counter == count_max_limits) ? {{DIVIDER_BW}{1'b0}} : clock_counter + 'd1;

assign count_equals_0            = (clock_counter == 'd0) & enable_clock_gen;               //for posedge generation
assign count_equals_half         = (clock_counter == count_by_2 ) & enable_clock_gen;       //for negedge generation to handle 50% duty cycle requirement 

assign clear_toggle registers_p  = enable_clock_gen  & ~(enable_clock_gen_dly_p);
assign clear_toggle registers_n  = enable_clock_gen  & ~(enable_clock_gen_dly_n);

always @(posedge ref_clock or negedge reset_n) begin
    if(!reset_n) begin
       clock_counter          <= {{DIVIDER_BW}{1'b0}}; 
       pos_branch             <=  1'b0; 
       neg_branch_even_div    <=  1'b0;
       enable_clock_gen_dly_p <=  1'b0;
    end else begin
       enable_clock_gen_dly_p <= enable_clock_gen;
       if(enable_clock_gen) begin
          clock_counter <= next_clock_counter;   
       end

       if(count_equals_0) begin
	  pos_branch <= ~pos_branch;
       end
       if(count_equals_half)begin
	  neg_branch_even_div <= ~neg_branch_even_div;
       end
    end
end

// The negative edge of the clock is used to generated the 50% duty cycle 

always @(negedge ref_clock or negedge reset_n) begin
    if(!reset_n) begin
       neg_branch_odd_div <= 1'b0;
       enable_clock_gen_dly_n<= 1'b0;
    end else begin
       enable_clock_gen_dly_n <= enable_clock_gen;
       if(count_equals_half)begin
	  neg_branch_odd_div <= ~neg_branch_out_div;
       end
    end
end





assign odd_div_clk_out      = pos_branch ^ neg_branch_odd_div;
assign even_div_clk_out     = pos_branch ^ neg_branch_even_div;
assign eff_div_clk_out      = odd_div_clk_out ? odd_div_clk_out : even_div_clk_out;

assign divided_clock        = (enable_clock_gen) & (divider_value > 'd1) ? eff_div_clk_out: ref_clock; 


endmodule 
