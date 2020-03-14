' Command 018 .019
' 20200226
'
180:
   ' Frequency
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
            Incr W_temp1
            ' Band
            Memorycontent_b(W_temp1) = B_temp1
            W_temp1 = W_temp1 + 3
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
181:
   Mem_function = 2
   Gosub S_Read_mem
Return
'
182:
   ' mode
   If Commandpointer >= 4 Then
      If Command_b(3) < 107 And Command_b(4) < 10 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 10
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
183:
   Mem_function = 3
   Gosub S_Read_mem
Return
'
184:
   If Commandpointer >= 4 Then
      'filter
      If Command_b(3) < 107 And Command_b(4) < 3 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 11
         Memorycontent_b(W_temp1) = Command_b(4) + 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
185:
   Mem_function = 4
   Gosub S_Read_mem
Return
'
186:
   If Commandpointer >= 4 Then
      'Data Mode
      If Command_b(3) < 107 And Command_b(4) < 2 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 12
         Memorycontent_b(W_temp1) = Command_b(4)
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
187:
   Mem_function = 5
   Gosub S_Read_mem
Return
'
188:
   If Commandpointer >= 4 Then
      'Tone
      If Command_b(3) < 107 And Command_b(4) < 4 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 13
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
189:
   Mem_function = 6
   Gosub S_Read_mem
Return
'
18A:
   If Commandpointer >= 4 Then
      'Duplex
      If Command_b(3) < 107 And Command_b(4) < 4 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 10
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
18B:
   Mem_function = 7
   Gosub S_Read_mem
Return
'
18C:
   If Commandpointer >= 4 Then
      'digital Squelch
      If Command_b(3) < 107 And Command_b(4) < 3 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 14
         Memorycontent_b(W_temp1) = Command_b(4)
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
18D:
   Mem_function = 8
   Gosub S_Read_mem
Return
'
18E:
   If Commandpointer >= 4 Then
      'Tone frequency
      If Command_b(3) < 107 And Command_b(4) < 50 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 15
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
18F:
   Mem_function = 9
   Gosub S_Read_mem
Return
'
190:
   If Commandpointer >= 4 Then
      'Tone frequency
      If Command_b(3) < 107 And Command_b(4) < 50 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 18
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
191:
   Mem_function = 10
   Gosub S_Read_mem
Return
'
192:
   If Commandpointer >= 5 Then
      'DTCS frequency
      If Command_b(3) < 107 Then
         W_temp2 = Command_b(4) * 256
         W_temp2 = W_temp2 + Command_b(5)
         If W_temp2 < 512 Then
            Gosub DTCS
            W_temp1 = Command_b(3) * 114
            W_temp1 = W_temp1 + 22
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
193:
   Mem_function = 11
   Gosub S_Read_mem
Return
'
194:
   If Commandpointer >= 4 Then
      'DTCS polarity
      If Command_b(3) < 107 And Command_b(4) < 4 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 21
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
195:
   Mem_function = 12
   Gosub S_Read_mem
Return
'
196:
   If Commandpointer >= 4 Then
      'DV Code
      If Command_b(3) < 107 And Command_b(4) < 101 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 24
         Memorycontent_b(W_temp1) = Makebcd(Command_b(3))
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
197:
   Mem_function = 13
   Gosub S_Read_mem
Return
'
198:
   ' Duplex offset
   If Commandpointer >= 6 Then
      Frequenz_b(4) = Command_b(4)
      Frequenz_b(3) = Command_b(5)
      Frequenz_b(2) = Command_b(6)
      Frequenz_b(1) = 0
      If Frequenz < 1000000 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 27
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
199:
   Mem_function = 14
   Gosub S_Read_mem
Return
'
19A:
   ' UR
   If Commandpointer >= 4 Then
      If Command_b(4) < 0 Then
         B_temp2 = Command_b(4) + 3
         If Commandpointer > B_temp2 Then
            W_temp1 = Command_b(3) * 114
            W_temp1 = W_temp1 + 28
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
19B:
   Mem_function = 15
   Gosub S_Read_mem
Return
'
19C:
   ' R1
   If Commandpointer >= 4 Then
      If Command_b(4) < 0 Then
         B_temp2 = Command_b(4) + 3
         If Commandpointer > B_temp2 Then
            W_temp1 = Command_b(3) * 114
            W_temp1 = W_temp1 + 36
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
19D:
   Mem_function = 16
   Gosub S_Read_mem
Return
'
19E:
   ' R1
   If Commandpointer >= 4 Then
      If Command_b(4) < 0 Then
         B_temp2 = Command_b(4) + 3
         If Commandpointer > B_temp2 Then
            W_temp1 = Command_b(3) * 114
            W_temp1 = W_temp1 + 44
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
19F:
   Mem_function = 17
   Gosub S_Read_mem
Return
'