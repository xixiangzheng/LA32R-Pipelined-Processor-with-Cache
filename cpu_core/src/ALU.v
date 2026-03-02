module ALU (
    input                   [31 : 0]            alu_src0,
    input                   [31 : 0]            alu_src1,
    input                   [ 4 : 0]            alu_op,

    output      reg         [31 : 0]            alu_res
);

//相应的运算操作码
`define ADD                 5'B00000    
`define SUB                 5'B00010   
`define SLT                 5'B00100
`define SLTU                5'B00101
`define AND                 5'B01001
`define OR                  5'B01010
`define XOR                 5'B01011
`define SLL                 5'B01110   
`define SRL                 5'B01111    
`define SRA                 5'B10000  
`define SRC0                5'B10001
`define SRC1                5'B10010

always @(*) begin
    case(alu_op)
        `ADD:
            alu_res = alu_src0 + alu_src1;
        `SUB:
            alu_res = alu_src0 - alu_src1;
        `SLT:   begin   //有符号比较
            if(alu_src0[31] == alu_src1[31])    //同号时，作差比大小即可
                alu_res = ($signed(alu_src1 - alu_src0) > 0) ? 1 : 0;
            else if (alu_src0[31] == 1 & alu_src1[31] == 0)
                alu_res = 1;
            else alu_res = 0;
        end
        `SLTU:  begin   //无符号比较
            if(alu_src0[31] == alu_src1[31]) begin  //最高位相同时，作差比大小即可
                alu_res = ($signed(alu_src1 - alu_src0) > 0) ? 1 : 0;
            end else if (alu_src0[31] == 1 & alu_src1[31] == 0) begin
                alu_res = 0;
            end else alu_res = 1;            
        end
        `AND:
            alu_res = alu_src0 & alu_src1;
        `OR:
            alu_res = alu_src0 | alu_src1;
        `XOR:
            alu_res = alu_src0 ^ alu_src1;
        `SLL:
            alu_res = alu_src0 << alu_src1[4:0]; 
        `SRL:
            alu_res = alu_src0 >> alu_src1[4:0];
        `SRA:   begin   //算术右移
            if(alu_src0[31] == 1)
                alu_res = (alu_src0 >> alu_src1[4:0]) + (32'hffff_ffff << (32-alu_src1[4:0]));    //符号位为1时算术右移需额外在前面补1
            else
                alu_res = alu_src0 >> alu_src1[4:0];
        end
        `SRC0:
            alu_res = alu_src0;
        `SRC1:
            alu_res = alu_src1;   
        default:
            alu_res = 32'H0;
    endcase
end
endmodule
