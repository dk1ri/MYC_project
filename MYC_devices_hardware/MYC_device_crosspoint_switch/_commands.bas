' Commands
' 200124
'
01:
If K_mode = 0 Then
   If Commandpointer >= 3 Then
      If Command_b(2) < 8 Then
         If Command_b(3) < 9 Then
            B_temp1 = Command_b(2) + 1
            Mat(B_temp1) = Command_b(3)
            Gosub Send_data
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Else
   Command_not_found
   Gosub Command_received
End If
Return
'
02:
If K_mode = 0 Then
   If Commandpointer >= 9 Then
      If Command_b(2) < 9 Then
         If Command_b(3) < 9 Then
            If Command_b(4) < 9 Then
               If Command_b(5) < 9 Then
                  If Command_b(6) < 9 Then
                     If Command_b(7) < 9 Then
                        If Command_b(8) < 9 Then
                           If Command_b(9) < 9 Then
                              Mat(1) = Command_b(2)
                              Mat(2) = Command_b(3)
                              Mat(3) = Command_b(4)
                              Mat(4) = Command_b(5)
                              Mat(5) = Command_b(6)
                              Mat(6) = Command_b(7)
                              Mat(7) = Command_b(8)
                              Mat(8) = Command_b(9)
                              Gosub Send_data
                           Else
                              Parameter_error
                           End If
                        Else
                           Parameter_error
                        End If
                     Else
                        Parameter_error
                     End If
                  Else
                     Parameter_error
                  End If
               Else
                  Parameter_error
               End If
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
Else
   Command_not_found
   Gosub Command_received
End If
Return
'
03:
If K_mode = 1 Then
   If Commandpointer >= 3 Then
      If Command_b(2) < 4 Then
         If Command_b(3) < 9 Then
            B_temp1 = Command_b(2)  + 1
            Mat(B_temp1) = Command_b(3)
            Gosub Send_data
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Else
   Command_not_found
   Gosub Command_received
End If
Return
'
04:
If K_mode = 1 Then
   If Commandpointer >= 5 Then
      If Command_b(2) < 9 Then
         If Command_b(3) < 9 Then
            If Command_b(4) < 9 Then
               If Command_b(5) < 9 Then
                  Mat(1) = Command_b(2)
                  Mat(2) = Command_b(3)
                  Mat(3) = Command_b(4)
                  Mat(4) = Command_b(5)
                  Gosub Send_data
               Else
                  Parameter_error
               End If
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
Else
   Command_not_found
   Gosub Command_received
End If
Return
'
05:
If K_mode = 2 Then
   If Commandpointer >= 3 Then
      If Command_b(2) < 4 Then
         If Command_b(3) < 5 Then
            B_temp1 = Command_b(2)
            Mat(B_temp1) = Command_b(3)
            B_temp1 = Command_b(2) + 4
            Mat(B_temp1) = Command_b(3)
            Gosub Send_data
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Else
   Command_not_found
   Gosub Command_received
End If
Return
'
06:
If K_mode = 2 Then
   If Commandpointer >= 5 Then
      If Command_b(2) < 5 Then
         If Command_b(3) < 5 Then
            If Command_b(4) < 5 Then
               If Command_b(5) < 5 Then
                  Mat(1) = Command_b(2)
                  Mat(2) = Command_b(3)
                  Mat(3) = Command_b(4)
                  Mat(4) = Command_b(5)
                  Mat(5) = Command_b(2)
                  Mat(6) = Command_b(3)
                  Mat(7) = Command_b(4)
                  Mat(8) = Command_b(5)
                  Gosub Send_data
               Else
                  Parameter_error
               End If
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
Else
   Command_not_found
   Gosub Command_received
End If
Return
'
07:
   Tx_time = 1
   Tx_b(1) = &H07
   Tx_b(2) = Mat(1)
   Tx_b(3) = Mat(2)
   Tx_b(4) = Mat(3)
   Tx_b(5) = Mat(4)
   Tx_b(6) = Mat(5)
   Tx_b(7) = Mat(6)
   Tx_b(8) = Mat(7)
   Tx_b(9) = Mat(8)
   Tx_write_pointer = 10
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
08:
If Commandpointer >= 2 Then
   If Command_b(2) < 3 Then
      K_mode = Command_b(2)
      K_mode_eeram = K_mode
      Gosub Switch_off_on
      Mat(1) = 0
      Mat(2) = 0
      Mat(3) = 0
      Mat(4) = 0
      Mat(5) = 0
      Mat(6) = 0
      Mat(7) = 0
      Mat(8) = 0
      Gosub Send_data
   Else
       Parameter_error
   End If
   Gosub Command_received
End If
Return
'
09:
Tx_time = 1
Tx_b(1) = &H09
Tx_b(2) = K_mode
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'