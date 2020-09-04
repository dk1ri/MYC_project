' additional configs
' 200200808
'
' Modul Input
'INA - INH in the circuit diagramm
Ta1 Alias PortA.0
Config Ta1 = Output
Ta2 Alias PortA.1
Config Ta2 = Output
Ta3 Alias portA.2
Config Ta3 = Output
Ta4 Alias PortA.3
Config Ta4 = Output
Ta5 Alias PortA.4
Config Ta5 = Output
Ta6 Alias PortA.5
Config Ta6 = Output
Ta7 Alias portA.6
Config Ta7 = Output
Ta8 Alias PortA.7
Config Ta8 = Output
PortA = &HFF
'
' Modul Output; Input with Pullup
' 1 - 8 in the circuit diagramm
Out1 Alias Pinc.7
Config Out1 = Input
Out1 = 1
Out2 Alias Pinc.6
Config Out2 = Input
Out2 = 1
Out3 Alias Pinc.5
Config Out3 = Input
Out3 = 1
Out4 Alias PinC.4
Config Out4 = Input
Out4 = 1
Out5 Alias Pinc.3
Config Out5 = Input
Out5 = 1
Out6 Alias PinC.2
Config Out6 = Input
Out6 = 1
Out7 Alias Pind.7
Config Out7 = Input
Out7 = 1
Out8 Alias Pind.6
Config Out8 = Input
Out8 = 1
'
Str_ Alias PinD.2
Config Str_ = Input
Stg_ Alias PinD.3
Config Stg_ = Input
Sts_ Alias PinD.4
Config Sts_ = Input
'
S_ Alias PortB.7
Sp_ Alias PinB.7
T_ Alias PortB.6
Tp_ Alias PinB.6
U_ Alias PortB.5
Up_ Alias PinB.5
V_ Alias PortB.3
Vp_ Alias PinB.3
W_ Alias PortB.2
Wp_ Alias PinB.2
X_ Alias PortB.1
Xp_ Alias PinB.1
Y_ Alias PortB.0
Yp_ Alias PinB.0
Z_ Alias PortD.5
Zp_ Alias PinD.5
'
Config Timer1 = Timer, Prescale = 1024
Stop Timer1
Timer1 = 0