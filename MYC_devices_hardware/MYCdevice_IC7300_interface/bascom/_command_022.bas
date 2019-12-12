' IC7300 Command 220 - 23F
' 191129
 '
220:
   Civ_cmd4 = &H86
   Gosub Civ_print4_1a0500
Return
221:
   B_temp1 = 2
   Civ_cmd4 = &H87
   Gosub Civ_print_l_5_1a0500
Return
222:
   Civ_cmd4 = &H87
   Gosub Civ_print4_1a0500
Return
223:
   B_temp1 = 2
   Civ_cmd4 = &H88
   Gosub Civ_print_l_5_1a0500
Return
224:
   Civ_cmd4 = &H88
   Gosub Civ_print4_1a0500
Return
225:
   B_temp1 = 4
   Civ_cmd4 = &H89
   Gosub Civ_print_l_5_1a0500
Return
226:
   Civ_cmd4 = &H89
   Gosub Civ_print4_1a0500
Return
227:
   B_temp1 = 2
   Civ_cmd4 = &H90
   Gosub Civ_print_l_5_1a0500
Return
228:
   Civ_cmd4 = &H90
   Gosub Civ_print4_1a0500
Return
229:
   If Commandpointer >= 3 Then
      B_temp1 = Command_b(3)
      If B_temp1 > 0 Then
         If Command_b(3) < 11 Then
            B_temp2 = B_temp1 + 3
            If Commandpointer >= B_temp2 Then
               Temps = Chr(&H1A) + Chr(&H05)
               Temps_b(3) = &H00
               Temps_b(4) = &H91
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
22A:
   Civ_cmd4 = &H91
   Gosub Civ_print4_1a0500
Return
22B:
   B_temp1 = 2
   Civ_cmd4 = &H92
   Gosub Civ_print_l_5_1a0500
Return
22C:
   Civ_cmd4 = &H92
   Gosub Civ_print4_1a0500
Return
22D:
   B_temp1 = 2
   Civ_cmd4 = &H93
   Gosub Civ_print_l_5_1a0500
Return
22E:
   Civ_cmd4 = &H93
   Gosub Civ_print4_1a0500
Return
22F:
   If Commandpointer >= 5 Then
      If Command_b(3) < 100 Or Command_b(4) < 12 Or Command_b(5) < 31 Then
         Temps = Chr(&H1A) + Chr(&H05)
         Temps_b(3) = &H00
         Temps_b(4) = &H94
         Temps_b(5) = &H20
         Temps_b(6) = Makebcd(Command_b(3))
         Temps_b(7) = Makebcd(Command_b(4))
         Temps_b(8) = Makebcd(Command_b(5))
         Civ_len = 8
         Gosub Civ_print
       Else
         Parameter_error
      End If
   End If
Return
230:
   Civ_cmd4 = &H94
   Gosub Civ_print4_1a0500
Return
231:
   If Commandpointer >= 4 Then
      If Command_b(3) < 24 Or Command_b(4) < 60 Then
         Temps = Chr(&H1A) + Chr(&H05)
         Temps_b(3) = &H00
         Temps_b(4) =&H95
         Temps_b(5) = Makebcd(Command_b(3))
         Temps_b(6) = Makebcd(Command_b(4))
         Civ_len = 6
         Gosub Civ_print
       Else
         Parameter_error
      End If
   End If
Return
232:
   Civ_cmd4 = &H95
   Gosub Civ_print4_1a0500
Return
233:
   If Commandpointer >= 4 Then
      W_temp1_h = Command_b(3)
      W_temp1_l = Command_b(4)
      If W_temp1 < 1681 Then
         Temps = Chr(&H1A) + Chr(&H05)
         Temps_b(3) = &H00
         Temps_b(4) = &H96
         If W_temp1 <= 840 Then
            '-
            W_temp1 = 840 - W_temp1
            Temps_b(7) = 1
         Else
            W_temp1 = W_temp1 - 840
            Temps_b(7) = 0
         End If
         W_temp2 = W_temp1 / 60
         B_temp1 = W_temp2
         W_temp2 = W_temp1 Mod 60
         B_temp2 = W_temp2
         Temps_b(5) = Makebcd(B_temp1)
         Temps_b(6) = Makebcd(B_temp2)
         Civ_len = 7
         Gosub Civ_print
      Else
         parameter_error
      End If
   End If
Return
234:
   Civ_cmd4 = &H96
   Gosub Civ_print4_1a0500
Return
235:
   B_temp1 = 2
   Civ_cmd4 = &H97
   Gosub Civ_print_l_5_1a0500
Return
236:
   Civ_cmd4 = &H97
   Gosub Civ_print4_1a0500
Return
237:
   B_temp1 = 3
   Civ_cmd4 = &H98
   Gosub Civ_print_l_5_1a0500
Return
238:
   Civ_cmd4 = &H98
   Gosub Civ_print4_1a0500
Return
239:
   B_temp1 = 3
   Civ_cmd4 = &H99
   Gosub Civ_print_l_5_1a0500
Return
23A:
   Civ_cmd4 = &H99
   Gosub Civ_print4_1a0500
Return
23B:
   B_temp1 = 2
   Civ_cmd4 = &H00
   Gosub Civ_print_l_5_1a0501
Return
23C:
   Civ_cmd4 = &H00
   Gosub Civ_print4_1a0501
Return
23D:
   B_temp1 = 2
   Civ_cmd4 = &H01
   Gosub Civ_print_l_5_1a0501
Return
23E:
   Civ_cmd4 = &H91
   Gosub Civ_print4_1a0501
Return
23F:
   B_temp1 = 4
   Civ_cmd4 = &H02
   Gosub Civ_print_l_5_1a0501
Return