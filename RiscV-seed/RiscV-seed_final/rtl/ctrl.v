// +FHDR----------------------------------------------------------------------------
//                 Copyright (c) 2022 
//                       ALL RIGHTS RESERVED
// ---------------------------------------------------------------------------------
// Filename      : id.v
// Author        : Rongye
// Created On    : 2022-03-22 19:10
// Last Modified : 2022-04-13 04:05
// ---------------------------------------------------------------------------------
// Description   : The main control module decodes the read instructions 
//                 to obtain the control signals, corresponding addresses 
//                 and immediate data of multiple modules. 
//
//
// -FHDR----------------------------------------------------------------------------
`include "rvseed_defines.v"

module ctrl (
    input      [`CPU_WIDTH-1:0]        inst,       // instruction input

    output reg                         branch,     // branch flag
    output reg                         jump,       // jump flag

    output reg                         reg_wen,    // register write enable
    output reg [`REG_ADDR_WIDTH-1:0]   reg_waddr,  // register write address
    output reg [`REG_ADDR_WIDTH-1:0]   reg1_raddr, // register 1 read address
    output reg [`REG_ADDR_WIDTH-1:0]   reg2_raddr, // register 2 read address
    
    output reg [`IMM_GEN_OP_WIDTH-1:0] imm_gen_op, // immediate extend opcode

    output reg [`ALU_OP_WIDTH-1:0]     alu_op,     // alu opcode
    output reg [`ALU_SRC_WIDTH-1:0]    alu_src_sel // alu source select flag
);

wire [`OPCODE_WIDTH-1:0] opcode = inst[`OPCODE_WIDTH-1:0];            
wire [`FUNCT3_WIDTH-1:0] funct3 = inst[`FUNCT3_WIDTH+`FUNCT3_BASE-1:`FUNCT3_BASE];
wire [`FUNCT7_WIDTH-1:0] funct7 = inst[`FUNCT7_WIDTH+`FUNCT7_BASE-1:`FUNCT7_BASE]; 
wire [`REG_ADDR_WIDTH-1:0] rd   = inst[`REG_ADDR_WIDTH+`RD_BASE-1:`RD_BASE]; 
wire [`REG_ADDR_WIDTH-1:0] rs1  = inst[`REG_ADDR_WIDTH+`RS1_BASE-1:`RS1_BASE]; 
wire [`REG_ADDR_WIDTH-1:0] rs2  = inst[`REG_ADDR_WIDTH+`RS2_BASE-1:`RS2_BASE]; 


always @(*) begin
    branch      = 1'b0;
    jump        = 1'b0;
    reg_wen     = 1'b0;
    reg1_raddr  = `REG_ADDR_WIDTH'b0;//默认零地址
    reg2_raddr  = `REG_ADDR_WIDTH'b0;
    reg_waddr   = `REG_ADDR_WIDTH'b0;
    imm_gen_op  = `IMM_GEN_I;//默认I型，立即数型扩展
    alu_op      = `ALU_AND;//最初的and指令
    alu_src_sel = `ALU_SRC_REG;
    case (opcode)
        `INST_TYPE_R: begin
            reg_wen     = 1'b1;
            reg1_raddr  = rs1;
            reg2_raddr  = rs2;
            reg_waddr   = rd;
            alu_src_sel = `ALU_SRC_REG;//数据源选择，这里数据源为寄存器
            case (funct3)
                `INST_ADD_SUB: 
                    alu_op = (funct7 == `FUNCT7_INST_A) ? `ALU_ADD : `ALU_SUB; // A:add B:sub 
            endcase
        end
        `INST_TYPE_I: begin
            reg_wen     = 1'b1;
            reg1_raddr  = rs1;
            reg_waddr   = rd;
            //前面已经默认给了imm_gen_op  = `IMM_GEN_I;
            //所以不需要额外显式赋值
            alu_src_sel = `ALU_SRC_IMM;//寄存器和立即数，详见宏定义文件
            case (funct3)
                `INST_ADDI: 
                    alu_op = `ALU_ADD; 
            endcase
        end
        `INST_TYPE_B: begin
            reg1_raddr  = rs1;
            reg2_raddr  = rs2;
            //前面默认了为I型，所以这里需要做修改
            imm_gen_op  = `IMM_GEN_B;
            alu_src_sel = `ALU_SRC_REG;
            case (funct3)
                `INST_BNE: begin
                    branch     = 1'b1;
                    alu_op     = `ALU_SUB;//使用减法判断是否相等
                end
            endcase
        end
        `INST_JAL: begin // only jal
            jump        = 1'b1;
            reg_wen     = 1'b1;
            reg_waddr   = rd;
            imm_gen_op  = `IMM_GEN_J;
            alu_op      = `ALU_ADD;
            alu_src_sel = `ALU_SRC_FOUR_PC; //pc + 4
        end
        `INST_LUI: begin // only lui
                reg_wen     = 1'b1;
                reg1_raddr  = `REG_ADDR_WIDTH'b0; // x0 = 0
                reg_waddr   = rd;
                imm_gen_op  = `IMM_GEN_U;
                alu_op      = `ALU_ADD;
                alu_src_sel = `ALU_SRC_IMM; // x0 + imm
        end
    endcase 
end

endmodule
