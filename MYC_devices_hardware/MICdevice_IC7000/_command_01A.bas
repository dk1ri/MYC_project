' Command 1A0 - 1BF
' 20200219
'
1A0:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H23)
   Civ_len = 4
   Gosub Civ_print
Return
'
1A1:
   B_temp1 = 2
   Civ_cmd4 = &H24
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1A2:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H24)
   Civ_len = 4
   Gosub Civ_print
Return

1A3:
   B_temp1 = 2
   Civ_cmd4 = &H25
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1A4:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H25)
   Civ_len = 4
   Gosub Civ_print
Return
'
1A5:
   B_temp1 = 2
   Civ_cmd4 = &H26
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1A6:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H26)
   Civ_len = 4
   Gosub Civ_print
Return
'
1A7:
   B_temp1 = 2
   Civ_cmd4 = &H27
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1A8:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H27)
   Civ_len = 4
   Gosub Civ_print
Return
'
1A9:
   B_temp1 = 2
   Civ_cmd4 = &H28
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1AA:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H28)
   Civ_len = 4
   Gosub Civ_print
Return
'
1AB:
   B_temp1 = 2
   Civ_cmd4 = &H29
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1AC:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H29)
   Civ_len = 4
   Gosub Civ_print
Return
'
1AD:
   B_temp1 = 2
   Civ_cmd4 = &H30
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1AE:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H30)
   Civ_len = 4
   Gosub Civ_print
Return
'
1AF:
   B_temp1 = 2
   Civ_cmd4 = &H31
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1B0:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H31)
   Civ_len = 4
   Gosub Civ_print
Return
'
1B1:
   B_temp1 = 2
   Civ_cmd4 = &H32
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1B2:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H32)
   Civ_len = 4
   Gosub Civ_print
Return
'
1B3:
   B_temp1 = 2
   Civ_cmd4 = &H33
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1B4:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H33)
   Civ_len = 4
   Gosub Civ_print
Return
'
1B5:
   B_temp1 = 2
   Civ_cmd4 = &H34
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1B6:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H34)
   Civ_len = 4
   Gosub Civ_print
Return
'
1B7:
   B_temp1 = 2
   Civ_cmd4 = &H35
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1B8:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H35)
   Civ_len = 4
   Gosub Civ_print
Return
'
1B9:
   B_temp1 = 2
   Civ_cmd4 = &H36
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1BA:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H36)
   Civ_len = 4
   Gosub Civ_print
Return
'
1BB:
   If Commandpointer >= 3 Then
      B_temp1 = Command_b(3)
      If B_temp1 > 0 Then
         If Command_b(3) < 11 Then
            B_temp2 = B_temp1 + 3
            If Commandpointer >= B_temp2 Then
               Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H37)
               For B_temp3 = 1 To B_temp1
                Temps_b(B_temp3 + 4) = Command_b(B_temp3 + 3)
               Next B_temp3
              Civ_len = 4 + B_temp1
              Gosub Civ_print
            End If
         Else
            Parameter_error
         End If
      End If
   End If
Return
'
1BC:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H37)
   Civ_len = 4
   Gosub Civ_print
Return
'
1BD:
   B_temp1 = 2
   Civ_cmd4 = &H38
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1BE:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H38)
   Civ_len = 4
   Gosub Civ_print
Return
'
1BF:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H39) + Chr(&H20)
   Temps_b(6) = Makebcd(Command_b(3))
   Civ_len = 6
   Gosub Civ_print
Return