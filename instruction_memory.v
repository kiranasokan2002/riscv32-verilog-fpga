// ============================================================
// Instruction Memory — LOOPS FOREVER for continuous LED show
// Last instruction jumps back to start (not infinite freeze)
// ============================================================
module instruction_memory (
    input  [31:0] addr,
    output [31:0] instruction
);
    reg [31:0] mem [0:255];
    integer k;
    initial begin
        mem[0]  = 32'h00500093; // addi x1, x0, 5    -> 5
        mem[1]  = 32'h00A00113; // addi x2, x0, 10   -> 10
        mem[2]  = 32'h002081B3; // add  x3, x1, x2   -> 15
        mem[3]  = 32'h40110233; // sub  x4, x2, x1  = 5  (FIXED: was wrong rs1 encoding)
        mem[4]  = 32'h0020F2B3; // and  x5, x1, x2   -> 0
        mem[5]  = 32'h0020E333; // or   x6, x1, x2   -> 15
        mem[6]  = 32'h0020C3B3; // xor  x7, x1, x2   -> 15
        mem[7]  = 32'h00109413; // slli x8, x1, 1    -> 10
        mem[8]  = 32'h00115493; // srli x9, x2, 1    -> 5
        mem[9]  = 32'h0020A533; // slt  x10,x1, x2   -> 1
        mem[10] = 32'h0020B5B3; // sltu x11,x1, x2   -> 1
        mem[11] = 32'h00302023; // sw   x3, 0(x0)    mem[0]=15
        mem[12] = 32'h00002603; // lw   x12, 0(x0)   -> 15
        mem[13] = 32'h001606B3; // add  x13,x12,x1   -> 20
        // JAL back to start (instruction 0) — LOOP FOREVER
        // jal x0, -56  (jump back 56 bytes = 14 instructions)
        mem[14] = 32'hFC9FF06F; // jal  x0, -56  -> back to mem[0]

        for (k=15; k<256; k=k+1)
            mem[k] = 32'h00000013; // NOP
    end
    assign instruction = mem[addr[9:2]];
endmodule
