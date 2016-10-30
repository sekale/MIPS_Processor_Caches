  org 0x0000
  ori $31, $0, 0x001C
  ori $2, $0, 0x00ba
  ori $3, $0, 0x00F0
  ori $4, $0, 0x00ba
  JR $31
  sw $2, 0($3)
  ori $6, $0, 0x00ba
  ori $7, $0, 0x00ba # JR comes here
  halt
