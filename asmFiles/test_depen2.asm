  # test JAL and JR

  org 0x0000
  ori $27, $0, 0xC0   // define address to 0xC0
  ori $8,  $0, 0xCCCC
  ori $22,  $0, 0xCCAC
  ori $3,  $0, 0xCABD

  sw $8, 0($27)
  sw $3, 4($27)
  j postlabel

postlabel:
  ori $1, $0, 0xfade
  add $22, $8, $1
  sub $23, $22, $1
  and $11, $22, $8
  or $6, $22, $3

  sw $1, 8($27)
  sw $22, 8($27)
  sw $23, 8($27)
  sw $11, 8($27)
  sw $6, 8($27)

  halt

