' additional configs
' 20200117

'
UCSR1B.3 = 0
UCSR1B.4 = 0
' Enable Driver IC (OE0 to OE7)( aktive low)
Oe0 Alias PortB.3
Config Oe0 = Output
Oe0 = 1
Oe1 Alias PortC.2
Config Oe1 = Output
Oe1= 1
Oe2 Alias PortC.3
Config Oe2 = Output
Oe2 = 1
Oe3 Alias PortC.4
Config Oe3 = Output
Oe3 = 1
Oe4 Alias PortC.5
Config Oe4 = Output
Oe4 = 1
Oe5 Alias PortC.6
Config Oe5 = Output
Oe5 = 1
Oe6 Alias PortC.7
Config Oe6 = Output
Oe6 = 1
Oe7 Alias PortB.2
Config Oe7 = Output
Oe7 = 1
'
' Copy data to Output:
Strb Alias Portd.6
Config Strb = Output
Reset Strb
'
' Clock for Shifting
Sclk Alias Portd.5
Config Sclk = Output
Reset Sclk
'
' Data in to 1st Driver (0)
Data_ Alias Portd.4
Config Data_ = Output
Reset Data_
'
' Fan
Cool Alias Portd.7
Config Cool = Output
Reset Cool
'
' Clear frequency counter
Clr_counter Alias PortB.0
Config Clr_counter = Output
Clr_counter = 1
'
' frequency counter  enabled
Cnt_enable Alias PinD.2
Config Cnt_enable = Input
Set Cnt_enable
'
'  frequency Count Input
Qc Alias PinB.1
Config Qc = Input
Qc = 1
'
' RS232 enable (no pullup required)
Read_enable Alias PortD.3
Config Read_enable = Output
Read_enable = 1
'
'
CONFIG ADC = single, PRESCALER = AUTO, REFERENCE = Avcc
'
' Used to measure frequency (gatetime) and others
' Input to timer after prescale: 14400Hz  (69,44 us)
Config Timer3 = Timer, Prescale = 1024
Tcnt3 = 0
Start Timer3
'
Config Timer1 = Counter , Edge = Falling
TCNT1 = 0
Start Timer1
'