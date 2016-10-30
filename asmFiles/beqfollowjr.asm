  # test beq followed by jr

  org 0x0000
  ori $1, $zero, 0xD269   // define address to 0xC0
  ori $2,  $zero, 0x37F1

  ori $21, $zero, 0x80
  ori $22, $zero, 0xF0

  or $3, $1, $2 #$3 = 0xf7f9
  and $4, $3, $2 #register dependency $3

  sw $4, 0($21)
  sw $3, 0($22) 

  lui $3, 0xFC00 #3 is loaded with halt instruction

  beq $3, $3, newbranch #equal should go to newbranch
  jr $3 #this one should be skipped that is halt



  newbranch:

  add $4, $3, $2 #$4 gets new value which is FC00 + 37F1
  sw $4, 4($21) #if value of 4 update is reflect then success
  halt


