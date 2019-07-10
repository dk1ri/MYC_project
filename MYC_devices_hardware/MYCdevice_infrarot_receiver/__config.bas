' additional configs
' 190610
'
DDRD.3 = 0
PortD.3 = 1
Config Timer1 = Timer, Prescale = 1
Config Rc5 = Pind.3 , Timer = 1 , Mode = background, Wait = 100
Enable Interrupts