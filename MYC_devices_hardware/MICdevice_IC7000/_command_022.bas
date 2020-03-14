' Command 220 - 23F
' 20200221
 '
220:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H87)
   Civ_len = 4
   Gosub Civ_print
Return
'
221:
   B_temp1 = 2
   Civ_cmd4 = &H88
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
222:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H88)
   Civ_len = 4
   Gosub Civ_print
Return
'
223:
   B_temp1 = 2
   Civ_cmd4 = &H89
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
224:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H89)
   Civ_len = 4
   Gosub Civ_print
Return
'
225:
   B_temp1 = 2
   Civ_cmd4 = &H90
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
226:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H90)
   Civ_len = 4
   Gosub Civ_print
Return
'
227:
   B_temp1 = 2
   Civ_cmd4 = &H91
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
228:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H91)
   Civ_len = 4
   Gosub Civ_print
Return
'
229:
   B_temp1 = 2
   Civ_cmd4 = &H92
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
22A:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H92)
   Civ_len = 4
   Gosub Civ_print
Return
'
22B:
   Civ_cmd4 = &H93
   Gosub Civ_print_255_6_1a0500_bcd
Return
'
22C:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H93)
   Civ_len = 4
   Gosub Civ_print
Return
'
22D:
   B_temp1 = 11
   Civ_cmd4 = &H94
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
22E:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H94)
   Civ_len = 4
   Gosub Civ_print
Return
'
22F:
   B_temp1 = 2
   Civ_cmd4 = &H95
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
230:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H95)
   Civ_len = 4
   Gosub Civ_print
Return
'
231:
   B_temp1 = 2
   Civ_cmd4 = &H96
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
232:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H96)
   Civ_len = 4
   Gosub Civ_print
Return
'
233:
   B_temp1 = 5
   Civ_cmd4 = &H97
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
234:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H97)
   Civ_len = 4
   Gosub Civ_print
Return
'
235:
   B_temp1 = 4
   Civ_cmd4 = &H98
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
236:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H98)
   Civ_len = 4
   Gosub Civ_print
Return
'
237:
   If Commandpointer > 4 Then
      W_temp1 = Command_b(3) * 256
      W_temp1 = W_temp1 + Command_b(4)
      If W_temp1 < 9999 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H99)
         Incr W_temp1
         B_temp1 = W_temp1 / 100
         Temps_b(5) = Makebcd(B_temp1)
         B_temp1 = W_temp1 Mod 100
         Temps_b(6) = Makebcd(B_temp1)
         Civ_len = 6
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
238:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H99)
   Civ_len = 4
   Gosub Civ_print
Return
'
239:
   B_temp1 = 60
   Civ_cmd4 = &H00
   Gosub Civ_print_l_5_1a0501_bcd
Return
'
23A:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H00)
   Civ_len = 4
   Gosub Civ_print
Return
'
23B:
   If Commandpointer > 3 Then
      B_temp1 = Command_b(3)
      If W_temp1 < 18 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H01)
         B_temp1 = B_temp1 + 18
         Temps_b(5) = Makebcd(B_temp1)
         Civ_len = 6
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
23C:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H01)
   Civ_len = 4
   Gosub Civ_print
Return
23D:
   B_temp1 = 4
   Civ_cmd4 = &H02
   Gosub Civ_print_l_5_1a0501_bcd
Return
'
23E:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H02)
   Civ_len = 4
   Gosub Civ_print
Return
'
23F:
   B_temp1 = 2
   Civ_cmd4 = &H03
   Gosub Civ_print_l_5_1a0501_bcd
Return
'