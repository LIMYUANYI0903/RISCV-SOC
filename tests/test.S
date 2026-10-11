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
    addi x1, x0, -8
    addi x2, x0, 8

    slli x3, x2, 2
    srli x4, x2, 2
    srai x5, x1, 2
    srli x6, x1, 2