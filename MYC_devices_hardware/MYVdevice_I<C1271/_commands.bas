' name: _commands.bas
' 20200213
'
01:
   If Commandpointer >= 5 Then
      Frequenz_b(4) = Command_b(2)
      Frequenz_b(3) = Command_b(3)
      Frequenz_b(2) = Command_b(4)
      Frequenz_b(1) = Command_b(5)

      ' convert 4 Byte frequncy to 5 Byte BCD
      ' Input start at B_temp5
      ' D_temp2 is limit
      ' Output start at Temps(B_temp4)
      ' Temps empty if error
      Temps = "000000"
      If Frequenz < 70000000 Then
         Frequenz = Frequenz + 1240000000
         'Frequenz to convert
         D_temp1 = Frequenz / 100000000
         B_temp1 = D_temp1
         Temps_b(6) = Makebcd(B_temp1)
         Frequenz = Frequenz Mod 100000000
         D_temp1 = Frequenz / 1000000
         B_temp1 = D_temp1
         Temps_b(5) = Makebcd(B_temp1)
         Frequenz = Frequenz Mod 1000000
         D_temp1 = Frequenz / 10000
         B_temp1 = D_temp1
         Temps_b(4) = Makebcd(B_temp1)
         Frequenz = Frequenz Mod 10000
         W_temp1 = Frequenz / 100
         B_temp1 = W_temp1
         Temps_b(3) = Makebcd(B_temp1)
         Frequenz = Frequenz Mod 100
         B_temp1 = Frequenz
         Temps_b(2) = Makebcd(B_temp1)
         Civ_len = 6
         Gosub Civ_print
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
02:
   Temps = "{003}"
   Civ_len = 1
   Gosub Civ_print
Return
'
03:
   If Commandpointer >= 4 Then
      If Command_b(3) < 5 And Command_b(3) < 2 Then
         Temps_b(1) = &H06
         B_temp1 = Command_b(2)
         Temps_b(2) = B_temp1
         Temps_b(3) = Command_b(3) + 1
         Civ_len = 3
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
   Return
'
04:
   Temps = "{004}"
   Civ_len = 1
   Gosub Civ_print
   Return
'
05:
   Temps_b(1) = "{002}"
   Civ_len = 1
   Gosub Civ_print
   Return
'
06:
   Temps = "{007}"
   Civ_len = 1
   Gosub Civ_print
   Return
'
07:
   Temps = "{008}"
   Civ_len = 1
   Gosub Civ_print
   Return
'
08:
   Temps = "{009}"
   Civ_len = 1
   Gosub Civ_print
   Return
'
09:
   Temps = "{010}"
   Civ_len = 1
   Gosub Civ_print
   Return
'
0A:
   If Commandpointer >= 4 Then
      W_temp1 = Command_b(2) * 65636
      W_temp2 = Command_b(3) * 256
      W_temp1 = W_temp1 + W_temp2
      W_temp1 = W_temp1 + Command_b(4)
      If W_temp1 < 100000 Then
         Temps_b(1) = &H0D
         W_temp2 = W_temp1 / 10000
         B_temp1 = W_temp2
         Temps_b(4) = Makebcd(B_temp1)
         W_temp1 = W_temp1 Mod 10000
         W_temp2 = W_temp1 / 100
         B_temp1 = W_temp2
         Temps_b(3) = Makebcd(B_temp1)
         W_temp1 = W_temp1 Mod 100
         B_temp1 = W_temp1
         Temps_b(2) = Makebcd(B_temp1)
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
   Return
'
0B:
   Temps = "{012}"
   Civ_len = 1
   Gosub Civ_print
   Return
'