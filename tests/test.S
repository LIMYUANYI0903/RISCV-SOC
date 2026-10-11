/***
.org 0x0
.global _start
_start:
    ori x5, x4, 2
    ori x5, x4, 3
    ori x5, x4, 4
    ori x5, x4, 5
***/

.org 0x0
.globl _start

_start:
    addi x1, x0, -16
    addi x2, x0, 2

    sll  x3, x2, x2
    srl  x4, x1, x2
    sra  x5, x1, x2
    slt  x6, x1, x2
    sltu x7, x1, x2