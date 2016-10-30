  # test JAL and JR

  org 0x0000
  ori $22, $0, 0xC0   // define address to 0xC0
  ori $8,  $0, 0xCCCC
  sw $8, 0($22)
  j postlabel

label:
  ori $1, $0, 0xdead
  ori $2, $0, 0xbeef
  sw  $1, 0($22)
  sw  $2, 4($22)
  JR  $31

postlabel:
  jal label
  ori $1, $0, 0xfade
  sw  $1, 8($22)
  halt

