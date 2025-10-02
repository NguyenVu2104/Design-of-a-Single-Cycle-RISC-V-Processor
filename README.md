# Design-of-a-Single-Cycle-RISC-V-Processor

	This repository is a comprehensive endeavor centered around the development of a Single Cycle Processor tailored for the RV32I instruction set architecture. First and foremost, the Arithmetic Logic Unit (ALU) is designed to execute a wide range of operations, addressing the core computational needs of the RV32I processor. Additionally, a Branch Comparison Unit (BRC) has been incorporated, facilitating the gathering of register values and performing comparisons for executing branching instructions efficiently. Next, a Register File is established in strict compliance with RISC-V specifications, featuring 32-bit registers. Notably, Register 0 is reserved and consistently holds the value of 0.

	To manage data transfers between the processor and memory, a Load-Store Unit is included, complete with a memory map. The Control Unit takes center stage as the orchestrator of the processor, generating and managing a substantial portion of the signals required for its operation. This unit ensures that instructions are executed correctly and effectively. Then, we craft a set of assembly instructions that define the actions our processor will execute. These instructions are then converted into binary code, the language that the processor comprehends and executes directly. To enable the execution of these binary instructions, we employ a memory model for storage. The binary code is seamlessly integrated into this memory model, and we utilize directives like readmemh to manage memory access. This directive serves a dual purpose by not only facilitating the reading and execution of instructions but also enabling the control of output peripherals and reading processes.

  <img width="975" height="500" alt="image" src="https://github.com/user-attachments/assets/d593078c-db3d-4c4c-a1c0-02c7d1a5d958" />

## Arithmetic Logic Unit (ALU)

<img width="1086" height="470" alt="image" src="https://github.com/user-attachments/assets/4b804a92-2241-47b1-a275-0cb4b9ce400a" />

	Since we do not have operators for subtraction (–), comparison (<,  >), shifting (<<, >> and >>>), multiplication (∗), division (/), modulo (%), and other unsynthesizable operators in designs thus these operations can be executed as follows: 
- Subtraction:  Achieved by computing the two's complement of the second operand (i_operand_b) and adding it to the first operand (i_operand_a). This is done by inverting the bits of i_operand_b and adding 1, effectively performing rs1 - rs2 = rs1 + ~rs2 + 1.
- Comparison:
  + SLT (Signed Less Than): Performs a signed comparison by checking if i_operand_a is less than i_operand_b. This is determined by the sign bit of the subtraction result (i_operand_a - i_operand_b).
  + SLTU (Unsigned Less Than): Performs an unsigned comparison by directly comparing the magnitudes of i_operand_a and i_operand_b.
- Shifting:
  + SLL (Shift Left Logical): Uses the left shift operator (<<) to shift i_operand_a left by the number of bits specified in i_operand_b, filling the least significant bits with zeros.
  + SRL (Shift Right Logical): Uses the right shift operator (>>) to shift i_operand_a right, filling the most significant bits with zeros.
  + SRA (Shift Right Arithmetic): Uses the arithmetic right shift operator (>>>) to shift i_operand_a right, preserving the sign bit for signed numbers by filling the most significant bits with the original sign bit.
- Bitwise Operations (XOR, OR, AND): Directly applies the corresponding bitwise operators (^, |, &) to the operands i_operand_a and i_operand_b.
- Pass-through (B): Outputs i_operand_b directly without modification, used in certain instructions where no computation is required like LUI instruction.

	The operation is selected using a case statement in the alu module, driven by the 4-bit opcode (i_alu_op) input. This ensures that the correct computation is performed for each instruction type, supporting both R-type and I-type instructions as specified in the RV32I architecture.


