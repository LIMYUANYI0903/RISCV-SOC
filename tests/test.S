.text
.global _start

_start:
    addi x10, x0, 100

    nop
    nop
    nop
    nop
    nop

    addi x5, x0, 42

    nop
    nop
    nop
    nop
    nop

    sw x5, 0(x10)

    nop
    nop
    nop
    nop
    nop

    lw x1, 0(x10)
    addi x2, x1, 1
    addi x3, x0, 10
    addi x4, x0, 20

    nop
    nop
    nop
    nop
    nop
    nop