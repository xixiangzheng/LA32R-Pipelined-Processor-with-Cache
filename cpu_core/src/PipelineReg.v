module PipelineReg # (
    parameter       WIDTH               = 32
)(
    input                               clk,
    input                               rst,
    input                               en,         // 让段间寄存器受到 PDU 的控制，保证其与 PC 寄存器 en 端口的同步
    input                               stall1,     // 停驻
    input                               stall2,
    input                               stall3,
    input                               stall4,
    input                               flush1,     // 同步清空
    input                               flush2,
    input                               flush3,
    input                               flush4,

    input           [WIDTH-1 : 0]       init,       // 清空所用的初值
    input           [WIDTH-1 : 0]       pre,        // 信号产生时的值
    output   reg    [WIDTH-1 : 0]       post1,      // 每一周期向后传递一个寄存器，CPU 流水线共有五段，最多传递五次
    output   reg    [WIDTH-1 : 0]       post2,
    output   reg    [WIDTH-1 : 0]       post3,
    output   reg    [WIDTH-1 : 0]       post4
);

// 段间寄存器模块，信号一经产生就传递到最后
always @(posedge clk) begin
    if (rst) begin
        post1 <= init;
        post2 <= init;
        post3 <= init;
        post4 <= init;
    end
    else if (en) begin
        if (flush1) begin
            post1 <= init;
        end
        else if (stall1) begin
            post1 <= post1;
        end
        else begin
            post1 <= pre;
        end

        if (flush2) begin
            post2 <= init;
        end
        else if (stall2) begin
            post2 <= post2;
        end
        else begin
            post2 <= post1;
        end

        if (flush3) begin
            post3 <= init;
        end
        else if (stall3) begin
            post3 <= post3;
        end
        else begin
            post3 <= post2;
        end

        if (flush4) begin
            post4 <= init;
        end
        else if (stall4) begin
            post4 <= post4;
        end
        else begin
            post4 <= post3;
        end
    end
    else begin
        post1 <= post1;
        post2 <= post2;
        post3 <= post3;
        post4 <= post4;
    end
end

endmodule