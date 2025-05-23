// +FHDR----------------------------------------------------------------------------
//                 Copyright (c) 2022 
//                       ALL RIGHTS RESERVED
// ---------------------------------------------------------------------------------
// Filename      : imm_gen.v
// Author        : Rongye
// Created On    : 2022-03-23 22:23
// Last Modified : 2022-04-11 20:20
// ---------------------------------------------------------------------------------
// Description   : There are five cases of immediate expansion. 
//
//
// -FHDR----------------------------------------------------------------------------
`include "rvseed_defines.v"

module imm_gen (
    input      [`CPU_WIDTH-1:0]        inst,       // instruction input
    input      [`IMM_GEN_OP_WIDTH-1:0] imm_gen_op, // immediate extend opcode

    output reg [`CPU_WIDTH-1:0]        imm         // immediate  
);

//高位符号位拓展，低位零拓展
always @(*) begin
    imm = `CPU_WIDTH'b0;
    case (imm_gen_op)
        `IMM_GEN_I: 
             imm = {{20{inst[31]}},inst[31:20]};//将立即数符号位重复20次放前边
        `IMM_GEN_S: 
             imm = {{20{inst[31]}},inst[31:25],inst[11:7]};
        `IMM_GEN_B: 
             imm = {{20{inst[31]}},inst[7],inst[30:25],inst[11:8], 1'b0};
        `IMM_GEN_J: 
             imm = {{12{inst[31]}},inst[19:12],inst[20],inst[30:21], 1'b0};
        `IMM_GEN_U: 
             imm = {inst[31:12],12'b0};
    endcase
end

endmodule
