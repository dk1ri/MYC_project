' Loop / Main_end
' 20251206
'
If Commandpointer > 0 And Interface_transparent_active = 0 Then
   ' start Cmd_watchdog:
   If Cmd_watchdog = 0 Then Incr Cmd_watchdog
   If Interface_transparent_active = 0 Then
#IF Command_is_2_byte = 0
      If Commandpointer >= 1 Then
         If Command_b(1) = 254 Then
#ELSE
      If Commandpointer >= 2 Then
         If Command_b(1) = &HFF And Command_b(2) = 254 Then
#ENDIF
            Gosub Select_command
         Else
            B_temp1 = 0
            Select Case Command_origin
               Case 0
                  If Serial_active = 1 Then B_temp1 = 1
               Case 1
                  If USB_active = 1 Then B_temp1 = 1
               Case 2
                  If Serial_active = 1 Or USB_active = 1 Then B_temp1 = 1
               Case 3
                  If I2c_active = 1 Then B_temp1 = 1
               Case 4
                  If Radio_type > 0 Then B_temp1 = 1
            End Select
            If B_temp1 = 1 Then
               Gosub Select_command
            Else
               Gosub Command_received
               Not_valid_at_this_time
            End If
         End If
     End If
   End If
End If
'
' one loop wtachdog
Stop Watchdog                                         '
Goto Loop_