' Loop start
'1.7.0, 190512
'
Loop_:
Start Watchdog
'Loop must be less than 2s
'
' timeout
Incr J
If J = 255 Then
   Incr I
   Select Case I
      Case  90
         If Tx_time > 0 Then
            Incr Tx_time
            If Tx_time > Tx_timeout Then
               Gosub Reset_tx
               Tx_time_too_long
            End If
         End If
      Case 180
         If I2c_active = 1 And Pin_sda = 0 Then
            Incr Watch_twi
            If  Watch_twi > I2c_watchdog Then Gosub Reset_i2c
         Else
            Watch_twi = 0
         End If
      Case 255
         'commands are expected as a string arriving in short time.
         'this watchdog assures, that a wrong commands will be deleted
         'commandbuffers is reset
         If Cmd_watchdog > 0 Then Incr Cmd_watchdog
         If Cmd_watchdog > Cmd_watchdog_time Then
            Command_watchdog
            Gosub Command_received
         End If
    End Select
'
' additional time dependent conditions
'
$include "__time.bas"
'
End If