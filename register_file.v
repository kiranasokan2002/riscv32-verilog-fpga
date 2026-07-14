module register_file (
    input         clk,
    input         rst,
    input         RegWrite,
    input  [ 4:0] rs1, rs2, rd,
    input  [31:0] WriteData,
    output [31:0] ReadData1,
    output [31:0] ReadData2
);
    reg [31:0] regs [0:31];
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i=0; i<32; i=i+1)
                regs[i] <= 32'b0;
        end
        else if (RegWrite && rd != 5'b0)
            regs[rd] <= WriteData;
    end
    assign ReadData1 = (rs1==5'b0) ? 32'b0 : regs[rs1];
    assign ReadData2 = (rs2==5'b0) ? 32'b0 : regs[rs2];
endmodule
