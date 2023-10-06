' commands
' 20200817
'
01:
   If Commandpointer >= 2 Then
      If Command_b(2) < 3 Then
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
      If Command_b(2) < 3 Then
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
      If Command_b(2) < 4 Then
         Gosub Configuration
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
04:
   If Commandpointer >= 2 Then
      B_temp1 = Command_b(2)
      ' sequence may be wrong!!!
      TA1 = B_temp1.0
      TA2 = B_temp1.1
      TA3 = B_temp1.2
      TA4 = B_temp1.3
      TA5 = B_temp1.4
      TA6 = B_temp1.5
      TA7 = B_temp1.6
      TA8 = B_temp1.7
      DU3 = 0
      K = T_short
      Gosub Switch_on
      Gosub Command_received
   End If
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