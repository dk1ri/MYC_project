' commands
' 20200818
'
01:
   Tx_time = 1
   Tx = "_ _ _ _ _ _ _ _ _"
   Tx_b(1) = &H01
   Tx_b(2) = 15
   Tx_write_pointer = 18
   If Out1 = 0 Then Tx_b(3) = 124
   If Out2 = 0 Then Tx_b(5) = 124
   If Out3 = 0 Then Tx_b(7) = 124
   If Out4 = 0 Then Tx_b(9) = 124
   If Out5 = 0 Then Tx_b(11) = 124
   If Out6 = 0 Then Tx_b(13) = 124
   If Out7 = 0 Then Tx_b(15) = 124
   If Out8 = 0 Then Tx_b(17) = 124
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
02:
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
03:
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
04:
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
05:
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
'
06:
Gosub Command_received
Return
'
07:
   Tx_time = 1
   Tx_b(1) = &H07
   Tx_b(2) = &H02
   Tx_b(3) = Last_switch + &H30
   Tx_b(4) = Last_status + &H30
   Tx_write_pointer = 5
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'