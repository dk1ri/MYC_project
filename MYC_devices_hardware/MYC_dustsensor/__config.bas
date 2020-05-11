' additional configs
' 20200315
'
Config Com2 = 115200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
'
Open "Com2:" For Binary As #2

Config Timer1 = Timer, Prescale = 1024
'3,36s
Enable Interrupts
Enable Timer1
'
Declare Sub Seri2()
Enable URXC1
On  URXC1 Seri2, SAVEALL
'
Start Timer1
On Timer1 Timer_interrupt