' Loop / Main_end
' 202509
'
If Tx_write_pointer > 1 Then
   Commandpointer = 0
   Command_pointer = 0
   Last_command_pointer = 0
   Not_valid_at_this_time
Else
   If Command_pointer > Last_command_pointer Then
      Last_command_pointer = Command_pointer
      ' start Cmd_watchdog:
      If Cmd_watchdog = 0 Then Incr Cmd_watchdog
#IF Command_is_2_byte = 0
      Commandpointer = Command_pointer
      If Interface_transparent_active = 0 Then
        If Command_b(1) = 254 Then
           Gosub Select_command
        Else
           If Command_allowed = 1 Then
              Gosub Select_command
           Else
              Commandpointer = 0
              Command_pointer = 0
              Last_command_pointer = 0
              Not_valid_at_this_time
           End If
        End If
      End If
#Else
      If Command_pointer >= 2 Then
         Commandpointer = Command_pointer
         If Interface_transparent_active
            If Command_b(1) = &HFF And Command_b(2) = 254 Then
              Gosub Commandparser
           Else
              If Command_allowed = 1 Then
                 Gosub Select_command
              Else
                 Commandpointer = 0
                 Command_pointer = 0
                 Last_command_pointer = 0
                 Not_valid_at_this_time
              End If
           End If
        End If
      End If
#ENDIF
   End If
   ' Either command is finished or new data necessary
End If
'
Reset Watchdog                                           '
Goto Loop_