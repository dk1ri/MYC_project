' additional configs
'20240102
'
CS1 Alias PortD.5
Config CS1 = Output
CLK1 Alias PortD.6
Config CLK1 = Output
MISO1 Alias PinD.7
Config MISO1 = Input
CS2 Alias PortD.2
Config CS2 = Output
CLK2 Alias PortD.3
Config CLK2 = Output
MISO2 Alias PinD.4
Config MISO2 = Input
PORTD = &HFF
Reset CLK1
Reset CLK2
Config Adc = Single , Prescaler = Auto , Reference = Internal