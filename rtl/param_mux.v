module param_mux
#(
  parameter  N         = 16,
  parameter  SEL_LINES = 4, //No of select lines log2(N)
  parameter  M         = 4 //M bitwidth of Each input 

)
(
  input wire  [(N*M)-1:0]          input_data, //N input data packed into N*M bus {input_N,input_(N-1),input_(N-2)......input_0}
  input wire  [SEL_LINES-1:0]    sel,

  output reg  [M-1:0]        mux_out


);

reg [N-1:0] sel_dec;

// Conversion of selection bits to one hot encoding

always @(sel) begin
    sel_dec <= {{{N-1}{1'b0}},1'b1}<<sel;
end

integer i;

always @(*) begin
   for(i=0;i<N;i=i+1)begin
      mux_out <= sel_dec[i] ? input_data[((i+1)*M)-1:i*M] : {{M-1}{1'b0}};
   end
end

endmodule
