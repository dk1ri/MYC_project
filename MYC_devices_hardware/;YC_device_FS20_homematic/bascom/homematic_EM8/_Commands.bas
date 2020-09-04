' commands
' 20200810
'
01:
   If Commandpointer >= 3 Then
      If Kanal_mode = 0 Then
         If Command_b(2) < 4 And Command_b(3) < 2 Then
            Switch = Command_b(2) * 2
            ' 0 2 4 6 (off)
            If Command_b(3) = 1  Then Incr Switch
            ' 1 3 5 7 -> on
            Incr Switch
            K = T_short
            Gosub Switch_on
         Else
            Parameter_error
         End If
      Else
         Command_not_found
      End If
      Gosub Command_received
   End If
Return
'
02:
   If Commandpointer >= 2 Then
      If Kanal_mode = 1 Then
         If Command_b(2) < 9 Then
            Switch = Command_b(2)
            K = T_short
            Gosub Switch_on
         Else
            Parameter_error
         End If
      Else
         Command_not_found
      End If
      Gosub Command_received
   End If
Return
'
03:
   If Commandpointer >= 2 Then
      If Kanal_mode = 2 Then
         If Command_b(2) < 9 Then
            If Window_contact = 0 Then
               Switch = Command_b(2)
               K = T_short
               Window_contact = 1
               Gosub Switch_on
            Else
               Window_contact = 0
               Gosub Switch_off
            End If
         Else
            Parameter_error
         End If
      Else
         Command_not_found
      End If
      Gosub Command_received
   End If
Return
'
04:
   Tx_time = 1
   Tx_b(1) = &H04
   Tx_b(2) = Window_contact
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
05:
   Tx_time = 1
   Tx_b(1) = &H05
   Tx_b(2) = Transmit_error
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
06:
   If Commandpointer = 2 Then
      If Command_b(2) < 3  Then
         Kanal_mode = Command_b(2)
         Kanal_mode_eeram = Kanal_mode
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
07:
   Tx_time = 1
   Tx_b(1) = &H07
   Tx_b(2) = Kanal_mode
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'