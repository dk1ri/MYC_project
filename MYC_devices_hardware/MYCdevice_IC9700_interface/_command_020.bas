' Command 020 .. 021
' 20200301
'
200:
   B_temp1 = 11
   Civ_cmd4 = &H24
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
201:
   Civ_cmd4 = &H24
   Gosub Civ_print4_1a0500
Return
'
202:
   B_temp1 = 11
   Civ_cmd4 = &H25
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
203:
   Civ_cmd4 = &H25
   Gosub Civ_print4_1a0500
Return
'
204:
   B_temp1 = 11
   Civ_cmd4 = &H26
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
205:
   Civ_cmd4 = &H26
   Gosub Civ_print4_1a0500
Return
'
206:
   Civ_cmd4 = &H27
   Gosub Civ_print_255_6_1a0500_bcd
Return
'
207:
   Civ_cmd4 = &H27
   Gosub Civ_print4_1a0500
Return
'
208:
   B_temp1 = 2
   Civ_cmd4 = &H28
   Gosub Civ_print_l_5_1a0500
Return
'
209:
   Civ_cmd4 = &H28
   Gosub Civ_print4_1a0500
Return
'
20A:
   B_temp1 = 2
   Civ_cmd4 = &H29
   Gosub Civ_print_l_5_1a0500
Return
'
20B:
   Civ_cmd4 = &H29
   Gosub Civ_print4_1a0500
Return
'
20C:
   B_temp1 = 4
   Civ_cmd4 = &H30
   Gosub Civ_print_l_5_1a0500
Return
'
20D:
   Civ_cmd4 = &H30
   Gosub Civ_print4_1a0500
Return
'
20E:
   If Commandpointer > 3 Then
      W_temp2 = Command_b(3)
      W_temp1 = W_temp1 + &H50
      W_temp1 = Makebcd(W_temp2)
      Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H31)
      Temps_b(5) = W_temp1_h
      Temps_b(6) = W_temp1_l
      Civ_len = 6
      Gosub Civ_print
   Else
      Parameter_error
   End If
Return
'
20F:
   Civ_cmd4 = &H31
   Gosub Civ_print4_1a0500
'
210:
   If Commandpointer > 3 Then
      W_temp2 = Command_b(3)
      W_temp1 = W_temp1 + &H50
      W_temp1 = Makebcd(W_temp2)
      Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H32)
      Temps_b(5) = W_temp1_h
      Temps_b(6) = W_temp1_l
      Civ_len = 6
      Gosub Civ_print
   Else
      Parameter_error
   End If
Return
'
211:
   Civ_cmd4 = &H32
   Gosub Civ_print4_1a0500
'
Return
'
212:
   B_temp1 = 2
   Civ_cmd4 = &H33
   Gosub Civ_print_l_5_1a0500
Return
'
213:
   Civ_cmd4 = &H33
   Gosub Civ_print4_1a0500
'
214:
   B_temp1 = 2
   Civ_cmd4 = &H34
   Gosub Civ_print_l_5_1a0500
Return
'
215:
   Civ_cmd4 = &H34
   Gosub Civ_print4_1a0500
'
216:
   B_temp1 = 2
   Civ_cmd4 = &H35
   Gosub Civ_print_l_5_1a0500
Return
'
217:
   Civ_cmd4 = &H35
   Gosub Civ_print4_1a0500
'
218:
   B_temp1 = 3
   Civ_cmd4 = &H36
   Gosub Civ_print_l_5_1a0500
Return
'
219:
   Civ_cmd4 = &H36
   Gosub Civ_print4_1a0500
Return
'
21A:
   B_temp1 = 2
   Civ_cmd4 = &H37
   Gosub Civ_print_l_5_1a0500
Return
'
21B:
   Civ_cmd4 = &H37
   Gosub Civ_print4_1a0500
Return
'
21C:
   B_temp1 = 6
   Civ_cmd4 = &H38
   Gosub Civ_print_l_5_1a0500
Return
'
21D:
   Civ_cmd4 = &H38
   Gosub Civ_print4_1a0500
Return
'
21E:
   B_temp1 = 6
   Civ_cmd4 = &H39
   Gosub Civ_print_l_5_1a0500
Return
'
21F:
   Civ_cmd4 = &H39
   Gosub Civ_print4_1a0500
Return
'