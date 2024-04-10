' additional configs
'202240405

' outputs are set by init_micro
'
' external Temp Sensor (analog Innput)
Temp Alias PinA.0
'
R Alias PinA.1
'
F Alias PinA.2
'
T Alias Pina.3
Config T = Input
Set PortA.3
'
' swr of 28V PA (analog Input)
Swr Alias Pina.4
'
'PA1
PA1_ Alias Pina.5
Config PA1_ = Input
Set PortA.5
'
'PA2.2
PA2_2 Alias Pina.6
Config PA2_2 = Input
Set PortA.6
'
'PA2.1
PA2_1 Alias Pina.7
Config PA2_1 = Input
Set PortA.7
'
'12V_DATV PortB.0
'
'Kerr
Kerr Alias Pinb.1
Config Kerr = Input
Set Portb.1
'
'1WPA2 PinB.2
'
'BiasT PortB.3
'
'PlutoWB PortC.0
'
'LED_ PortC.1
'
'1WPA1 PortC.2
'
'Relais PortC.3
'
'13cmPA_PTT PortC.4
'
'Ptt_out_ PinC.5
'
'Ptt_in
Ptt_in Alias PinC.6
Config Ptt_in = Input
Set PortC.6
'
'NB_WB_in
NB_WB_IN Alias PinC.7
Config NB_WB_in = Input
' NB
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
' Other than document<tion (old) new firmware has 19200 as Baudrate
Config Com2 = 9600 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Open "Com2:" For Binary As #2