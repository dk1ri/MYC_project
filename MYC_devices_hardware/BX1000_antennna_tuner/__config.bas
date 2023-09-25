' additional configs
' 20230908

'
UCSR1B.3 = 0
UCSR1B.4 = 0
'
' Data in to 1st Driver (0)
Data_ Alias Portd.4
Config Data_ = Output
Reset Data_
'
' Fan
Cool Alias Portd.7
Config Cool = Output
Set Cool
'
' Clear frequency counter
Clr_counter Alias PortB.0
Config Clr_counter = Output
'
' frequency counter  enabled
' not used; ISR counts always. value is 0 if disabled _> not used
Cnt_enable Alias PinD.2
Config Cnt_enable = Input
Set Cnt_enable
'
'  frequency Count Input
Qc Alias PinB.1
Config Qc = Input
'Set Qc
'
' RS232 enable switch between read and write
Read_enable Alias PortD.3
Config Read_enable = Output
'read
Set Read_enable
'
'
CONFIG ADC = single, PRESCALER = AUTO, REFERENCE = Avcc
'
' 16 bit timer:used to initiate regular measurements
' Input to timer after prescale: 14400Hz  (69,44 us) (14,7456 MHz crystal)
Config Timer3 = Timer, Prescale = 1024
Tcnt3 = 0
Start Timer3
'
' 8 Bit Timer, used for gatetime of Timer1 (counter)
' Input to timer after prescale: 14400Hz  (69,44 us) (14,7456 MHz crystal)
' Gatetime is (256 - 9) * 69.44us = 17.151ms
Config Timer0 = Timer, Prescale = 1024
On Timer0 Frequency_isr
Enable INTERRUPTS
enable Timer0
TCnT0 = 9
Start Timer0
'
Config Timer1 = Counter , Edge = Falling
TCNT1 = 0
Reset Clr_counter
Set Clr_counter
Start Timer1
'