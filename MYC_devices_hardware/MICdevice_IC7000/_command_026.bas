' Command 260 - 27F
' 20200222
'
260:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H19)
   Civ_len = 4
   Gosub Civ_print
Return
'
261:
   B_temp1 = 3
   Civ_cmd2 = &H06
   Gosub Civ_print_l_3_1a
Return

262:
   Temps = Chr(&H1A) + Chr(&H06)
   Civ_len = 2
   Gosub Civ_print
Return
'
263:
   B_temp1 = 2
   Civ_cmd2 = &H07
   Gosub Civ_print_l_3_1a
Return
'
264:
   Temps = Chr(&H1A) + Chr(&H07)
   Civ_len = 2
   Gosub Civ_print
Return
'
265:
   B_temp1 = 3
   Civ_cmd2 = &H08
   Gosub Civ_print_l_3_1a
Return
'
266:
   Temps = Chr(&H1A) + Chr(&H08)
   Civ_len = 2
   Gosub Civ_print
Return
'
267:
   B_temp1 = 3
   Civ_cmd2 = &H09
   Gosub Civ_print_l_3_1a
Return
'
268:
   Temps = Chr(&H1A) + Chr(&H09)
   Civ_len = 2
   Gosub Civ_print
Return
'
269:
   B_temp1 = 2
   Civ_cmd2 = &H0A
   Gosub Civ_print_l_3_1a
Return
'
26A:
   Temps = Chr(&H1A) + Chr(&H0A)
   Civ_len = 2
   Gosub Civ_print
Return
'
26B:
   If Commandpointer >= 4 Then
      W_temp1 = Command_b(3) * 256
      W_temp1 = W_temp1 + Command_b(4)
      If W_temp1 < 4000 Then
         Temps = Chr(&H1A) + Chr(&H0B) + Chr(&H00) + Chr(&H00)
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
26C:
   Temps =  Chr(&H1A) + Chr(&H0B) + Chr(&H00)
   Civ_len = 2
   Gosub Civ_print
Return
'
26D:
   If Commandpointer >= 4 Then
      W_temp1 = Command_b(3) * 256
      W_temp1 = W_temp1 + Command_b(4)
      If W_temp1 < 4000 Then
         Temps = Chr(&H1A) + Chr(&H0B) + Chr(&H01) + Chr(&H00)
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
26E:
   Temps =  Chr(&H1A) + Chr(&H0B) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
Return
'
26F:
   If Commandpointer >= 4 Then
      W_temp1 = Command_b(3) * 256
      W_temp1 = W_temp1 + Command_b(4)
      If W_temp1 < 512 Then
         Temps = Chr(&H1A) + Chr(&H0B) + Chr(&H02)
         Temps_b(4) = DTCSS_b(1)
         W_temp2 = W_temp1 And &H0007
         B_Temp1 = W_temp2
         Shift W_temp1, Right, 3
         W_temp2 = W_temp1 And &H0007
         B_Temp2 = W_temp2
         Shift B_temp1, Left, 4
         Temps_b(6) = B_Temp1 Or B_Temp2
         Shift W_temp1, Right, 3
         W_temp2 = W_temp1 And &H0007
         B_Temp2 = W_temp2
         Temps_b(5) = B_Temp2
         DTCSS_b(2) = Temps_b(5)
         DTCSS_b(3) = Temps_b(6)
         Civ_len = 6
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
'
270:
   Temps =  Chr(&H1A) + Chr(&H0B) + Chr(&H02)
   Civ_len = 2
   Last_command = &H0270
   Gosub Civ_print
Return
'
271:
   If Commandpointer >= 4 Then
      If Command_b(3) < 3 And Command_b(4) < 3 Then
         Temps = Chr(&H1A) + Chr(&H0B) + Chr(&H02)
         B_temp1 = Command_b(3)
         Shift B_temp1, Left,4
         DTCSS_b(1) = B_temp1 Or Command_b(4)
         Temps_b(4) = DTCSS_b(1)
         Temps_b(5) = DTCSS_b(2)
         Temps_b(6) = DTCSS_b(3)
         Civ_len = 6
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
272:
   Temps =  Chr(&H1A) + Chr(&H0B) + Chr(&H02)
   Civ_len = 2
   Last_command = &H0272
   Gosub Civ_print
Return
'
273:
   If Commandpointer >= 3 Then
      If Command_b(3) < 2 Then
         Temps = Chr(&H1A) + Chr(&H0C) + Chr(&H00)
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
274:
   Temps =  Chr(&H1A) + Chr(&H0C) + Chr(&H00)
   Civ_len = 2
   Gosub Civ_print
Return
'
275:
   If Commandpointer >= 3 Then
      If Command_b(3) < 3 Then
         Temps = Chr(&H1A) + Chr(&H0C) + Chr(&H01)
         Temps_b(4) = Command_b(3)
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
276:
   Temps =  Chr(&H1A) + Chr(&H0C) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
Return
'