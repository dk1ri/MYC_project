' Tx subs
' 20200221
'
Civ_print:
Reset Pin_rx_enable
UCSR1b.4 = 0
'Switch off Com2 Rx
Printbin #2, 254; 254; Civ_adress; 224
For B_temp1 = 1 To Civ_len
   B_temp2 = Temps_b(B_temp1)
   Printbin #2, B_temp2
Next B_temp1
Printbin #2, 253
Set Pin_rx_enable
Gosub Command_received
'The programm continues immediately after initiating the transmit
' so wait for 1 character before enable receive
Waitms 1
UCSR1b.4 = 1
Return
'
Civ_print_l_3_1a:
'1 Parameter with limit (B_temp1)
If Commandpointer >= 3 Then
   If Command_b(3) < b_Temp1 Then
      Temps = Chr(&H1A)
      Temps_b(2) = Civ_cmd2
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
Civ_print_l_5_1a0500:
'1 Parameter with limit (B_temp1)
If Commandpointer >= 3 Then
   If Command_b(3) < B_temp1 Then
      Temps = Chr(&H1A) + Chr(&H05)
      Temps_b(3) = &H00
      Temps_b(4) = Civ_cmd4
      Temps_b(5) = Command_b(3)
      Civ_len = 5
      Gosub Civ_print
   Else
      Parameter_error
      Gosub Command_received
   End If
End If
Return
'
Civ_print_l_6_1a0500_bcd:
'1 Parameter with limit (B_temp1)
If Commandpointer >= 3 Then
   If Command_b(3) < B_temp1 Then
      Temps = Chr(&H1A) + Chr(&H05)
      Temps_b(3) = &H00
      Temps_b(4) = Civ_cmd4
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
'
Civ_print_l_3:
'1 Parameter with limit (B_temp1)
If Commandpointer >= 3 Then
   If Command_b(3) < B_temp1 Then
      Temps_b(1) = Civ_cmd1
      Temps_b(2) = Civ_cmd2
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
Civ_print_l_3p1:
'1 Parameter with limit (B_temp1)
If Commandpointer >= 3 Then
   If Command_b(3) < B_temp1 Then
      Temps_b(1) = Civ_cmd1
      Temps_b(2) = Civ_cmd2
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
Civ_print_255_4_bcd:
'1 Parameter 0.. 255
If Commandpointer >= 3 Then
   Temps_b(1) = Civ_cmd1
   Temps_b(2) = Civ_cmd2
   B_temp1 = Command_b(3) / 100
   Temps_b(3) = B_temp1
   B_temp1 = Command_b(3) Mod 100
   Temps_b(4) = Makebcd(B_temp1)
   Civ_len = 4
   Gosub Civ_print
End If
Return
'
Civ_print_255_5_1a0500:
'1 Parameter 0.. 255
If Commandpointer >= 3 Then
   Temps = Chr(&H1A) + Chr(&H05)
   Temps_b(3) = &H00
   Temps_b(4) = Civ_cmd4
   Temps_b(5) = Command_b(3)
   Civ_len = 5
   Gosub Civ_print
End If
Return
'
Civ_print_l_5_1a0500_bcd:
'1 Parameter 0.. < 100 -> BCD out
If Commandpointer >= 3 Then
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00)
   Temps_b(4) = Civ_cmd4
   Temps_b(5) = Makebcd(Command_b(3))
   Civ_len = 5
   Gosub Civ_print
End If
Return
'
Civ_print_l_5_1a0501_bcd:
'1 Parameter 0.. < 100 -> BCD out
If Commandpointer >= 3 Then
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01)
   Temps_b(4) = Civ_cmd4
   Temps_b(5) = Makebcd(Command_b(3))
   Civ_len = 5
   Gosub Civ_print
End If
Return
'
Civ_print_255_6_1a0500_bcd:
'1 Parameter 0.. 255 -> BCD out
If Commandpointer >= 3 Then
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00)
   Temps_b(4) = Civ_cmd4
   B_temp1 = Command_b(3) / 100
   Temps_b(5) = B_temp1
   B_temp1 = Command_b(3) Mod 100
   Temps_b(6) = Makebcd(B_temp1)
   Civ_len = 6
   Gosub Civ_print
End If
Return
'
Civ_print_255_6_1a0501_bcd:
'1 Parameter 0.. 255 -> BCD out
If Commandpointer >= 3 Then
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01)
   Temps_b(4) = Civ_cmd4
   B_temp1 = Command_b(3) / 100
   Temps_b(5) = B_temp1
   B_temp1 = Command_b(3) Mod 100
   Temps_b(6) = Makebcd(B_temp1)
   Civ_len = 6
   Gosub Civ_print
End If
Return
'
S_frequency:
   ' convert 4 Byte frequncy to 5 Byte BCD
   ' Input start at B_temp5
   ' D_temp2 is limit
   ' Output start at Temps(B_temp4)
   ' Temps empty if error
   Temps = ""
   Frequenz_b(4) = Command_b(B_temp5)
   Frequenz_b(3) = Command_b(B_temp5 + 1)
   Frequenz_b(2) = Command_b(B_temp5 + 2)
   Frequenz_b(1) = Command_b(B_temp5 + 3)
   If Frequenz < D_temp2 Then
      Frequenz = Frequenz + 30000
      'Frequenz to convert
      D_temp1 = Frequenz / 100000000
      B_temp1 = D_temp1
      Temps_b(B_temp4 + 4) = Makebcd(B_temp1)
      Frequenz = Frequenz Mod 100000000
      D_temp1 = Frequenz / 1000000
      B_temp1 = D_temp1
      Temps_b(B_temp4 + 3) = Makebcd(B_temp1)
      Frequenz = Frequenz Mod 1000000
      D_temp1 = Frequenz / 10000
      B_temp1 = D_temp1
      Temps_b(B_temp4 + 2) = Makebcd(B_temp1)
      Frequenz = Frequenz Mod 10000
      W_temp1 = Frequenz / 100
      B_temp1 = W_temp1
      Temps_b(B_temp4 + 1) = Makebcd(B_temp1)
      Frequenz = Frequenz Mod 100
      B_temp1 = Frequenz
      Temps_b(B_temp4) = Makebcd(B_temp1)
    End If
Return
'
