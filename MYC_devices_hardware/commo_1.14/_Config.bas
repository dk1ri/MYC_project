' blw, Config
' 20250601
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Watchdog_reset
Else
   Error_no = 255
End If
'
CONFIG SPI = HARD, INTERRUPT = OFF, DATA_ORDER = MSB , MASTER = YES , POLARITY = LOW , PHASE = 0 , CLOCKRATE = 128 , NOSS=0
spiinit
'
Config PinB.2 = Input
Pin_reset Alias PinB.2
Set PortC.2
'
' Wireless reset:
Config PortC.7 = Output
Reset_w Alias PortC.7
Set Reset_w
Config PinB.1 = Input
X1 Alias PinB.1
Set PortB.1
Config PinB.3 = Input
Mode_in Alias PinB.3
Set PortB.3
'
#IF Processor = "8"
Pin_sda Alias PinC.4
Pin_scl Alias PinC.5
#ELSEIF  Processor = "4"
Pin_sda Alias PinC.1
Pin_scl Alias PinC.0
#ENDIF
'
Config Watchdog = 2048
Enable Interrupts
'
Declare Sub Seri()
Enable URXC
On  URXC Seri, SAVEALL
'
#IF Use_i2c = 1
Declare Sub I2c()
Enable TWI
On TWI I2c
#ENDIF
'
'additional config
$include "__config.bas"