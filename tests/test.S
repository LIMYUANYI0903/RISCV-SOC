    .text
    .global _start

_start:
    # Test 1: BNE taken
    li x2, 2
    li x3, 1
    nop
    nop
    bne x2, x3, test2

    # These must be flushed
    li x10, 10
    li x11, 11

test2:
    # Reaching this point means execution continued
    li x12, 12

    # Test 2: BNE not taken
    li x4, 5
    li x5, 5
    nop
    nop
    bne x4, x5, fail

    # Should execute normally
    li x13, 13
    li x14, 14

    # Test 3: BNE taken again
    li x6, 7
    li x7, 8
    nop
    nop
    bne x6, x7, success

    # These must be flushed
    li x15, 15
    li x16, 16

success:
    li x17, 17
    j done

fail:
    li x18, 18

done:
    j done

    .end