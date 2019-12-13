jmp main

.include "../graph/hub75.asm"
.include "../lib/sleep.asm"

main:
  ; set the stack pointer to the start of the stack
  ldi TMP, HIGH(RAMEND)
  out SPH, TMP
  ldi TMP, LOW(RAMEND)
  out SPL, TMP

  call initialize

  ldi RGB, 0b00000011
loop:
  clr POSY
ytjes:
  clr POSX
  call clearFrameBuffer
xjes:
  call setPixel
  inc POSX
  cpi POSX, 64
  brne xjes
  call drawFrame
  inc POSY
  cpi POSY, 64
  brne ytjes
  rjmp loop
