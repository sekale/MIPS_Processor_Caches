#
#   Lab 2 : Multiply Algorithm
#   ----------------------------
#   You will construct an algorithm that multiplies two unsigned words.
#   Data will be passed to this routine via a stack.
#   You will implement this stack via the stack pointer register sp(29).
#   At the start of the program you must initialize your stack to address 0xFFFC.
#

  org 0x0000  # address for code segment

setup:
  ori $29, $0, 0xFFFC   # initialize stack to required address
  ori $1, $0, 0x0005    # give value 1
  ori $2, $0, 0x0002    # give value 2
  push $1
  push $2
  jal parentMult
  pop $3
  halt

parentMult:
  pop $8
  pop $9
  andi $10, $0, 0x0000
  andi $11, $0, 0x0000

mtp:
  beq $10, $8, fin      # if($10 != $8) goto fin
  add $11, $11, $9      # else $11 += $9
  addi $10, $10, 1      # and  $10++
  j mtp

fin:
  push $11
  jr $31

