// ============================================================
// RISC-V Top Level — HARDWARE with CLOCK DIVIDER (FIXED)
// Board: Arty A7-100T
// Clock divider runs independent of rst
// ============================================================
module riscv_top_hw (
    input  clk,
    output [7:0] led_result,
    output [3:0] led_opcode
);
    wire rst;

    vio_0 u_vio (
        .clk        (clk),
        .probe_out0 (rst),
        .probe_in0  (led_result),
        .probe_in1  ({28'b0, led_opcode})
    );

    // ── CLOCK DIVIDER — runs always, NOT affected by rst ──
    // 100MHz -> ~1.5Hz  (slower so clearly visible)
    reg [25:0] div_counter = 0;
    reg slow_clk = 0;
    always @(posedge clk) begin
        div_counter <= div_counter + 1;
        if (div_counter == 26'd33_000_000) begin
            div_counter <= 0;
            slow_clk <= ~slow_clk;
        end
    end

    wire [31:0] pc, pc_plus4, pc_next, pc_branch, pc_jump;
    wire [31:0] instruction;
    wire [31:0] read_data1, read_data2;
    wire [31:0] imm, alu_b, alu_a;
    wire [31:0] alu_result, mem_read_data, write_back_data;
    wire        RegWrite, ALUSrc, MemRead, MemWrite;
    wire        MemToReg, Branch, Jump, Zero;
    wire [3:0]  ALUCtrl;

    wire [4:0] rs1    = instruction[19:15];
    wire [4:0] rs2    = instruction[24:20];
    wire [4:0] rd     = instruction[11:7];
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    assign pc_plus4  = pc + 32'd4;
    assign pc_branch = pc + imm;
    assign pc_jump   = alu_result;
    assign pc_next   = Jump             ? pc_jump   :
                       (Branch && Zero) ? pc_branch :
                                          pc_plus4;

    program_counter u_pc (
        .clk(slow_clk), .rst(rst),
        .pc_next(pc_next), .pc(pc)
    );

    instruction_memory u_imem (
        .addr(pc), .instruction(instruction)
    );

    register_file u_regfile (
        .clk(slow_clk), .rst(rst),
        .RegWrite(RegWrite),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .WriteData(write_back_data),
        .ReadData1(read_data1),
        .ReadData2(read_data2)
    );

    imm_gen u_immgen (
        .instruction(instruction),
        .imm_out(imm)
    );

    control_unit u_ctrl (
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .RegWrite(RegWrite), .ALUSrc(ALUSrc),
        .MemRead(MemRead),   .MemWrite(MemWrite),
        .MemToReg(MemToReg), .Branch(Branch),
        .Jump(Jump),         .ALUCtrl(ALUCtrl)
    );

    assign alu_b = ALUSrc ? imm : read_data2;
    assign alu_a = (opcode == 7'b1101111) ? pc : read_data1;

    alu u_alu (
        .A(alu_a), .B(alu_b),
        .ALUCtrl(ALUCtrl),
        .Result(alu_result),
        .Zero(Zero)
    );

    data_memory u_dmem (
        .clk(slow_clk), .rst(rst),
        .MemRead(MemRead), .MemWrite(MemWrite),
        .addr(alu_result),
        .WriteData(read_data2),
        .ReadData(mem_read_data)
    );

    assign write_back_data = Jump     ? pc_plus4     :
                             MemToReg ? mem_read_data :
                                        alu_result;

    assign led_result = alu_result[7:0];

    reg [3:0] opcode_type;
    always @(*) begin
        case (opcode)
            7'b0110011: opcode_type = 4'b0001;
            7'b0010011: opcode_type = 4'b0010;
            7'b0000011: opcode_type = 4'b0011;
            7'b0100011: opcode_type = 4'b0100;
            7'b1100011: opcode_type = 4'b0101;
            7'b1101111: opcode_type = 4'b0110;
            default:    opcode_type = 4'b0000;
        endcase
    end
    assign led_opcode = opcode_type;

endmodule
