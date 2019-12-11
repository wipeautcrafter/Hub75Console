jmp main

.include "../hub75.asm"
.include "../sleep.asm"

main:
  ; set the stack pointer to the start of the stack
  ldi TMP, HIGH(RAMEND)
  out SPH, TMP
  ldi TMP, LOW(RAMEND)
  out SPL, TMP

  call initialize
  call clearFrameBuffer
leinit:
  ldi TMP4, 3
grid:
  clr POSY
row:
  clr POSX
col:
  ldi RGB, 0b00000010
  call setPixel
  inc POSX
  cp POSX, TMP4
  brne col
  inc POSY
  cp POSY, TMP4
  brne row
loop:
  call drawFrame
  inc TMP4
  cpi TMP4, 64
  brne grid
  call clearFrameBuffer
  rjmp leinit
