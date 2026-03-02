module SLU (
    input                   [31 : 0]                addr,
    input                   [ 3 : 0]                dmem_access,

    input                   [31 : 0]                rd_in,  //从寄存器读到的原始数据
    input                   [31 : 0]                wd_in,  //要写入存储器的原始数据

    output      reg         [31 : 0]                rd_out, //根据 dmem_access 处理过的读到的数据
    output      reg         [31 : 0]                wd_out  //根据 dmem_access 处理过的要写入的数据
);

// 访存控制单元 SL Unit
always @(*) begin
    rd_out = rd_in;
    wd_out = wd_in;
    case (dmem_access)
        4'b0000:   //ld_b
            case(addr[1:0])
                2'b00:  rd_out = {{24{rd_in[ 7]}},rd_in[ 7: 0]};
                2'b01:  rd_out = {{24{rd_in[15]}},rd_in[15: 8]};
                2'b10:  rd_out = {{24{rd_in[23]}},rd_in[23:16]};
                2'b11:  rd_out = {{24{rd_in[31]}},rd_in[31:24]};
                default;
            endcase
        4'b0001:    //ld_h
            case(addr[1:0])
                2'b00:  rd_out = {{16{rd_in[15]}},rd_in[15: 0]};
                2'b01:  ;     //非正常半字访问，不做处理
                2'b10:  rd_out = {{16{rd_in[31]}},rd_in[31:16]};
                2'b11:  ;     //非正常半字访问，不做处理
                default;
            endcase
        4'b0010:    rd_out = rd_in;     //ld_w
        4'b0100:   //st_b
            case(addr[1:0])
                2'b00:  wd_out = {rd_in[31: 8],wd_in[ 7:0]};
                2'b01:  wd_out = {rd_in[31:16],wd_in[ 7:0],rd_in[ 7:0]};
                2'b10:  wd_out = {rd_in[31:24],wd_in[ 7:0],rd_in[15:0]};
                2'b11:  wd_out = {wd_in[ 7: 0],rd_in[23:0]};
                default;
            endcase
        4'b0101:    //st_h
            case(addr[1:0])
                2'b00:  wd_out = {rd_in[31:16],wd_in[15:0]};
                2'b01:  ;     //非正常半字访问，不做处理
                2'b10:  wd_out = {wd_in[15: 0],rd_in[15:0]};
                2'b11:  ;     //非正常半字访问，不做处理
                default;
            endcase
        4'b0110:    wd_out = wd_in;     //st_w
        4'b1000:   //ld_bu
            case(addr[1:0])
                2'b00:  rd_out = {24'b0, rd_in[ 7: 0]};
                2'b01:  rd_out = {24'b0, rd_in[15: 8]};
                2'b10:  rd_out = {24'b0, rd_in[23:16]};
                2'b11:  rd_out = {24'b0, rd_in[31:24]};
                default;
            endcase
        4'b1001:    //ld_hu
            case(addr[1:0])
                2'b00:  rd_out = {16'b0, rd_in[15: 0]};
                2'b01:  ;     //非正常半字访问，不做处理
                2'b10:  rd_out = {16'b0, rd_in[31:16]};
                2'b11:  ;     //非正常半字访问，不做处理
                default;
            endcase
        default:    ;
    endcase
end
endmodule