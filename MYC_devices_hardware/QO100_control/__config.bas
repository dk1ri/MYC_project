' additional configs
'202230914

' outputs are set by init_micro
'
' external Temp Sensor (analog Innput)
Temp Alias PinA.0
'
R Alias PinA.1
'
F Alias PinA.2
'
K_Err Alias Pina.3
Config K_err = Input
Set PortA.3
'
' swr of 28V PA (analog Input)
Swr Alias Pina.4
'
'PA1.1
PA1_1 Alias Pina.5
Config PA1_1 = Input
Set PortA.5
'
'PA2.1
PA2_1 Alias Pina.7
Config PA2_1 = Input
Set PortA.7
'
T Alias Pinb.1
Config T = Input
Set Portb.1
'
Led Alias Portc.1
'
Ptt_pin Alias PinC.6
Config Ptt_pin = Input
Set PortC.6
'
NB_WB_pin Alias PinC.7
Config NB_WB_pin = Input
Set PortC.7
'
Config Adc = Single , Prescaler = Auto , Reference = AVCC

' Timerfrequency: 19,5kHz, 51us
Config Timer1 = Timer, Prescale = 1024
Enable Interrupts
Enable Timer1
Declare Sub Timer1_int()
On Timer1 Timer1_int
'
Config Timer3 = Timer, Prescale = 1024
Enable Timer3
Declare Sub Switch_upconverter_on_serial()
On Timer3 Switch_upconverter_on_serial saveall

' Com2 must be a hardware UART!
' Other than document<tion (old) new firmware has 19200 as Baudrate
Config Com2 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Open "Com2:" For Binary As #2