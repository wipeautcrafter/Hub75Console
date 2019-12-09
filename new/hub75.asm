.dseg ; data segment
frameBuffer: .BYTE 48 * 32

.cseg ; code segment
.equ OE = 5 ; B
.equ LATCH = 0 ; C
.equ CLK = 1 ; D

.def TMP = r13
.def TMP2 = r14
.def TMP3 = r15
.def RGB = r16
.def POSX = r17
.def POSY = r18

initialize:
  ser TMP
  out DDRB, r16
  out DDRC, r16
  out DDRD, r16
  clr TMP
  out PORTB, r16
  out PORTC, r16
  out PORTD, r16
  ret

; RELATED TO FRAME BUFFER

clearFrameBuffer:
  ldi ZH, high(frameBuffer)
  ldi ZL, low(frameBuffer)
  clr TMP
  ldi XH, high(48 * 32 - 1)
  ldi XL, low(48 * 32 - 1)
clearBufferLoop:
  st Z+, TMP
  brne clearBufferLoop
  ret

; 0b00RGBRGB
;     222111
setPixel:
  push POSX
  push POSY
  push RGB

  cpi POSY, 32
  brlo calcBufferOffset
  subi POSY, 32
  lsl RGB
  lsl RGB
  lsl RGB
calcBufferOffset:
  ldi ZL, low(frameBuffer)
  ldi ZH, high(frameBuffer)

  ; calculate offset: (y * 48) + ((x * 6) >> 3)
  ldi TMP, 48
  mul TMP, POSY
  movw Y, r0
  ldi TMP, 6
  mul TMP, POSX
  movw, X, r0
  lsl XH
  lsl XH
  lsl XH
  lsl XH
  lsl XH
  lsr XL
  lsr XL
  lsr XL
  or XL, XH
  add YL, XL
  adc YH, XH
calcBufferPos:
  ; grab bytes from buffer (memory)
  ld TMP, X+
  ld TMP2, X

  andi POSX, 0b0011

  cpi POSX, 0b0011
  breq bufferPosOcc4
  cpi POSX, 0b0010
  breq bufferPosOcc3
  cpi POSX, 0b0001
  breq bufferPosOcc2
bufferPosOcc1:
  andi TMP, 0b00000011
  lsl RGB
  lsl RGB
  or TMP, RGB
  rjmp writeToBuffer
bufferPosOcc2:
  andi TMP, 0b11111100
  andi TMP2, 0b00001111
  mov TMP3, RGB
  lsl RGB
  lsl RGB
  lsl RGB
  lsl RGB
  lsr TMP3
  lsr TMP3
  lsr TMP3
  lsr TMP3
  or TMP2, RGB
  or TMP, TMP3
  rjmp writeToBuffer
bufferPosOcc3:
andi TMP, 0b11110000
andi TMP2, 0b00111111
mov TMP3, RGB
lsr RGB
lsr RGB
lsl TMP3
lsl TMP3
lsl TMP3
lsl TMP3
lsl TMP3
lsl TMP3
or TMP, RGB
or TMP, TMP3
rjmp writeToBuffer
bufferPosOcc4:

writeToBuffer:
  st TMP2, X-
  st TMP, X

  pop RGB
  pop POSY
  pop POSX
  ret

; RELATED TO DRAWING TO SCREEN
