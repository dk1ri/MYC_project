' commands
' 20200609
'
01:
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
                  Pause = 0
                  Gosub Switch_on
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
02:
   If Commandpointer >= 2 Then
      If Kanal_mode = 0 Then
         If Command_b(2) < 4 Then
            If Dimming = 0 Then
               If Busy = 0 Then
                  Switch = Command_b(2) + 1
                  B_temp1 = Switch * 2
                  Switch1 = 0
                  Dimming = 1
                  Dimm_chanal = Switch
                  ' will not start timer
                  Gosub Switch_on
               Else
                  Not_valid_at_this_time
               End If
            Else
               B_temp1 = Command_b(2) + 1
               If B_temp1 = Dimm_chanal Then
                  'Switch dimming chanal only
                  Dimming = 0
                  Dimm_chanal = 0
                  Gosub Switch_off1
                  Busy = 0
                  Pause = 0
               End If
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
03:
   If Commandpointer >= 2 Then
      If Kanal_mode = 0 Then
         If Command_b(2) < 4 Then
            If Dimming = 0 Then
               If Busy = 0 Then
                  Switch = Command_b(2) + 1
                  Switch = Switch * 2
                  Decr Switch
                  Switch1 = 0
                  Dimming = 1
                  Dimm_chanal = Switch
                  ' will not start timer
                  Gosub Switch_on
               Else
                  Not_valid_at_this_time
               End If
            Else
               B_temp1 = Command_b(2) + 1
               If B_temp1 = Dimm_chanal Then
                  'Switch dimming chanal only
                  Dimming = 0
                  Dimm_chanal = 0
                  Gosub Switch_off1
                  Busy = 0
                  Pause = 0
               End If
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
   If Commandpointer >= 2 Then
      If Kanal_mode = 0 Then
         If Command_b(2) < 4 Then
            If Busy = 0 Then
               Switch = Command_b(2) + 1
               Switch = Switch * 2
               '2 4 6 8
               Switch1 = Switch
               '1 3 5 7
               Decr Switch1
               K = T_timer
               Pause = 0
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
05:
   If Commandpointer >= 2 Then
      If Kanal_mode = 1 Then
         If Command_b(2) < 8 Then
            If Busy = 0 Then
               Switch = Command_b(2) + 1
               Switch1 = 0
               K = T_short
               Pause = 0
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
06:
   If Commandpointer >= 2 Then
      If Kanal_mode = 1 Then
         If Command_b(2) < 8 Then
            If Dimming = 0 Then
               If Busy = 0 Then
                  Switch = Command_b(2) + 1
                  Switch1 = 0
                  Dimming = 1
                  Dimm_chanal = Switch
                  ' will not start timer
                  Gosub Switch_on
               Else
                  Not_valid_at_this_time
               End If
            Else
               B_temp1 = Command_b(2) + 1
               If B_temp1 = Dimm_chanal Then
                  'Switch dimming chanal only
                  Dimming = 0
                  Dimm_chanal = 0
                  Gosub Switch_off1
                  Busy = 0
                  Pause = 0
               End If
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
   If Commandpointer >= 2 Then
      If Kanal_mode = 1 Then
         If Command_b(2) < 8 Then
            If Busy = 0 Then
               Switch = Command_b(2) + 1
               Switch1 = 0
               K = T_timer
               Pause = 0
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
08:
   Tx_time = 1
   Tx_b(1) = &H08
   Tx_b(2) = Dimm_chanal
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
09:
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
            Pause = 0
            K = T_modus
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
0A:
   Tx_time = 1
   Tx_b(1) = &H0A
   Tx_b(2) = Kanal_mode
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
0B:
   If Commandpointer >= 2 Then
      If Kanal_mode = 0 Then
         If Command_b(2) < 10 Then
            If Busy = 0 Then
               Set4 = Command_b(2)
               Set4_eeram = Set4
               Funktion_pointer = 1
               Change_set_active = 1
               Gosub Change_set
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
0C:
   If Commandpointer >= 2 Then
      If Kanal_mode = 1 Then
         If Command_b(2) < 10 Then
            If Busy = 0 Then
               Set8 = Command_b(2)
               Set8_eeram = Set8
               Funktion_pointer = 1
               Change_set_active = 1
               8chanal_pre = 1
               Gosub Change_set
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
0D:
   Tx_time = 1
   Tx_b(1) = &H0D
   Tx_write_pointer = 3
   Tx_b(2) = Busy
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
0E:
   If Commandpointer >= 10 Then
      If Busy = 0 Then
         B_temp3 = 0
         If Command_b(2) <> 8 Then B_temp3 = 1
         For B_temp1 = 3 to 10
            B_temp2 = Command_b(B_temp1)
            If B_temp2 < 49 Or B_temp2 > 52 Then B_temp3 = 1
            ' Error
         Next B_temp1
         If B_temp3 = 0 Then
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
            K = T_modus
            Send_pointer = 1
            Send_length = 8
           ' start housecode
            Pause = 2
            Gosub Switch_on
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
0F:
   Tx_time = 1
   Tx_b(1) = &H0F
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
10:
   If Commandpointer >= 7 Then
      If Command_b(2) < 10 Then
         If Command_b(3) < 4 Then
            B_temp3 = 0
            For B_temp1 = 4 To 7
               B_temp2 = Command_b(B_temp1)
               If B_temp2 < 49 Or B_temp2 > 52 Then B_temp3 = 1
               ' Error
            Next B_temp1
            If B_temp3 = 0 Then
               B_temp1 = Command_b(2) * 16
               B_temp4 = Command_b(3) * 4
               B_temp1 = B_temp1 + B_temp4
               ' string start with 1
               Incr B_temp1
               For B_temp2 = 4 To 7
                  B_temp3 = Command_b(B_temp2)
                  Code4_b(B_temp1) = B_temp3
                  Incr B_temp1
               Next B_temp2
            Else
               Parameter_error
            End If
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
11:
   If Commandpointer >= 3 Then
      If Command_b(2) < 10 Then
         If Command_b(3) < 4 Then
            Tx_time = 1
            Tx_b(1) = &H11
            Tx_b(2) = Command_b(2)
            Tx_b(3) = Command_b(3)
            Tx_b(4) = 4
            B_temp1 = Command_b(2) * 16
            B_temp4 = Command_b(3) * 4
            B_temp1 = B_temp1 + B_temp4
            ' string start with 1
            Incr B_temp1
            For B_temp2 = 5 to 8
               B_temp3 = Code4_b(B_temp1)
               Tx_b(B_temp2) = B_temp3
               Incr B_temp1
            Next B_temp2
            Tx_write_pointer = 9
            If Command_mode = 1 Then Gosub Print_tx
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
12:
   If Commandpointer >= 7 Then
      If Command_b(2) < 10 Then
         If Command_b(3) < 8 Then
            B_temp3 = 0
            For B_temp1 = 4 To 7
               B_temp2 = Command_b(B_temp1)
               If B_temp2 < 49 Or B_temp2 > 52 Then B_temp3 = 1
               ' Error
            Next B_temp1
            If B_temp3 = 0 Then
               B_temp1 = Command_b(2) * 32
               B_temp4 = Command_b(3) * 4
               B_temp1 = B_temp1 + B_temp4
               ' string start with 1
               Incr B_temp1
               For B_temp2 = 4 To 7
                  B_temp3 = Command_b(B_temp2)
                  Code8_b(B_temp1) = B_temp3
                  Incr B_temp1
               Next B_temp2
            Else
               Parameter_error
            End If
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
13:
   If Commandpointer >= 3 Then
      If Command_b(2) < 10 Then
         If Command_b(3) < 8 Then
            Tx_time = 1
            Tx_b(1) = &H13
            Tx_b(2) = Command_b(2)
            Tx_b(3) = Command_b(3)
            Tx_b(4) = 4
            B_temp1 = Command_b(2) * 32
            B_temp4 = Command_b(3) * 4
            B_temp1 = B_temp1 + B_temp4
            ' string start with 1
            Incr B_temp1
            For B_temp2 = 5 to 8
               B_temp3 = Code8_b(B_temp1)
               Tx_b(B_temp2) = B_temp3
               Incr B_temp1
            Next B_temp2
            Tx_write_pointer = 9
            If Command_mode = 1 Then Gosub Print_tx
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
14:
   If Busy = 0 Then
      Switch = 2
      Switch1 = 4
      K = T_Modus
      Pause = 2
      Send_string = "1"
      Send_pointer = 1
      Send_length = 1
      Gosub Switch_on
   Else
      Not_valid_at_this_time
   End If
Return