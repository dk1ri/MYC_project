' Commandparser start
'1.7.0, 190512
'
Commandparser:
'checks to avoid commandbuffer overflow are within commands !!
'
If Cmd_watchdog = 0 Then Incr Cmd_watchdog
'
Select Case Command_b(1)
   Case 0
      Tx_busy = 2
      Tx_time = 1
      A_line = 0
      Number_of_lines = 1
      Send_line_gaps = 2
      Gosub Sub_restore
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received