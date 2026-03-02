module SegCtrl(
    input                   [ 0 : 0]        rf_we_EX,
    input                   [ 1 : 0]        rf_wd_sel_EX,
    input                   [ 4 : 0]        rf_wa_EX,   
    input                   [ 4 : 0]        rf_ra0_ID,
    input                   [ 4 : 0]        rf_ra1_ID,
    input                   [ 1 : 0]        npc_sel_EX,

    output      reg         stall_pc, stall_IF_ID, stall_ID_EX, stall_EX_MEM, stall_MEM_WB,
    output      reg         flush_pc, flush_IF_ID, flush_ID_EX, flush_EX_MEM, flush_MEM_WB
);

always @(*) begin
    // 本模块控制所有 stall, flush 信号，需赋初值以避免组合环
    stall_pc = 0;
    stall_IF_ID = 0;
    stall_ID_EX = 0;
    stall_EX_MEM = 0;
    stall_MEM_WB = 0;
    flush_pc = 0;
    flush_IF_ID = 0;
    flush_ID_EX = 0;
    flush_EX_MEM = 0;
    flush_MEM_WB = 0;

    if(rf_we_EX & rf_wd_sel_EX == 2'b10 & rf_wa_EX != 5'b00000 & (rf_ra0_ID == rf_wa_EX || rf_ra1_ID == rf_wa_EX)) begin    // load-use 冒险，发生时应插入一个气泡，也即清空 ID/EX 段间寄存器，同时令 IF 前的 PC、IF/ID 段间寄存器停驻一个周期，使气泡在其之前通过
        stall_pc = 1;
        stall_IF_ID = 1;
        flush_ID_EX = 1;
    end 
    else if(npc_sel_EX == 2'b01) begin  // 跳转指令控制冒险，发生时应插入两个气泡，按照加 4 的错误地址读取到的 IF/ID 段间寄存器与 ID/EX 段间寄存器都需要清空
        flush_IF_ID = 1;
        flush_ID_EX = 1;
    end
end

endmodule