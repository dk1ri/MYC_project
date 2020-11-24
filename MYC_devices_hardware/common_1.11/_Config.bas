' blw, Config
' 20200730
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Watchdog_reset
Else
   Error_no = 255
End If
'
#IF Processor = "8"
Config PinB.2 = Input
Pin_reset Alias PinB.2
Port_reset Alias PortB.2
Pin_sda Alias PinC.4
Pin_scl Alias PinC.5
Port_sda Alias PortC.4
Port_scl Alias PortC.5
#ELSEIF  Processor = "4"
Config PinB.2 = Input
Pin_reset Alias PinB.4
Port_reset Alias PortB.4
Pin_sda Alias PinC.1
Pin_scl Alias PinC.0
Port_sda Alias PortC.1
Port_scl Alias PortC.0
#ENDIF
Set Port_reset
Config Watchdog = 2048
Enable Interrupts
#If Use_seri = 1
Declare Sub Seri()
Enable URXC
On  URXC Seri, SAVEALL
#ENDIF
#IF Use_i2c = 1
Declare Sub I2c()  
Enable TWI
On TWI I2c
#ENDIF
'
'additional config
$include "__config.bas"