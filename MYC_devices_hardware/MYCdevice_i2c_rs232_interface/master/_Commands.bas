' Commands
' 20200423
'
01:
If No_myc = 1 Then
   If Commandpointer >= 2 Then
      If Command_b(2) = 0 Then
         Gosub Command_received
      Else
         If Command_b(2) > Stringlength Then
            Parameter_error
            Gosub Command_received
         Else
            I2c_len = Command_b(2) + 2
            If Commandpointer >= I2c_len Then
               'string finished
               I2c_start = 3
               I2c_len = I2c_len - 2
               I2c_s
               Gosub Command_received
            End If
         End If
      End If
   End If
Else
   Command_not_found
   Gosub Command_received
End If
Return
'
02:
If No_myc = 1 Then
   If Commandpointer >= 2 Then
      If Command_b(2) <> 0 Then
         If Command_b(2) > Stringlength Then
            Parameter_error
         Else
            ' get data
            I2c_len = Command_b(2)
            I2c_rec
         End If
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
If No_myc = 0 Then
   Tx_time = 1
   A_line = 3
   Number_of_lines = 1
   Gosub Sub_restore
   Gosub Print_tx
Else
   Command_not_found
End If
Gosub Command_received
Return
'
04:
If No_myc = 0 Then
   If Commandpointer >= 2 Then
      If Command_b(2) = 0 Then
         Gosub Command_received
      Else
         If Command_b(2) > Stringlength Then
            Parameter_error
            Gosub Command_received
         Else
            B_Temp1 = Command_b(2) + 2
            If Commandpointer >= B_Temp1 Then
               'string finished
               Command_b(1) = 1
               I2c_len = Command_b(2) + 2
               I2c_start = 1
               I2c_s
               Gosub Command_received
            End If
         End If
      End If
   End If
Else
   Command_not_found
   Gosub Command_received
End If
Return
'
05:
If No_myc = 0 Then
   Tx_time = 1
   ' copy RS232 to I2C
   I2c_len = 1
   I2c_start = 1
   Command_b(1) = 2
   I2c_s
   If I2c_len = 1 Then
      'find length
      I2c_r
      If I2c_len > 0 Then
         Printbin &H12
         printbin I2c_len
         ' get data
         I2c_rec
      End If
   End If
Else
   Command_not_found
End If
      Gosub Command_received
Return
'
06:
If No_myc = 0 Then
   I2c_len = 1
   I2c_start = 1
   Command_b(1) = &HFC
   I2c_s
   If I2c_len = 1 Then
      'find length
      I2c_r
      If I2c_len > 0 Then
         Printbin &H12
         printbin I2c_len
         ' get data
         I2c_rec
      End If
   End If
Else
   Command_not_found
End If
Gosub Command_received
Return
'
07:
If No_myc = 0 Then
   I2c_len = 1
   I2c_start = 1
   Command_b(1) = &HFD
   I2c_s
   If I2c_len = 1 Then
      Printbin &H14
      I2c_rec
   End If
Else
   Command_not_found
End If
Gosub Command_received
Return
'
08:                                           '
If Commandpointer >= 2 Then
   If Command_b(2) < 128 And Command_b(2) > 0 Then
      Adress_ = Command_b(2) * 2
      Adress__eeram = Adress_
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
09:
printbin &H09
B_temp1 = Adress_ / 2
Printbin B_temp1
Gosub Command_received
Return                               '
'
10:                                          '
If Commandpointer >= 2 Then
   Select Case Command_b(2)
      Case 0
         no_myc = 0
         no_myc_eeram = 0
      Case 1
         no_myc = 1
         no_myc_eeram = 1
      Case Else
         Parameter_error
   End Select
   Gosub Command_received
End If
Return
'
11:
Printbin &H0B
Printbin no_myc
Gosub Command_received
Return                          '