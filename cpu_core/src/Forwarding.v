module Forwarding(
    input                   [ 0 : 0]        rf_we_MEM,
    input                   [ 0 : 0]        rf_we_WB,
    input                   [ 4 : 0]        rf_wa_MEM,   
    input                   [ 4 : 0]        rf_wa_WB,
    input                   [31 : 0]        rf_wd_MEM,      // rf_wd 在 WB 段直接传入即可，在 MEM 段可将 alu_res 传入
    input                   [31 : 0]        rf_wd_WB,
    input                   [ 4 : 0]        rf_ra0_EX,      // 传入 EX 段的信号，用于与 MEM 段、WB 段信号比对确定前递是否发生
    input                   [ 4 : 0]        rf_ra1_EX,

    output      reg         [ 0 : 0]        rf_rd0_fe,      // 前递使能信号
    output      reg         [ 0 : 0]        rf_rd1_fe,      // 前递数据信号
    output      reg         [31 : 0]        rf_rd0_fd,
    output      reg         [31 : 0]        rf_rd1_fd
);

always @(*) begin
    // 赋初值以避免组合环
    rf_rd0_fe = 0;
    rf_rd1_fe = 0;
    rf_rd0_fd = 32'h0000_0000;
    rf_rd1_fd = 32'h0000_0000;

    // wb -> ex, 两部分同时需要传递且地址一致时本部分会被覆盖
    if(rf_we_WB & rf_wa_WB != 5'b00000) begin
        if(rf_ra0_EX == rf_wa_WB) begin
            rf_rd0_fe = 1;
            rf_rd0_fd = rf_wd_WB;
        end
        if(rf_ra1_EX == rf_wa_WB) begin
            rf_rd1_fe = 1;
            rf_rd1_fd = rf_wd_WB;
        end
    end
    
    // mem -> ex, 本部分位置必须在上一部分代码之后
    if(rf_we_MEM & rf_wa_MEM != 5'b00000) begin
        if(rf_ra0_EX == rf_wa_MEM) begin
            rf_rd0_fe = 1;
            rf_rd0_fd = rf_wd_MEM;
        end
        if(rf_ra1_EX == rf_wa_MEM) begin
            rf_rd1_fe = 1;
            rf_rd1_fd = rf_wd_MEM;
        end
    end
end

endmodule