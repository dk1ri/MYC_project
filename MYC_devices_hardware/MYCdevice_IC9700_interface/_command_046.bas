' Command 460 - 47F
' 20200310
'
460:
   Civ_cmd4 = &H34
   Gosub Civ_print4_1a0503
Return
'
461:
   Civ_cmd4 = &H35
   Gosub Civ_print_255_l_5_1a0503
Return
'
462:
   Civ_cmd4 = &H35
   Gosub Civ_print4_1a0503
Return
'
463:
   B_temp1 = 2
   Civ_cmd4 = &H36
   Gosub Civ_print_l_5_1a0503
Return
'
464:
   Civ_cmd4 = &H36
   Gosub Civ_print4_1a0503
Return
'
465:
   Civ_cmd4 = &H37
   Gosub Civ_print_255_l_5_1a0503
Return
'
466:
   Civ_cmd4 = &H37
   Gosub Civ_print4_1a0503
Return
'
467:
   B_temp1 = 2
   Civ_cmd4 = &H38
   Gosub Send_text_3
Return
'
468:
   Civ_cmd4 = &H38
   Gosub Civ_print4_1a0503
Return
'
469:
   B_temp1 = 3
   Civ_cmd4 = &H39
   Gosub Send_text_3
Return
'
46A:
   Civ_cmd4 = &H39
   Gosub Civ_print4_1a0503
Return
'
46B:
   If Commandpointer >= 3 Then
      If Command_b(3) < 4 Then
         Temps = Chr(&H1A) + Chr(&H06)
         If Command_b(3) = 0 Then
            Temps_b(3) = 0
            Temps_b(4) = 0
         Else
            Temps_b(3) = 1
            Temps_b(4) = Command_b(3)
         End If
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
46C:
   Temps = Chr(&H1A) + Chr(&H06)
   Civ_len = 2
   Gosub Civ_print
Return
'
46D:
   B_temp1 = 2
   Civ_cmd2 = &H08
   Gosub Civ_print_l_3_1a
Return
'
46E:
   Temps = Chr(&H1A) + Chr(&H08)
   Civ_len = 2
   Gosub Civ_print
Return
'
46F:
   Temps = Chr(&H1A) + Chr(&H09)
   Civ_len = 2
   Gosub Civ_print
Return
'
470:
   Temps = Chr(&H1A) + Chr(&H0A)
   Civ_len = 2
   Gosub Civ_print
Return
'
471:
   Civ_cmd2 = 0
   Gosub Tone
Return
'
472:
   Temps = Chr(&H1B) + Chr(&H00)
   Civ_len = 2
   Gosub Civ_print
Return
'
473:
   Civ_cmd2 = 1
   Gosub Tone
Return
'
474:
   Temps = Chr(&H1B) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
Return
'
475:
   If Commandpointer >= 7 Then
      If Command_b(3) < 2 And Command_b(4) < 2 And Command_b(5) < 7 And Command_b(6) < 7 And Command_b(7) < 7 Then
         Temps = Chr(&H1B) + Chr(&H02)
         Temps_b(3) = Command_b(3)
         Shift Temps_b(3), Left, 4
         Temps_b(3) = Temps_b(3) Or Command_b(4)
         Temps_b(4) = Command_b(5)
         Temps_b(5) = Command_b(6)
         Shift Temps_b(5), Left, 4
         Temps_b(5) = Temps_b(5) Or Command_b(7)
         Civ_len = 5
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
'
476:
   Temps = Chr(&H1B) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
Return
'
477:
   Temps = Chr(&H1B) + Chr(&H07)
   Temps_b(3) = Makebcd(Command_b(3))
   Civ_len = 2
   Gosub Civ_print
Return
'
478:
   Temps = Chr(&H1B) + Chr(&H07)
   Civ_len = 2
   Gosub Civ_print
Return
'
479:
   B_temp1 = 2
   Civ_cmd1 = &H1C
   Civ_cmd2 = &H00
   Gosub Civ_print_l_3
Return
'
47A:
   Temps = Chr(&H1C) + Chr(&H00)
   Civ_len = 2
   Gosub Civ_print
Return
'
47B:
   B_temp1 = 2
   Civ_cmd1 = &H1C
   Civ_cmd2 = &H02
   Gosub Civ_print_l_3
Return
'
47C:
   Temps = Chr(&H1C) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
Return
'
47D:
   Temps = Chr(&H1C) + Chr(&H03)
   Civ_len = 2
   Gosub Civ_print
Return
'
47E:
   Temps = Chr(&H1B) + Chr(&H00)
   Civ_len = 2
   Gosub Civ_print
Return
'
47F:
   Temps = Chr(&H1B) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
Return
'