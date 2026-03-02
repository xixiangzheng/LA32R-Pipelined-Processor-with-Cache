module Branch(
    input                   [ 3 : 0]            br_type,    // 与各跳转指令一一对应

    input                   [31 : 0]            br_src0,    // 用于判断跳转与否的两个源数据
    input                   [31 : 0]            br_src1,

    output      reg         [ 1 : 0]            npc_sel     // 取2'b00时为pc_add4，取2'b01时为pc_offset
);

always @(*) begin
    case (br_type)
        4'b0011:    npc_sel = 2'b01;
        4'b0100:    npc_sel = 2'b01;
        4'b0101:    npc_sel = 2'b01;
        4'b0110:    npc_sel = (br_src0 == br_src1) ? 2'b01 : 2'b00;
        4'b0111:    npc_sel = (br_src0 != br_src1) ? 2'b01 : 2'b00;
        4'b1000:    npc_sel = ($signed(br_src0) <  $signed(br_src1)) ? 2'b01 : 2'b00;
        4'b1001:    npc_sel = ($signed(br_src0) >= $signed(br_src1)) ? 2'b01 : 2'b00;
        4'b1010:    npc_sel = (br_src0 <  br_src1) ? 2'b01 : 2'b00;
        4'b1011:    npc_sel = (br_src0 >= br_src1) ? 2'b01 : 2'b00;
        default:    npc_sel = 2'b00;
    endcase
end

endmodule