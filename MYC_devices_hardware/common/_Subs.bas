'Some subs
'1.7.0, 190512
'
Reset_tx:
Tx_pointer = 1
Tx_write_pointer = 1
Tx_busy = 0
Tx_time = 0
TWDR = Not_valid_cmd
Return
'
Command_received:
Commandpointer = 1
Cmd_watchdog = 0
Incr Command_no
If Command_no = Error_cmd_no Then
   Error_cmd_no = 0
   Error_no = 255
End If
Return
'
Print_tx:
Decr  Tx_write_pointer
For b_Temp2 = 1 To Tx_write_pointer
   b_Temp3 = Tx_b(b_Temp2)
   Printbin b_Temp3
Next b_Temp2
Gosub Reset_tx
Return
'
Sub_restore:
' read one line
'
'Byte beyond restored data must be 0:
For b_Temp2 = 1 To Tx_length
   Tx_b(b_Temp2) = 0
Next b_Temp2
'
Select Case A_line
   Case 0
      Restore Announce0
'
$include "__restore.bas"
'
End Select
Read Tx
b_Temp3 = Len(Tx)
For b_Temp2 = b_Temp3 To 1 Step - 1
   b_Temp1 = b_Temp2 + Send_line_gaps
   Tx_b(b_Temp1) = Tx_b(b_Temp2)
Next b_Temp2
Select Case Send_line_gaps
   Case 1
      'additional announcement lines
      Tx_b(1) = b_Temp3
      Tx_write_pointer = b_Temp3 + 2
      Send_line_gaps = 1
      Incr A_line
      Tx_write_pointer = b_Temp3 + 2
      If A_line >= No_of_announcelines Then A_line = 0
      Tx_busy = 2
   Case 2
      'start basic announcement
      Tx_b(1) = &H00
      Tx_b(2) = b_Temp3
      Tx_write_pointer = b_Temp3 + 3
   Case 4
      'start of announceline(s), send 3 byte first
      Tx_b(1) = &HF0
      Tx_b(2) = A_line
      Tx_b(3) = Number_of_lines
      Tx_b(4) = b_Temp3
      Tx_write_pointer = b_Temp3 + 5
      Send_line_gaps = 1
      Incr A_line
      If A_line >= No_of_announcelines Then A_line = 0
      Tx_busy = 2
End Select
Decr Number_of_lines
Tx_pointer = 1
Return
'