  # test jr followed by beq

  org 0x0000
  ori $1, $zero, 0xD269   // define address to 0xC0
  ori $2,  $zero, 0x37F1

  ori $21, $zero, 0x80
  ori $22, $zero, 0xF0

  or $3, $1, $2 #$3 = 0xf7f9
  and $4, $3, $2 #register dependency $3

  sw $4, 0($21)
  sw $3, 0($22)

  ori $3, $zero, halt_instr
  #ori $5, $zero, 0xFC00
  #sw $5 ,0($3) #mem location $3 has address 37f1 which has instruction fc00 which is accomplished using this sw operation

  jr $3 #this one should be loaded in PC to halt
  beq $3, $3, newbranch #this should not happen ideally

  newbranch:

  add $4, $3, $2 #$4 gets new value which is FC00 + 37F1
  sw $4, 4($21) #if value of 4 update is reflect then fail

halt_instr:
  halt
