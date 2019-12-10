jmp main

.include "hub75.asm"
.include "sleep.asm"

main:
  ; set the stack pointer to the start of the stack
  ldi TMP1, HIGH(RAMEND)
  out SPH, TMP1
  ldi TMP1, LOW(RAMEND)
  out SPL, TMP1

  call initialize
  call clearFrameBuffer

  ldi POSY, 0
  ldi POSX, 0

row:
  ldi RGB, 0b00000111
  call setPixel
  inc POSX
  cpi POSX, 64
  brne row
loop:
  call drawFrame
  jmp loop
