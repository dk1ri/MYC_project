' additional configs
' 20250716
'
Config Int1 = Falling
Config Timer1 = Counter, Prescale = 8
'
Start Timer1
Declare Sub Read_time
On Int1 Read_time
Enable Interrupts
Enable Int1

Config PinD.3 = input
50Hz Alias PinD.3
Set PortD.3