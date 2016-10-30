#
#   Lab 2 : Multiply Procedure
#   ----------------------------
#   In this program place two operands on the stack then call the
#   multiply sub routine and return back to the main program with the result
#   at the stack location of the first operand. The main program should be able
#   to push a variable number of operands (2+) and multiply all of them until
#   the result is the top most item on the stack.
#
#   You will construct an algorithm that multiplies two unsigned words.
#   Data will be passed to this routine via a stack.
#   You will implement this stack via the stack pointer register sp(29).
#   At the start of the program you must initialize your stack to address 0xFFFC.
#

  org 0x0000  # address for code segment

setup:
  ori $29, $0, 0xFFFC   # initialize stack to required address
  ori $8, $0, 0x0002
  push $8
  ori $8, $0, 0x0005
  push $8
  ori $8, $0, 0x0004
  push $8
  ori $8, $0, 0x0002
  push $8
  ori $8, $0, 0x0002
  push $8



  ori $4, $0, 0xFFF8    # until only 1 value remains
operation:
  beq $29, $4, finished  # see if stack pointer == 0xfff8
  jal parentMult
  j operation

finished:
  pop  $1
  push $1
  halt




# ------------------------ multiplication below -------------------------- #
#                      uses temp registers 8,9,10,11                       #
# ------------------------------------------------------------------------ #
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

