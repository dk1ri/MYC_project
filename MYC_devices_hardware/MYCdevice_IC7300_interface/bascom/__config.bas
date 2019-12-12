' additional configs
' 190722
'
print "Y"
Config PortC.3 = Output
Pin_rx_enable Alias PortC.2
Config Com2 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 1
' Clockpol = 1 works
'Hardware require activ clock high (N Chanal Fet in Com2 RX line) correct ? P chanal FET?
Open "Com2:" For Binary As #2
Declare Sub Seri()
Declare Sub I2c()
Enable Interrupts
'Enable URXC
Enable TWI
'On  URXC Seri, SAVEALL
On TWI I2c