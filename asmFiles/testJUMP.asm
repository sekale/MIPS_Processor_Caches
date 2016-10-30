  # test J

  org 0x0000
  J label
  ori $1, $0, 0xaabb
  ori $1, $0, 0xaabb
  ori $1, $0, 0xaabb
  halt
prelabel:
  ori $3, $0, 0xfade
  sw  $3, 8($9)
  halt

label:
  ori $1, $0, 0xdead
  ori $2, $0, 0xbeef
  ori $9, $0, 0xF0
  sw  $1, 0($9)
  sw  $2, 4($9)
  j prelabel

