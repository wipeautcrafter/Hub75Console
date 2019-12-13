; delay with r23 as parameter

.def TIMEOUT = r23

delay:
  push r24
  push r25
  clr r24
  clr r25
wait_1:
  adiw r25:r24, 1
  brne wait_1
  dec TIMEOUT
  brne delay
  pop r25
  pop r24
  ret
