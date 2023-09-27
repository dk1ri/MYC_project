' commands
' 20230926
'
01:
   If Commandpointer >= 2 Then
      If Command_b(2) < 2 Then
         If Busy = 0 Then
            If Command_b(2) = 0 Then
               Kanal_mode = 0
               Kanal_mode_eeram = 0
               Switch = 1
               Switch1 = 4
            Else
               Kanal_mode = 1
               Kanal_mode_eeram = 1
               Switch = 2
               Switch1 = 3
            End If
            K = T_modus
            Busy = 1
            Wait_ = 1
            Gosub Switch_on
            Start Timer1
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
02:
   Tx_time = 1
   Tx_b(1) = &H02
   Tx_b(2) = Kanal_mode
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
03:
   If Commandpointer >= 3 Then
      If Kanal_mode = 0 Then
         If Command_b(2) < 4 Then
            If Command_b(3) < 2 Then
               If Busy = 0 Then
                  Switch = Command_b(2) + 1
                  Switch = Switch * 2
                  If Command_b(3) = 0 Then Decr Switch
                  Switch1 = 0
                  K = T_short
                  Busy = 1
                  Wait_ = 1
                  Gosub Switch_on
                  Start Timer1
               Else
                  Not_valid_at_this_time
               End If
            Else
               Parameter_error
            End If
         Else
            Parameter_error
         End If
      Else
         Command_not_found
      End If
      Gosub Command_received
   End If
Return
'
04:
   If Commandpointer >= 3 Then
      If Kanal_mode = 0 Then
         If Command_b(2) < 8 Then
            Switch = Command_b(2) - 1
            Switch1 = 0
            If Busy = 0 Then
               K = T_long
               Busy = 1
               Wait_ = 1
               Gosub Switch_on
               Start Timer1
            Else
               Not_valid_at_this_time
            End If
         Else
            Parameter_error
         End If
      Else
         Command_not_found
      End If
      Gosub Command_received
   End If
Return
'
05:
   If Commandpointer >= 2 Then
      If Kanal_mode = 0 Then
         If Command_b(2) < 4 Then
            If Busy = 0 Then
               Switch = Command_b(2) + 1
               Switch = Switch * 2
               '2 4 6 8
               Switch1 = Switch - 1
               '1 3 5 7
               Decr Switch1
               K = T_timer
               Busy = 1
               Wait_ = 1
               Gosub Switch_on
               Start Timer1
            Else
               Not_valid_at_this_time
            End If
         Else
            Parameter_error
         End If
      Else
         Command_not_found
      End If
      Gosub Command_received
   End If
Return
'
06:
   If Commandpointer >= 2 Then
      If Kanal_mode = 1 Then
         If Command_b(2) < 8 Then
            If Busy = 0 Then
               Switch = Command_b(2) + 1
               Switch1 = 0
               K = T_short
               Busy = 1
               Wait_ = 1
               Gosub Switch_on
               Start Timer1
            Else
               Not_valid_at_this_time
            End If
         Else
            Parameter_error
         End If
      Else
         Command_not_found
      End If
      Gosub Command_received
   End If
Return
'
07:
   If Commandpointer >= 3 Then
      If Kanal_mode = 1 Then
         If Command_b(2) < 16 Then
            If Command_b(2) > 7 Then
               If Busy = 0 Then
               ' one chanal can be dimmed at a time only
                  Switch = Command_b(2) - 7
                  Switch1 = 0
                  K = T_long
                  Busy = 1
                  Wait_ = 1
                  Gosub Switch_on
                  ' will not start timer: do not switch off by timer
                 '  Start Timer1
               Else
                  Not_valid_at_this_time
               End If
            Else
               Gosub Switch_off
            End If
         Else
            Parameter_error
         End If
      Else
         Command_not_found
      End If
      Gosub Command_received
   End If
Return
'
08:
   If Commandpointer >= 2 Then
      If Kanal_mode = 1 Then
         If Command_b(2) < 8 Then
            If Busy = 0 Then
               Switch = Command_b(2) + 1
               B_temp1 = Switch Mod 2
               If B_temp1 = 0 Then
                  Switch1 = Switch -1
               Else
                  Switch1 = Switch + 1
               End If
               K = T_timer
               Busy = 5
               Wait_ = 1
               Gosub Switch_on
            Else
               Not_valid_at_this_time
            End If
         Else
            Parameter_error
         End If
      Else
         Command_not_found
      End If
      Gosub Command_received
   End If
Return
'
09:
   Tx_time = 1
   Tx_b(1) = &H09
   Tx_write_pointer = 3
   Tx_b(2) = Busy
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
10:
   If Commandpointer >= 10 Then
      If Busy = 0 Then
         B_temp3 = 0
         If Command_b(2) <> 8 Then B_temp3 = 1
         For B_temp1 = 3 to 10
            B_temp2 = Command_b(B_temp1)
            If B_temp2 < &H31 Or B_temp2 > &H34 Then B_temp3 = 1
            ' Error
         Next B_temp1
         If B_temp3 = 0 Then
            ' no error
            S_temp10 = String(10, 0)
            B_temp4 = 3
            For B_temp1 = 1 To 8
               B_temp2 = Command_b(B_temp4)
               S_temp10_b(B_temp1) = B_temp2
               Send_string_b(B_temp1) = B_temp2 - 48
               Incr B_temp4
            Next B_temp1
            Housecode = S_temp10
            Housecode_eeram = Housecode
            Switch = 1
            Switch1 = 3
           ' start send
            K = T_modus
            Busy = 2
            Wait_ = 1
            Send_length = 8
            Send_pointer = 1
            Start Timer1
         Else
            Parameter_error
         End If
      Else
         Not_valid_at_this_time
      End If
      Gosub Command_received
   End If
Return
'
11:
   Tx_time = 1
   Tx_b(1) = &H0B
   Tx_b(2) = 8
   B_temp2 = 1
   For B_temp1 = 3 to 10
      Tx_b(B_temp1) = Housecode_b(B_temp2)
      Incr B_temp2
   Next B_temp1
   Tx_write_pointer = 11
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
12:
   If Busy = 0 Then
      Switch = 2
      Switch1 = 4
      K = T_modus
      Busy = 2
      Wait_ = 1
      Send_string_b(1) = 1
      Send_length = 1
      Send_pointer = 1
      Start Timer1
   Else
      Not_valid_at_this_time
   End If
Return