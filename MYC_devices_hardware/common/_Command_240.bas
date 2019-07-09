' Command240
'1.7.0, 190512
'
   Case 240
      If Commandpointer >= 3 Then
         A_line = Command_b(2)
         Number_of_lines = Command_b(3)
         If A_line < No_of_announcelines And Number_of_lines < No_of_announcelines Then
            If Command_b(3) > 0 Then
               Tx_busy = 2
               Tx_time = 1
               Send_line_gaps = 4
               Gosub Sub_restore
               If Command_mode = 1 Then
                  Gosub Print_tx
                  While Number_of_lines > 0
                     Gosub Sub_restore
                     Gosub Print_tx
                  Wend
                  Gosub Reset_tx
               End If
            End If
         Else_Parameter_error
         Gosub Command_received
      Else_Incr_Commandpointer