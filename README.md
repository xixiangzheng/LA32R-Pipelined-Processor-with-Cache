# Implementation of a 32-Bit 5-Stage Pipelined LA32R Processor with Parameterized N-Way Set-Associative Cache

[English Version] | **[中文版](./README_CN.md)**

## 📌 Overview

This repository contains the RTL implementation of a 32-bit, 5-stage pipelined microprocessor based on the **LA32R (LoongArch 32-bit Reduced)** instruction set architecture, alongside a standalone, highly parameterized **N-way set-associative Cache IP**. Designed entirely in Verilog HDL, the project incrementally evolved from a basic single-cycle datapath into a fully robust pipelined architecture with an advanced memory hierarchy.

It features comprehensive handling of structural, data, and control hazards through advanced forwarding (bypassing) and pipeline stall/flush mechanisms. The CPU design has been fully verified via simulation and successfully synthesized and deployed on the FPGAOL platform for physical testing, while the Cache IP is thoroughly verified via rigorous testbenches with simulated main memory latencies.

### System Datapath

![](.\cpu_core\docs\datapath.png)

>   **Note:** The diagram above illustrates the baseline 5-stage pipeline. Advanced forwarding paths and hazard detection logic are implemented in RTL but omitted here for visual clarity.

## 🚀 Key Architectural Features

### CPU Core Features

-   **Full 5-Stage Pipeline:** Implements standard Instruction Fetch (IF), Decode (ID), Execute (EX), Memory (MEM), and Write Back (WB) stages to maximize clock frequency and instruction throughput.
-   **Dynamic Data Forwarding (Bypass):** Features a dedicated `Forwarding` unit that eliminates Read-After-Write (RAW) hazards by dynamically routing the most recent ALU or MEM outputs directly to the EX stage, minimizing NOP bubble insertions.
-   **Load-Use & Control Hazard Handling:** Integrates a Hazard Detection Unit (`SegCtrl`) that intelligently stalls the pipeline (freezing PC and IF/ID registers) during Load-Use conflicts and flushes the pipeline when a branch is taken.
-   **Write-Through Register File:** Resolves ID/WB structural hazards by implementing internal forwarding. If a read and write occur at the same register address in the same cycle, the data to be written is prioritized and output directly.
-   **Advanced Memory Access Controller:** Includes a Store/Load Unit (`SLU`) capable of handling unaligned memory accesses, facilitating arbitrary byte, half-word, and word transactions with precise sign/zero extensions.
-   **Hardware On-Board Debugging Integration:** Seamlessly interfaces with a Peripheral Debugging Unit (PDU). It synchronously exposes internal CPU states (e.g., `commit` signals, PC, register updates) for real-time validation on physical FPGAs.

### Configurable Cache IP Features

-   **Parameterized N-Way Set-Associative:** Supports dynamic configuration for 2-way, 4-way, 8-way, and 16-way set-associativity. (N is strictly constrained to powers of 2 to ensure high-performance hardware mapping and efficient address decoding).
-   **Multiple Eviction Policies:** Pluggable hardware modules for handling Cache Misses when sets are full:
    -   **LRU (Least Recently Used):** Utilizes age timestamps to evict the least recently accessed line.
    -   **FIFO (First-In-First-Out):** Uses a strict queue counter based on allocation order.
    -   **Pseudo-Random:** Achieves acceptable hit rates with minimal hardware overhead.
-   **Write Policy:** Implements Write-Back and Write-Allocate strategies for optimal memory bandwidth utilization. (Aligned word-level access).
-   **Memory Latency Simulation:** The `mem.v` controller explicitly simulates realistic main memory delays (e.g., 5 cycles for simulation, configurable up to 50+ cycles to mirror physical RAM constraints).

## 📊 Verification & Performance Report

Detailed quantitative analysis, simulation waveforms (Hit/Miss/Write-Back logic), and performance data across various configurations are meticulously documented in the following reports:

👉 **[Click here to view the detailed CPU Pipeline Verification Report](.\cpu_core\docs\CPU_Pipeline_Verification_Report.pdf)**

👉 **[Click here to view the detailed Cache Performance Analysis Report](.\cache_module\reports\Cache_Performance_Analysis_Report.pdf)**

## 📂 Project Structure & Directory Tree

The repository is strictly organized into two independent subsystems.

```
LA32R-Pipelined-Processor-with-Cache/
├── README.md                  # Project documentation
├── LICENSE                    # Open-source license
├── cpu_core/                  # Subsystem 1: 5-Stage Pipelined CPU Core
│   ├── src/                   # CPU Verilog source code
│   │   ├── CPU.v              
│   │   ├── PipelineTop.v      
│   │   ├── PipelineReg.v      
│   │   ├── Forwarding.v       
│   │   ├── SegCtrl.v          
│   │   ├── PC.v               
│   │   ├── Decoder.v          
│   │   ├── RegFile.v          
│   │   ├── ALU.v              
│   │   ├── Branch.v           
│   │   ├── SLU.v              
│   │   └── MUX2.v             
│   └── docs/                  # Architecture diagrams & FPGA deployment photos
│       ├── datapath.png    
│		└── CPU_Pipeline_Verification_Report.pdf
└── cache_module/              # Subsystem 2: High-Speed Cache IP
    ├── src/                   # Cache design source code
    │   ├── simple_cache.v     
    │   ├── lru_eviction.v     
    │   ├── fifo_eviction.v    
    │   └── random_eviction.v  
    ├── sim/                   # Simulation & Testbench environment
    │   ├── mem.v              
    │   ├── bram.v   
    │   ├── generate_tb.v 	   # Generate the test files mem_bram.v and cache_tb.v
    │   ├── mem_bram.v    
    │   └── cache_tb.v         
    └── reports/               # Performance analysis & waveforms
        └── Cache_Performance_Analysis_Report.pdf
```

## 🧩 Module Architecture & Verilog File Details

### 1. CPU Core Modules

**Layer 1: Top-Level Integration & Pipeline Backbone**

1.  **`CPU.v` (System Wrapper):** The top-level entity. It instantiates and wires all datapath modules, the `PipelineTop`, and memory interfaces. It routes signals across the 5 stages and latches the debugging `commit` signals for the PDU.
2.  **`PipelineTop.v` (Pipeline Artery):** A centralized pipeline register manager. It encapsulates all inter-stage registers and synchronizes global `stall` and `flush` signals to control the flow of data and control signals from IF down to WB smoothly.
3.  **`PipelineReg.v` (Unified Inter-stage Register):** A highly parameterized, 4-stage shift-register-like module. It serves as the physical memory boundary between pipeline stages, equipped with synchronous `stall` (hold data) and `flush` (reset to init) capabilities.

**Layer 2: Hazard Resolution & Control**

1.  **`Forwarding.v` (Data Bypass Unit):** Continuously compares the source registers in the EX stage (`rf_ra0_EX`, `rf_ra1_EX`) against the destination registers in the MEM and WB stages. If a match occurs, it enables bypass paths to forward the latest computational results directly to the ALU inputs.
2.  **`SegCtrl.v` (Hazard Detection Unit):** Despite the name (Segment Control), it acts as the global Hazard Detection Unit. It monitors for Load-Use data dependencies and branch outcomes, emitting precise `stall` and `flush` signals to `PipelineTop` and `PC` to maintain instruction integrity.

**Layer 3: Datapath & Execution Components**

1.  **`PC.v` (Program Counter):** Maintains the current instruction address (IF stage). Supports halting (`stall`) and branch jumping (`flush`), with a hardcoded reset vector of `32'h1C000000`.
2.  **`Decoder.v` (Instruction Decoder):** Resides in the ID stage. It parses 32-bit LA32R machine code, extracting register addresses, immediates (with correct sign extensions), and generating control signals for the ALU, memory, and multiplexers.
3.  **`RegFile.v` (Register File):** Contains thirty-two 32-bit general-purpose registers. Notably features a write-through mechanism to resolve structural hazards natively.
4.  **`ALU.v` (Arithmetic Logic Unit):** The execution engine (EX stage). Handles all arithmetic (ADD, SUB), logical (AND, OR, XOR), shifts, and comparison operations (handling both signed and unsigned comparisons accurately).
5.  **`Branch.v` (Branch Evaluator):** Evaluates branch conditions (BEQ, BNE, BLT, BGE, etc.) using the forwarded source operands in the EX stage. If a branch is taken, it signals the `PC` to jump and the `SegCtrl` to flush wrong-path instructions.
6.  **`SLU.v` (Store/Load Unit):** Operates in the MEM stage. Depending on the low-order bits of the memory address and the instruction type, it masks, truncates, or sign-extends data for byte (`ld.b`, `st.b`) or half-word (`ld.h`, `st.h`) memory accesses.
7.  **`MUX2.v` (Data Selector):** A highly reused parameterized multiplexer. Based on the RTL code, it functions as a 4-to-1 data selector to route various signals (e.g., ALU inputs, Write-back data sources) throughout the datapath.

### 2. Cache & Memory Modules

| **Module Name**         | **Description**                                              |
| ----------------------- | ------------------------------------------------------------ |
| **`simple_cache.v`**    | The core Cache controller state machine and datapath, handling read/write requests, hits/misses, and memory interfacing. |
| **`lru_eviction.v`**    | Eviction logic implementing the Least Recently Used policy using age tracking. |
| **`fifo_eviction.v`**   | Eviction logic implementing the First-In-First-Out policy using allocation counters. |
| **`random_eviction.v`** | Eviction logic implementing a pseudo-random replacement policy for low hardware overhead. |
| **`mem.v` / `bram.v`**  | Simulated main memory backend and block RAM primitives, injecting realistic read/write latency cycles for thorough testing. |

## 🛠 Development Environment

-   **Hardware Description Language:** Verilog HDL
-   **Synthesis & Simulation:** Xilinx Vivado
-   **Target Hardware:** FPGAOL Platform (ZYNQ / Artix-7 Series)
