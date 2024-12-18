' Commandparser
' 20201123
'
Commandparser:
If Command_b(1) = 0 Then
   Tx_time = 1
   A_line = 0
   Number_of_lines = 1
   Send_line_gaps = 2
   Gosub Sub_restore
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Else
   $include "__select_command.bas"
End If
Return
'
'==================================================
End