' Tx subs
' 20200312
'
Civ_print:
Reset Pin_rx_enable
UCSR1b.4 = 0
'Switch off Com2 Rx
Printbin #2, 254; 254; Civ_adress; 224
For B_temp1 = 1 To Civ_len
   B_temp2 = Temps_b(B_temp1)
   Printbin #2, B_temp2
   Printbin  B_temp2
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
Civ_print3_1a:
' different commands
'&H1A + civ_cmd2 + civ_cmd3
Temps = Chr(&H1A)
Temps_b(2) = civ_cmd2
Temps_b(3) = civ_cmd3
Civ_len  = 3
Gosub Civ_print
Return
'
Civ_print4_1a0500:
'&H1A0500 + civ_cmd4
Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00)
Temps_b(4) = Civ_cmd4
Civ_len  = 4
Gosub Civ_print
Return
'
Civ_print4_1a0501:
'&H1A0500 + civ_cmd4
Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01)
Temps_b(4) = Civ_cmd4
Civ_len = 4
Gosub Civ_print
Return
'
Civ_print4_1a0502:
'&H1A0500 + civ_cmd4
Temps = Chr(&H1A) + Chr(&H05) + Chr(&H02)
Temps_b(4) = Civ_cmd4
Civ_len = 4
Gosub Civ_print
Return
'
Civ_print4_1a0503:
'&H1A0500 + civ_cmd4
Temps = Chr(&H1A) + Chr(&H05) + Chr(&H03)
Temps_b(4) = Civ_cmd4
Civ_len = 4
Gosub Civ_print
Return
'
Civ_print4_1a0500_bcd:
'&H1A0500 + civ_cmd4
Temps = Chr(&H1A) + Chr(&H05)
Temps_b(3) = &H00
Temps_b(4) = Makebcd(Civ_cmd4)
Civ_len  = 4
Gosub Civ_print
Return
'
Civ_print4_1a0501_bcd:
'&H1A0500 + civ_cmd4
Temps = Chr(&H1A) + Chr(&H05)
Temps_b(3) = &H01
Temps_b(4) = Makebcd(Civ_cmd4)
Civ_len  = 4
Gosub Civ_print
Return
'
Civ_print5_1a0500:
'&H1A0500 + civ_cmd4
Temps = Chr(&H1A) + Chr(&H05)
Temps_b(3) = &H00
Temps_b(4) = Civ_cmd3
Temps_b(5) = Civ_cmd4
Civ_len = 5
Gosub Civ_print
Return
'
Civ_print_l_3_1a:
'1 Parameter with limit (B_temp1)
If Commandpointer >= 3 Then
   If Command_b(3) < B_temp1 Then
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
   If Command_b(3) < b_Temp1 Then
      Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00)
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
Civ_print_l_5_1a0501:
'1 Parameter with limit (B_temp1)
If Commandpointer >= 3 Then
   If Command_b(3) < b_Temp1 Then
      Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01)
      Temps_b(4) = Civ_cmd4
      Temps_b(5) = Command_b(3)
      Civ_len = 5
      Gosub Civ_print
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
Civ_print_l_5_1a0502:
'1 Parameter with limit (B_temp1)
If Commandpointer >= 3 Then
   If Command_b(3) < b_Temp1 Then
      Temps = Chr(&H1A) + Chr(&H05) + Chr(&H02)
      Temps_b(4) = Civ_cmd4
      Temps_b(5) = Command_b(3)
      Civ_len = 5
      Gosub Civ_print
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
Civ_print_l_5_1a0503:
'1 Parameter with limit (B_temp1)
If Commandpointer >= 3 Then
   If Command_b(3) < b_Temp1 Then
      Temps = Chr(&H1A) + Chr(&H05) + Chr(&H03)
      Temps_b(4) = Civ_cmd4
      Temps_b(5) = Command_b(3)
      Civ_len = 5
      Gosub Civ_print
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
Civ_print_l_3:
'1 Parameter with limit (B_temp1)
If Commandpointer >= 3 Then
   If Command_b(3) < b_Temp1 Then
      Temps_b(1) = Civ_cmd1
      Temps_b(2) = Civ_cmd2
      Temps_b(3) = Command_b(3)
      Civ_len = 3
      Gosub Civ_print
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
Civ_print_l_3_bcd:
'1 Parameter with limit (B_temp1)
If Commandpointer >= 3 Then
   If Command_b(3) < b_Temp1 Then
      Temps_b(1) = Civ_cmd1
      Temps_b(2) = Civ_cmd2
      Temps_b(3) = Makebcd(Command_b(3))
      Civ_len = 3
      Gosub Civ_print
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
Civ_print_l_4:
'1 Parameter with limit (B_temp1)
If Commandpointer >= 3 Then
   If Command_b(3) < b_Temp1 Then
      Temps_b(1) = Civ_cmd1
      Temps_b(2) = Civ_cmd2
      Temps_b(3) = Civ_cmd3
      Temps_b(4) = Command_b(3)
      Civ_len = 3
      Gosub Civ_print
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
Civ_print_l_5_plus1_1a0501_bcd:
'1 Parameter with limit (B_temp1)
' + 1
If Commandpointer >= 3 Then
   If Command_b(3) < b_Temp1 Then
      Temps = Chr(&H1A) + Chr(&H05) + Chr(01)
      Temps_b(4) = Civ_cmd4
      Temps_b(5) = Makebcd(Command_b(3) + 1)
      Civ_len = 5
      Gosub Civ_print
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
Civ_print_l_5_plus1_1a0502_bcd:
'1 Parameter with limit (B_temp1)
' + 1
If Commandpointer >= 3 Then
   If Command_b(3) < b_Temp1 Then
      Temps = Chr(&H1A) + Chr(&H05) + Chr(02)
      Temps_b(4) = Civ_cmd4
      Temps_b(5) = Makebcd(Command_b(3) + 1)
      Civ_len = 5
      Gosub Civ_print
   Else
      Parameter_error
   End If
   Gosub Command_received
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
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00)
   Temps_b(4) = Civ_cmd4
   Temps_b(5) = Command_b(3)
   Civ_len = 5
   Gosub Civ_print
End If
Return
'
Civ_print_255_l_5_1a0501:
'1 Parameter 0.. 255
If Commandpointer >= 3 Then
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01)
   Temps_b(4) = Civ_cmd4
   Temps_b(5) = Command_b(3)
   Civ_len = 5
   Gosub Civ_print
End If
Return
'
Civ_print_255_l_5_1a0502:
'1 Parameter 0.. 255
If Commandpointer >= 3 Then
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H02)
   Temps_b(4) = Civ_cmd4
   Temps_b(5) = Command_b(3)
   Civ_len = 5
   Gosub Civ_print
End If
Return
'
Civ_print_255_l_5_1a0503:
'1 Parameter 0.. 255
If Commandpointer >= 3 Then
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H03)
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
   Temps = Chr(&H1A) + Chr(&H05)
   Temps_b(3) = &H00
   Temps_b(4) = Civ_cmd4
   Temps_b(5) = Makebcd(Command_b(3))
   Civ_len = 5
   Gosub Civ_print
End If
Return
'
Civ_print_l_5_1a0502_bcd:
'1 Parameter 0.. < 100 -> BCD out
If Commandpointer >= 3 Then
   Temps = Chr(&H1A) + Chr(&H05) + CHr(&H02)
   Temps_b(4) = Civ_cmd4
   Temps_b(5) = Makebcd(Command_b(3))
   Civ_len = 5
   Gosub Civ_print
End If
Return
'
Civ_print_l_5_1a0503_bcd:
'1 Parameter 0.. < 100 -> BCD out
If Commandpointer >= 3 Then
   Temps = Chr(&H1A) + Chr(&H05) + CHr(&H03)
   Temps_b(4) = Civ_cmd4
   Temps_b(5) = Makebcd(Command_b(3))
   Civ_len = 5
   Gosub Civ_print
End If
Return
'
Civ_print_l_6_1a0501_bcd:
'1 Parameter 0.. 254 -> BCD out
If Commandpointer >= 3 Then
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01)
   Temps_b(4) = Civ_cmd4
   Temps_b(5) = Makebcd(Command_b(3) / 100)
   B_temp2 = Command_b(3) Mod 100
   Temps_b(6) = Makebcd(B_temp2)
   Civ_len = 6
   Gosub Civ_print
End If
Return
'
Civ_print_l_5_1a0501_answer1:
'1 Parameter 0.. < 100 -> BCD out
If Commandpointer >= 3 Then
   If Command_b(3) < B_temp1 Then
      Temps = Chr(&H1A) + Chr(&H05)
      Temps_b(3) = &H01
      Temps_b(4) = Civ_cmd4 + Command_b(3)
      Civ_len = 4
      Gosub Civ_print
   Else
      Parameter_error
      Gosub Command_received
   End If
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
Civ_print_2_2_bcd:
' 2Byte in, 2 byte bcd out 1A0502 (<= 9999)
' limit W_temp1 4. char: cmd4
If Commandpointer >=4 Then
   W_temp1 = Command_b(3) * 256
   W_temp1 = W_temp1 + Command_b(4)
   If W_temp1 < W_temp1 Then
      Temps = Chr(&H1A) + Chr(&H05)+ Chr(&H02)
      Temps_b(4) = Civ_cmd4
      B_temp1 = W_temp1 / 100
      Temps_b(5) =  Makebcd(B_temp1)
      B_temp1 = W_temp1 Mod 100
      Temps_b(6) =  Makebcd(B_temp1)
      Civ_len = 6
      Gosub Civ_print
   Else
      Parameter_error
      Gosub Command_received
   End If
End If
Return
'
Civ_print_2_2_bcd_3:
' 2Byte in, 2 byte bcd out 1A0502 (<= 9999)
' limit W_temp1 4. char: cmd4
If Commandpointer >=4 Then
   W_temp1 = Command_b(3) * 256
   W_temp1 = W_temp1 + Command_b(4)
   If W_temp1 < W_temp1 Then
      Temps = Chr(&H1A) + Chr(&H05) + Chr(&H03)
      Temps_b(4) = Civ_cmd4
      B_temp1 = W_temp1 / 100
      Temps_b(5) =  Makebcd(B_temp1)
      B_temp1 = W_temp1 Mod 100
      Temps_b(6) =  Makebcd(B_temp1)
      Civ_len = 6
      Gosub Civ_print
   Else
      Parameter_error
      Gosub Command_received
   End If
End If
Return
'
S_frequency:
   ' convert 4 Byte frequncy to 5 Byte BCD
   ' Output start at Temps(B_temp4)
   ' Temps empty if error
   Temps = ""
   Frequenz = Frequenz + Frequenz_adder
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
Return
'
Hpf_lpf:
If Commandpointer >= 4 Then
   If Command_b(3) < 21 And Command_b(4) < 21 Then
      Temps = Chr(&H1A) + Chr(&H05)
      Temps_b(3) = &H00
      Temps_b(4) = Civ_cmd4
      'LPF
      B_temp1 = Command_b(3)
      Temps_b(5) = Makebcd(B_temp1 )
      'HPF
      B_temp1 = Command_b(4)
      B_temp1 = B_temp1 + 5
      Temps_b(6) = Makebcd(B_temp1 )
      Civ_len = 6
      Gosub Civ_print
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
Ssb_tx_bw:
If Commandpointer >= 4 Then
   If Command_b(3) < 4 And Command_b(4) < 4 Then
      Temps = Chr(&H1A) + Chr(&H05)
      Temps_b(3) = &H00
      Temps_b(4) = Civ_cmd4
      Temps_b(5) = Command_b(3)
      B_temp1 = Command_b(4)
      Shift B_temp1, Left, 4
      Temps_b(5)  = Temps_b(5)  Or B_temp1
      Civ_len = 5
      Gosub Civ_print
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
Split_offset:
If Commandpointer >= 4 Then
   Temps = Chr(&H1A) + Chr(&H05)
   Temps_b(3) = &H00
   Temps_b(4) = Civ_cmd4
   W_temp1_h = Command_b(3)
   W_temp1_l = Command_b(4)
   If W_temp1 < 19999 Then
      If W_temp1 > 9998 Then
         Temps_b(8) = 0
         ' 9999 is "0"
         W_temp1 = W_temp1 - 9999
      Else
         Temps_b(8) = 1
         W_temp1 = 9999 - W_temp1
      End If
      Temp_dw = W_temp1 * 10
      Multiplier = 10000
      For B_temp1 = 7 To 5 Step -1
         Temp_dw1 = Temp_dw / Multiplier
         B_temp2 = Temp_dw1
         Temps_b(B_temp1) = Makebcd(B_temp2)
         Temp_dw = Temp_dw Mod Multiplier
         Multiplier = Multiplier / 100
      Next B_temp1
      Civ_len = 8
      Gosub Civ_print
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
Spectrum:
If Commandpointer >= 5 Then
   Temps = Chr(&H1A) + Chr(&H05)+ Chr(&H01)
   Temps_b(4) = Civ_cmd4
   Temps_b(5) = Command_b(3) / 100
   B_temp1 = Command_b(3) Mod 100
   Temps_b(6) = Makebcd(B_temp1)
   '
   Temps_b(7) = Command_b(4) / 100
   B_temp1 = Command_b(4) Mod 100
   Temps_b(8) = Makebcd(B_temp1)
   '
   Temps_b(9) = Command_b(5) / 100
   B_temp1 = Command_b(5) Mod 100
   Temps_b(10) = Makebcd(B_temp1 )
   Civ_len = 10
   Gosub Civ_print
End If
Return
'
Spectrum2:
If Commandpointer >= 5 Then
   Temps = Chr(&H1A) + Chr(&H05)+ Chr(&H02)
   Temps_b(4) = Civ_cmd4
   Temps_b(5) = Command_b(3) / 100
   B_temp1 = Command_b(3) Mod 100
   Temps_b(6) = Makebcd(B_temp1)
   '
   Temps_b(7) = Command_b(4) / 100
   B_temp1 = Command_b(4) Mod 100
   Temps_b(8) = Makebcd(B_temp1)
   '
   Temps_b(9) = Command_b(5) / 100
   B_temp1 = Command_b(5) Mod 100
   Temps_b(10) = Makebcd(B_temp1 )
   Civ_len = 10
   Gosub Civ_print
End If
Return
'
S_scope_edge::
' F_offset: startfrequency
' W_temp3:  frequency limit
If Commandpointer >= 7 Then
   W_temp2 =  Command_b(6) * 256
   W_temp2 = W_temp2 +  Command_b(7)
   If W_temp2 < 995 Then
      ' Span ok
      D_temp2 =  Command_b(4) * 256
      D_temp2 = D_temp2 +  Command_b(5)
      D_temp2 = D_temp2 + F_offset
      ' high edge:
      D_temp3 = D_temp2 + W_temp2
      D_temp3 = D_temp3 + 5
      If D_temp2 <= D_temp1 And D_temp3 <= D_temp1 Then
         ' ok < limit
         Temps = Chr(&H1A) + Chr(&H05)+ Chr(&H01)
         ' covers 3 civ-commands:
         Temps_b(4) = Civ_cmd4 + Command_b(3)
         'low edge
         Temp_dw = D_temp2
         Temp_dw1 = Temp_dw / 1000
         b_Temp3 = Temp_dw1
         Temps_b(7) = Makebcd(B_temp3)
         Temp_dw = Temp_dw Mod 10000
         Temp_dw = Temp_dw Mod 1000
         Temp_dw1 = Temp_dw / 10
         B_temp3 = Temp_dw1
         Temps_b(6) = Makebcd(B_temp3)
         Temp_dw = Temp_dw Mod 100
         Temp_dw = Temp_dw Mod 10
         B_temp1 = Temp_dw
         B_temp1 = Makebcd(B_temp1)
         Shift B_temp1, Left, 4
         Temps_b(5) = B_temp1
         ' high edge
         Temp_dw = D_temp3
         Temp_dw1 = Temp_dw / 1000
         b_Temp3 = Temp_dw1
         Temps_b(10) = Makebcd(B_temp3)
         Temp_dw = Temp_dw Mod 10000
         Temp_dw = Temp_dw Mod 1000
         Temp_dw1 = Temp_dw / 10
         B_temp3 = Temp_dw1
         Temps_b(9) = Makebcd(B_temp3)
         Temp_dw = Temp_dw Mod 100
         Temp_dw = Temp_dw Mod 10
         B_temp1 = Temp_dw
         Shift B_temp1, Left, 4
         Temps_b(8) = B_temp1
         Civ_len = 10
         Gosub Civ_print
      End If
   Else
      Parameter_error
      Gosub Command_received
   End If
End If
Return
'
Tone:
If Commandpointer >= 3 Then
   If Command_b(3) < 50 Then
      Temps_b(1) = &H1B
      Temps_b(2) = Civ_cmd2
      B_temp1 = Command_b(3) + 1
      W_temp1 = Lookup(B_temp1, Tones)
      Temps_b(3) = W_temp1_h
      Temps_b(4) = W_temp1_l
      Civ_len = 4
      Gosub Civ_print
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
Mem_to_civ:
Temps_b(1) = &H1A
Temps_b(2) = &H00
W_temp1 = Command_b(3) * 114
Incr W_temp1
' Copy complete content
For B_temp1 = 1 To 114
   Temps_b(B_temp1 + 2) = Memorycontent_b(W_temp1)
   Incr W_temp1
Next B_temp1
' Overwrite Chanal:
Temps_b(4) = Command_b(3) / 100
Temps_b(5) = Makebcd(Command_b(3) Mod 100)
Civ_len = 116
Gosub Civ_print
' aktivate memory
If Vfo_mem = 1 Then
   Gosub 105
   Gosub 109
End If
Return
'
S_Read_mem:
   If Commandpointer >= 3 Then
      If Command_b(3) < 108 Then
         Temps_b(1) = &H1A
         Temps_b(2) = &H00
         Temps_b(3) = Command_b(3) / 100
         Temps_b(4) = Makebcd(Command_b(3) Mod 100)
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
'
DTCS:
W_temp3 = W_temp2 And &H0007
B_Temp1 = W_temp3
Shift W_temp2, Right, 3
W_temp3 = W_temp2 And &H0007
B_Temp2 = W_temp3
Shift B_temp1, Left, 4
Temps_b(6) = B_Temp1 Or B_Temp2
Shift W_temp1, Right, 3
W_temp2 = W_temp1 And &H0007
B_Temp2 = W_temp2
Return
'
Tx_position_data:
   If Commandpointer >= 13 Then
      If Command_b(3) < 99 And Command_b(6) < 2 And Command_b(10) < 2 And Command_b(13) < 2 Then
         W_temp1 = Command_b(4) * 256
         W_temp1 = Command_b(5) + W_temp1
         W_temp2 = Command_b(8) * 256
         W_temp2 = Command_b(9) + W_temp2
         W_temp3 = Command_b(11) * 256
         W_temp3 = W_temp3 + Command_b(12)
         If W_temp1 < 59999 And Command_b(7) < 199 And W_temp2 < 599999 And W_temp3 < 199999 Then
            ' Lat
            Temps = Chr(&H1A) + Chr(&H02)
            '
            Temps_b(4) = Makebcd(Command_b(3))
            '
            B_temp1 = W_temp1 / 1000
            Temps_b(5) = Makebcd(B_temp1)
            W_temp1 = W_temp1 Mod 1000
            B_temp1 = W_temp1 / 10
            Temps_b(6) = Makebcd(B_temp1)
            B_temp1 = W_temp1 Mod 10
            B_temp1 = B_temp1  * 16
            Temps_b(7) = Makebcd(B_temp1)
            '
            Temps_b(8) = Command_b(6)
            ' Long
            B_temp1 = Command_b(7) / 100
            Temps_b(9) = Makebcd(B_temp1)
            B_temp1 = Command_b(7) Mod 100
            Temps_b(10) = Makebcd(B_temp1)
            '
            B_temp1 = W_temp2 / 1000
            Temps_b(11) = Makebcd(B_temp1)
            W_temp2 = W_temp2 Mod 1000
            B_temp1 = W_temp2 / 10
            Temps_b(12) = Makebcd(B_temp1)
            B_temp1 = W_temp2 Mod 10
            B_temp1 = B_temp1  * 16
            Temps_b(13) = Makebcd(B_temp1)
            Temps_b(14) = Command_b(10)
            ' alt
            B_temp1 = W_temp3 / 1000
            Temps_b(15) = Makebcd(B_temp1)
            W_temp3 = W_temp3 Mod 1000
            B_temp3 = W_temp3 / 10
            Temps_b(16) = Makebcd(B_temp1)
            B_temp1 = W_temp2 Mod 10
            Temps_b(17) = Makebcd(B_temp1)
            Temps_b(18) = Command_b(13)
            Civ_len = 18
            Gosub Civ_print
         Else
            Parameter_error
         End if
      Else
         Parameter_error
      End If
   End If
Return
'
Send_text:
   If Commandpointer >= 3 Then
      If Command_b(3) < B_temp1 Then
         B_temp2 = B_temp1 + 3
         If Commandpointer >= B_temp2 Then
            Temps = Chr(&H1A) + Chr(&H05)+ Chr(&H02)
            B_temp2 = 4
            B_temp3 = 4
            For B_temp1 = 1 To Command_b(3)
               Temps_b(B_temp1) = Command_b(B_temp2)
               Incr B_temp2
            Next B_temp1
            Civ_len = Command_b(3) + 3
            Gosub Civ_print
         Else
            Parameter_error
         End If
      End If
   End If
Return
'
Send_text_3:
   If Commandpointer >= 3 Then
      If Command_b(3) < B_temp1 Then
         B_temp2 = B_temp1 + 3
         If Commandpointer >= B_temp2 Then
            Temps = Chr(&H1A) + Chr(&H05)+ Chr(&H03)
            B_temp2 = 4
            B_temp3 = 4
            For B_temp1 = 1 To Command_b(3)
               Temps_b(B_temp1) = Command_b(B_temp2)
               Incr B_temp2
            Next B_temp1
            Civ_len = Command_b(3) + 3
            Gosub Civ_print
         Else
            Parameter_error
         End If
      End If
   End If
Return
'
Send_text_x:
   If Commandpointer >= 3 Then
      If Command_b(3) < B_temp1 Then
         B_temp2 = B_temp1 + 3
         If Commandpointer >= B_temp2 Then
            B_temp2 = 4
            B_temp3 = 4
            For B_temp1 = 1 To Command_b(3)
               Temps_b(B_temp3) = Command_b(B_temp2)
               Incr B_temp2
               Incr B_temp3
            Next B_temp1
            Civ_len = Command_b(3) + 3
            Gosub Civ_print
         Else
            Parameter_error
         End If
      End If
   End If
Return
'
Send_text_x_3:
   If Commandpointer >= 3 Then
      If Command_b(3) < B_temp1 Then
         B_temp2 = B_temp1 + 3
         If Commandpointer >= B_temp2 Then
            B_temp2 = 4
            B_temp3 = 5
            For B_temp1 = 1 To Command_b(3)
               Temps_b(B_temp3) = Command_b(B_temp2)
               Incr B_temp2
               Incr B_temp3
            Next B_temp1
            Civ_len = Command_b(3) + 3
            Gosub Civ_print
         Else
            Parameter_error
         End If
      End If
   End If
Return