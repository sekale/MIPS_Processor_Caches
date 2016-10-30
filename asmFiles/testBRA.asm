  # test BEQ and BNE
  org 0x0000
  ori $22, $0, 0xF0
  ori $1, $0, 0x8888
  sw $1, 0($22)
  ori $2, $0, 0x9999
  ori $3, $0, 0x9999
  beq $1, $2, errorHere
  bne $0, $0, errorHere
  beq $2, $3, goodNews
  halt
returnA:
  bne $1, $2, goodNewsAgain
  halt
returnB:
  halt

goodNews:
  lui $1, 0xaaaa
  ori $1, $0, 0xaaaa
  sw $1, 4($22)
  j returnA

goodNewsAgain:
  lui $1, 0xbbbb
  ori $1, $0, 0xbbbb
  sw $1, 8($22)
  j returnB

errorHere:
  lui $1, 0xbadb
  ori $1, $0, 0xadba
  sw $1, 0($22)
  halt

