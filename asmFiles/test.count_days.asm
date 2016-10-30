#
#   Lab 2 : Calculate Days
#   ------------------------
#
#   Program to roughly calculate the number of days since the year 2000.
#   Use your multiply sub routine in this program for the following equation.
#
#   Days = CurrentDay + (30 * (CurrentMonth -1)) + 365 * (CurrentYear - 2000).
#
#   Variables
#   CurrentDay={1..31}.
#   CurrentMonth={1..12}.
#   CurrentYear is the year with all four digits.
#

  org 0x0000  # address for code segment

setup:
  ori $29,$0, 0xFFFC    # initialize stack pointer
  ori $2, $0, 0x0006    # current day (20th)
  ori $3, $0, 0x0001    # current month (Jan)
  ori $4, $0, 0x07E0    # current year (2016)

process:
  or $5, $0, $2         # result is set value of current day

  ori $1, $0, 0x0001    # $1 <- 1
  subu $3, $3, $1       # decrement current month by 1

  ori $1, $0, 0x07D0    # $1 <- 2000
  subu $4, $4, $1       # decrement current year by 2000

  ori $1, $0, 0x001E    # set register 1 to 30
  push $1
  push $3
  jal parentMult        # multiply: 30 * $3(currentMonth)
  pop $3

  ori $1, $0, 0x016D    # set register 1 to 365
  push $1
  push $4
  jal parentMult        # multiply: 365 * $4(currentYear)
  pop $4

  add $5, $5, $3
  add $5, $5, $4

  push $5
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

