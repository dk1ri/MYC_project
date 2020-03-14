' Command 01A .01B
' 20200226
'
1A0:
   ' Frequncy split
   If Commandpointer >= 7 Then
      If Command_b(3) < 107 Then
         B_temp4 = 2
         Frequenz_b(4) = Command_b(3)
         Frequenz_b(3) = Command_b(4)
         Frequenz_b(2) = Command_b(5)
         Frequenz_b(1) = Command_b(6)
         If Frequenz < 2000000 Then
            Frequenz_adder = 144000000
            Gosub S_frequency
            B_temp1 = 1
         Else
            If Frequenz > 22000000 Then
               Frequenz_adder = 428000000
               Gosub S_frequency
               B_temp1 = 2
            Else
               If Frequenz > 82000000 Then
                  Frequenz_adder = 1218000000
                  Gosub S_frequency
                  B_temp1 = 3
               Else
                  Parameter_error
                  Gosub Command_received
               End If
            End If
         End If
         If Temps <> "" Then
            ' Copy Frequency to Memorycontent
            W_temp1 = Command_b(3) * 114
            W_temp1 = W_temp1 + 55
            For B_temp1 = 1 To 5
               Memorycontent_b(W_temp1) = Temps_b(B_temp1)
               Incr W_temp1
            Next B_temp1
            Gosub Mem_to_civ
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1A1:
   Mem_function = 18
   Gosub S_Read_mem
Return
'
1A2:
   ' mode split
   If Commandpointer >= 4 Then
      If Command_b(3) < 107 And Command_b(4) < 10 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 61
         If Command_b(4) > 5 Then Incr Command_b(4)
         If Command_b(4) = 8 Then Command_b(4) = &H17
         If Command_b(4) = 9 Then Command_b(4) = &H22
         Memorycontent_b(W_temp1) = Command_b(4)
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1A3:
   Mem_function = 19
   Gosub S_Read_mem
Return
'
1A4:
   If Commandpointer >= 4 Then
      'filter split
      If Command_b(3) < 107 And Command_b(4) < 3 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 62
         Memorycontent_b(W_temp1) = Command_b(4) + 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1A5:
   Mem_function = 20
   Gosub S_Read_mem
Return
'
1A6:
   If Commandpointer >= 4 Then
      'Data Mode split
      If Command_b(3) < 107 And Command_b(4) < 2 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 63
         Memorycontent_b(W_temp1) = Command_b(4)
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1A7:
   Mem_function =21
   Gosub S_Read_mem
Return
'
1A8:
   If Commandpointer >= 4 Then
      'Tone  split
      If Command_b(3) < 107 And Command_b(4) < 4 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 64
         Memorycontent_b(W_temp1) = Memorycontent_b(W_temp1) And &HF0
         Memorycontent_b(W_temp1) = Memorycontent_b(W_temp1)  Or Command_b(4)
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1A9:
   Mem_function = 22
   Gosub S_Read_mem
Return
'
1AA:
   If Commandpointer >= 4 Then
      'Duplex  split
      If Command_b(3) < 107 And Command_b(4) < 4 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 61
         ' Mode:
         B_temp1 = Memorycontent_b(W_temp1)
         W_temp1 = W_temp1 + 3
         B_temp2 = 0
         If B_temp1 = &H22 And Command_b(4) = 3 Then B_temp2 = 1
         If B_temp1 <> &H22 And Command_b(4) <> 3 Then B_temp2 = 1
         If B_temp2 = 1 Then
            Memorycontent_b(W_temp1) = Memorycontent_b(W_temp1) And &H0F
            Shift Command_b(4), Left,4
            Memorycontent_b(W_temp1) = Memorycontent_b(W_temp1) Or Command_b(4)
            Gosub Mem_to_civ
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1AB:
   Mem_function = 23
   Gosub S_Read_mem
Return
'
1AC:
   If Commandpointer >= 4 Then
      'Tone split
      If Command_b(3) < 107 And Command_b(4) < 3 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 65
         Memorycontent_b(W_temp1) = Command_b(4)
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1AD:
   Mem_function = 24
   Gosub S_Read_mem
Return
'
1AE:
   If Commandpointer >= 4 Then
      'Tone frequency split
      If Command_b(3) < 107 And Command_b(4) < 50 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 66
         B_temp1 = Command_b(3) + 1
         W_temp2 = Lookup(B_temp1, Tones)
         Memorycontent_b(W_temp1) = W_temp2_h
         Incr W_temp1
         Memorycontent_b(W_temp1) = W_temp2_l
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1AF:
   Mem_function = 25
   Gosub S_Read_mem
Return
'
1B0:
   If Commandpointer >= 4 Then
      'Tone frequency split
      If Command_b(3) < 107 And Command_b(4) < 50 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 69
         B_temp1 = Command_b(3) + 1
         W_temp2 = Lookup(B_temp1, Tones)
         Memorycontent_b(W_temp1) = W_temp2_h
         Incr W_temp1
         Memorycontent_b(W_temp1) = W_temp2_l
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1B1:
   Mem_function = 26
   Gosub S_Read_mem
Return
'
1B2:
   If Commandpointer >= 5 Then
      'DTCS frequency split
      If Command_b(3) < 107 Then
         W_temp2 = Command_b(4) * 256
         W_temp2 = W_temp2 + Command_b(5)
         If W_temp2 < 512 Then
            Gosub DTCS
            W_temp1 = Command_b(3) * 114
            W_temp1 = W_temp1 + 73
            Memorycontent_b(W_temp1) = W_temp3_h
            Incr W_temp1
            Memorycontent_b(W_temp1) = W_temp3_l
            Gosub Mem_to_civ
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1B3:
   Mem_function = 27
   Gosub S_Read_mem
Return
'
1B4:
   If Commandpointer >= 4 Then
      'DTCS polarity split
      If Command_b(3) < 107 And Command_b(4) < 4 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 72
         Select Case Command_b(4)
            Case 0
               Memorycontent_b(W_temp1) = 0
            Case 1
               Memorycontent_b(W_temp1) = 8
            Case 30
               Memorycontent_b(W_temp1) = 1
            Case 0
               Memorycontent_b(W_temp1) = 9
         End Select
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1B5:
   Mem_function = 28
   Gosub S_Read_mem
Return
'
1B6:
   If Commandpointer >= 4 Then
      'DV Code split
      If Command_b(3) < 107 And Command_b(4) < 101 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 75
         Memorycontent_b(W_temp1) = Makebcd(Command_b(3))
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1B7:
   Mem_function = 29
   Gosub S_Read_mem
Return
'
1B8:
   ' Duplex offset split
   If Commandpointer >= 6 Then
      Frequenz_b(4) = Command_b(4)
      Frequenz_b(3) = Command_b(5)
      Frequenz_b(2) = Command_b(6)
      Frequenz_b(1) = 0
      If Frequenz < 1000000 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 78
         B_temp1 = Frequenz / 10000
         Memorycontent_b(W_temp1) = B_temp1
         Decr  W_temp1
         Frequenz = Frequenz Mod 10000
         B_temp1 = Frequenz / 100
         Memorycontent_b(W_temp1) = B_temp1
         Decr W_temp1
         Frequenz = Frequenz Mod 100
         B_temp1 = Frequenz
         Memorycontent_b(W_temp1) = B_temp1
         Gosub Mem_to_civ
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
'
1B9:
   Mem_function = 30
   Gosub S_Read_mem
Return
'
1BA:
   ' UR split
   If Commandpointer >= 4 Then
      If Command_b(4) < 0 Then
         B_temp2 = Command_b(4) + 3
         If Commandpointer > B_temp2 Then
            W_temp1 = Command_b(3) * 114
            W_temp1 = W_temp1 + 79
            For B_temp1 = 1 To 8
               If B_temp1 <= Command_b(4) Then
                  Memorycontent_b(W_temp1) = Command_b(B_temp1 + 3)
               Else
                  Memorycontent_b(W_temp1) = &H20
               End If
               Incr  W_temp1
            Next B_temp1
            Gosub Mem_to_civ
         End If
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
'
1BB:
   Mem_function = 31
   Gosub S_Read_mem
Return
'
1BC:
   ' R1 split
   If Commandpointer >= 4 Then
      If Command_b(4) < 0 Then
         B_temp2 = Command_b(4) + 3
         If Commandpointer > B_temp2 Then
            W_temp1 = Command_b(3) * 114
            W_temp1 = W_temp1 + 87
            For B_temp1 = 1 To 8
               If B_temp1 <= Command_b(4) Then
                  Memorycontent_b(W_temp1) = Command_b(B_temp1 + 3)
               Else
                  Memorycontent_b(W_temp1) = &H20
               End If
               Incr  W_temp1
            Next B_temp1
            Gosub Mem_to_civ
         End If
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
'
1BD:
   Mem_function = 32
   Gosub S_Read_mem
Return
'
1BE:
   ' R2  split
   If Commandpointer >= 4 Then
      If Command_b(4) < 0 Then
         B_temp2 = Command_b(4) + 3
         If Commandpointer > B_temp2 Then
            W_temp1 = Command_b(3) * 114
            W_temp1 = W_temp1 + 95
            For B_temp1 = 1 To 8
               If B_temp1 <= Command_b(4) Then
                  Memorycontent_b(W_temp1) = Command_b(B_temp1 + 3)
               Else
                  Memorycontent_b(W_temp1) = &H20
               End If
               Incr  W_temp1
            Next B_temp1
            Gosub Mem_to_civ
         End If
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
'
1BF:
   Mem_function = 33
   Gosub S_Read_mem
Return
'