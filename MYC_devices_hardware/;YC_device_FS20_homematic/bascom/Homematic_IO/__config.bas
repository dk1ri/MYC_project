' additional configs
' 20200616
'
Config PortA.7 = Output
D1 Alias PortA.7
Config PortA.6 = Output
D2 Alias portA.6
Config PortA.5 = Output
D3 Alias PortA.5
Config PortA.4 = Output
D4 Alias PortA.4
Config PortA.3 = Output
Analog1 Alias PortA.3
Config PortA.2 = Output
Analog2 Alias PortA.2
Config PortA.1 = Output
Analog3 Alias PortA.1
Config PortA.0 = Output
Analog4 Alias PortA.0
PortA = 0
'
Sch1 Alias PinC.7
Config Sch1 = Input
Sch1 = 1
Sch2 Alias PinC.6
Config Sch2 = Input
Sch2 = 1
Sch3 Alias PinC.5
Config Sch2 = Input
Sch3 = 1
Sch4 Alias PinC.4
Config Sch4 = Input
Sch4 = 1
Sch5 Alias PinC.3
Config Sch5 = Input
Sch5 = 1
Sch6 Alias PinC.2
Config Sch6 = Input
Sch6 = 1
Sch7 Alias PinD.7
Config Sch7 = Input
Sch7 = 1
Sch8 Alias PinD.6
Config Sch8 = Input
Sch8 = 1
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
'
' Timer3 for PWM
' Timer tic is us (Prescale 512)
' All outputs should be resetted after 1024 tics: 13ms -> 20Hz
' -> resolution 10Bit
Config Timer3 = Timer, Prescale = 256
Start Timer3