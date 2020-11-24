' Commandparser
' 20200422
'
Command0:
   Tx_time = 1
   A_line = 0
   Number_of_lines = 1
   Send_line_gaps = 2
   Gosub Sub_restore
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return