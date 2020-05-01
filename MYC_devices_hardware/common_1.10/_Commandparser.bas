' Commandparser
' 20200422
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
'
#IF Command_is_2_byte = 0
   $include "__select_command.bas"
'
#ELSE
   Select Case Command_b(1)
      $include "__select_command.bas"
   End Select
#ENDIF
End If
Return
'
'==================================================
End