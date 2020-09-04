' commands
' 20200817
'
01:
   If Commandpointer >= 2 Then
      If Command_b(2) < 2 Then
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
   If Commandpointer >= 2 Then
      If Command_b(2) < 2 Then
         Switch = Command_b(2)
         K = T_long
         Gosub Switch_on
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
03:
   If Commandpointer >= 2 Then
         B_temp1 = Command_b(2)
        PortA = B_temp1
   End If
Return
'
04:
   Tx_time = 1
   Tx_b(1) = &H05
   Tx_b(2) = Transmit_error
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'