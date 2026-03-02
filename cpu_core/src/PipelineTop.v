module PipelineTop (
    input                              clk,
    input                              rst,
    input                              global_en,
    input                              stall_IF_ID, stall_ID_EX, stall_EX_MEM, stall_MEM_WB,
    input                              flush_IF_ID, flush_ID_EX, flush_EX_MEM, flush_MEM_WB,

    inout          [31 : 0]            pc_IF, pc_ID, pc_EX, pc_MEM, pc_WB,
    inout          [31 : 0]            pc_add4_IF, pc_add4_ID, pc_add4_EX, pc_add4_MEM, pc_add4_WB,
    inout          [31 : 0]            inst_IF, inst_ID, inst_EX, inst_MEM, inst_WB,
    inout          [ 4 : 0]            alu_op_IF, alu_op_ID, alu_op_EX, alu_op_MEM, alu_op_WB,
    inout          [ 3 : 0]            dmem_access_IF, dmem_access_ID, dmem_access_EX, dmem_access_MEM, dmem_access_WB,
    inout          [ 0 : 0]            dmem_wd_en_IF, dmem_wd_en_ID, dmem_wd_en_EX, dmem_wd_en_MEM, dmem_wd_en_WB,
    inout          [31 : 0]            imm_IF, imm_ID, imm_EX, imm_MEM, imm_WB,
    inout          [ 4 : 0]            rf_ra0_IF, rf_ra0_ID, rf_ra0_EX, rf_ra0_MEM, rf_ra0_WB,
    inout          [ 4 : 0]            rf_ra1_IF, rf_ra1_ID, rf_ra1_EX, rf_ra1_MEM, rf_ra1_WB,
    inout          [ 4 : 0]            rf_wa_IF, rf_wa_ID, rf_wa_EX, rf_wa_MEM, rf_wa_WB,
    inout          [ 0 : 0]            rf_we_IF, rf_we_ID, rf_we_EX, rf_we_MEM, rf_we_WB,
    inout          [ 1 : 0]            rf_wd_sel_IF, rf_wd_sel_ID, rf_wd_sel_EX, rf_wd_sel_MEM, rf_wd_sel_WB,
    inout          [ 0 : 0]            alu_src0_sel_IF, alu_src0_sel_ID, alu_src0_sel_EX, alu_src0_sel_MEM, alu_src0_sel_WB,
    inout          [ 0 : 0]            alu_src1_sel_IF, alu_src1_sel_ID, alu_src1_sel_EX, alu_src1_sel_MEM, alu_src1_sel_WB,
    inout          [ 3 : 0]            br_type_IF, br_type_ID, br_type_EX, br_type_MEM, br_type_WB,
    inout          [31 : 0]            rf_rd0_raw_IF, rf_rd0_raw_ID, rf_rd0_raw_EX, rf_rd0_raw_MEM, rf_rd0_raw_WB,
    inout          [31 : 0]            rf_rd1_raw_IF, rf_rd1_raw_ID, rf_rd1_raw_EX, rf_rd1_raw_MEM, rf_rd1_raw_WB,
    inout          [31 : 0]            alu_src0_IF, alu_src0_ID, alu_src0_EX, alu_src0_MEM, alu_src0_WB,
    inout          [31 : 0]            alu_src1_IF, alu_src1_ID, alu_src1_EX, alu_src1_MEM, alu_src1_WB,
    inout          [31 : 0]            alu_res_IF, alu_res_ID, alu_res_EX, alu_res_MEM, alu_res_WB,
    inout          [ 1 : 0]            npc_sel_IF, npc_sel_ID, npc_sel_EX, npc_sel_MEM, npc_sel_WB,
    inout          [31 : 0]            npc_IF, npc_ID, npc_EX, npc_MEM, npc_WB,
    inout          [31 : 0]            rf_rd0_IF, rf_rd0_ID, rf_rd0_EX, rf_rd0_MEM, rf_rd0_WB,
    inout          [31 : 0]            rf_rd1_IF, rf_rd1_ID, rf_rd1_EX, rf_rd1_MEM, rf_rd1_WB,
    inout          [31 : 0]            dmem_rd_out_IF, dmem_rd_out_ID, dmem_rd_out_EX, dmem_rd_out_MEM, dmem_rd_out_WB,
    inout          [31 : 0]            dmem_wd_out_IF, dmem_wd_out_ID, dmem_wd_out_EX, dmem_wd_out_MEM, dmem_wd_out_WB,
    inout          [31 : 0]            rf_wd_IF, rf_wd_ID, rf_wd_EX, rf_wd_MEM, rf_wd_WB
);
// 封装所有段间寄存器模块，避免 CPU.v 文件代码过于冗长
/* ------------------------------ IF stage ----------------------------- */
PipelineReg pipeline_pc(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_IF_ID),
    .stall2(stall_ID_EX),
    .stall3(stall_EX_MEM),
    .stall4(stall_MEM_WB),
    .flush1(flush_IF_ID),
    .flush2(flush_ID_EX),
    .flush3(flush_EX_MEM),
    .flush4(flush_MEM_WB),
    .init(32'h1C000000),
    .pre(pc_IF),
    .post1(pc_ID),
    .post2(pc_EX),
    .post3(pc_MEM),
    .post4(pc_WB)
);

PipelineReg pipeline_pc_add4(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_IF_ID),
    .stall2(stall_ID_EX),
    .stall3(stall_EX_MEM),
    .stall4(stall_MEM_WB),
    .flush1(flush_IF_ID),
    .flush2(flush_ID_EX),
    .flush3(flush_EX_MEM),
    .flush4(flush_MEM_WB),
    .init(32'h1C000004),
    .pre(pc_add4_IF),
    .post1(pc_add4_ID),
    .post2(pc_add4_EX),
    .post3(pc_add4_MEM),
    .post4(pc_add4_WB)
);

PipelineReg pipeline_inst(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_IF_ID),
    .stall2(stall_ID_EX),
    .stall3(stall_EX_MEM),
    .stall4(stall_MEM_WB),
    .flush1(flush_IF_ID),
    .flush2(flush_ID_EX),
    .flush3(flush_EX_MEM),
    .flush4(flush_MEM_WB),
    .init(0),
    .pre(inst_IF),
    .post1(inst_ID),
    .post2(inst_EX),
    .post3(inst_MEM),
    .post4(inst_WB)
);

/* ------------------------------ ID stage ----------------------------- */
PipelineReg #(5) pipeline_alu_op(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(alu_op_ID),
    .post1(alu_op_EX),
    .post2(alu_op_MEM),
    .post3(alu_op_WB),
    .post4()
);

PipelineReg #(4) pipeline_dmem_access(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(dmem_access_ID),
    .post1(dmem_access_EX),
    .post2(dmem_access_MEM),
    .post3(dmem_access_WB),
    .post4()
);

PipelineReg #(1) pipeline_dmem_wd_en(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(dmem_wd_en_ID),
    .post1(dmem_wd_en_EX),
    .post2(dmem_wd_en_MEM),
    .post3(dmem_wd_en_WB),
    .post4()
);

PipelineReg pipeline_imm(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(imm_ID),
    .post1(imm_EX),
    .post2(imm_MEM),
    .post3(imm_WB),
    .post4()
);

PipelineReg #(5) pipeline_rf_ra0(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(rf_ra0_ID),
    .post1(rf_ra0_EX),
    .post2(rf_ra0_MEM),
    .post3(rf_ra0_WB),
    .post4()
);

PipelineReg #(5) pipeline_rf_ra1(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(rf_ra1_ID),
    .post1(rf_ra1_EX),
    .post2(rf_ra1_MEM),
    .post3(rf_ra1_WB),
    .post4()
);

PipelineReg #(5) pipeline_rf_wa(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(rf_wa_ID),
    .post1(rf_wa_EX),
    .post2(rf_wa_MEM),
    .post3(rf_wa_WB),
    .post4()
);

PipelineReg #(1) pipeline_rf_we(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(rf_we_ID),
    .post1(rf_we_EX),
    .post2(rf_we_MEM),
    .post3(rf_we_WB),
    .post4()
);

PipelineReg #(2) pipeline_rf_wd_sel(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(rf_wd_sel_ID),
    .post1(rf_wd_sel_EX),
    .post2(rf_wd_sel_MEM),
    .post3(rf_wd_sel_WB),
    .post4()
);

PipelineReg #(1) pipeline_alu_src0_sel(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(alu_src0_sel_ID),
    .post1(alu_src0_sel_EX),
    .post2(alu_src0_sel_MEM),
    .post3(alu_src0_sel_WB),
    .post4()
);

PipelineReg #(1) pipeline_alu_src1_sel(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(alu_src1_sel_ID),
    .post1(alu_src1_sel_EX),
    .post2(alu_src1_sel_MEM),
    .post3(alu_src1_sel_WB),
    .post4()
);

PipelineReg #(4) pipeline_br_type(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(br_type_ID),
    .post1(br_type_EX),
    .post2(br_type_MEM),
    .post3(br_type_WB),
    .post4()
);

PipelineReg pipeline_rf_rd0_raw(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(rf_rd0_raw_ID),
    .post1(rf_rd0_raw_EX),
    .post2(rf_rd0_raw_MEM),
    .post3(rf_rd0_raw_WB),
    .post4()
);

PipelineReg pipeline_rf_rd1_raw(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_ID_EX),
    .stall2(stall_EX_MEM),
    .stall3(stall_MEM_WB),
    .stall4(0),
    .flush1(flush_ID_EX),
    .flush2(flush_EX_MEM),
    .flush3(flush_MEM_WB),
    .flush4(0),
    .init(0),
    .pre(rf_rd1_raw_ID),
    .post1(rf_rd1_raw_EX),
    .post2(rf_rd1_raw_MEM),
    .post3(rf_rd1_raw_WB),
    .post4()
);

/* ------------------------------ EX stage ----------------------------- */
PipelineReg pipeline_alu_src0(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_EX_MEM),
    .stall2(stall_MEM_WB),
    .stall3(0),
    .stall4(0),
    .flush1(flush_EX_MEM),
    .flush2(flush_MEM_WB),
    .flush3(0),
    .flush4(0),
    .init(0),
    .pre(alu_src0_EX),
    .post1(alu_src0_MEM),
    .post2(alu_src0_WB),
    .post3(),
    .post4()
);

PipelineReg pipeline_alu_src1(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_EX_MEM),
    .stall2(stall_MEM_WB),
    .stall3(0),
    .stall4(0),
    .flush1(flush_EX_MEM),
    .flush2(flush_MEM_WB),
    .flush3(0),
    .flush4(0),
    .init(0),
    .pre(alu_src1_EX),
    .post1(alu_src1_MEM),
    .post2(alu_src1_WB),
    .post3(),
    .post4()
);

PipelineReg pipeline_alu_res(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_EX_MEM),
    .stall2(stall_MEM_WB),
    .stall3(0),
    .stall4(0),
    .flush1(flush_EX_MEM),
    .flush2(flush_MEM_WB),
    .flush3(0),
    .flush4(0),
    .init(0),
    .pre(alu_res_EX),
    .post1(alu_res_MEM),
    .post2(alu_res_WB),
    .post3(),
    .post4()
);

PipelineReg #(2) pipeline_npc_sel(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_EX_MEM),
    .stall2(stall_MEM_WB),
    .stall3(0),
    .stall4(0),
    .flush1(flush_EX_MEM),
    .flush2(flush_MEM_WB),
    .flush3(0),
    .flush4(0),
    .init(0),
    .pre(npc_sel_EX),
    .post1(npc_sel_MEM),
    .post2(npc_sel_WB),
    .post3(),
    .post4()
);

PipelineReg pipeline_npc(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_EX_MEM),
    .stall2(stall_MEM_WB),
    .stall3(0),
    .stall4(0),
    .flush1(flush_EX_MEM),
    .flush2(flush_MEM_WB),
    .flush3(0),
    .flush4(0),
    .init(0),
    .pre(npc_EX),
    .post1(npc_MEM),
    .post2(npc_WB),
    .post3(),
    .post4()
);

PipelineReg pipeline_rf_rd0(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_EX_MEM),
    .stall2(stall_MEM_WB),
    .stall3(0),
    .stall4(0),
    .flush1(flush_EX_MEM),
    .flush2(flush_MEM_WB),
    .flush3(0),
    .flush4(0),
    .init(0),
    .pre(rf_rd0_EX),
    .post1(rf_rd0_MEM),
    .post2(rf_rd0_WB),
    .post3(),
    .post4()
);

PipelineReg pipeline_rf_rd1(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_EX_MEM),
    .stall2(stall_MEM_WB),
    .stall3(0),
    .stall4(0),
    .flush1(flush_EX_MEM),
    .flush2(flush_MEM_WB),
    .flush3(0),
    .flush4(0),
    .init(0),
    .pre(rf_rd1_EX),
    .post1(rf_rd1_MEM),
    .post2(rf_rd1_WB),
    .post3(),
    .post4()
);

/* ----------------------------- MEM stage ----------------------------- */
PipelineReg pipeline_dmem_rd_out(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_MEM_WB),
    .stall2(0),
    .stall3(0),
    .stall4(0),
    .flush1(flush_MEM_WB),
    .flush2(0),
    .flush3(0),
    .flush4(0),
    .init(0),
    .pre(dmem_rd_out_MEM),
    .post1(dmem_rd_out_WB),
    .post2(),
    .post3(),
    .post4()
);

PipelineReg pipeline_dmem_wd_out(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(stall_MEM_WB),
    .stall2(0),
    .stall3(0),
    .stall4(0),
    .flush1(flush_MEM_WB),
    .flush2(0),
    .flush3(0),
    .flush4(0),
    .init(0),
    .pre(dmem_wd_out_MEM),
    .post1(dmem_wd_out_WB),
    .post2(),
    .post3(),
    .post4()
);

/* ------------------------------ WB stage ----------------------------- */
PipelineReg pipeline_rf_wd(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall1(0),
    .stall2(0),
    .stall3(0),
    .stall4(0),
    .flush1(0),
    .flush2(0),
    .flush3(0),
    .flush4(0),
    .init(0),
    .pre(rf_wd_WB),
    .post1(),
    .post2(),
    .post3(),
    .post4()
);
endmodule