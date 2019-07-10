' additional configs
'
Config  PORTB.1 = Output
Morse_pin Alias PortB.1
'
' Life LED:
Config Portd.2 = Output
Config Portd.3 = Output
Led3 Alias Portd.3
'life LED
Led4 Alias Portd.2
'on if cmd activ, off, when cmd finished