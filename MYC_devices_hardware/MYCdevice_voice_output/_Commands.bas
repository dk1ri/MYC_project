' _Commands
' 20200823
'
01:
If Commandpointer >= 2 Then
   If Command_b(2) < 11 Then
      If Time_ = 0 Then
         If Command_b(2) > 0 Then
            Time_ = T_short
            Voicea = Command_b(2)
            'start Music
            Gosub Control_sound
         End If
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
If Commandpointer >= 2 Then
   If Command_b(2) < 11 Then
      If Time_ = 0 Then
         If Command_b(2) > 0 Then
            Time_ = T_long
            Voicea = Command_b(2)
            'start playlist
            Gosub Control_sound
         End If
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
03:
If Commandpointer >= 2 Then
   If Command_b(2) < 15 Then
      If Time_ = 0 Then
         If Command_b(2) > 0 Then
            ' > 10s, see Table2
            Time_ = T_10s
            Select Case Command_b(2)
               Case 1 to 8
                  Voicea = Command_b(2) + 2
                  Voiceb = 1
               Case 9 To 10
                  Voicea = Command_b(2) - 6
                  Voiceb = 2
               Case 12 To 15
                  Voicea = Command_b(2) - 4
                  Voiceb = 2
            End Select
            Gosub Control_sound
         End If
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
04:
Tx_time = 1
Tx_b(1) = &H04
If Config_at_start = 0 Then
   Tx_b(2) = 1
Else
   Tx_b(2) = 0
End If
Tx_write_pointer = 3
If Command_mode = 1 Then  Gosub Print_tx
Gosub Command_received
Return