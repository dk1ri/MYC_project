' Config
' 20251207
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Watchdog_reset
Else
   Error_no = 255
End If
'
Config PinB.2 = Input
Pin_reset Alias PinB.2
Set PortC.2
'
' Config_mode set at each start
Config PinB.3 = Input
Mode_in Alias PinB.3
Set PortB.3
'
'Myc_mode = 1
Interface_transparent_active = 0
B_temp1 = InterfaceFU
If B_temp1 = 0 Then
   ' Wireless parameter is ignored -> always wireless
   If Mode_in = 1 Then
      ' transparent
     Interface_transparent_active = 1
   End If
End if
'
Config PortD.5 = Output
GPPS Alias PortD.5
Set GPPS
'
Config PortD.6 = Input
GFIX Alias PortD.6
Set GFIX
'
Config PortD.7 = Output
GEN Alias PortD.7
Set GEN
'
Declare Sub Seri()
Enable URXC
On  URXC Seri, SAVEALL

Declare Sub Write_spi(Byval Spi_len As Byte)
'
Declare Sub Read_spi(Byval B_temp1 As Byte)
'
Config Watchdog = 2048
Enable Interrupts
'
#IF Use_i2c = 1
   Declare Sub I2c()
   Enable TWI
   On TWI I2c
   #IF Processor = "8"
      Pin_sda Alias PinC.4
      Pin_scl Alias PinC.5
   #ELSEIF  Processor = "4"
      Pin_sda Alias PinC.1
      Pin_scl Alias PinC.0
   #ENDIF
#ENDIF
'
#IF Use_wireless = 1
   CONFIG SPI = HARD, INTERRUPT = OFF, DATA_ORDER = MSB , MASTER = YES , POLARITY = LOW , PHASE = 0 , CLOCKRATE = 128 , NOSS=1
   spiinit
'
   Config PortA.0 = Output
   B_mod Alias PortA.0
   Set B_mod
'
   Config PinB.1 = Input
   INT_G0 Alias PortB.1
   Set INT_G0
'
   Config PortB.4 = Output
   SCS Alias PortB.4
   Reset SCS
'
   Config PortC.7 = Output
   Reset_Ce Alias PortC.7
   Set Reset_ce
'
#ENDIF
'
'additional config
$include "__config.bas"