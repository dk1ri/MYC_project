' Loop start
' 20251207
'
Loop_:
Start Watchdog
' each Loop must be less than 2s
'
' timeout
Incr Timeout_J
If Timeout_J = 100 Then
   Incr Timeout_I
   Select Case Timeout_I
#IF Use_i2c = 1
      Case 180
         If I2c_activ = 1 And Pin_sda = 0 Then
            Incr Watch_twi
            If  Watch_twi > I2c_watchdog Then Gosub Reset_i2c
         Else
            Watch_twi = 0
         End If
#ENDIF
      Case 255
         'commands are expected as a string arriving in short time.
         'this watchdog assures, that a wrong commands will be deleted
         'commandbuffers is reset
         If Cmd_watchdog > 0 Then
            Incr Cmd_watchdog
         End If
         If Cmd_watchdog > Cmd_watchdog_time Then
            Command_watchdog
            Gosub Command_received
            ' start again
            Commandpointer = 0
            Old_commandpointer = 0
         End If
    End Select
End If
'
' additional time dependent conditions
'
$include "__time.bas"
'
B_temp1 = InterfaceFU
If B_temp1 = 1 Then
   ' for FU only!
   If Radio_type > 0 Then
      Select Case Radio_type
         Case 1
            Gosub RFM95_receive0
         Case 4
            Gosub nRF24_receive4
      End Select
   End If
End If