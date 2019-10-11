' additional configs
'190816 for board V04.0only!!!
'
Fet7 Alias PortC.0
Fet6 Alias PortC.1  
Fet5 Alias PortC.2
Fet4 Alias PortC.3
Fet3 Alias PortD.2
Fet2 Alias PortD.3
Fet1 Alias PortD.4
Ldac Alias PortD.5
Led Alias PortB.1
Gon Alias PortB.0     
Config Fet1 = Output
Set Fet1
Config Fet2 = Output
Set Fet2
Config Fet3 = Output
Set Fet3
Config Fet4 = Output
Set Fet4
Config Fet5 = Output
Set Fet5
Config Fet6 = Output
Set Fet6
Config Fet7 = Output
Set Fet7
Config Ldac = Output
Set Ldac
Config Led = Output
Set Led
'
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = High, Phase = 1, Clockrate = 4, Noss = 0
Spiinit
'
' Software I2C is default, pin definition required:
Config SDA = PortD.6
Config SCL = PortD.7
Config Twi = 100000
I2cinit
'
' Timer1 (16bit) to indicate that a conversion of ADC is done
' Timerfrequency: 19,5kHz, 51us
Config Timer1 = Timer, Prescale = 1024