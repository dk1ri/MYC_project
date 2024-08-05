' additional configs
'20210722
'
Relais Alias PortB.1
Config Relais = Output
Portd.3 = 1
' ir_myc in the circuit diagram
Rel_amp Alias Pind.3:
Config Rel_amp = Input
Set Portd.3
Wdat Alias Portd.5
Config Wdat = Output
Fqud Alias Portd.7
Config Fqud = Output
Wclk Alias Portd.6
Config Wclk = Output
'
Enable Interrupts
Config PinB.0 = Input
Set PortB.0
Config Rc5 = Pinb.0, Wait = 2000
Config ADC = Single, Prescaler = AUTO, Reference = AVCC
'
Acsr.acd = 0 ' switch off analog comparator