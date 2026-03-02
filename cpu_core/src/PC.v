module PC (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,
    input                   [ 0 : 0]            en,
    input                   [ 0 : 0]            stall,
    input                   [ 0 : 0]            flush,
    input                   [31 : 0]            npc,

    output      reg         [31 : 0]            pc
);

always @(posedge clk) begin
    if (rst)
        pc <= 32'h1C000000; 
    else if (en)
        if (flush) begin
            pc <= 32'h1C000000;
        end
        else if (stall) begin
            pc <= pc;
        end
        else begin
            pc <= npc;
        end
    else 
        pc <= pc;
end
endmodule
