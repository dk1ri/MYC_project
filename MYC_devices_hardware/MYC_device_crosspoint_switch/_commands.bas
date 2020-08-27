' Commands
' 20200825
'
01:
If Commandpointer >= 3 Then
   If K_mode = 0 Then
      If Command_b(2) < 9 Then
         If Command_b(3) < 9 Then
            If Command_b(2) = 0 Then
               B_temp2 = Command_b(3)
               Gosub Output_off
            Else
               Mat(Command_b(2)) = Command_b(3)
            End If
            Gosub Copy_mat
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
If Commandpointer >= 9 Then
   If K_mode = 0 Then
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
                              Gosub Copy_mat
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
   Else
      Command_not_found
   End If
   Gosub Command_received
End If
Return
'
03:
If Commandpointer >= 3 Then
   If K_mode = 1 Then
      If Command_b(2) < 5 Then
         If Command_b(3) < 9 Then
            If Command_b(2) = 0 Then
               B_temp2 = Command_b(3)
               Gosub Output_off
            Else
               Mat(Command_b(2)) = Command_b(3)
               B_temp1 = Command_b(2) + 4
               Mat(B_temp1) = Command_b(3)
            End If
            Gosub Copy_mat
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
If Commandpointer >= 5 Then
   If K_mode = 1 Then
      If Command_b(2) < 9 Then
         If Command_b(3) < 9 Then
            If Command_b(4) < 9 Then
               If Command_b(5) < 9 Then
                  Mat(1) = Command_b(2)
                  Mat(2) = Command_b(3)
                  Mat(3) = Command_b(4)
                  Mat(4) = Command_b(5)
                  Mat(5) = Command_b(2)
                  Mat(6) = Command_b(3)
                  Mat(7) = Command_b(4)
                  Mat(8) = Command_b(5)
                  Gosub Copy_mat
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
      Command_not_found
   End If
   Gosub Command_received
End If
Return
'
'
05:
If Commandpointer >= 3 Then
   If K_mode = 2 Then
      If Command_b(2) < 5 Then
         If Command_b(3) < 5 Then
            If Command_b(2) = 0 Then
               B_temp2 = Command_b(3)
               Gosub Output_off
            Else
               Mat(Command_b(2)) = Command_b(3)
               B_temp1 = Command_b(2) + 4
               Mat(B_temp1) = Command_b(3) + 4
            End If
            Gosub Copy_mat
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
06:
If Commandpointer >= 5 Then
   If K_mode = 2 Then
      If Command_b(2) < 5 Then
         If Command_b(3) < 5 Then
            If Command_b(4) < 5 Then
               If Command_b(5) < 5 Then
                  Mat(1) = Command_b(2)
                  Mat(2) = Command_b(3)
                  Mat(3) = Command_b(4)
                  Mat(4) = Command_b(5)
                  Mat(5) = Command_b(2) + 4
                  Mat(6) = Command_b(3) + 4
                  Mat(7) = Command_b(4) + 4
                  Mat(8) = Command_b(5) + 4
                  Gosub Copy_mat
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
      Command_not_found
   End If
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
      Mat(1) = 0
      Mat(2) = 0
      Mat(3) = 0
      Mat(4) = 0
      Mat(5) = 0
      Mat(6) = 0
      Mat(7) = 0
      Mat(8) = 0
      ' set to GND
      M(1) = &B00001001
      M(2) = &B00001001
      M(3) = &B00001001
      M(4) = &B00001001
      M(5) = &B00001001
      M(6) = &B00001001
      M(7) = &B00001001
      M(8) = &B00001001
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
0A:
If Commandpointer >= 9 Then
   If Command_b(2) < 9 Then
      If Command_b(3) < 9 Then
         If Command_b(4) < 9 Then
            If Command_b(5) < 9 Then
               If Command_b(6) < 9 Then
                  If Command_b(7) < 9 Then
                     If Command_b(8) < 9 Then
                        If Command_b(9) < 9 Then
                           For B_temp1 = 1 To 8
                              If Mat(B_temp1) = 0 Then Mat(B_temp1) = &B00001000
                           Next B_temp1
                           Mat_eeram(1) = Command_b(2)
                           Mat_eeram(2) = Command_b(3)
                           Mat_eeram(3) = Command_b(4)
                           Mat_eeram(4) = Command_b(5)
                           Mat_eeram(5) = Command_b(6)
                           Mat_eeram(6) = Command_b(7)
                           Mat_eeram(7) = Command_b(8)
                           Mat_eeram(8) = Command_b(9)
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
Return
'
0B:
   Tx_time = 1
   Tx_b(1) = &H0B
   Tx_b(2) = Mat_eeram(1)
   Tx_b(3) = Mat_eeram(2)
   Tx_b(4) = Mat_eeram(3)
   Tx_b(5) = Mat_eeram(4)
   Tx_b(6) = Mat_eeram(5)
   Tx_b(7) = Mat_eeram(6)
   Tx_b(8) = Mat_eeram(7)
   Tx_b(9) = Mat_eeram(8)
   Tx_write_pointer = 10
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'