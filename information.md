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

## Zo ziet de framebuffer er uit:

```
0     1      2      3      4     5      6      7       <= Pixel nummer
12345612 34561234 56123456 12345612 34561234 56123456  <= RGBRGB
11111111 11111111 11111111 11111111 11111111 11111111  <= Gewoon 1-tjes ter referentie
0        1        2        3        4        5         <= Byte nummer
```

Oftewel: RGB waardes voor 2 pixels (6 bits) zijn allemaal achter geplakt, zodat we 2 bits per byte besparen in RAM, omdat die stink-atmega maar 2KB ram heeft en anders onze stack wordt overschreven door de framebuffer.


## Maskeer pixels logica
```
RGB = 0b00000111
Y >= 32, X and 0b0011 == 00   andi TMP, 0b00011111, andi TMP2, 0b11111111
Y >= 32, X and 0b0011 == 01   andi TMP, 0b11111100, andi TMP2, 0b01111111
Y >= 32, X and 0b0011 == 10   andi TMP, 0b11110001, andi TMP2, 0b11111111
Y >= 32, X and 0b0011 == 11   andi TMP, 0b11000111, andi TMP2, 0b11111111

RGB = 0b00111000
Y < 32, X and 0b0011 == 00   andi TMP, 0b11100011, andi TMP2, 0b11111111
Y < 32, X and 0b0011 == 01   andi TMP, 0b11111111, andi TMP2, 0b10001111
Y < 32, X and 0b0011 == 10   andi TMP, 0b11111110, andi TMP2, 0b00111111
Y < 32, X and 0b0011 == 11   andi TMP, 0b11111000, andi TMP2, 0b11111111
```
