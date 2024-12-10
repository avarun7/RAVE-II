# test: 
# R1 = 2
# R2 = 3
# R3 = R1 + R2
# R6 = 0x400
# M[0x400] = 5
# R8 = M[0x400] = 5
# R11 = R8 * R2 = 15
# R13 = R11 / R1
# jump to pc 0

0x00200093 # addi x1, 0x0, 0x2
0x00300113 # addi x2, 0x0, 0x3
0x002081B3 # add  x3, x1, x2
0x40038313 # addi x6, x7, 0x400
0x00332023 # sw x3, 0(x6)
0x00032403 # lw x8, 0(x6) 
0x028105B3 # mul x11, x8, x2
0x02B0C6B3 # div x13, x11, x1

# 2B0C6B3


0x00000067  # jalr x0, x0, 0
