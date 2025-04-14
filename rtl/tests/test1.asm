main:
        addi     a5,zero, 64
        addi    a6,zero,64
        lui    a7,4096
        mul     a5,a6,a5
        add     a5,a7,a5
halt:
        .word 0xdeadbeef
