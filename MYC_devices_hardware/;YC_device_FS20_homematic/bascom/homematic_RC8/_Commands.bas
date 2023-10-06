' commands
' 20200521
'
01:
   If Commandpointer >= 2 Then
      If Command_b(2) < 9 Then
         Switch = Command_b(2)
         K = T_short
         Gosub Switch_on
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
02:
   Tx_time = 1
   Tx_b(1) = &H02
   Tx_b(2) = Transmit_error
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'