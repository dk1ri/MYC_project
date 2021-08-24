' additional configs
'20210722
'
Relais Alias PortB.1
Config Relais = Output
Portd.3 = 1
IR_Myc Alias Pind.3
Config IR_Myc = Input
Wdat Alias Portd.5
Config Wdat = Output
Fqud Alias Portd.7
Config Fqud = Output
Wclk Alias Portd.6
Config Wclk = Output
'
Config PinB.0 = Input
Set PortB.0
Config Rc5 = Pinb.0, Wait = 2000
Config Timer1 = Timer , Prescale = 1
Config ADC = Single, Prescaler = AUTO, Reference = AVCC
'
Acsr.acd = 0 ' switch off analog comparator