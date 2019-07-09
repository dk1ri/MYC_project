' blw, Config
'1.7.0, 190607
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
        Reset__ Alias PinB.2
        Pin_sda Alias PinC.4
        Pin_scl Alias PinC.5
        Port_sda Alias PortC.4
        Port_scl Alias PortC.5
#ELSEIF  Processor = "4"
        Config PinB.4 = Input
        Reset__ Alias PinB.4
        Pin_sda Alias PinC.1
        Pin_scl Alias PinC.0
        Port_sda Alias PortC.1
        Port_scl Alias PortC.0
#ELSEIF  Processor = "A"
        Config PinB.1 = Input
        Reset__ Alias PinB.1
        Pin_sda Alias PinC.1
        Pin_scl Alias PinC.0
        Port_sda Alias PortC.1
        Port_scl Alias PortC.0
#ENDIF
Set Reset__
Config Watchdog = 2048
'
'additional config
$include "__config.bas"