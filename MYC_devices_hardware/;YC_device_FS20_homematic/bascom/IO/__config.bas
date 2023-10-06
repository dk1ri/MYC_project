' additional configs
' 20231002
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'Definitions are different to the other homematic modules!
'reason: Cs for the PWM Output!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
' Modul output
'Ta1 - Ta8 in the circuit diagramm  (inputs)
' default input (off -> high) modul has pullup
' set to output  if low
Out1 Alias Portc.6
Out2 Alias Portc.5
Out3 Alias portc.4
Out4 Alias Portc.3
Out5 Alias Portc.2
Out6 Alias Portd.7
Out7 Alias portd.6
Out8 Alias Portd.5
'
' Modul Input;
' Out1 - Out8 in the circuit diagramm
Analog1 Alias Pina.0
Config Analog1 = Output
Analog2 Alias Pina.1
Config Analog2 = Output
Analog3 Alias Pina.2
Config Analog3 = Output
Analog4 Alias Pina.3
Config Analog4 = Output
Digital1 Alias Pina.4
Config Digital1 = Output
Digital2 Alias Pina.5
Config Digital2 = Output
Digital3 Alias Pina.6
Config Digital3 = Output
Digital4 Alias Pina.7
Config Digital4 = Output
PortA = 0
' other modul pins are connected to GND -> processor as input ok
'
Config Timer1 = Timer, Prescale = 1024
Stop Timer1
'
' Timer3 for PWM
' Timer tic is 25us (Prescale 512)
' All outputs should be resetted after 1024 tics: 26ms -> 38Hz
' -> resolution 8Bit
Config Timer3 = Timer, Prescale = 256
Start Timer3