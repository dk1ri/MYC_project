' additional configs
'202240806

' outputs are set by init_micro
'
' PinA0: external Temp Sensor (analog Innput)
'
''PinA.1  reflected (analog)input)
'
'  PinA.2    forward (analog Input)
'
' error Signal for Kuhne Upconverter
K_err Alias Pina.3
Config K_err = Input
Set K_err
'
' Pin A.4 swr of 28V PA (analog Input)
'
' PA1  general purpose in
PA1_ Alias Pina.5
Config PA1_ = Input
Set PA1_
'
'PA2.2  general purpose  in
PA2_2 Alias Pina.6
Config PA2_2 = Input
Set PA2_2
'
' PA2.1 general purpose
PA2_1 Alias Pina.7
Config PA2_1 = Input
Set PA2_1
'
'12V_DATV PortB.0  output
'
'T
T Alias Pinb.1
Config T = Input
Set T
'
'1WPA2 PinB.2  output
'
'BiasT PortB.3  output
'
'PlutoWB PortC.0 output
'
'LED_ PortC.1 output
'
'1WPA1 PortC.2  output
'
'Relais PortC.3   output
'
'13cmPA_PTT PortC.4
'
'Ptt_out_ PinC.5 output
'
'Ptt_in
Ptt_in Alias PinC.6
Config Ptt_in = Input
Set PortC.6
'
'NB_WB_in
NB_WB_IN Alias PinC.7
Config NB_WB_in = Input
Set PortC.7
'
'Minitiouner PortD.5
'
'Upcon PortD.6
'
'Fan PortD.7
'
Config Adc = Single , Prescaler = Auto , Reference = AVCC

' Timerfrequency: 19,5kHz, 51us
' used for LED
Config Timer1 = Timer, Prescale = 1024
Enable Interrupts
Enable Timer1
Declare Sub Timer1_int()
On Timer1 Timer1_int
'
' serial timeout
Config Timer3 = Timer, Prescale = 1024
Enable Timer3
Declare Sub Check_serial_timeout()
On Timer3 Check_serial_timeout
Stop Timer3

' Com2 must be a hardware UART!
' Other than documentation (old) new firmware has 19200 as Baudrate
Config Com2 = 9600 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Open "Com2:" For Binary As #2