' additional comands
' 202240424
'
01:
   Gosub Measure_forward
   Tx_time = 1
   Tx_b(1) = &H01
   Tx_b(2) = High(Forward)
   Tx_b(3) = Low(Forward)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
02:
   Gosub Measure_reflected
   Tx_time = 1
   Tx_b(1) = &H02
   Tx_b(2) = High(Reflected)
   Tx_b(3) = Low(Reflected)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
03:
   Gosub Measure_forward
   Gosub Measure_reflected
   Gosub Calc_vswr
   Tx_b(1) = &H03
   Tx_b(2) = VSWR
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
04:
   If Commandpointer >= 3 Then
   W_temp1 = Command_b(2) * 256
   W_temp1 = W_temp1 + Command_b(3)
   If W_temp1 < 1000 Then
      Attf = W_temp1
   Else
      Parameter_error
   End If
   Gosub Command_received
   End If
Return
'
05:
   Tx_b(1) = &H05
   Tx_b(2) = High(Attf)
   Tx_b(3) = Low(Attf)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
06:
   If Commandpointer >= 3 Then
      W_temp1 = Command_b(2) * 256
      W_temp1 = W_temp1 + Command_b(3)
      If W_temp1 < 1000 Then
         Attr = W_temp1
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
07:
   Tx_b(1) = &H07
   Tx_b(2) = High(Attr)
   Tx_b(3) = Low(Attr)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
08:
   Gosub Read_temp_f
   Tx_b(1) = &H08
   Tx_b(2) = High(Temp_val)
   Tx_b(3) = Low(Temp_val)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
09:
   Gosub Read_temp_r
   Tx_b(1) = &H09
   Tx_b(2) = High(Temp_val)
   Tx_b(3) = Low(Temp_val)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return