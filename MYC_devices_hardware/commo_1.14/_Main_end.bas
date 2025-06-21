' Loop / Main_end
' 20250413
'
   If New_data > 0 Then
      New_data = 0
      If Tx_write_pointer > 1 Then
         Command_pointer = 0
         Not_valid_at_this_time
      Else
      ' start Cmd_watchdog:
      If Cmd_watchdog = 0 Then Incr Cmd_watchdog
   #IF Command_is_2_byte = 0
         Commandpointer = Command_pointer
         If Command_b(1) = 254 Then
            Gosub Commandparser
         Else
            Gosub Commandparser
         End If
   #Else
         If Command_b(1) = 0 Then
            Gosub Command0
         Else
            If Command_pointer >= 2 Then
               Commandpointer = Command_pointer
               If Command_b(1) = &HFF And Command_b(2) = 254 Then
                  Gosub Commandparser
               Else
                  If Command_allowed = 1 Then
                     Gosub Commandparser
                  Else
                     Commandpointer = 0
                     Command_pointer = 0
                     Not_valid_at_this_time
                  End If
               End If
            End If
         End If
   #ENDIF
      End If
   End If
'
Reset Watchdog                                           '
Goto Loop_