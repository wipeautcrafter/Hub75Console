; delay with r16 as parameter
delay:
  push r24
  push r25
  clr r24
  clr r25
wait_1:
  adiw r25:r24, 1
  push r16
  call drawFrame
  pop r16
  brne wait_1
  dec r16
  brne delay
  pop r25
  pop r24
  ret
