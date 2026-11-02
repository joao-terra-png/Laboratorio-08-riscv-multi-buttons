.text    # 0x00000000 
.globl _start
_start:
    li t0, 1
    li t1, 512
    li t2, 1
    li s0, 0x104
    li s1, 0x110
loop:
bindo:
    sw t2, 0(s0)
    lw t3, 0(s1)
    bne t3, 0, bindo
indo:
    slli t2, t2, 1
    sw t2, 0(s0)
    bne t2, t1, indo
bvoltando:
    sw t2, 0(s0)
    lw t3, 0(s1)
    bne t3, 0, bvoltando
voltando:
    srli t2, t2, 1
    sw t2, 0(s0)
    bne t2, t0, voltando
j loop