' commands
' 20200611
'
01:
   Tx_time = 1
   Tx_b(1) = &H01
   Tx_b(2) = &H00
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
02:
   Tx_time = 1
   Tx_b(1) = &H02
   Tx_write_pointer = 3
   B_temp1 = 0
   If Sch1 = 1 Then B_temp1 = B_temp1 Or &B00000001
   If Sch2 = 1 Then B_temp1 = B_temp1 Or &B00000010
   If Sch3 = 1 Then B_temp1 = B_temp1 Or &B00000100
   If Sch4 = 1 Then B_temp1 = B_temp1 Or &B00001000
   If Sch5 = 1 Then B_temp1 = B_temp1 Or &B00010000
   If Sch6 = 1 Then B_temp1 = B_temp1 Or &B00100000
   If Sch7 = 1 Then B_temp1 = B_temp1 Or &B01000000
   If Sch8 = 1 Then B_temp1 = B_temp1 Or &B10000000
   Tx_b(2) = B_temp1
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
03:
   If Commandpointer >= 2 Then
      If Command_b(2) < 8 Then
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
      If Command_b(2) < 8 Then
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