' IC7300 Command 02E. 2F
' 191030
'
2E0:
   If Commandpointer >= 3 Then
      If Command_b(3) < 2 Then
         Temps = Chr(&H25)
         Temps_b(2) = Command_b(3)
         Civ_len = 2
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
2E1:
   If Commandpointer >= 5 Then
      If Command_b(3) < 2 And Command_b(4) < 12 And Command_b(5) < 3 Then
         Temps = Chr(&H26)
         Temps_b(2) = Command_b(3)
         If Command_b(4) < 8 Then
            Temps_b(3) = Command_b(4)
            If Temps_b(3) > 5 Then Incr Tx_b(3)
            Temps_b(4) = &H00
         Else
            Temps_b(4) = &H01
            If Command_b(4) = 11 Then
               Temps_b(3) = &H05
            Else
               Temps_b(3) = Command_b(4) - 8
            End If
         End If
         Temps_b(5) = Command_b(5) + 1
         Civ_len = 5
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
2E2:
   If Commandpointer >= 3 Then
      If Command_b(3) < 2 Then
         Temps = Chr(&H26)
         Temps_b(2) = Command_b(3)
         Civ_len = 2
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
2E3:
   Gosub Command_received
Return
'
2E4:
   B_temp1 = 2
   Civ_cmd1 = &H27
   Civ_cmd2 = &H10
   Gosub Civ_print_l_3
Return
'
2E5:
   Temps = Chr(&H27) + Chr(&H10)
   Civ_len = 2
   Gosub Civ_print
Return
'
2E6:
   B_temp1 = 2
   Civ_cmd1 = &H27
   Civ_cmd2 = &H11
   Gosub Civ_print_l_3
   Return
'
2E7:
   Temps = Chr(&H27) + Chr(&H11)
   Civ_len = 2
   Gosub Civ_print
Return
'
2E8:
   Temps = Chr(&H27) + Chr(&H12)
   Civ_len = 2
   Gosub Civ_print
Return
'
2E9:
   Temps = Chr(&H27) + Chr(&H13)
   Civ_len = 2
   Gosub Civ_print
Return
'
2EA:
   If Commandpointer >= 3 Then
      If Command_b(3) < 2 Then
         Temps = Chr(&H27) + Chr(&H14) + Chr(&H00)
         Temps_b(4) = Command_b(3)
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
2EB:
   Temps = Chr(&H27) + Chr(&H14)
   Temps_b(3) = &H00
   Civ_len = 3
   Gosub Civ_print
Return
'
2EC:
   If Commandpointer >= 3 Then
      If Command_b(3) < 8 Then
         Temps = Chr(&H27) + Chr(&H15)
         Temps_b(3) = &H00
         Temps_b(4) = &H00
         Select case Command_b(3)
            Case 0
               Temps_b(5) = &H25
               Temps_b(6) = &H00
            Case 1
               Temps_b(5) = &H25
               Temps_b(6) = &H00
            Case 2
               Temps_b(5) = &H00
               Temps_b(6) = &H01
            Case 3
               Temps_b(5) = &H50
               Temps_b(6) = &H02
            Case 4
               Temps_b(5) = &H00
               Temps_b(6) = &H05
            Case 5
               Temps_b(5) = &H00
               Temps_b(6) = &H10
            Case 6
               Temps_b(5) = &H00
               Temps_b(6) = &H25
            Case 7
               Temps_b(5) = &H00
               Temps_b(6) = &H50
         End Select
         Temps_b(7) = &H00
         Temps_b(8) = &H00
         Civ_len = 8
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
2ED:
   Temps = Chr(&H27) + Chr(&H15)
   Temps_b(3) = &H00
   Civ_len = 3
   Gosub Civ_print
Return
'
2EE:
   If Commandpointer >= 3 Then
      If Command_b(3) < 3 Then
         Temps = Chr(&H27) + Chr(&H16)
         Temps_b(3) = &H00
         Temps_b(4) = Command_b(3) + 1
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
2EF:
   Temps = Chr(&H27) + Chr(&H16)
   Temps_b(3) = &H00
   Civ_len = 3
   Gosub Civ_print
Return
'
2F0:
   If Commandpointer >= 3 Then
      If Command_b(3) < 2 Then
         Temps = Chr(&H27) + Chr(&H17)
         Temps_b(3) = &H00
         Temps_b(4) = Command_b(3)
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
2F1:
   Temps = Chr(&H27) + Chr(&H17)
   Temps_b(3) = &H00
   Civ_len = 3
   Gosub Civ_print
Return
'
2F2:
   If Commandpointer >= 3 Then
      If Command_b(3) < 81 Then
         Temps = Chr(&H27) + Chr(&H19)
         Temps_b(3) = &H00
         If Command_b(3) < 40 Then
            B_temp1 = 40 - Command_b(3)
            Temps_b(6) = 1
         Else
            B_temp1 = Command_b(3) - 40
            Temps_b(6) = 0
         End If
         B_temp2 = B_temp1 / 2
         Temps_b(4) = Makebcd(B_temp2)
         Temps_b(5) = B_temp1 Mod 2
         Temps_b(5) = Temps_b(5) * &H50
         Civ_len = 6
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
2F3:
   Temps = Chr(&H27) + Chr(&H19)
   Temps_b(3) = &H00
   Civ_len = 3
   Gosub Civ_print
Return
'
2F4:
   If Commandpointer >= 3 Then
      If Command_b(3) < 3 Then
         Temps = Chr(&H27) + Chr(&H1A)
         Temps_b(3) = &H00
         Temps_b(4) = Command_b(3)
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
2F5:
   Temps = Chr(&H27) + Chr(&H1A)
   Temps_b(3) = &H00
   Civ_len = 3
   Gosub Civ_print
Return
'
2F6:
   B_temp1 = 2
   Civ_cmd1 = &H27
   Civ_cmd2 = &H1B
   Gosub Civ_print_l_3
Return
'
2F7:
   Temps = Chr(&H27) + Chr(&H1B)
   Civ_len = 2
   Gosub Civ_print
Return
'
2F8:
   B_temp1 = 3
   Civ_cmd1 = &H27
   Civ_cmd2 = &H1C
   Gosub Civ_print_l_3
Return
'
2F9:
   Temps = Chr(&H27) + Chr(&H1C)
   Civ_len = 2
   Gosub Civ_print
Return
'
2FA:
   If Commandpointer >= 3 Then
      If Command_b(3) < 2 Then
         Temps = Chr(&H27) + Chr(&H1D)
         Temps_b(3) = &H00
         Temps_b(4) = Command_b(3)
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
2FB:
   Temps = Chr(&H27) + Chr(&H1D)
   Temps_b(3) = &H00
   Civ_len = 3
   Gosub Civ_print
Return
'
2FC:
   ' Frequncy
   If Commandpointer >= 7 Then
      If Command_b(3) < 100 Then
         D_temp2 = 69970000
         B_temp5 = 4
         B_temp4 = 1
         Gosub S_frequency
         If Temps <> "" Then
            ' Copy Frequency to Memorycontent
            W_temp1 = Command_b(3) * 39
            W_temp1 = W_temp1 + 2
            For B_temp1 = 1 To 4
               Memorycontent_b(W_temp1) = Temps_b(B_temp1)
               Incr W_temp1
            Next B_temp1
            B_temp1 = 1
            Gosub Mem_to_civ
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
2FD:
   Mem_function = 2
   Gosub S_Read_mem
Return
'
2FE:
   ' mode
   If Commandpointer >= 4 Then
      If Command_b(3) < 100 And Command_b(4) < 8 Then
         W_temp1 = Command_b(3) * 39
         W_temp1 = W_temp1 + 7
         If Command_b(4) > 5 Then Incr Command_b(4)
         Memorycontent_b(W_temp1) = Command_b(4)
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
2FF:
   Mem_function = 3
   Gosub S_Read_mem
Return