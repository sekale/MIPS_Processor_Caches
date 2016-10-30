
  org 0x0000
  ori $1, $0, 500
  ori $2, $0, 400
  ori $3, $0, 200
  ori $4, $0, 0x5a
  ori $5, $0, 0xa5
  ori $29, $0, 0xFFFC

  addu $6, $1, $2 // 500 + 400 = 900
  srl  $3, $3, 1  // 200 >> 1 = 100
  add  $6, $6, $3 // 900 + 100 = 1000
  sll  $3, $3, 1  // 100 << 1 = 200
  and  $20, $4, $5  // 0x5a & 0xa5 = 0x00
  jal  jaljrtest
  beq  $0, $20, beqtest
backToMain:
  nor $20, $0, $0   // $20 <- '1
  xor $21, $0, $20  // $21 <- '1
  bne $21, $20, fail
  sub $25, $6, $1 // $25 <- 500
  subu $26, $1, $6 // $26 <- 500 - 1000
  slt $22, $26, $25
  ori $19, $0, 1
  bne $19, $22, fail
  sltu $22, $26, $25
  ori $19, $0, 1
  beq $19, $22, fail
  push $31
  pop $25
  bne $31, $25, fail
  jal storeShit
  halt

bnetest:
  beq $4, $5, fail
  bne $0, $20, fail
  j backToMain

jaljrtest:
  jr $31

beqtest:
  bne $4, $5, bnetest

fail:
  lui $1, 0xdead
  ori $1, $0, 0xbeef
  ori $2, $0, 0xF0
  sw $1, 0($2)
  halt

storeShit:
  sw $20, 4($2) // 65
  sw $21, 8($2) // 66
  sw $25, 12($2)  // 67
  sw $26, 16($2)  // 68
  sw $22, 24($2)  // 6a
  sw $19, 28($2)  // 6b
  sw $22, 32($2)  // 6c
  sw $25, 36($2)  // 6d
  sw $6, 40($2)   // 6e
  sw $3, 44($2)   // 6f
  jr $31
