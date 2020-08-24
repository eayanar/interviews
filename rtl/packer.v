
module packer
#(
   parameter INPUT_WIDTH = 40
   parameter OUT_WIDTH = 66
 )
(
  input wire                   clk,
  input wire                   reset_n,
  input wire                   input_data_valid,
  input wire [INPUT_WIDTH-1:0] input_data,

  output reg                   valid_pack_out,
  output reg [OUT_WIDTH-1:0]   pack_data_out
 );

localparam EXT_DATA = INPUT_WIDTH * OUT_WIDTH /2; //1320 =40*33


wire [5:0] next_inp_count;
wire [4:0] next_pack_count;

wire limit_reached;
wire pack_limit_reached;

wire [EXT_DATA-1:0] bit_array_rd;
reg  [EXT_DATA-1:0] bit_array0;
reg  [EXT_DATA-1:0] bit_array1;
assign limit_reached         = (input_count == 6'd32);
assign pack_limit_reached    = (pack_count ==  5'd9);


assign next_inp_count   =  limit_reached ? 6'd0: input_count + 'd1;
assign next_pack_count  =  pack_limit_reached ? 6'd0: input_count + 'd1;

assign bit_array_rd = toggle_wr ? bit_array0:
                                  bit_array1;

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
       bit_array0 <= {{EXT_DATA}{1'b0}};
       bit_array1 <= {{EXT_DATA}{1'b0}};
       valid_pack_out <=1'b0
       input_count <= 6'd0; 
       pack_count  <= 5'd0;
       toggle_wr   <= 1'b0;
   end else begin
      if(input_valid) begin
          input_count <= next_inp_count;
	 if(!toggle_wr) begin
           bit_array0 <= { bit_array0[EXT_DATA-INPUT_DATA-1:0],input_data};
         end else begin
           bit_array1 <= { bit_array1[EXT_DATA-INPUT_DATA-1:0],input_data};
	 end
      end
      if(limit_reached) begin
         valid_pack_out <= 1'b1;
	 toggle_wr      <= ~toggle_wr;
      end
      if(valid_pack_out) begin
         pack_count <= next_pack_count;
      end
      if(valid_pack_out & pack_limit_reached) begin
         valid_pack_out <=1'b0;
      end
   end 
end

always @(*) begin
   case(pack_count)
     5'd0 :  pack_data_out <= bit_array_rd[1*OUT_WIDTH-1:0];           
     5'd1 :  pack_data_out <= bit_array_rd[2 *OUT_WIDTH-1:1*OUT_WIDTH]; 
     5'd2 :  pack_data_out <= bit_array_rd[3 *OUT_WIDTH-1:2*OUT_WIDTH];
     5'd3 :  pack_data_out <= bit_array_rd[4 *OUT_WIDTH-1:3*OUT_WIDTH];
     5'd4 :  pack_data_out <= bit_array_rd[5 *OUT_WIDTH-1:4*OUT_WIDTH];
     5'd5 :  pack_data_out <= bit_array_rd[6 *OUT_WIDTH-1:5*OUT_WIDTH];
     5'd6 :  pack_data_out <= bit_array_rd[7 *OUT_WIDTH-1:6*OUT_WIDTH];
     5'd7 :  pack_data_out <= bit_array_rd[8 *OUT_WIDTH-1:7*OUT_WIDTH];
     5'd8 :  pack_data_out <= bit_array_rd[9 *OUT_WIDTH-1:8*OUT_WIDTH];
     5'd9 :  pack_data_out <= bit_array_rd[10*OUT_WIDTH-1:9*OUT_WIDTH];
     5'd10:  pack_data_out <= bit_array_rd[11*OUT_WIDTH-1:10*OUT_WIDTH]; 
     5'd11:  pack_data_out <= bit_array_rd[12*OUT_WIDTH-1:11*OUT_WIDTH];
     5'd12:  pack_data_out <= bit_array_rd[13*OUT_WIDTH-1:12*OUT_WIDTH];
     5'd13:  pack_data_out <= bit_array_rd[14*OUT_WIDTH-1:13*OUT_WIDTH];
     5'd14:  pack_data_out <= bit_array_rd[15*OUT_WIDTH-1:14*OUT_WIDTH];
     5'd15:  pack_data_out <= bit_array_rd[16*OUT_WIDTH-1:15*OUT_WIDTH];
     5'd16:  pack_data_out <= bit_array_rd[17*OUT_WIDTH-1:16*OUT_WIDTH];
     5'd17:  pack_data_out <= bit_array_rd[18*OUT_WIDTH-1:17*OUT_WIDTH];
     5'd18:  pack_data_out <= bit_array_rd[19*OUT_WIDTH-1:18*OUT_WIDTH];
     5'd19:  pack_data_out <= bit_array_rd[20*OUT_WIDTH-1:19*OUT_WIDTH];
     5'd20:  pack_data_out <= bit_array_rd[21*OUT_WIDTH-1:20*OUT_WIDTH];
     5'd21:  pack_data_out <= bit_array_rd[22*OUT_WIDTH-1:21*OUT_WIDTH];
     5'd22:  pack_data_out <= bit_array_rd[23*OUT_WIDTH-1:22*OUT_WIDTH];
     5'd23:  pack_data_out <= bit_array_rd[24*OUT_WIDTH-1:23*OUT_WIDTH];
     5'd24:  pack_data_out <= bit_array_rd[25*OUT_WIDTH-1:24*OUT_WIDTH];
     5'd25:  pack_data_out <= bit_array_rd[26*OUT_WIDTH-1:25*OUT_WIDTH];
     5'd26:  pack_data_out <= bit_array_rd[27*OUT_WIDTH-1:26*OUT_WIDTH];
     5'd27:  pack_data_out <= bit_array_rd[28*OUT_WIDTH-1:27*OUT_WIDTH];
     5'd28:  pack_data_out <= bit_array_rd[29*OUT_WIDTH-1:28*OUT_WIDTH];
     5'd29:  pack_data_out <= bit_array_rd[30*OUT_WIDTH-1:29*OUT_WIDTH];
     5'd30:  pack_data_out <= bit_array_rd[31*OUT_WIDTH-1:30*OUT_WIDTH];
     5'd31:  pack_data_out <= bit_array_rd[32*OUT_WIDTH-1:31*OUT_WIDTH];
     5'd32:  pack_data_out <= bit_array_rd[33*OUT_WIDTH-1:32*OUT_WIDTH];
     default : pack_data_out <= bit_array_rd[1*OUT_WIDTH-1:0];
   endcase
endmodule
	
