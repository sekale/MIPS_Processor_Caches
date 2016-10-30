  org   0x0000
  ori   $1,$zero,0xF0
  ori   $2,$zero,0x80
  ori   $3,$zero,0xF0
  ori   $4,$zero,0x0F

  ori   $5,$zero,0x0A
  ori   $6,$zero,0x0B
  ori   $7,$zero,0x0C
  ori   $8,$zero,0x0D
  ori   $9,$zero,0x0E
  ori   $10,$zero,0xF0
  ori   $11,$zero,0xF1


  lw    $2, 20($1)
  add   $4, $2, $5
  sw    $4, 4($1)
  or    $4, $4, $7
  sll   $9, $4, 5

  sw $2, 0($1)
  sw $4, 8($1)
  sw $9, 12($1)

  halt
