
    .text
    .global _start

_start:
    # Jump forward first
    jal x0, forward

backward_target:
    addi x10, x0, 10
    jal x0, finish

forward:
    addi x11, x0, 11

    # Jump backward
    jal x0, backward_target

    # Must be flushed
    addi x12, x0, 12

finish:
    addi x13, x0, 13

done:
    jal x0, done

    .end
