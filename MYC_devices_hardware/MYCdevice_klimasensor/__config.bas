' additional configs
'191012
'
Config PortB.2 = Output
Spi_cs Alias PortB.2
Config Spi = Hard, Interrupt = Off, Data Order = Msb, Master = Yes, Polarity = High, Phase = 1, Clockrate = 4, Noss = 1
Spiinit