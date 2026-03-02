`timescale 1ns / 1ps
module CPU (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [ 0 : 0]            global_en,

/* ------------------------------ Memory (inst) ----------------------------- */
    output                  [31 : 0]            imem_raddr,
    input                   [31 : 0]            imem_rdata,

/* ------------------------------ Memory (data) ----------------------------- */
    input                   [31 : 0]            dmem_rdata,
    output                  [ 0 : 0]            dmem_we,
    output                  [31 : 0]            dmem_addr,
    output                  [31 : 0]            dmem_wdata,

/* ---------------------------------- Debug --------------------------------- */
    output                  [ 0 : 0]            commit,
    output                  [31 : 0]            commit_pc,
    output                  [31 : 0]            commit_inst,
    output                  [ 0 : 0]            commit_halt,
    output                  [ 0 : 0]            commit_reg_we,
    output                  [ 4 : 0]            commit_reg_wa,
    output                  [31 : 0]            commit_reg_wd,
    output                  [ 0 : 0]            commit_dmem_we,
    output                  [31 : 0]            commit_dmem_wa,
    output                  [31 : 0]            commit_dmem_wd,

    input                   [ 4 : 0]            debug_reg_ra,
    output                  [31 : 0]            debug_reg_rd
);

wire    [ 0:0]      stall_pc, stall_IF_ID, stall_ID_EX, stall_EX_MEM, stall_MEM_WB;
wire    [ 0:0]      flush_pc, flush_IF_ID, flush_ID_EX, flush_EX_MEM, flush_MEM_WB;
wire    [ 0:0]      commit_IF, commit_ID, commit_EX, commit_MEM, commit_WB;

wire    [31:0]      pc_IF, pc_ID, pc_EX, pc_MEM, pc_WB;
wire    [31:0]      pc_add4_IF, pc_add4_ID, pc_add4_EX, pc_add4_MEM, pc_add4_WB;
wire    [31:0]      npc_IF, npc_ID, npc_EX, npc_MEM, npc_WB;
wire    [ 1:0]      npc_sel_IF, npc_sel_ID, npc_sel_EX, npc_sel_MEM, npc_sel_WB;
wire    [31:0]      inst_IF, inst_ID, inst_EX, inst_MEM, inst_WB;
wire    [31:0]      imm_IF, imm_ID, imm_EX, imm_MEM, imm_WB;
wire    [ 3:0]      br_type_IF, br_type_ID, br_type_EX, br_type_MEM, br_type_WB;

wire    [ 4:0]      rf_ra0_IF, rf_ra0_ID, rf_ra0_EX, rf_ra0_MEM, rf_ra0_WB;
wire    [ 4:0]      rf_ra1_IF, rf_ra1_ID, rf_ra1_EX, rf_ra1_MEM, rf_ra1_WB;
wire    [ 4:0]      rf_wa_IF, rf_wa_ID, rf_wa_EX, rf_wa_MEM, rf_wa_WB;
wire    [ 0:0]      rf_we_IF, rf_we_ID, rf_we_EX, rf_we_MEM, rf_we_WB;
wire    [31:0]      rf_wd_IF, rf_wd_ID, rf_wd_EX, rf_wd_MEM, rf_wd_WB;
wire    [31:0]      rf_rd0_raw_IF, rf_rd0_raw_ID, rf_rd0_raw_EX, rf_rd0_raw_MEM, rf_rd0_raw_WB;
wire    [31:0]      rf_rd1_raw_IF, rf_rd1_raw_ID, rf_rd1_raw_EX, rf_rd1_raw_MEM, rf_rd1_raw_WB;
wire    [31:0]      rf_rd0_IF, rf_rd0_ID, rf_rd0_EX, rf_rd0_MEM, rf_rd0_WB;
wire    [31:0]      rf_rd1_IF, rf_rd1_ID, rf_rd1_EX, rf_rd1_MEM, rf_rd1_WB;
wire    [ 1:0]      rf_wd_sel_IF, rf_wd_sel_ID, rf_wd_sel_EX, rf_wd_sel_MEM, rf_wd_sel_WB;

wire    [ 0:0]      alu_src0_sel_IF, alu_src0_sel_ID, alu_src0_sel_EX, alu_src0_sel_MEM, alu_src0_sel_WB;
wire    [ 0:0]      alu_src1_sel_IF, alu_src1_sel_ID, alu_src1_sel_EX, alu_src1_sel_MEM, alu_src1_sel_WB;
wire    [31:0]      alu_src0_IF, alu_src0_ID, alu_src0_EX, alu_src0_MEM, alu_src0_WB;
wire    [31:0]      alu_src1_IF, alu_src1_ID, alu_src1_EX, alu_src1_MEM, alu_src1_WB;
wire    [ 4:0]      alu_op_IF, alu_op_ID, alu_op_EX, alu_op_MEM, alu_op_WB;
wire    [31:0]      alu_res_IF, alu_res_ID, alu_res_EX, alu_res_MEM, alu_res_WB;

wire    [31:0]      dmem_rd_out_IF, dmem_rd_out_ID, dmem_rd_out_EX, dmem_rd_out_MEM, dmem_rd_out_WB;
wire    [31:0]      dmem_wd_out_IF, dmem_wd_out_ID, dmem_wd_out_EX, dmem_wd_out_MEM, dmem_wd_out_WB;
wire    [ 0:0]      dmem_wd_en_IF, dmem_wd_en_ID, dmem_wd_en_EX, dmem_wd_en_MEM, dmem_wd_en_WB;
wire    [ 3:0]      dmem_access_IF, dmem_access_ID, dmem_access_EX, dmem_access_MEM, dmem_access_WB;

wire    [ 0:0]      rf_rd0_fe;
wire    [ 0:0]      rf_rd1_fe;
wire    [31:0]      rf_rd0_fd;
wire    [31:0]      rf_rd1_fd;

/* ------------------------------ IF stage ----------------------------- */
PC pc(
    .clk            (clk),
    .rst            (rst),
    .en             (global_en),
    .stall          (stall_pc),
    .flush          (flush_pc),
    .npc            (npc_EX),

    .pc             (pc_IF)
);

assign pc_add4_IF = pc_IF + 4;
assign imem_raddr = pc_IF;
assign inst_IF = imem_rdata;

/* ------------------------------ ID stage ----------------------------- */
Decoder decoder(
    .inst           (inst_ID),

    .alu_op         (alu_op_ID),
    .dmem_access    (dmem_access_ID),
    .dmem_we        (dmem_wd_en_ID),
    .imm            (imm_ID),
    .rf_ra0         (rf_ra0_ID),
    .rf_ra1         (rf_ra1_ID),
    .rf_wa          (rf_wa_ID),
    .rf_we          (rf_we_ID),
    .rf_wd_sel      (rf_wd_sel_ID),
    .alu_src0_sel   (alu_src0_sel_ID),
    .alu_src1_sel   (alu_src1_sel_ID),
    .br_type        (br_type_ID)
);

RegFile regfile(
    .clk            (clk),
    .rf_ra0         (rf_ra0_ID),
    .rf_ra1         (rf_ra1_ID), 
    .rf_ra2         (debug_reg_ra), 
    .rf_wa          (rf_wa_WB),
    .rf_we          (rf_we_WB),
    .rf_wd          (rf_wd_WB),

    .rf_rd0         (rf_rd0_raw_ID),
    .rf_rd1         (rf_rd1_raw_ID),
    .rf_rd2         (debug_reg_rd)
);

/* ------------------------------ EX stage ----------------------------- */
assign alu_src0_EX = alu_src0_sel_EX ?  pc_EX : rf_rd0_EX;
assign alu_src1_EX = alu_src1_sel_EX ? imm_EX : rf_rd1_EX;

ALU alu(
    .alu_src0       (alu_src0_EX),
    .alu_src1       (alu_src1_EX),
    .alu_op         (alu_op_EX),

    .alu_res        (alu_res_EX)
);

Branch branch(
    .br_type        (br_type_EX),
    .br_src0        (rf_rd0_EX),
    .br_src1        (rf_rd1_EX),

    .npc_sel        (npc_sel_EX)
);

assign npc_EX = npc_sel_EX[0] ? alu_res_EX : pc_add4_IF;
assign rf_rd0_EX = rf_rd0_fe ? rf_rd0_fd : rf_rd0_raw_EX;
assign rf_rd1_EX = rf_rd1_fe ? rf_rd1_fd : rf_rd1_raw_EX;

/* ----------------------------- MEM stage ----------------------------- */
SLU slu(
    .addr           (dmem_addr),
    .dmem_access    (dmem_access_MEM),
    .rd_in          (dmem_rdata),
    .wd_in          (rf_rd1_MEM),
    
    .rd_out         (dmem_rd_out_MEM),
    .wd_out         (dmem_wd_out_MEM)
);

assign dmem_we = dmem_wd_en_MEM;
assign dmem_addr = alu_res_MEM;
assign dmem_wdata = dmem_wd_out_MEM;

/* ------------------------------ WB stage ----------------------------- */
MUX2 rf_wd_mux(
    .src0           (pc_add4_WB),
    .src1           (alu_res_WB),
    .src2           (dmem_rd_out_WB),
    .src3           (0),
    .sel            (rf_wd_sel_WB),

    .res            (rf_wd_WB)
);

/* --------------------------------------------------------------------- */
PipelineTop pipelinetop (
    .clk            (clk),
    .rst            (rst),
    .global_en      (global_en),
    .stall_IF_ID    (stall_IF_ID),
    .stall_ID_EX    (stall_ID_EX),
    .stall_EX_MEM   (stall_EX_MEM),
    .stall_MEM_WB   (stall_MEM_WB),
    .flush_IF_ID    (flush_IF_ID),
    .flush_ID_EX    (flush_ID_EX),
    .flush_EX_MEM   (flush_EX_MEM),
    .flush_MEM_WB   (flush_MEM_WB),

    .pc_IF           (pc_IF),
    .pc_ID           (pc_ID),
    .pc_EX           (pc_EX),
    .pc_MEM          (pc_MEM),
    .pc_WB           (pc_WB),
    .pc_add4_IF      (pc_add4_IF),
    .pc_add4_ID      (pc_add4_ID),
    .pc_add4_EX      (pc_add4_EX),
    .pc_add4_MEM     (pc_add4_MEM),
    .pc_add4_WB      (pc_add4_WB),
    .inst_IF         (inst_IF),
    .inst_ID         (inst_ID),
    .inst_EX         (inst_EX),
    .inst_MEM        (inst_MEM),
    .inst_WB         (inst_WB),
    .alu_op_IF       (alu_op_IF),
    .alu_op_ID       (alu_op_ID),
    .alu_op_EX       (alu_op_EX),
    .alu_op_MEM      (alu_op_MEM),
    .alu_op_WB       (alu_op_WB),
    .dmem_access_IF  (dmem_access_IF),
    .dmem_access_ID  (dmem_access_ID),
    .dmem_access_EX  (dmem_access_EX),
    .dmem_access_MEM (dmem_access_MEM),
    .dmem_access_WB  (dmem_access_WB),
    .dmem_wd_en_IF   (dmem_wd_en_IF),
    .dmem_wd_en_ID   (dmem_wd_en_ID),
    .dmem_wd_en_EX   (dmem_wd_en_EX),
    .dmem_wd_en_MEM  (dmem_wd_en_MEM),
    .dmem_wd_en_WB   (dmem_wd_en_WB),
    .imm_IF          (imm_IF),
    .imm_ID          (imm_ID),
    .imm_EX          (imm_EX),
    .imm_MEM         (imm_MEM),
    .imm_WB          (imm_WB),
    .rf_ra0_IF       (rf_ra0_IF),
    .rf_ra0_ID       (rf_ra0_ID),
    .rf_ra0_EX       (rf_ra0_EX),
    .rf_ra0_MEM      (rf_ra0_MEM),
    .rf_ra0_WB       (rf_ra0_WB),
    .rf_ra1_IF       (rf_ra1_IF),
    .rf_ra1_ID       (rf_ra1_ID),
    .rf_ra1_EX       (rf_ra1_EX),
    .rf_ra1_MEM      (rf_ra1_MEM),
    .rf_ra1_WB       (rf_ra1_WB),
    .rf_wa_IF        (rf_wa_IF),
    .rf_wa_ID        (rf_wa_ID),
    .rf_wa_EX        (rf_wa_EX),
    .rf_wa_MEM       (rf_wa_MEM),
    .rf_wa_WB        (rf_wa_WB),
    .rf_we_IF        (rf_we_IF),
    .rf_we_ID        (rf_we_ID),
    .rf_we_EX        (rf_we_EX),
    .rf_we_MEM       (rf_we_MEM),
    .rf_we_WB        (rf_we_WB),
    .rf_wd_sel_IF    (rf_wd_sel_IF),
    .rf_wd_sel_ID    (rf_wd_sel_ID),
    .rf_wd_sel_EX    (rf_wd_sel_EX),
    .rf_wd_sel_MEM   (rf_wd_sel_MEM),
    .rf_wd_sel_WB    (rf_wd_sel_WB),
    .alu_src0_sel_IF     (alu_src0_sel_IF),
    .alu_src0_sel_ID     (alu_src0_sel_ID),
    .alu_src0_sel_EX     (alu_src0_sel_EX),
    .alu_src0_sel_MEM    (alu_src0_sel_MEM),
    .alu_src0_sel_WB     (alu_src0_sel_WB),
    .alu_src1_sel_IF     (alu_src1_sel_IF),
    .alu_src1_sel_ID     (alu_src1_sel_ID),
    .alu_src1_sel_EX     (alu_src1_sel_EX),
    .alu_src1_sel_MEM    (alu_src1_sel_MEM),
    .alu_src1_sel_WB     (alu_src1_sel_WB),
    .br_type_IF          (br_type_IF),
    .br_type_ID          (br_type_ID),
    .br_type_EX          (br_type_EX),
    .br_type_MEM         (br_type_MEM),
    .br_type_WB          (br_type_WB),
    .rf_rd0_raw_IF       (rf_rd0_raw_IF),
    .rf_rd0_raw_ID       (rf_rd0_raw_ID),
    .rf_rd0_raw_EX       (rf_rd0_raw_EX),
    .rf_rd0_raw_MEM      (rf_rd0_raw_MEM),
    .rf_rd0_raw_WB       (rf_rd0_raw_WB),
    .rf_rd1_raw_IF       (rf_rd1_raw_IF),
    .rf_rd1_raw_ID       (rf_rd1_raw_ID),
    .rf_rd1_raw_EX       (rf_rd1_raw_EX),
    .rf_rd1_raw_MEM      (rf_rd1_raw_MEM),
    .rf_rd1_raw_WB       (rf_rd1_raw_WB),
    .alu_src0_IF     (alu_src0_IF),
    .alu_src0_ID     (alu_src0_ID),
    .alu_src0_EX     (alu_src0_EX),
    .alu_src0_MEM    (alu_src0_MEM),
    .alu_src0_WB     (alu_src0_WB),
    .alu_src1_IF     (alu_src1_IF),
    .alu_src1_ID     (alu_src1_ID),
    .alu_src1_EX     (alu_src1_EX),
    .alu_src1_MEM    (alu_src1_MEM),
    .alu_src1_WB     (alu_src1_WB),
    .alu_res_IF      (alu_res_IF),
    .alu_res_ID      (alu_res_ID),
    .alu_res_EX      (alu_res_EX),
    .alu_res_MEM     (alu_res_MEM),
    .alu_res_WB      (alu_res_WB),
    .npc_sel_IF      (npc_sel_IF),
    .npc_sel_ID      (npc_sel_ID),
    .npc_sel_EX      (npc_sel_EX),
    .npc_sel_MEM     (npc_sel_MEM),
    .npc_sel_WB      (npc_sel_WB),
    .npc_IF          (npc_IF),
    .npc_ID          (npc_ID),
    .npc_EX          (npc_EX),
    .npc_MEM         (npc_MEM),
    .npc_WB          (npc_WB),
    .rf_rd0_IF       (rf_rd0_IF),
    .rf_rd0_ID       (rf_rd0_ID),
    .rf_rd0_EX       (rf_rd0_EX),
    .rf_rd0_MEM      (rf_rd0_MEM),
    .rf_rd0_WB       (rf_rd0_WB),
    .rf_rd1_IF       (rf_rd1_IF),
    .rf_rd1_ID       (rf_rd1_ID),
    .rf_rd1_EX       (rf_rd1_EX),
    .rf_rd1_MEM      (rf_rd1_MEM),
    .rf_rd1_WB       (rf_rd1_WB),
    .dmem_rd_out_IF  (dmem_rd_out_IF),
    .dmem_rd_out_ID  (dmem_rd_out_ID),
    .dmem_rd_out_EX  (dmem_rd_out_EX),
    .dmem_rd_out_MEM (dmem_rd_out_MEM),
    .dmem_rd_out_WB  (dmem_rd_out_WB),
    .dmem_wd_out_IF  (dmem_wd_out_IF),
    .dmem_wd_out_ID  (dmem_wd_out_ID),
    .dmem_wd_out_EX  (dmem_wd_out_EX),
    .dmem_wd_out_MEM (dmem_wd_out_MEM),
    .dmem_wd_out_WB  (dmem_wd_out_WB),
    .rf_wd_IF        (rf_wd_IF),
    .rf_wd_ID        (rf_wd_ID),
    .rf_wd_EX        (rf_wd_EX),
    .rf_wd_MEM       (rf_wd_MEM),
    .rf_wd_WB        (rf_wd_WB)
);

Forwarding forwarding(
    .rf_we_MEM(rf_we_MEM),
    .rf_we_WB(rf_we_WB),
    .rf_wa_MEM(rf_wa_MEM),   
    .rf_wa_WB(rf_wa_WB),
    .rf_wd_MEM(alu_res_MEM),
    .rf_wd_WB(rf_wd_WB),
    .rf_ra0_EX(rf_ra0_EX),   
    .rf_ra1_EX(rf_ra1_EX),

    .rf_rd0_fe(rf_rd0_fe),
    .rf_rd1_fe(rf_rd1_fe),
    .rf_rd0_fd(rf_rd0_fd),
    .rf_rd1_fd(rf_rd1_fd)
);

SegCtrl segctrl(
    .rf_we_EX(rf_we_EX),
    .rf_wd_sel_EX(rf_wd_sel_EX),
    .rf_wa_EX(rf_wa_EX),   
    .rf_ra0_ID(rf_ra0_ID),
    .rf_ra1_ID(rf_ra1_ID),
    .npc_sel_EX(npc_sel_EX),

    .stall_pc       (stall_pc),
    .stall_IF_ID    (stall_IF_ID),
    .stall_ID_EX    (stall_ID_EX),
    .stall_EX_MEM   (stall_EX_MEM),
    .stall_MEM_WB   (stall_MEM_WB),
    .flush_pc       (flush_pc),
    .flush_IF_ID    (flush_IF_ID),
    .flush_ID_EX    (flush_ID_EX),
    .flush_EX_MEM   (flush_EX_MEM),
    .flush_MEM_WB   (flush_MEM_WB)
);

reg  [ 0 : 0]   commit_reg          ;
reg  [31 : 0]   commit_pc_reg       ;
reg  [31 : 0]   commit_inst_reg     ;
reg  [ 0 : 0]   commit_halt_reg     ;
reg  [ 0 : 0]   commit_reg_we_reg   ;
reg  [ 4 : 0]   commit_reg_wa_reg   ;
reg  [31 : 0]   commit_reg_wd_reg   ;
reg  [ 0 : 0]   commit_dmem_we_reg  ;
reg  [31 : 0]   commit_dmem_wa_reg  ;
reg  [31 : 0]   commit_dmem_wd_reg  ;

PipelineReg #(1) pipeline_commit(
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
    .pre(1'h1),
    .post1(commit_ID),
    .post2(commit_EX),
    .post3(commit_MEM),
    .post4(commit_WB)
);

always @(posedge clk) begin
    if (rst) begin
        commit_reg          <= 1'H0;
        commit_pc_reg       <= 32'H0;
        commit_inst_reg     <= 32'H0;
        commit_halt_reg     <= 1'H0;
        commit_reg_we_reg   <= 1'H0;
        commit_reg_wa_reg   <= 5'H0;
        commit_reg_wd_reg   <= 32'H0;
        commit_dmem_we_reg  <= 1'H0;
        commit_dmem_wa_reg  <= 32'H0;
        commit_dmem_wd_reg  <= 32'H0;
    end
    else if (global_en) begin
        commit_reg          <= commit_WB;
        commit_pc_reg       <= pc_WB; 
        commit_inst_reg     <= inst_WB;
        commit_halt_reg     <= inst_WB == 32'h80000000;
        commit_reg_we_reg   <= rf_we_WB;  
        commit_reg_wa_reg   <= rf_wa_WB;
        commit_reg_wd_reg   <= rf_wd_WB;
        commit_dmem_we_reg  <= dmem_wd_en_WB;                         
        commit_dmem_wa_reg  <= alu_res_WB;                         
        commit_dmem_wd_reg  <= dmem_wd_out_WB;
    end
end

assign commit               = commit_reg;
assign commit_pc            = commit_pc_reg;
assign commit_inst          = commit_inst_reg;
assign commit_halt          = commit_halt_reg;
assign commit_reg_we        = commit_reg_we_reg;
assign commit_reg_wa        = commit_reg_wa_reg;
assign commit_reg_wd        = commit_reg_wd_reg;
assign commit_dmem_we       = commit_dmem_we_reg;
assign commit_dmem_wa       = commit_dmem_wa_reg;
assign commit_dmem_wd       = commit_dmem_wd_reg;

endmodule