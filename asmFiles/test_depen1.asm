org 0x000
ori $22, $0, 0xC0
ori $8, $0, 0xF0
sw $8, 0($22)
j label

label:
  ori $1, $0, 0xdead
  ori $2, $0, 0xbeef
  sw $2, 12($22)

  add $2, $2, $2
  lw $6, 12($22)
  sub $6, $2, $6

  sw $2, 4($22)
  sw $6, 8($22)
halt


