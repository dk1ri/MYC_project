' IC7300 Command 280 - 29F
' 191129
'
280:
   Civ_cmd4 = &H60
   Gosub Civ_print4_1a0501
Return
281:
   If Commandpointer >= 3 Then
      If Command_b(3) < 18 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H61)
         Command_b(3) = Command_b(3) + 28
         B_temp1 = Makebcd(Command_b(3))
         Temps_b(5) = B_temp1
         Civ_len = 5
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
282:
   Civ_cmd4 = &H61
   Gosub Civ_print4_1a0501
Return
283:
   B_temp1 = 4
   Civ_cmd4 = &H62
   Gosub Civ_print_l_5_1a0501
Return
284:
   Civ_cmd4 = &H62
   Gosub Civ_print4_1a0501
Return
285:
   B_temp1 = 2
   Civ_cmd4 = &H63
   Gosub Civ_print_l_5_1a0501
Return
286:
   Civ_cmd4 = &H63
   Gosub Civ_print4_1a0501
Return
287:
   B_temp1 = 3
   Civ_cmd4 = &H64
   Gosub Civ_print_l_5_1a0501
Return
288:
   Civ_cmd4 = &H64
   Gosub Civ_print4_1a0501
Return
289:
   B_temp1 = 2
   Civ_cmd4 = &H65
   Gosub Civ_print_l_5_1a0501
Return
28A:
   Civ_cmd4 = &H65
   Gosub Civ_print4_1a0501
Return
28B:
   B_temp1 = 4
   Civ_cmd4 = &H66
   Gosub Civ_print_l_5_1a0501
Return
28C:
   Civ_cmd4 = &H66
   Gosub Civ_print4_1a0501
Return
28D:
   Civ_cmd4 = &H67
   Gosub Spectrum
Return
28E:
   Civ_cmd4 = &H67
   Gosub Civ_print4_1a0501
Return
28F:
   B_temp1 = 2
   Civ_cmd4 = &H68
   Gosub Civ_print_l_5_1a0501
Return
290:
   Civ_cmd4 = &H68
   Gosub Civ_print4_1a0501
Return
291:
   B_temp1 = 2
   Civ_cmd4 = &H69
   Gosub Civ_print_l_5_1a0501
Return
292:
   Civ_cmd4 = &H69
   Gosub Civ_print4_1a0501
Return
293:
   B_temp1 = 2
   Civ_cmd4 = &H70
   Gosub Civ_print_l_5_1a0501
Return
294:
   Civ_cmd4 = &H70
   Gosub Civ_print4_1a0501
Return
295:
   Civ_cmd4 = &H71
   Gosub Spectrum
Return
296:
   Civ_cmd4 = &H71
   Gosub Civ_print4_1a0501
Return
297:
   Civ_cmd4 = &H72
   Gosub Spectrum
Return
298:
   Civ_cmd4 = &H72
   Gosub Civ_print4_1a0501
Return
299:
   B_temp1 = 2
   Civ_cmd4 = &H73
   Gosub Civ_print_l_5_1a0501
Return
29A:
   Civ_cmd4 = &H73
   Gosub Civ_print4_1a0501
Return
29B:
   B_temp1 = 2
   Civ_cmd4 = &H74
   Gosub Civ_print_l_5_1a0501
Return
29C:
   Civ_cmd4 = &H74
   Gosub Civ_print4_1a0501
Return
29D:
   B_temp1 = 2
   Civ_cmd4 = &H75
   Gosub Civ_print_l_5_1a0501
Return
29E:
   Civ_cmd4 = &H75
   Gosub Civ_print4_1a0501
Return
29F:
   B_temp1 = 2
   Civ_cmd4 = &H76
   Gosub Civ_print_l_5_1a0501
Return