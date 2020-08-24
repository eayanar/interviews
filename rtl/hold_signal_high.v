module hold_signal_high
#( parameter COUNT_BW = 10
)
(
   input wire                 clock             ,
   input wire                 reset_n           ,
   input wire                 signal_in         ,
   input wire [COUNT_BW-1:0]  cfg_extent_counter,

   output wire                signal_out
);


localparam FIND_POSEDGE = 2'd0;
localparam FIND_NEGEDGE = 2'd1;
localparam EXTN_NEGEDGE = 2'd2;

wire                posedge_signal_in    ;
wire                negedge_signal_in    ;
wire                signal_out_w          ;
wire [COUNT_BW-1:0] next_ext_counter     ;
wire [COUNT_BW-1:0] count_limit          ;
wire                count_limit_reached  ;
wire                cfg_count_equals_one  ;


reg                          signal_in_dly      ;
reg                          ext_signal         ;
reg     [1:0]                curr_state         ;
reg                          enable_ext_counter ;
reg     [COUNT_BW-1:0]       ext_counter        ;

assign posedge_signal_in =  signal_in & ~signal_in_dly;
assign negedge_signal_in = ~signal_in &  signal_in_dly;
assign signal_out_w        =  ext_signal | posedge_signal_in; //To generate an output signal alligned with input signal. Since posedge is used to generate extended signal


assign signal_out = ~(|cfg_extent_counter) ? signal_in : signal_out_w;

always @(posedge clock or negedge reset_n) begin
   if(!reset_n)begin
      signal_in_dly <= 1'b0     ;
   end else begin
      signal_in_dly <= signal_in;
   end
end


assign count_limit          = cfg_extent_counter - {{{COUNT_BW-2}{1'b0}},2'b10};//Since Negative edge detection takes one clock cycle to generate limit is cfg count -2  
assign count_limit_reached  = (ext_counter == count_limit);
assign cfg_count_equals_one =  (~|(cfg_extent_counter[COUNT_BW-1:1])) & cfg_extent_counter[0];

assign next_ext_counter     = (count_limit_reached) ? {{{COUNT_BW-1}{1'b0}},1'b0}:ext_counter + {{{COUNT_BW-1}{1'b0}},1'b1}; 

//Generate (ext_signal) signal to extend the negedge. based on the posedge an
//signal is generated first and then when Negedge is detected the current
//value of signal is extended for a counter duration.


always @(posedge clock or negedge reset_n) begin
   if(!reset_n)begin
      ext_signal         <= 1'b0;
      curr_state         <= FIND_POSEDGE;
      enable_ext_counter <= 1'b0;
      initialize_counter <= 1'b0;
      ext_counter        <= {{COUNT_BW}{1'b0}};
   end else begin
      case(curr_state)
	 FIND_POSEDGE:begin
                            ext_counter  <= {{COUNT_BW}{1'b0}};
	                    if(posedge_signal_in)begin
			       ext_signal <= 1'b1;
			       curr_state <= FIND_NEGEDGE;
			    end else begin
			       ext_signal <= 1'b0;
			    end
	              end
	 FIND_NEGEDGE:begin
	                    if(negedge_signal_in) begin
			       if(cfg_count_equals_one) begin //To handle configured counter value as 0  
	                          curr_state <= FIND_POSEDGE;
	                          ext_signal <= 1'b0;
			      end else begin
			          curr_state         <= EXTN_NEGEDGE;
			          enable_ext_counter <= 1'b1;
				  ext_counter        <= {{COUNT_BW}{1'b0}}; //intialize or restart the counter
			       end
			    end
		      end
         EXTN_NEGEDGE:begin
			    if(enable_ext_counter) begin
			       ext_counter <= next_ext_counter;
			    end
	                    if(enable_ext_counter) begin
			       if(posedge_signal_in) begin    // When a input signal is recived when current counter is running //find negative edge and restart the counter
	                          curr_state <= FIND_NEGEDGE;                                                
	                          ext_signal <= 1'b1;          
			          enable_ext_counter <= 1'b1;  
			       end else begin
				  if(count_limit_reached) begin
			            curr_state <= FIND_POSEDGE;
			            ext_signal <= 1'b0;
			            enable_ext_counter <= 1'b0;
			          end
			       end
			    end
		      end
         default     :begin 
	                       curr_state <= FIND_POSEDGE;
	                       ext_signal <= 1'b0;
		      end
      endcase
   end

end


endmodule
