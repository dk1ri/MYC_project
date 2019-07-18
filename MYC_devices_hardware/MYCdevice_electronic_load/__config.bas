' additional configs
'190611
'
Gon Alias PortD.5    
Config PortC.4 = Output
Fet1 Alias PortC.4
Set Fet1
Config PortC.7 = Output
Fet2 Alias PortC.7
Set Fet2
Config PortC.5 = Output
Fet3 Alias PortC.5
Set Fet3
Config PortC.6 = Output
Fet4 Alias PortC.6
Set Fet4
Config PortC.2 = Output
Fet5 Alias PortC.2
Set Fet5
Config PortC.3 = Output
Fet6 Alias PortC.3
Set Fet6
Config PortD.7 = Output
Fet7 Alias PortD.7
Set Fet7
Config PortD.6 = Output
LDAC Alias PortD.6
Set Ldac
Config PortB.0 = Output
Led Alias PortB.0
Set Led
Config PortD.4 = Output
'
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = High, Phase = 1, Clockrate = 4, Noss = 0
Spiinit
'
Config Adc = Single , Prescaler = Auto , Reference = Internal_2.56
Start ADC
'must, will not work without start
'