module random_eviction #(
    parameter INDEX_WIDTH               = 3,
    parameter WAY_NUM                   = 2
)(
    input                               clk,    
    input                               rstn,
    input       [INDEX_WIDTH-1:0]       index,
    output      reg         [7:0]       eviction
);
  
always @(posedge clk or negedge rstn) begin
    if(!rstn)
        eviction <= 0;
    else if(eviction == WAY_NUM - 1) 
        eviction <= 0;
    else
        eviction <= eviction + 1;
end
endmodule