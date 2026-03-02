module Decoder(
    input                   [31 : 0]            inst,

    output      reg         [ 4 : 0]            alu_op,
    output      reg         [ 3 : 0]            dmem_access,    //访存类型
    output      reg         [ 0 : 0]            dmem_we,
    output      reg         [31 : 0]            imm,

    output      reg         [ 4 : 0]            rf_ra0,
    output      reg         [ 4 : 0]            rf_ra1,
    output      reg         [ 4 : 0]            rf_wa,
    output      reg         [ 0 : 0]            rf_we,
    output      reg         [ 1 : 0]            rf_wd_sel,      //寄存器堆写回数据选择器的选择信号

    output      reg         [ 0 : 0]            alu_src0_sel,
    output      reg         [ 0 : 0]            alu_src1_sel,
    output      reg         [ 3 : 0]            br_type         //分支跳转的类型
);



always @(*) begin
    alu_op = 5'b11111;      //ALU中未定义的运算默认输出0
    dmem_access = 4'b0011;  //默认无需SLU修正
    dmem_we = 0;            //data_mem默认不写
    imm = 0;

    rf_ra0 = inst[9:5];     //此三指令在指令中位置固定，可直接截取
    rf_ra1 = inst[14:10];
    rf_wa = inst[4:0];
    rf_we = 0;              //非合法指令默认不写
    rf_wd_sel = 2'b01;      //默认寄存器堆将alu_res写回数据选择器

    alu_src0_sel = 0;       //默认src0,src1均来自寄存器堆
    alu_src1_sel = 0;
    br_type = 4'b0000;      //默认无需分支跳转

    if (inst[31:30] == 2'b01) begin  //指令码首个1出现在位30
        alu_op = 5'b00000;
        imm = (inst[28:27] == 2'b10) ? {{6{inst[9]}}, {inst[9:0]}, {inst[25:10]}} << 2 : {{16{inst[25]}}, {inst[25:10]}} << 2;    //inst[28:27]为10的二个指令拥有更长立即数，且注意立即数应左移2位
        rf_ra1 = rf_wa;                                                             //应当比较的是rj与rd，故作此修正
        if (inst[29:26] == 4'b0101) rf_wa = 5'b00001;                               //仅bl指令需要赋值指定1号寄存器
        if (inst[29:26] == 4'b0101 || inst[29:26] == 4'b0011)   rf_we = 1;          //仅bl,jirl指令需要进行链接
        rf_wd_sel = 2'b00; 
        if (inst[29:26] != 4'b0011) alu_src0_sel = 1;                               //仅jirl指令为间接跳转
        alu_src1_sel = 1;
        br_type = inst[29:26];
    end
    else if (inst[31:29] == 3'b001) begin       //指令码首个1出现在位29
        alu_op = 5'b00000;
        dmem_access = inst[25:22];
        if (inst[24] == 1)  dmem_we = 1;        //若为st指令则需要进行写入data_mem
        imm = {{20{inst[21]}}, {inst[21:10]}};
        rf_ra1 = rf_wa;                         //应当从寄存器堆读出的是rd，故作此修正
        if (inst[24] == 0)  rf_we = 1;          //若为ld指令则需要进行写入寄存器堆
        rf_wd_sel = 2'b10;
        alu_src1_sel = 1;
        dmem_access = inst[25:22];
    end
    else if (inst[31:28] == 4'b0001) begin      //指令码首个1出现在位28
        imm = inst[24:5] << 12;
        rf_we = 1;
        alu_src0_sel = 1;   //src0来自PC
        alu_src1_sel = 1;   //src1来自立即数
        case (inst[27:25])
            3'b010: alu_op = 5'b10010;  //LU12I.W
            3'b110: alu_op = 5'b00000;  //PCADDU12I
            default: alu_op = 5'b11111; 
        endcase
        
    end     
    else if (inst[31:25] == 7'b0000001) begin    //指令码首个1出现在位25
        imm = inst[24] ? {20'b0, inst[21:10]} : {{20{inst[21]}}, {inst[21:10]}};     //inst[24]为1的三个指令是无符号立即数，另三个指令为有符号立即数
        rf_we = 1;
        alu_src1_sel = 1;
        case (inst[24:22])
            3'b000: alu_op = 5'b00100;  //SLTI.W
            3'b001: alu_op = 5'b00101;  //SLTUI.W
            3'b010: alu_op = 5'b00000;  //ADDI.W
            3'b101: alu_op = 5'b01001;  //ANDI
            3'b110: alu_op = 5'b01010;  //ORI
            3'b111: alu_op = 5'b01011;  //XORI
            default: alu_op = 5'b11111;
        endcase
    end
    else if (inst[31:22] == 10'b0000000001) begin    //指令码首个1出现在位22
        imm = {27'b0, inst[14:10]};
        rf_we = 1;
        alu_src1_sel = 1;
        case (inst[21:15])
            7'b00000001:    alu_op = 5'b01110;  //SLLI.W
            7'b00001001:    alu_op = 5'b01111;  //SRLI.W
            7'b00010001:    alu_op = 5'b10000;  //SRAI.W
            default: alu_op = 5'b11111;
        endcase
    end
    else if (inst[31:20] == 12'b000000000001) begin  //指令码首个1出现在位20
        alu_op = inst[19:15];   //AND.W, SUB.W, SLT, SLTU, AND, OR, XOR, SLL.W, SRL.W, SRA.W
        rf_we = 1;
    end
end

endmodule
