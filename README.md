# Design-of-a-Single-Cycle-RISC-V-Processor

This repository is a comprehensive endeavor centered around the development of a Single Cycle Processor tailored for the RV32I instruction set architecture. First and foremost, the Arithmetic Logic Unit (ALU) is designed to execute a wide range of operations, addressing the core computational needs of the RV32I processor. Additionally, a Branch Comparison Unit (BRC) has been incorporated, facilitating the gathering of register values and performing comparisons for executing branching instructions efficiently. Next, a Register File is established in strict compliance with RISC-V specifications, featuring 32-bit registers. Notably, Register 0 is reserved and consistently holds the value of 0.

To manage data transfers between the processor and memory, a Load-Store Unit is included, complete with a memory map. The Control Unit takes center stage as the orchestrator of the processor, generating and managing a substantial portion of the signals required for its operation. This unit ensures that instructions are executed correctly and effectively. Then, we craft a set of assembly instructions that define the actions our processor will execute. These instructions are then converted into binary code, the language that the processor comprehends and executes directly. To enable the execution of these binary instructions, we employ a memory model for storage. The binary code is seamlessly integrated into this memory model, and we utilize directives like readmemh to manage memory access. This directive serves a dual purpose by not only facilitating the reading and execution of instructions but also enabling the control of output peripherals and reading processes.


  <img width="975" height="500" alt="image" src="https://github.com/user-attachments/assets/d593078c-db3d-4c4c-a1c0-02c7d1a5d958" />


## Arithmetic Logic Unit (ALU)

ALU (Arithmetic Logic Unit) is a fundamental component responsible for performing arithmetic and bitwise operations on binary data. The ALU is responsible for executing various operations such as addition, subtraction, bitwise XOR, bitwise AND, bitwise OR, set less than, set less than unsigned, shift left logical, shift right logical, and shift right arithmetic.

The table below describes the operations that ALU needs to execute:


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

## Branch Comparison Unit (BRC)

The Branch Comparison Unit (BRC) is a critical component in the RV32I single-cycle processor, tasked with comparing two register values to evaluate branch instruction outcomes. It supports both signed and unsigned comparisons, ensuring compliance with the RV32I instruction set requirements.

The table below describes the tasks that BRU needs to execute: 

<img width="975" height="259" alt="image" src="https://github.com/user-attachments/assets/ce60c330-9891-4497-b474-7475047410ab" />

Since we do not have operators for subtraction (–), comparison (<,  >), shifting (<<, >> and >>>), multiplication (∗), division (/), modulo (%), and other unsynthesizable operators in designs thus these operations can be executed as follows:

- Equality: The o_br_equal output is generated by performing a bitwise XOR between i_rs1_data and i_rs2_data, followed by a reduction NOR operation. If no bits differ, the result is 1, indicating equality.

- Less Than:
  + Unsigned Comparison: When i_br_un is 1, the BRC treats the inputs as 32-bit unsigned integers. It compares the bits from the most significant bit (MSB) to the least significant bit (LSB), determining which value is smaller based on binary magnitude.
  + Signed Comparison: When i_br_un is 0, the BRC accounts for two’s complement representation. If the sign bits (bit 31) of i_rs1_data and i_rs2_data differ, the positive number (sign bit 0) is greater. If the sign bits are identical, the comparison proceeds as a magnitude comparison, adjusted for signed interpretation.

The BRC must accurately set the o_br_less and o_br_equal outputs based on the values of i_rs1_data and i_rs2_data, interpreting them as signed or unsigned integers depending on the i_br_un signal.

## Immediate Generator Unit (ImmGen)

The Immediate Generator (ImmGen) is an essential module in the RV32I single-cycle processor design, tasked with extracting and extending immediate values from 32-bit instructions. This component ensures that instructions requiring immediate operands—such as arithmetic operations, memory addressing, branches, and jumps—receive correctly formatted 32-bit values within a single clock cycle. Below, we outline the design strategy for the ImmGen module based on its implementation in the test file.

The ImmGen takes a 32-bit instruction as its primary input and generates a 32-bit immediate output. The module supports multiple immediate formats, each corresponding to a specific RV32I instruction type: I-type, S-type, B-type, U-type, and J-type. The design leverages combinational logic to perform bit extraction, concatenation, and sign extension, ensuring low latency and seamless integration into the processor’s single-cycle datapath.

The module accepts a 32-bit instruction and uses the opcode (bits [6:0]) to identify the instruction type. This decoding step determines the immediate format to be generated, Immediate format:

- I-type: Extracts a 12-bit immediate from bits [31:20], sign-extending it to 32 bits by replicating the most significant bit (MSB).
- S-type: Combines bits [31:25] and [11:7] to form a 12-bit immediate, followed by sign extension.
- B-type: Rearranges bits [31], [7], [30:25], and [11:8] into a 12-bit immediate (with an implicit zero in the LSB), sign-extended to 32 bits.
- U-type: Takes bits [31:12] as a 20-bit immediate and shifts it left by 12 bits, filling the lower bits with zeros.
- J-type: Assembles bits [31], [19:12], [20], and [30:21] into a 20-bit immediate (with an implicit zero in the LSB), sign-extended to 32 bits.

## Control Unit (CU)

The Control Unit (CU) serves as the core component that decodes instructions and generates control signals to manage the processor's operations. It interprets the fetched instruction and directs the behavior of other units, including the Arithmetic Logic Unit (ALU), Branch Comparison Unit (BRC), Register File, and Load-Store Unit, ensuring proper execution within a single-cycle RV32I processor. Below is a detailed description of every function the Control Unit performs to ensure proper execution of the RV32I instruction set:

| First Header  | Second Header |
| ------------- | ------------- |
| Content Cell  | Content Cell  |
| Content Cell  | Content Cell  |



  
