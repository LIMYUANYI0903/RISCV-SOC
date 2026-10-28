
    .text
    .global _start

_start:
    # ========================================
    # Test 1: Branch Taken / Not Taken
    # ========================================
    addi x1, x0, 5
    addi x2, x0, 10
    addi x3, x0, -1

    # BEQ taken
    beq x1, x1, beq_ok
    addi x10, x0, 1
beq_ok:

    # BEQ not taken
    beq x1, x2, beq_fail
    addi x11, x0, 11
beq_fail:

    # BNE taken
    bne x1, x2, bne_ok
    addi x12, x0, 1
bne_ok:

    # BNE not taken
    bne x1, x1, bne_fail
    addi x13, x0, 13
bne_fail:

    # BLT signed taken (-1 < 5)
    blt x3, x1, blt_ok
    addi x14, x0, 1
blt_ok:

    # BLT not taken
    blt x2, x1, blt_fail
    addi x15, x0, 15
blt_fail:

    # BGE signed taken (10 >= 5)
    bge x2, x1, bge_ok
    addi x16, x0, 1
bge_ok:

    # BGE not taken (-1 >= 5 false)
    bge x3, x1, bge_fail
    addi x17, x0, 17
bge_fail:

    # BLTU taken (5 < 10)
    bltu x1, x2, bltu_ok
    addi x18, x0, 1
bltu_ok:

    # BLTU not taken (unsigned -1 > 5)
    bltu x3, x1, bltu_fail
    addi x19, x0, 19
bltu_fail:

    # BGEU taken (unsigned -1 >= 5)
    bgeu x3, x1, bgeu_ok
    addi x20, x0, 1
bgeu_ok:

    # BGEU not taken (5 >= 10 false)
    bgeu x1, x2, bgeu_fail
    addi x21, x0, 21
bgeu_fail:

    # ========================================
    # Test 2: JAL link + forwarding
    # ========================================
    jal x22, jal_target
    addi x23, x0, 23
    addi x24, x0, 24

jal_target:
    addi x25, x22, 0

    # ========================================
    # Test 3: JALR data hazard
    # ========================================
    auipc x26, 0
    addi x26, x26, 20
    jalr x27, 0(x26)

    addi x28, x0, 28
    addi x29, x0, 29

jalr_target:
    addi x30, x27, 0

    # ========================================
    # Test 4: Load-use + Branch
    # ========================================
    addi x4, x0, 256
    addi x5, x0, 42
    sw x5, 0(x4)

    lw x6, 0(x4)
    beq x6, x5, load_branch_ok
    addi x7, x0, 7

load_branch_ok:
    addi x8, x0, 8

done:
    jal x0, done

    .end
