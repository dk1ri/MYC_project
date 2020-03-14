' Command 4C0 -
' 20200314
'
4C0:
   If Commandpointer >= 4 Then
      If Command_b(3) < 2 And Command_b(4) < 2 Then
         Temps = Chr(&H27) + Chr(&H1D)
         Temps_b(3) = Command_b(3)
         Temps_b(4) = Command_b(4)
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
4C1:
   Temps = Chr(&H27) + Chr(&H1D)
   Civ_len = 2
   Gosub Civ_print
   Gosub Civ_print_l_4
Return
'
4C2:
   If Commandpointer >= 3 Then
      If Command_b(3) < 9 Then
         Temps = Chr(&H28)
         Temps_b(3) = Command_b(3)
         Civ_len = 3
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
