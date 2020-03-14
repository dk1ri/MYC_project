' additional configs
' 190722
'
Config PortC.3 = Output
Pin_rx_enable Alias PortC.2
Config Com2 = 19200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 1
' Clockpol = 1 works
Open "Com2:" For Binary As #2