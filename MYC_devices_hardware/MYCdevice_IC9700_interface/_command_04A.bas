' Command 4A0 - 4BF
' 20200314
'
4A0:
   Temps = Chr(&H23) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
Return
'
4A1:
   B_temp1 = 2
   Civ_cmd1 = &H24
   Civ_cmd2 = &H00
   Civ_cmd3 = &H00
   Gosub Civ_print_l_4
Return
'
4A2:
   Temps = Chr(&H24) + Chr(&H00) + Chr(&H00)
   Civ_len = 2
   Gosub Civ_print
Return
'
4A3:
   B_temp1 = 2
   Civ_cmd1 = &H24
   Civ_cmd2 = &H00
   Civ_cmd3 = &H01
   Gosub Civ_print_l_4
Return
'
4A4:
   Temps = Chr(&H24) + Chr(&H00) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
Return
'
4A5:
   If Commandpointer >= 7 Then
      If Command_b(3) < 2 Then
         Temps = Chr(&H25)
         Temps_b(2) = Command_b(3)
         D_temp2 = 69970000
         B_temp5 = 4
         B_temp4 = 3
         Gosub S_frequency
          Civ_len = 7
         Gosub Civ_print
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
4A6:
   Temps = Chr(&H25)
   Civ_len = 1
   Gosub Civ_print
Return
'
4A7:
   If Commandpointer >= 5 Then
      If Command_b(3) < 2 And Command_b(4) < 10 And Command_b(5) < 3 Then
         Temps = Chr(&H26)
         Temps_b(2) = Command_b(3)
         If Command_b(4) < 6 Then
            Temps_b(3) = Command_b(4)
         Else
            Temps_b(3) = Command_b(4) + 1
         End If
         Temps_b(4) = 0
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
4A8:
   Temps = Chr(&H26)
   Civ_len = 1
   Gosub Civ_print
Return
'
4A9:
   Temps = Chr(&H27) + Chr(&H00)
   Civ_len = 1
   Gosub Civ_print
Return
'
4AA:
   B_temp1 = 2
   Civ_cmd1 = &H27
   Civ_cmd2 = &H10
   Gosub Civ_print_l_3
Return
'
4AB:
   Temps = Chr(&H27) + Chr(&H10)
   Civ_len = 2
   Gosub Civ_print
Return
'
4AC:
   B_temp1 = 2
   Civ_cmd1 = &H27
   Civ_cmd2 = &H11
   Gosub Civ_print_l_3
Return
'
4AD:
   Temps = Chr(&H27) + Chr(&H11)
   Civ_len = 2
   Gosub Civ_print
Return
'
4AE:
   B_temp1 = 2
   Civ_cmd1 = &H27
   Civ_cmd2 = &H12
   Gosub Civ_print_l_3
Return
'
4AF:
   Temps = Chr(&H27) + Chr(&H12)
   Civ_len = 2
   Gosub Civ_print
Return
'
4B0:
   If Commandpointer >= 4 Then
      If Command_b(3) < 2 And Command_b(4) < 2 Then
         Temps = Chr(&H27) + Chr(&H14)
         Temps_b(3) = Command_b(3)
         Temps_b(4) = Command_b(4)
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
4B1:
   Temps = Chr(&H27) + Chr(&H14)
   Civ_len = 2
   Gosub Civ_print
Return
'
4B2:
   If Commandpointer >= 4 Then
      If Command_b(3) < 2 And Command_b(4) < 8 Then
         Temps = Chr(&H27) + Chr(&H15)
         Temps_b(3) = Command_b(3)
         Temps_b(4) = &H00
         Select case Command_b(4)
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
4B3:
   Temps = Chr(&H27) + Chr(&H15)
   Civ_len = 2
   Gosub Civ_print
Return
'
4B4:
   If Commandpointer >= 4 Then
      If Command_b(3) < 2 And Command_b(4) < 3 Then
         Temps = Chr(&H27) + Chr(&H16)
         Temps_b(3) = Command_b(3)
         Temps_b(4) = Command_b(3) + 1
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
'
4B5:
   Temps = Chr(&H27) + Chr(&H16)
   Civ_len = 2
   Gosub Civ_print
Return
'
4B6:
   If Commandpointer >= 4 Then
      If Command_b(3) < 2 And Command_b(4) < 2 Then
         Temps = Chr(&H27) + Chr(&H17)
         Temps_b(3) = Command_b(3)
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
4B7:
   Temps = Chr(&H27) + Chr(&H17)
   Civ_len = 2
   Gosub Civ_print
Return
'
4B8:
   If Commandpointer >= 4 Then
      If Command_b(3) < 2 And Command_b(4) < 81 Then
         Temps = Chr(&H27) + Chr(&H19)
         Temps_b(3) = Command_b(3)
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
4B9:
   Temps = Chr(&H27) + Chr(&H19)
   Civ_len = 2
   Gosub Civ_print
Return
'
4BA:
   If Commandpointer >= 4 Then
      If Command_b(3) < 2 And Command_b(4) < 3 Then
         Temps = Chr(&H27) + Chr(&H1A)
         Temps_b(3) = Command_b(4)
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
4BB:
   Temps = Chr(&H27) + Chr(&H1A)
   Civ_len = 2
   Gosub Civ_print
Return
'
4BC:
   B_temp1 = 2
   Civ_cmd1 = &H27
   Civ_cmd2 = &H1B
   Gosub Civ_print_l_3
Return
'
4BD:
   Temps = Chr(&H27) + Chr(&H1B)
   Civ_len = 2
   Gosub Civ_print
Return
'
4BE:
   B_temp1 = 3
   Civ_cmd1 = &H27
   Civ_cmd2 = &H1C
   Gosub Civ_print_l_3
Return
'
4BF:
   Temps = Chr(&H27) + Chr(&H1C)
   Civ_len = 2
   Gosub Civ_print
Return
'