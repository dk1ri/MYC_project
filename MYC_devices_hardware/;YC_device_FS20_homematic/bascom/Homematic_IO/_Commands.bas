' commands
' 20200818
'
01:
   Tx_time = 1
   Tx_b(1) = &H01
   Tx_b(2) = &H00
   Tx_b(3) = &H00
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
02:
   Tx_time = 1
   Tx_b(1) = &H02
   B_temp1 = PinC And &B11111100
   B_temp2 = 2 * Sch6
   B_temp1 = B_temp1 + B_temp2
   B_temp1 = B_temp1 + Sch7
   Tx_b(2) = B_temp1
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
03:
   If Commandpointer >= 2 Then
      If Command_b(2) < 4 And Command_b(2) > 0 Then
         If Busy = 0 Then
            Switch = Command_b(2)
            K = T_short
            Gosub Switch_on
         Else
            Not_valid_at_this_time
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
04:
   If Commandpointer >= 2 Then
      If Command_b(2) < 4 And Command_b(2) > 0 Then
         If Busy = 0 Then
            Switch = Command_b(2)
            K = T_long
            Gosub Switch_on
         Else
            Not_valid_at_this_time
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
05:
   If Commandpointer >= 4 Then
      If Command_b(2) < 4 Then
         W_temp1 = Command_b(3) * 256
         W_Temp1 = W_temp1 + Command_b(4)
         If W_temp1 < 1024 Then
            B_temp1 = Command_b(2) + 1
            Analog_out(B_temp1) = W_temp1
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
06:
   If Commandpointer >= 2 Then
      If Command_b(2) < 4 Then
         Tx_time = 1
         Tx_b(1) = &H06
         B_temp1 = Command_b(2) + 1
         Tx_b(2) = High(Analog_out(B_temp1))
         Tx_b(3) = Low(Analog_out(B_temp1))
         Tx_write_pointer = 4
         If Command_mode = 1 Then Gosub Print_tx
      ELse
         Parameter_error
      End If
      Gosub Command_received
   End If
Return