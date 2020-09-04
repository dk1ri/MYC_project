' commands
' 20200616
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
   Tx_b(2) = Switch_status
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'