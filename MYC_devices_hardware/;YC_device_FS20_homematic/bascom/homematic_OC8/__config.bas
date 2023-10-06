' additional configs
' 20231001
'
' Modul Input
'Ta1 - Ta8 in the circuit diagramm  (modul inputs)
Ta1 Alias Portc.6
Ta2 Alias Portc.5
Ta3 Alias portc.4
Ta4 Alias Portc.3
Ta5 Alias Portc.2
Ta6 Alias Portd.7
Ta7 Alias portd.6
Ta8 Alias Portd.5
'
' Modul Output; Input with Pullup
' OUT1 - OUT8 in the circuit diagramm
Out1 Alias Pina.0
Config Out1 = Input
Out2 Alias Pina.1
Config Out2 = Input
Out3 Alias Pina.2
Config Out3 = Input
Out4 Alias Pina.3
Config Out4 = Input
Out5 Alias Pina.4
Config Out5 = Input
Out6 Alias Pina.5
Config Out6 = Input
Out7 Alias Pina.6
Config Out7 = Input
Out8 Alias Pina.7
Config Out8 = Input
PortA = &HFF
' other modul pins are connected to GND -> processor as input ok
' except V -> pullup not necessary but better
PortB.7 = 1
'
' other connected pins are GND -> Inputs (default)
'
Config Timer1 = Timer, Prescale = 1024
Stop Timer1
Timer1 = 0