' additional commands
'20230501
'
01:
   If Commandpointer >= 2 Then
      Select Case Command_b(2)
         Case 0
            'string empty
            Gosub Command_received
         Case Is > b_Chars
            Parameter_error
            Gosub Command_received
      End Select
      If Commandpointer >= 3 Then
         B_temp3 = Command_b(2) + 2
         If Commandpointer >= b_Temp3 Then
            For b_Temp2= 3 To Commandpointer
               LCD Chr(Command_b(b_Temp2))
               Incr b_Col
               If b_Col > b_Chars2 Then
                  If b_Row = 2 Then
                     b_Row = 1
                     Home Upper
                  Else
                     b_Row = 2
                     Home Lower
                  End If
                  b_Col = 1
               End If
            Next b_Temp2
            Gosub Command_received
         End If
      End If
   End If
Return
'
02:
If Commandpointer >= 2 Then
   If Command_b(2) > B_chars Then
      Parameter_error
      Gosub Command_received
   End If
   If Commandpointer >= 3 Then
      If Command_b(3) > 0 Then
         If Command_b(3) > B_chars Then
            Parameter_error
            Gosub Command_received
         Else
            B_temp2 = Command_b(3) + 3
            If Commandpointer >= B_temp2 Then
               If Command_b(2) > B_chars2 Then
                  b_Row = 2
               Else
                  b_Row = 1
               End If
               b_Temp3 = b_Row - 1
               b_Temp3 = b_Temp3 * b_Chars2
               b_Col = Command_b(2) - b_Temp3
               Incr b_Col
               'Command_b(2) is 0 based, Col 1 based
               Locate b_Row , b_Col
               For b_Temp2 = 4 To Commandpointer
                  LCD Chr(Command_b(b_Temp2))
                  Incr b_Col
                  If b_Col > b_Chars2 Then
                     If b_Row = 2 Then
                        b_Row = 1
                        Home Upper
                     Else
                        b_Row = 2
                        Home Lower
                     End If
                     b_Col = 1
                  End If
               Next b_Temp2
               Gosub Command_received
            End If
         End If
      End If
   End If
End If
Return
'
03:
If Commandpointer >= 2 Then
   If Command_b(2) < b_Chars Then
   'Command_b(2): 0 ... Chars - 1
      If Command_b(2) >= b_Chars2 Then
         b_Row = 2
      Else
         b_Row = 1
      End If
      b_Temp3 = b_Row - 1
      b_Temp3 = b_Temp3 * b_Chars2
      b_Col = Command_b(2) - b_Temp3
      Incr b_Col
      Locate b_Row , b_Col
   Else_Parameter_error
   Gosub Command_received
End If
Return
'
04:
   CLS
   Gosub Command_received
Return
'
05:
   If Commandpointer >= 2 Then
      B_cmp1 = Command_b(2)
      B_cmp1_eeram = B_cmp1
      Pwm1a = B_Cmp1
      Gosub Command_received
   End If
Return
'
06:
   Tx_time = 1
   Tx_b(1) = &H06
   Tx_b(2) = B_cmp1
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'