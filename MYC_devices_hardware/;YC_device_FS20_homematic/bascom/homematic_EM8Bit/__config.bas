' additional configs
' 20230929

Str_ Alias Pinb.3
Config Str_ = Input
Set Portb.3
Stg_ Alias PinB.4
Config Stg_ = Input
Set PortB.4
Sts_ Alias PinD.2
Config Sts_ = Input
Set PortD.2
'
TA1 Alias PortC.6   'TA1
TA2 Alias PortC.5   'TA2
TA3 Alias PortC.4   'TA3
TA4 Alias PortC.3   'TA4
TA5 Alias PortC.2   'TA5
TA6 Alias PortD.7   'TA6
TA7 Alias PortD.6   'TA7
TA8 Alias PortD.5   'TA8
TA00 ALias PortC.7   'S
DU3 Alias Portd.4   'T
TA10 Alias PortD.3   'U
TA20 Alias PortB.6   'Z
'
Config Timer1 = Timer, Prescale = 1024
Stop Timer1