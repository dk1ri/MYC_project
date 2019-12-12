' IC7300 Command 200 - 21F
' 191129
 '
200:
   Civ_cmd4 = &H70
   Gosub Civ_print4_1a0500
Return
201:
   B_temp1 = 2
   Civ_cmd4 = &H71
   Gosub Civ_print_l_5_1a0500
Return
202:
   Civ_cmd4 = &H71
   Gosub Civ_print4_1a0500
Return
203:
   If Commandpointer >= 3 Then
      If Command_b(3) <= 224 Then
         Temps = Chr(&H1A) + Chr(&H05)
         Temps_b(3) = &H00
         Temps_b(4) = &H72
         Temps_b(5)  = Command_b(3) / 100
         B_temp2 = Command_b(3) Mod 100
         Temps_b(6) = Makebcd(B_temp2)
         Civ_len = 6
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
204:
   Civ_cmd4 = &H72
   Gosub Civ_print4_1a0500
Return
205:
   B_temp1 = 2
   Civ_cmd4 = &H73
   Gosub Civ_print_l_5_1a0500
Return
206:
   Civ_cmd4 = &H73
   Gosub Civ_print4_1a0500
Return
207:
   Gosub Command_received
Return
208:
   Civ_cmd4 = &H74
   Gosub Civ_print4_1a0500
Return
209:
   B_temp1 = 2
   Civ_cmd4 = &H75
   Gosub Civ_print_l_5_1a0500
Return
20A:
   Civ_cmd4 = &H75
   Gosub Civ_print4_1a0500
Return
20B:
   B_temp1 = 2
   Civ_cmd4 = &H76
   Gosub Civ_print_l_5_1a0500
Return
20C:
   Civ_cmd4 = &H76
   Gosub Civ_print4_1a0500
Return
20D:
   B_temp1 = 4
   Civ_cmd4 = &H77
   Gosub Civ_print_l_5_1a0500
Return
20E:
   Civ_cmd4 = &H77
   Gosub Civ_print4_1a0500
Return
20F:
   B_temp1 = 3
   Civ_cmd4 = &H78
   Gosub Civ_print_l_5_1a0500
Return
210:
   Civ_cmd4 = &H78
   Gosub Civ_print4_1a0500
Return
211:
   B_temp1 = 3
   Civ_cmd4 = &H79
   Gosub Civ_print_l_5_1a0500
Return
212:
   Civ_cmd4 = &H79
   Gosub Civ_print4_1a0500
Return
213:
   B_temp1 = 4
   Civ_cmd4 = &H80
   Gosub Civ_print_l_5_1a0500
Return
214:
   Civ_cmd4 = &H80
   Gosub Civ_print4_1a0500
Return
215:
   Civ_cmd4 = &H81
   Gosub Civ_print_255_6_1a0500_bcd
Return
216:
   Civ_cmd4 = &H81
   Gosub Civ_print4_1a0500
Return
217:
   B_temp1 = 2
   Civ_cmd4 = &H82
   Gosub Civ_print_l_5_1a0500
Return
218:
   Civ_cmd4 = &H82
   Gosub Civ_print4_1a0500
Return
219:
   B_temp1 = 2
   Civ_cmd4 = &H83
   Gosub Civ_print_l_5_1a0500
Return
21A:
   Civ_cmd4 = &H83
   Gosub Civ_print4_1a0500
Return
21B:
   B_temp1 = 2
   Civ_cmd4 = &H84
   Gosub Civ_print_l_5_1a0500
Return
21C:
   Civ_cmd4 = &H84
   Gosub Civ_print4_1a0500
Return
21D:
   B_temp1 = 2
   Civ_cmd4 = &H85
   Gosub Civ_print_l_5_1a0500
Return
21E:
   Civ_cmd4 = &H85
   Gosub Civ_print4_1a0500
Return
21F:
   B_temp1 = 2
   Civ_cmd4 = &H86
   Gosub Civ_print_l_5_1a0500
Return