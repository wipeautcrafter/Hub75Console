jmp initialize

.include "sleep.asm"

.equ CLK = 1
.equ LATCH = 0
.equ OE = 5
.equ WHITE = 0b00111111

.def TMP1 = r16
.def RGB = r17
.def POSX = r20
.def POSY = r21

initialize:
  ; set all ports to output
  ser TMP1
  out DDRD, TMP1
  out DDRC, TMP1
  out DDRB, TMP1
  ; clear port output
  cbi PORTD, CLK
  cbi PORTC, LATCH
  cbi PORTB, OE

  ldi RGB, WHITE

grid:
  ldi POSY, 0
row:
  ldi POSX, 0
pixel:
  cbi PORTB, OE ; OE off
  ; clock in single pixel
  push RGB
  lsl RGB
  lsl RGB
  sbr RGB, 2 ; Set CLK bit (PD1)
  out PORTD, RGB
  cbi PORTD, CLK ; set CLK bit off
  pop RGB
  ; loop
  inc POSX
  cpi POSX, 63
  brne pixel
  ; draw line to POSY
  push POSY
  sbi PORTB, OE
  lsl POSY
  sbr POSY, 1 ; latch on
  out PORTC, POSY
  cbi PORTC, LATCH ; latch off
  pop POSY

  ldi TMP1, 5
  call delay

  ; loop
  inc POSY
  cpi POSY, 32
  brne row

  ; ldi r16, 3
  ; call delay

  rjmp grid
