.dseg ; data segment
frameBuffer: .BYTE 48 * 32

.cseg ; code segment
.equ OE = 5 ; B
.equ LATCH = 0 ; C
.equ CLK = 1 ; D

.def TMP = r16
.def TMP2 = r17
.def TMP3 = r18
.def TMP4 = r19
.def RGB = r20
.def POSX = r21
.def POSY = r22

initialize:
  ser TMP
  out DDRB, TMP
  out DDRC, TMP
  out DDRD, TMP
  clr TMP
  out PORTB, TMP
  out PORTC, TMP
  out PORTD, TMP
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
  sbiw X, 1
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
  movw X, r0
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
  add ZL, YL
  adc ZH, YH

  ld TMP, Z+
  ld TMP2, Z

  andi POSX, 0b0011

  cpi POSX, 0b0011
  breq bufferPosOcc4
  cpi POSX, 0b0010
  breq bufferPosOcc3
  cpi POSX, 0b0001
  breq bufferPosOcc2
bufferPosOcc1:
  ;andi TMP, 0b00000011
  lsl RGB
  lsl RGB
  or TMP, RGB
  rjmp writeToBuffer
bufferPosOcc2:
  ;andi TMP, 0b11111100
  ;andi TMP2, 0b00001111
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
  ;andi TMP, 0b11110000
  ;andi TMP2, 0b00111111
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
  or TMP2, TMP3
  rjmp writeToBuffer
bufferPosOcc4:
  ;andi TMP, 0b11000000
  or TMP, RGB
  rjmp writeToBuffer
writeToBuffer:
  st Z, TMP2
  st -Z, TMP
  pop RGB
  pop POSY
  pop POSX
  ret

; RELATED TO DRAWING TO SCREEN

drawFrame:
  ldi ZH, high(frameBuffer)
  ldi ZL, low(frameBuffer)
  clr POSY
drawFrameLine:
  clr POSX
drawFramePixels:
  ; 11111122 22223333
  ld RGB, Z+
  mov TMP, RGB
  lsr RGB
  lsr RGB
  call writeOneRGBPixel
  ; 11111122 22223333
  ; TMP      RGB
  ld RGB, Z+
  mov TMP2, RGB
  lsl TMP
  lsl TMP
  lsl TMP
  lsl TMP
  lsr RGB
  lsr RGB
  lsr RGB
  lsr RGB
  or RGB, TMP
  call writeOneRGBPixel
  ; 22223333 33444444
  ; TMP2     RGB
  ld RGB, Z+
  mov TMP, RGB
  lsl TMP2
  lsl TMP2
  lsr RGB
  lsr RGB
  lsr RGB
  lsr RGB
  lsr RGB
  lsr RGB
  or RGB, TMP2
  call writeOneRGBPixel
  ; 33444444 11111122
  mov RGB, TMP
  call writeOneRGBPixel
  ; next 4 pixels
  inc POSX
  cpi POSX, 16
  brne drawFramePixels
  ; clock in row
  call writeToRow
  inc POSY
  cpi POSY, 32
  brne drawFrameLine

writeToRow:
  push POSY
  sbi PORTB, OE
  lsl POSY
  andi POSY, 0b00111110
  sbr POSY, 1 ; latch on
  out PORTC, POSY
  cbi PORTC, LATCH ; latch off
  cbi PORTB, OE
  pop POSY
  ret

writeOneRGBPixel:
  push RGB
  lsl RGB
  lsl RGB
  sbr RGB, 2 ; Set CLK bit (PD1)
  out PORTD, RGB
  cbi PORTD, CLK ; set CLK bit off
  pop RGB
  ret
