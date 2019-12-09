;
; HUB75 DRIVER
; draw pixels to register with setPixel
; draw a frame with drawFrame
;

.dseg ; Start data segment
frameBuffer: .BYTE 64 * 32

.cseg ; Start code segment

.equ CLK = 1
.equ LATCH = 0
.equ OE = 5

.def TMP1 = r16
.def TMP2 = r22
.def RGB = r17
.def LINE = r18
.def COUNTER = r19
.def POSX = r20
.def POSY = r21

; initialize all ports and clear the buffer
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
  ret

; ALL CODE RELATED TO THE FRAME BUFFER

; loop through the frame buffer and clear every pixel
clearFrameBuffer:
  ; set Z to the start of the frame buffer
  ldi ZH, high(frameBuffer)
  ldi ZL, low(frameBuffer)
  ; set TMP1 to 0x00
  clr TMP1
  ; set X to the length of the frame buffer
  ldi XH, high(64 * 32 - 1)
  ldi XL, low(64 * 32 - 1)
clearBufferLoop:
  ; store of TMP1 to the buffer at Z then increment
  st Z+, TMP1
  ; subtract one from X
  sbiw X, 1
  ; loop while X is bigger than 0
  brne clearBufferLoop
  ret

; draw a frame
drawFrame:
  ; grab start address of buffer -> word
  ldi ZH, high(frameBuffer)
  ldi ZL, low(frameBuffer)
  ldi LINE, 0
next_line:
  ldi COUNTER, 64
next_pixel:
  ld RGB, Z+
  call writeOneRGBPixel
  dec COUNTER
  brne next_pixel
  call outputPixelsToLine
  inc LINE
  cpi LINE, 31
  brne next_line
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

outputPixelsToLine:
  push LINE
  sbi PORTB, OE
  lsl LINE
  andi LINE, 0b00111110
  sbr LINE, 1 ; latch on
  out PORTC, LINE
  cbi PORTC, LATCH ; latch off
  cbi PORTB, OE
  pop LINE
  ret

; set a pixel in the frame buffer to RGB
; POSY => Y Position
; POSX => X Position
; RGB => 0x00000BGR
setPixel:
  push POSY
  push POSX
  push RGB

  cpi POSY, 32
  brlo colorBufferAddr
  subi POSY, 32
  lsl RGB
  lsl RGB
  lsl RGB
colorBufferAddr:
  ldi TMP1, 64
  mul POSY, TMP1
  movw Z, r0
  add ZL, POSX
  brcc colorToBuffer
  inc ZH
colorToBuffer:
  ldi TMP1, low(frameBuffer)
  ldi TMP2, high(frameBuffer)
  add ZL, TMP1
  adc ZH, TMP2
  ld TMP1, Z
  or TMP1, RGB
  st Z, TMP1

  pop RGB
  pop POSX
  pop POSY

  ret

; ALL CODE RELATED TO THE DRAWING OF THE BUFFER
