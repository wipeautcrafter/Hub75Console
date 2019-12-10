jmp main

.include "hub75.asm"

main:
  ; set the stack pointer to the start of the stack
  ldi TMP, HIGH(RAMEND)
  out SPH, TMP
  ldi TMP, LOW(RAMEND)
  out SPL, TMP

  call initialize
  call clearFrameBuffer

  ldi POSY, 1
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
