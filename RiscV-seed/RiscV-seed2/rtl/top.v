`include "rvseed_defines.v"
module  top(
    input   clk,
    input   rst_n,
    input   branch,
    input   zero,
    input   jump,
    input   imm,

    output  inst
);
mux_pc mux_pc (
    .ena                    (ena),
    .branch                 (branch),
    .zero                   (zero),
    .jump                   (jump),
    .imm                    (imm),
    .curr_pc                (curr_pc),

    .next_pc                (next_pc)
    );

pc_reg pc_reg (
    .clk                    (clk),
    .rst_n                  (rst_n),
    .next_pc                (next_pc),

    .ena                    (ena),
    .curr_pc                (curr_pc) 
);

inst_mem inst_mem (
    .curr_pc                (curr_pc),

    .inst                   (inst)
);
endmodule