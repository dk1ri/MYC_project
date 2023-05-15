' Commands
' 20230515
'
01:
B_temp3 = 1
Gosub Set_command
Return
'
02:
B_temp3 = 2
Gosub Set_command
Return
'
03:
B_temp3 = 3
Gosub Set_command
Return
'
04:
B_temp3 = 4
Gosub Set_command
Return
'
05:
B_temp3 = 5
Gosub Set_command
Return
'
06:
B_temp3 = 6
Gosub Set_command
Return
'
07:
B_temp3 = 7
Gosub Set_command
Return
'
08:
B_temp3 = 8
Gosub Set_command
Return
'
09:
   Tx_time = 1
   Tx_b(1) = &H09
   ' string 8 byte
   Tx_b(2) = &H08
   Tx_b(3) = Mat(1) + 48
   Tx_b(4) = Mat(2) + 48
   Tx_b(5) = Mat(3) + 48
   Tx_b(6) = Mat(4) + 48
   Tx_b(7) = Mat(5) + 48
   Tx_b(8) = Mat(6) + 48
   Tx_b(9) = Mat(7) + 48
   Tx_b(10) = Mat(8) + 48
   Tx_write_pointer = 11
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
0A:
If Commandpointer >= 2 Then
   If Command_b(2) < 3 Then
      If K_mode <> Command_b(2) Then
         'write back
         If K_mode = 0 Then
            For B_temp1 = 1 To 8
               Mat88(B_temp1) = Mat(B_temp1)
            Next B_temp1
         Elseif K_mode = 1 Then
            For B_temp1 = 1 To 8
               Mat84(B_temp1) = Mat(B_temp1)
            Next B_temp1
         Else
            For B_temp1 = 1 To 8
               Mat44(B_temp1) = Mat(B_temp1)
            Next B_temp1
         End If
         K_mode = Command_b(2)
         K_mode_eeram = K_mode
         If Used(K_mode) = 1 Then
            If K_mode = 0 Then
               For B_temp1 = 1 To 8
                  Mat(B_temp1) = Mat88(B_temp1)
               Next B_temp1
            Elseif K_mode = 1 Then
               For B_temp1 = 1 To 8
                  Mat(B_temp1) = Mat84(B_temp1)
               Next B_temp1
            Else
               For B_temp1 = 1 To 8
                  Mat(B_temp1) = Mat44(B_temp1)
               Next B_temp1
            End If
         Else
            ' use eeram
            If K_mode = 0 Then
               For B_temp1 = 1 To 8
                  Mat(B_temp1) = Mat88_eeram(B_temp1)
               Next B_temp1
            Elseif K_mode = 1 Then
               For B_temp1 = 1 To 8
                  Mat(B_temp1) = Mat84_eeram(B_temp1)
               Next B_temp1
            Else
               For B_temp1 = 1 To 8
                  Mat(B_temp1) = Mat44_eeram(B_temp1)
               Next B_temp1
            End If
         End If
         Used(K_mode) = 1
         Gosub Copy_Mat
      End If
   Else
       Parameter_error
   End If
   Gosub Command_received
End If
Return
'
0B:
Tx_time = 1
Tx_b(1) = &H0B
Tx_b(2) = K_mode
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
0C:
' set default
   B_temp1 = 1
   While B_temp1 <= 9
      If K_mode = 0 Then
         Mat(B_temp1) = Mat88_eeram(B_temp1)
      Elseif K_mode = 1 Then
         Mat(B_temp1) = Mat84_eeram(B_temp1)
      Else
         Mat(B_temp1) = Mat44_eeram(B_temp1)
      End If
      B_temp1 = B_temp1 + 1
   Wend
   Gosub Copy_Mat
   Gosub Command_received
Return
'
0D:
B_temp1 = 1
   While B_temp1 <= 9
      If K_mode = 0 Then
         Mat88_eeram(B_temp1) = Mat(B_temp1)
      Elseif K_mode = 1 Then
         Mat84_eeram(B_temp1) = Mat(B_temp1)
      Else
         Mat44_eeram(B_temp1) = Mat(B_temp1)
      End If
      B_temp1 = B_temp1 + 1
   Wend
   Gosub Command_received
Return
'
0E:
   Tx_time = 1
   Tx_b(1) = &H0E
   Tx_b(2) = &H08
   B_temp1 = 1
   B_temp2 = 3
   While B_temp1 < 9
      If K_mode = 0 Then
         Tx_b(B_temp2) = Mat88_eeram(B_temp1) + 48
      Elseif K_mode = 1 Then
         Tx_b(B_temp2) = Mat84_eeram(B_temp1) + 48
      Else
         Tx_b(B_temp2) = Mat44_eeram(B_temp1) + 48
      End If
      B_temp1 = B_temp1 + 1
      B_temp2 = B_temp2 + 1
   Wend
   Tx_write_pointer = 11
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
0F:
' reset
   Gosub Reset_start
   Gosub Command_received
Return
'