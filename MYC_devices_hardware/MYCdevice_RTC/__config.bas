' additional configs
' 190828
'
Config Spi = Hard, Interrupt = Off, Data Order = Msb, Master = Yes, Polarity = Low, Phase = 1, Clockrate = 64, Noss = 1
'20MHz / 64 = 312KHz ; max is 500KHz
Config PortB.2 = Output
'SS pin for SPI
Set portB.2