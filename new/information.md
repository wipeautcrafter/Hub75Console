# general information
## registers
#### general purpose
The registers `r13` up until `r25` are general purpose: use them for anything
#### output ports
The output ports are divided into 3 tables:
<br>For data direction `DDRB` `DDRC` `DDRD`
<br>For port in/outputs `PORTB` `PORTC` `PORTD`

| Bit | PORTB | PORTC | PORTD |
|:---:|:-----:|:-----:|:-----:|
|**0**| (^)   | LAT   |       |
|**1**| (V)   | A     | CLK   |
|**2**| (<)   | B     | R1    |
|**3**| (>)   | C     | G1    |
|**4**| (A)   | D     | B1    |
|**5**| OE    | E     | R2    |
|**6**|       |       | G2    |
|**7**|       |       | B2    |
