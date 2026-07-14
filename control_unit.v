module control_unit (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg        RegWrite, ALUSrc, MemRead, MemWrite,
    output reg        MemToReg, Branch, Jump,
    output reg [ 3:0] ALUCtrl
);
    always @(*) begin
        RegWrite=0; ALUSrc=0; MemRead=0;
        MemWrite=0; MemToReg=0; Branch=0;
        Jump=0; ALUCtrl=4'b0000;
        case (opcode)
            7'b0110011: begin
                RegWrite=1;
                case ({funct7[5],funct3})
                    4'b0000: ALUCtrl=4'b0000;
                    4'b1000: ALUCtrl=4'b0001;
                    4'b0001: ALUCtrl=4'b0101;
                    4'b0010: ALUCtrl=4'b1000;
                    4'b0011: ALUCtrl=4'b1001;
                    4'b0100: ALUCtrl=4'b0100;
                    4'b0101: ALUCtrl=4'b0110;
                    4'b1101: ALUCtrl=4'b0111;
                    4'b0110: ALUCtrl=4'b0011;
                    4'b0111: ALUCtrl=4'b0010;
                    default: ALUCtrl=4'b0000;
                endcase
            end
            7'b0010011: begin
                RegWrite=1; ALUSrc=1;
                case (funct3)
                    3'b000: ALUCtrl=4'b0000;
                    3'b001: ALUCtrl=4'b0101;
                    3'b100: ALUCtrl=4'b0100;
                    3'b101: ALUCtrl=funct7[5]?4'b0111:4'b0110;
                    3'b110: ALUCtrl=4'b0011;
                    3'b111: ALUCtrl=4'b0010;
                    default:ALUCtrl=4'b0000;
                endcase
            end
            7'b0000011: begin RegWrite=1;ALUSrc=1;MemRead=1;MemToReg=1;ALUCtrl=4'b0000; end
            7'b0100011: begin ALUSrc=1;MemWrite=1;ALUCtrl=4'b0000; end
            7'b1100011: begin Branch=1;ALUCtrl=4'b0001; end
            7'b1101111: begin RegWrite=1;Jump=1;ALUCtrl=4'b0000; end
            7'b1100111: begin RegWrite=1;ALUSrc=1;Jump=1;ALUCtrl=4'b0000; end
            7'b0110111: begin RegWrite=1;ALUSrc=1;ALUCtrl=4'b0000; end
            default: begin end
        endcase
    end
endmodule
