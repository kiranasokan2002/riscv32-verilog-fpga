module data_memory (
    input         clk,
    input         rst,
    input         MemRead,
    input         MemWrite,
    input  [31:0] addr,
    input  [31:0] WriteData,
    output [31:0] ReadData
);
    reg [31:0] mem [0:255];
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i=0; i<256; i=i+1)
                mem[i] <= 32'b0;
        end
        else if (MemWrite)
            mem[addr[9:2]] <= WriteData;
    end
    assign ReadData = (MemRead) ? mem[addr[9:2]] : 32'b0;
endmodule
