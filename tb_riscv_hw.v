`timescale 1ns / 1ps
// ============================================================
// Testbench — simulation only
// Uses riscv_top_sim (no VIO)
// ============================================================
module tb_riscv_hw;
    reg  clk, rst;
    wire [7:0] led_result;
    wire [3:0] led_opcode, led_pc, led_regval;
    wire [31:0] dbg_pc, dbg_instr, dbg_alu_result, dbg_rd_data;

    riscv_top_sim uut (
        .clk(clk), .rst(rst),
        .led_result(led_result),
        .led_opcode(led_opcode),
        .led_pc(led_pc),
        .led_regval(led_regval),
        .dbg_pc(dbg_pc),
        .dbg_instr(dbg_instr),
        .dbg_alu_result(dbg_alu_result),
        .dbg_rd_data(dbg_rd_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk=0; rst=1;
        repeat(3) @(posedge clk);
        rst=0;
        $display("===== RISC-V Hardware Simulation =====");
        repeat(25) @(posedge clk); #1;

        $display("\n--- Verifying Opcodes ---");
        if(uut.u_regfile.regs[1]==32'd5)   $display("PASS | ADDI x1=5");
        else $display("FAIL | x1=%0d", uut.u_regfile.regs[1]);
        if(uut.u_regfile.regs[2]==32'd10)  $display("PASS | ADDI x2=10");
        else $display("FAIL | x2=%0d", uut.u_regfile.regs[2]);
        if(uut.u_regfile.regs[3]==32'd15)  $display("PASS | ADD  x3=15");
        else $display("FAIL | x3=%0d", uut.u_regfile.regs[3]);
        if(uut.u_regfile.regs[4]==32'd5)   $display("PASS | SUB  x4=5");
        else $display("FAIL | x4=%0d", uut.u_regfile.regs[4]);
        if(uut.u_regfile.regs[5]==32'd0)   $display("PASS | AND  x5=0");
        else $display("FAIL | x5=%0d", uut.u_regfile.regs[5]);
        if(uut.u_regfile.regs[6]==32'd15)  $display("PASS | OR   x6=15");
        else $display("FAIL | x6=%0d", uut.u_regfile.regs[6]);
        if(uut.u_regfile.regs[7]==32'd15)  $display("PASS | XOR  x7=15");
        else $display("FAIL | x7=%0d", uut.u_regfile.regs[7]);
        if(uut.u_regfile.regs[8]==32'd10)  $display("PASS | SLLI x8=10");
        else $display("FAIL | x8=%0d", uut.u_regfile.regs[8]);
        if(uut.u_regfile.regs[9]==32'd5)   $display("PASS | SRLI x9=5");
        else $display("FAIL | x9=%0d", uut.u_regfile.regs[9]);
        if(uut.u_regfile.regs[10]==32'd1)  $display("PASS | SLT  x10=1");
        else $display("FAIL | x10=%0d", uut.u_regfile.regs[10]);
        if(uut.u_regfile.regs[11]==32'd1)  $display("PASS | SLTU x11=1");
        else $display("FAIL | x11=%0d", uut.u_regfile.regs[11]);
        if(uut.u_dmem.mem[0]==32'd15)      $display("PASS | SW   mem[0]=15");
        else $display("FAIL | mem[0]=%0d", uut.u_dmem.mem[0]);
        if(uut.u_regfile.regs[12]==32'd15) $display("PASS | LW   x12=15");
        else $display("FAIL | x12=%0d", uut.u_regfile.regs[12]);
        if(uut.u_regfile.regs[13]==32'd20) $display("PASS | ADD  x13=20 (final result before loop)");
        else $display("FAIL | x13=%0d", uut.u_regfile.regs[13]);

        $display("\n--- LED Values ---");
        $display("led_result = %b = %0d", led_result, led_result);
        $display("led_opcode = %b", led_opcode);
        $display("led_pc     = %b", led_pc);
        $display("led_regval = %b", led_regval);
        $display("===== Done =====");
        $finish;
    end
    initial begin #2000; $display("TIMEOUT"); $finish; end
endmodule
