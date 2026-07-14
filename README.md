# 32-bit RISC-V Processor (RV32I) — Verilog HDL

A single-cycle 32-bit RISC-V processor implementing the RV32I base integer instruction set, designed from scratch in Verilog HDL, verified through behavioral simulation, and implemented on real FPGA hardware (Xilinx Arty A7-100T).

![Verilog](https://img.shields.io/badge/HDL-Verilog-blue)
![FPGA](https://img.shields.io/badge/FPGA-Arty%20A7--100T-green)
![Status](https://img.shields.io/badge/status-hardware%20verified-brightgreen)

---

## 📖 Overview

This project implements a **single-cycle RV32I RISC-V processor** — every instruction completes fetch, decode, execute, memory access, and write-back within one clock cycle. The design was built module-by-module, verified independently, integrated, simulated, and finally deployed on real FPGA hardware with live LED output showing opcode execution.

**Key highlights:**
- ✅ 8 independent Verilog modules, each with its own testbench
- ✅ 14 RV32I opcodes verified in simulation (100% PASS)
- ✅ Fully synthesizable design, implemented on Arty A7-100T FPGA
- ✅ Remote-lab friendly — VIO (Virtual I/O) core for reset control and live observation without physical board access
- ✅ Clock divider for human-visible LED output of ALU results

---

## 🏗️ Architecture

```
                    ┌──────────────────┐
        ┌──────────►│  Instruction Mem  ├──────────┐
        │           └──────────────────┘          │
┌───────┴──────┐                          ┌────────▼────────┐
│ Program       │                          │  Control Unit   │
│ Counter (PC)  │                          └────────┬────────┘
└───────▲──────┘                                    │
        │           ┌──────────────────┐            │
        │      ┌────►│  Register File   ├───┐        │
        │      │    └──────────────────┘   │        │
        │      │    ┌──────────────────┐   │        │
        │      └────►│ Immediate Gen    ├───┼────────┘
        │           └──────────────────┘   │
        │                                  ▼
        │                          ┌──────────────┐
        │                          │     ALU      ├──────┐
        │                          └──────────────┘      │
        │                                                 ▼
        │                                        ┌──────────────┐
        └────────────────────────────────────────┤  Data Memory │
                  (PC-next / Write-back MUXes)    └──────────────┘
```

**Datapath flow:** PC → Instruction Memory → Control Unit + Register File + Immediate Generator → ALU → Data Memory → Write-back → PC-next

---

## 📂 Repository Structure

```
├── rtl/                        # Synthesizable Verilog source
│   ├── program_counter.v       # PC register with reset
│   ├── instruction_memory.v    # 256×32 instruction ROM (test program)
│   ├── register_file.v         # 32×32-bit register file
│   ├── imm_gen.v                # Immediate generator (I/S/B/U/J formats)
│   ├── control_unit.v           # Opcode decoder → control signals
│   ├── alu.v                    # 10-operation ALU
│   ├── data_memory.v            # 256×32 data RAM
│   ├── riscv_top_sim.v          # Top module for SIMULATION (no VIO)
│   └── riscv_top_hw.v           # Top module for HARDWARE (VIO + clock divider)
│
├── testbench/
│   └── tb_riscv_hw.v            # Self-checking testbench
│
├── constraints/
│   └── arty_a7_100t.xdc         # Pin constraints for Arty A7-100T
│
└── docs/
    └── (add your waveform screenshots, block diagram, board photos here)
```

---

## ⚙️ Module Descriptions

| Module | Description |
|---|---|
| **program_counter.v** | 32-bit register holding the fetch address; updates to PC+4, branch, or jump target on each clock edge |
| **instruction_memory.v** | 256×32-bit combinational ROM storing the test program |
| **register_file.v** | 32 general-purpose registers (x0–x31); x0 hardwired to 0; 2 async reads, 1 sync write |
| **imm_gen.v** | Extracts and sign-extends immediates for I/S/B/U/J instruction formats |
| **control_unit.v** | Combinational decoder — generates RegWrite, ALUSrc, MemRead, MemWrite, MemToReg, Branch, Jump, ALUCtrl from opcode/funct3/funct7 |
| **alu.v** | Performs ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU based on 4-bit ALUCtrl |
| **data_memory.v** | 256×32-bit RAM; synchronous write, combinational read |
| **riscv_top_sim.v** | Simulation-only top module — plain `rst` input, includes debug output ports |
| **riscv_top_hw.v** | Hardware top module — VIO-controlled reset, clock divider, only `led_result` + `led_opcode` outputs |

---

## 🧮 ALU Operation Encoding

| ALUCtrl | Operation | ALUCtrl | Operation |
|---|---|---|---|
| 0000 | ADD | 0110 | SRL |
| 0001 | SUB | 0111 | SRA |
| 0010 | AND | 1000 | SLT |
| 0011 | OR | 1001 | SLTU |
| 0100 | XOR | | |
| 0101 | SLL | | |

---

## 🧪 Test Program

The instruction memory contains a hand-assembled program exercising all major RV32I opcode types, then loops forever (via JAL) so hardware LEDs keep cycling:

```asm
addi x1, x0, 5        # x1 = 5
addi x2, x0, 10        # x2 = 10
add  x3, x1, x2        # x3 = 15
sub  x4, x2, x1        # x4 = 5
and  x5, x1, x2        # x5 = 0
or   x6, x1, x2        # x6 = 15
xor  x7, x1, x2        # x7 = 15
slli x8, x1, 1         # x8 = 10
srli x9, x2, 1         # x9 = 5
slt  x10, x1, x2       # x10 = 1
sltu x11, x1, x2       # x11 = 1
sw   x3, 0(x0)         # mem[0] = 15
lw   x12, 0(x0)        # x12 = 15
add  x13, x12, x1      # x13 = 20
jal  x0, -56           # loop back to instruction 0
```

---

## ✅ Simulation Results

Verified in Vivado behavioral simulation using a self-checking testbench — **14/14 opcodes PASS**:

```
PASS | ADDI x1=5
PASS | ADDI x2=10
PASS | ADD  x3=15
PASS | SUB  x4=5
PASS | AND  x5=0
PASS | OR   x6=15
PASS | XOR  x7=15
PASS | SLLI x8=10
PASS | SRLI x9=5
PASS | SLT  x10=1
PASS | SLTU x11=1
PASS | SW   mem[0]=15
PASS | LW   x12=15
PASS | ADD  x13=20
```

**To run simulation in Vivado:**
1. Add all files in `rtl/` **except** `riscv_top_hw.v`
2. Add `testbench/tb_riscv_hw.v` as a simulation source
3. Set `tb_riscv_hw` as the top module
4. Run Behavioral Simulation → `run -all` in the Tcl Console

---

## 🔧 Hardware Implementation

**Target board:** Digilent Arty A7-100T (`xc7a100tcsg324-1`)

**To implement on hardware:**
1. Add all files in `rtl/` **except** `riscv_top_sim.v`
2. Add `constraints/arty_a7_100t.xdc`
3. Generate a **VIO (Virtual Input/Output)** IP core:
   - 2 input probes: `led_result[7:0]`, `led_opcode[3:0]`
   - 1 output probe: `rst` (1-bit, initial value 1)
4. Set `riscv_top_hw` as the top module
5. Run Synthesis → Implementation → Generate Bitstream
6. Program the device via Hardware Manager
7. In the VIO dashboard: set `rst = 1` then `rst = 0` to run

### Why VIO?
This project was implemented through a **remote FPGA lab** with no physical access to reset buttons. The VIO core allows reset control and live signal observation entirely through the Vivado GUI over the network.

### Why a Clock Divider?
The 100 MHz system clock executes instructions far faster than visually observable. A simple counter divides the clock to ~1–1.5 Hz so each instruction's LED output remains visible for about a second.

### LED Output Mapping

| Signal | Bits | Meaning |
|---|---|---|
| `led_result[7:0]` | 8 LEDs | Lower 8 bits of the ALU result (binary) |
| `led_opcode[3:0]` | 4 LEDs | Decoded instruction type |

| led_opcode | Instruction Type |
|---|---|
| 0001 | R-type (ADD, SUB, AND, OR, XOR, shifts, SLT, SLTU) |
| 0010 | I-type (ADDI, SLLI, SRLI) |
| 0011 | LW |
| 0100 | SW |
| 0101 | BEQ |
| 0110 | JAL |

---

## 🛠️ Tools Used

- **HDL:** Verilog
- **Simulation & Synthesis:** Xilinx Vivado 2024.1
- **Target FPGA:** Digilent Arty A7-100T (Xilinx Artix-7, `xc7a100tcsg324-1`)
- **Debug:** Xilinx VIO (Virtual Input/Output) IP core

---

## 📌 Notes

- `riscv_top_sim.v` and `riscv_top_hw.v` share the same 7 core modules but differ in reset handling and I/O — **never include both in the same Vivado project** (causes duplicate module conflicts).
- The instruction memory's final `JAL` instruction loops back to address 0, so the hardware demo runs continuously rather than halting.

---

## 🎓 Project Context

Developed as part of the VLSI SoC Design and Verification program at NIELIT Calicut, covering the complete digital design flow: RTL coding → module-level verification → system simulation → FPGA synthesis → remote hardware deployment.

---

## 📄 License

This project is released for educational purposes. Feel free to fork, study, and build upon it.
