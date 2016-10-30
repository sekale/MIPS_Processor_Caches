  org   0x0000
  ori   $1,$zero,0xF0
  ori   $2,$zero,0x80
  ori   $4,$zero,0x09

  sw    $4,0($2)

  # lw - sw without dep
  lw    $2, 0($1)
  sw    $1, 24($1)

  # lw - sw with dep
  lw    $2, 0($1)
  sw    $1, 4($2)

  # lw - R without dep
  lw    $2, 4($1)
  sub   $5, $4, $0

  # lw - R with dep
  lw    $2, 4($1)
  sub   $6, $2, $4

  # store values
  sw    $5, 8($2)
  sw    $6, 12($2)

  halt      # that's all

