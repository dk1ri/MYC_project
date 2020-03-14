' Command 480 - 49F
' 20200310
'
480:
   Temps = Chr(&H1B) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
Return
'
481:
   If Commandpointer >= 11 Then
      If Command_b(3) < 30 Then
        'lower edge
        Temps = Chr(&H1E) + Chr(&H03)
        Temps_b(3) = Command_b(3)
        Frequenz_b(4) = Command_b(4)
        Frequenz_b(3) = Command_b(5)
        Frequenz_b(2) = Command_b(6)
        Frequenz_b(1) = Command_b(7)
        If Frequenz < 1240000000 Then
           Temps = Chr(&H1E) + Chr(&H03)
           Temps_b(3) = Command_b(3) + 1
           Temp_dw1 = Frequenz / 1000000
           B_temp1 = Temp_dw1
           Temps_b(7) = Makebcd(B_temp1)
           Frequenz = Frequenz Mod 10000000
           Frequenz = Frequenz Mod 1000000
           Temp_dw1 = Frequenz / 10000
           B_temp1 = Temp_dw1
           Temps_b(6) = Makebcd(B_temp1)
           Frequenz = Frequenz Mod 100000
           Frequenz = Frequenz Mod 10000
           Temp_dw1 = Frequenz / 100
           B_temp1 = Temp_dw1
           Temps_b(5) = Makebcd(B_temp1)
           Frequenz = Frequenz Mod 1000
           Frequenz = Frequenz Mod 100
           B_temp1 = Frequenz
           Temps_b(4) = Makebcd(B_temp1)
  '
           Temps_b(8) = &H00
           Temps_b(9) = &H2D
  '
  'high edge
           Frequenz_b(4) = Command_b(8)
           Frequenz_b(3) = Command_b(9)
           Frequenz_b(2) = Command_b(10)
           Frequenz_b(1) = Command_b(11)
           If Frequenz < 1240000000 Then
              Temp_dw1 = Frequenz / 1000000
              B_temp1 = Temp_dw1
              Temps_b(13) = Makebcd(B_temp1)
              Frequenz = Frequenz Mod 10000000
              Frequenz = Frequenz Mod 1000000
              Temp_dw1 = Frequenz / 10000
              B_temp1 = Temp_dw1
              Temps_b(12) = Makebcd(B_temp1)
              Frequenz = Frequenz Mod 100000
              Frequenz = Frequenz Mod 10000
              Temp_dw1 = Frequenz / 100
              B_temp1 = Temp_dw1
              Temps_b(11) = Makebcd(B_temp1)
              Frequenz = Frequenz Mod 1000
              Frequenz = Frequenz Mod 100
              B_temp1 = Frequenz
              Temps_b(10) = Makebcd(B_temp1)
              Temps_b(4) = &H00
              Civ_len = 14
              Gosub Civ_print
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
482:
   Temps = Chr(&H1E) + Chr(&H03)
   Civ_len = 2
   Gosub Civ_print
Return
'
483:
   Temps = Chr(&H1F) + Chr(&H00)
   For B_temp1 = 3 To 26
      Temps_b(B_temp1) = " "
   Next B_temp1
   Civ_len = 26
   If Commandpointer >= 3 Then
      If Command_b(3) < 9 Then
         B_temp1 = Command_b(3) + 4
         If Commandpointer >= B_temp1 Then
            If Command_b(B_temp1) < 9 Then
               B_temp1 = B_temp1 + Command_b(B_temp1)
               Incr B_temp1
               If Commandpointer >= B_temp1 Then
                  If Command_b(B_temp1) < 9 Then
                     ' ok now
                     B_temp2 = 3
                     ' Pointer to Temps
                     B_temp3 = 3
                     ' Pointer to Command
                     If Command_b(B_temp3) > 0 Then
                        B_temp4 = Command_b(B_temp3)
                        For B_temp1 = 1 To B_temp4
                           Temps_b(B_temp2) = Command_b(B_temp3)
                           Incr B_temp2
                           Incr B_temp3
                        Next B_temp1
                     Else
                        Incr B_temp3
                     End If
                     If Command_b(B_temp3) > 0 Then
                        B_temp4 = Command_b(B_temp3)
                        For B_temp1 = 1 To B_temp4
                           Temps_b(B_temp2) = Command_b(B_temp3)
                           Incr B_temp2
                           Incr B_temp3
                        Next B_temp1
                     Else
                        Incr B_temp3
                     End If
                     If Command_b(B_temp3) > 0 Then
                        B_temp4 = Command_b(B_temp3)
                        For B_temp1 = 1 To B_temp4
                           Temps_b(B_temp2) = Command_b(B_temp3)
                           Incr B_temp2
                           Incr B_temp3
                        Next B_temp1
                     End If
                     Gosub Civ_print
                  Else
                     Parameter_error
                  End If
               End If
            Else
               Parameter_error
            End If
         End If
      Else
         Parameter_error
      End If
   End If
Return
'
484:
   Temps = Chr(&H1F) + Chr(&H00)
   Civ_len = 2
   Gosub Civ_print
Return
'
485:
   B_temp1 = 2
   Civ_cmd1 = &H1F
   Civ_cmd2 = &H01
   Gosub Civ_print_l_3
Return
'
486:
   Temps = Chr(&H1F) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
Return
'
487:
   Temps = Chr(&H1F) + Chr(&H03)
   B_temp1 = 21
   Gosub Send_text_x
Return
'
488:
   Temps = Chr(&H1F) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
Return
'
489:
   If Commandpointer >= 4 Then
   '2 byte frequency,
      W_temp1_h = Command_b(3)
      W_temp1_l = Command_b(4)
      If W_temp1 < 19999 Then
         Temps= Chr(&H21) + Chr(&H00)
         If W_temp1 > 9999 Then
            Temps_b(5) = 0
            W_temp1 = W_temp1 - 9999
         Else
            Temps_b(5) = 1
            W_temp1 = 9999 - W_temp1
         End If
         '
         W_temp2 = W_temp1 / 100
         B_temp1 = W_temp2
         Temps_b(4) =  Makebcd(B_temp1)
         W_temp1 = W_temp1 Mod 1000
         W_temp1 = W_temp1 Mod 100
         B_temp1 = W_temp1
         Temps_b(3) =  Makebcd(B_temp1)
         Civ_len = 5
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
48A:
   Temps = Chr(&H21) + Chr(&H00)
   Civ_len = 2
   Gosub Civ_print
Return
'
48B:
   B_temp1 = 2
   Civ_cmd1 = &H21
   Civ_cmd2 = &H01
   Gosub Civ_print_l_3
Return
'
48C:
   Temps = Chr(&H21) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
Return
'
48D:
   Temps = Chr(&H22) + Chr(&H00)
   B_temp1 = 30
   Gosub Send_text_x
Return
'
48E:
   Temps = Chr(&H22) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
Return
'
48F:
   B_temp1 = 2
   Civ_cmd1 = &H22
   Civ_cmd2 = &H00
   Civ_cmd4 = &H00
   Gosub Civ_print_l_4
Return
'
490:
   Temps = Chr(&H22) + Chr(&H01) + Chr(&H00)
   Civ_len = 3
   Gosub Civ_print
Return
'
491:
   Temps = Chr(&H22) + Chr(&H01)  + Chr(&H01)
   B_temp1 = 30
   Gosub Send_text_x_3
Return
'
492:
   Temps = Chr(&H22) + Chr(&H01) + Chr(&H01)
   Civ_len = 3
   Gosub Civ_print
Return
'
493:
   B_temp1 = 2
   Civ_cmd1 = &H22
   Civ_cmd2 = &H02
   Gosub Civ_print_l_3
Return
'
494:
   Temps = Chr(&H22) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
Return
'
495:
   B_temp1 = 2
   Civ_cmd1 = &H22
   Civ_cmd2 = &H03
   Gosub Civ_print_l_3
Return
'
496:
   Temps = Chr(&H22) + Chr(&H03)
   Civ_len = 2
   Gosub Civ_print
Return
'
497:
   B_temp1 = 2
   Civ_cmd1 = &H22
   Civ_cmd2 = &H04
   Gosub Civ_print_l_3
Return
'
498:
   Temps = Chr(&H22) + Chr(&H04)
   Civ_len = 2
   Gosub Civ_print
Return
'
499:
   B_temp1 = 2
   Civ_cmd1 = &H22
   Civ_cmd2 = &H05
   Gosub Civ_print_l_3_bcd
Return
'
49A:
   Temps = Chr(&H22) + Chr(&H05)
   Civ_len = 2
   Gosub Civ_print
Return
'
49B:
   Civ_len = 0
   Gosub Civ_print
Return
'
49C:
   Temps = Chr(&H23) + Chr(&H00)
   Civ_len = 2
   Gosub Civ_print
Return
'
49D:
   Temps = Chr(&H23) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
Return
'
49E:
If Commandpointer >= 3 Then
   If Command_b(3) < 3 Then
      Temps = Chr(&H23) + Chr(&H01)
      Temps_b(3) = Command_b(3)
      If Temps_b(3) > 0 Then Incr Temps_b(3)
      Civ_len = 3
      Gosub Civ_print
   Else
      Parameter_error
      Gosub Command_received
   End If
End If
Return
'
49F:
   If Commandpointer >= 13 Then
      If Command_b(3) < 99 And Command_b(6) < 2 And Command_b(10) < 2 And Command_b(13) < 2 Then
         W_temp1 = Command_b(4) * 256
         W_temp1 = Command_b(5) + W_temp1
         W_temp2 = Command_b(8) * 256
         W_temp2 = Command_b(9) + W_temp2
         W_temp3 = Command_b(11) * 256
         W_temp3 = W_temp3 + Command_b(12)
         If W_temp1 < 59999 And Command_b(7) < 199 And W_temp2 < 599999 And W_temp3 < 199999 Then
            ' Lat
            Temps = Chr(&H23) + Chr(&H02)
            '
            Temps_b(3) = Makebcd(Command_b(3))
            '
            B_temp1 = W_temp1 / 1000
            Temps_b(4) = Makebcd(B_temp1)
            W_temp1 = W_temp1 Mod 1000
            B_temp1 = W_temp1 / 10
            Temps_b(5) = Makebcd(B_temp1)
            B_temp1 = W_temp1 Mod 10
            B_temp1 = B_temp1  * 16
            Temps_b(6) = Makebcd(B_temp1)
            '
            Temps_b(7) = Command_b(6)
            ' Long
            B_temp1 = Command_b(7) / 100
            Temps_b(8) = Makebcd(B_temp1)
            B_temp1 = Command_b(7) Mod 100
            Temps_b(9) = Makebcd(B_temp1)
            '
            B_temp1 = W_temp2 / 1000
            Temps_b(10) = Makebcd(B_temp1)
            W_temp2 = W_temp2 Mod 1000
            B_temp1 = W_temp2 / 10
            Temps_b(11) = Makebcd(B_temp1)
            B_temp1 = W_temp2 Mod 10
            B_temp1 = B_temp1  * 16
            Temps_b(12) = Makebcd(B_temp1)
            Temps_b(13) = Command_b(10)
            ' alt
            B_temp1 = W_temp3 / 1000
            Temps_b(14) = Makebcd(B_temp1)
            W_temp3 = W_temp3 Mod 1000
            B_temp3 = W_temp3 / 10
            Temps_b(15) = Makebcd(B_temp1)
            B_temp1 = W_temp2 Mod 10
            Temps_b(16) = Makebcd(B_temp1)
            Temps_b(17) = Command_b(13)
            Civ_len = 17
            Gosub Civ_print
         Else
            Parameter_error
         End if
      Else
         Parameter_error
      End If
   End If
Return
'