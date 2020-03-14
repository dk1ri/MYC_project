' Command 240 - 25F
' 20200314
 '
240:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H03)
   Civ_len = 4
   Gosub Civ_print
Return
'
241:
   B_temp1 = 3
   Civ_cmd4 = &H04
   Gosub Civ_print_l_5_1a0501_bcd
Return
'
242:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H04)
   Civ_len = 4
   Gosub Civ_print
Return
'
243:
   B_temp1 = 2
   Civ_cmd4 = &H05
   Gosub Civ_print_l_5_1a0501_bcd
Return
'
244:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H05)
   Civ_len = 4
   Gosub Civ_print
Return
'
245:
   B_temp1 = 2
   Civ_cmd4 = &H06
   Gosub Civ_print_l_5_1a0501_bcd
Return
'
246:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H06)
   Civ_len = 4
   Gosub Civ_print
Return
'
247:
   B_temp1 = 2
   Civ_cmd4 = &H07
   Gosub Civ_print_l_5_1a0501_bcd
Return
'
248:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H07)
   Civ_len = 4
   Gosub Civ_print
Return
'
249:
   B_temp1 = 2
   Civ_cmd4 = &H08
   Gosub Civ_print_l_5_1a0501_bcd
Return
'
24A:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H08)
   Civ_len = 4
   Gosub Civ_print
Return
'
24B:
   B_temp1 = 2
   Civ_cmd4 = &H09
   Gosub Civ_print_l_5_1a0501_bcd
Return
'
24C:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H09)
   Civ_len = 4
   Gosub Civ_print
Return
'
24D:
   B_temp1 = 2
   Civ_cmd4 = &H10
   Gosub Civ_print_l_5_1a0501_bcd
Return
'
24E:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H10)
   Civ_len = 4
   Gosub Civ_print
Return
'
24F:
   B_temp1 = 3
   Civ_cmd4 = &H11
   Gosub Civ_print_l_5_1a0501_bcd
Return
'
250:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H11)
   Civ_len = 4
   Gosub Civ_print
Return
'
251:
   Civ_cmd4 = &H12
   Gosub Civ_print_255_6_1a0501_bcd
Return
'
252:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H12)
   Civ_len = 4
   Gosub Civ_print
Return
'
253:
   Civ_cmd4 = &H13
   Gosub Civ_print_255_6_1a0501_bcd
Return
'
254:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H13)
   Civ_len = 4
   Gosub Civ_print
Return
'
255:
   B_temp1 = 16
   Civ_cmd4 = &H14
   Gosub Civ_print_l_5_1a0501_bcd
Return
'
256:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H14)
   Civ_len = 4
   Gosub Civ_print
Return
'
257:
   Civ_cmd4 = &H15
   Gosub Civ_print_255_6_1a0501_bcd
Return
'
258:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H15)
   Civ_len = 4
   Gosub Civ_print
Return
'
259:
   Civ_cmd4 = &H16
   Gosub Civ_print_255_6_1a0501_bcd
Return
'
25A:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H16)
   Civ_len = 4
   Gosub Civ_print
Return
'
25B:
   B_temp1 = 21
   Civ_cmd4 = &H17
   Gosub Civ_print_l_5_1a0501_bcd
Return
'
25C:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H17)
   Civ_len = 4
   Gosub Civ_print
Return
'
25D:
   B_temp1 = 4
   Civ_cmd4 = &H18
   Gosub Civ_print_l_5_1a0501_bcd
Return
'
25E:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H18)
   Civ_len = 4
   Gosub Civ_print
Return
'
25F:
If Commandpointer >= 3 Then
   If Command_b(3) < 111 Then
      Temps = Chr(&H1A) + Chr(&H05) +Chr(&H01) + Chr(&H19)
      Temps_b(5) = Command_b(3) / 100
      B_temp1 = Command_b(3) Mod 100
      Temps_b(6) = Makebcd(B_Temp1)
      Civ_len = 6
      Gosub Civ_print
   Else
      Parameter_error
      Gosub Command_received
   End If
End If
Return