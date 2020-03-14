' IC7300 Command 30 - 31
' 191030
'
300:
   If Commandpointer >= 4 Then
      'filter
      If Command_b(3) < 100 And Command_b(4) < 3 Then
         W_temp1 = Command_b(3) * 39
         W_temp1 = W_temp1 + 8
         Memorycontent_b(W_temp1) = Command_b(4) + 1
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
301:
   Mem_function = 4
   Gosub S_Read_mem
Return
302:
   If Commandpointer >= 4 Then
      'Tone
      If Command_b(3) < 100 And Command_b(4) < 3 Then
         W_temp1 = Command_b(3) * 39
         W_temp1 = W_temp1 + 9
         Memorycontent_b(W_temp1) = Memorycontent_b(W_temp1) And &HF0
         Memorycontent_b(W_temp1) = Memorycontent_b(W_temp1)  Or Command_b(4)
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
303:
   Mem_function = 5
   Gosub S_Read_mem
Return
304:
   If Commandpointer >= 4 Then
      'Data Mode
      If Command_b(3) < 100 And Command_b(4) < 2 Then
         W_temp1 = Command_b(3) * 39
         W_temp1 = W_temp1 + 9
         Memorycontent_b(W_temp1) = Memorycontent_b(W_temp1) And &H0F
         Shift Command_b(4), Left,4
         Memorycontent_b(W_temp1) = Memorycontent_b(W_temp1) Or Command_b(4)
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
305:
   Mem_function = 6
   Gosub S_Read_mem
Return
306:
   If Commandpointer >= 4 Then
      'Tone frequency
      If Command_b(3) < 100 And Command_b(4) < 50 Then
         W_temp1 = Command_b(3) * 39
         W_temp1 = W_temp1 + 11
         B_temp1 = Command_b(3) + 1
         W_temp2 = Lookup(B_temp1, Tones)
         Memorycontent_b(W_temp1) = W_temp2_h
         Incr W_temp1
         Memorycontent_b(W_temp1) = W_temp2_l
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
307:
   Mem_function = 7
   Gosub S_Read_mem
Return
308:
   If Commandpointer >= 4 Then
      'Tone frequency
      If Command_b(3) < 100 And Command_b(4) < 50 Then
         W_temp1 = Command_b(3) * 39
         W_temp1 = W_temp1 + 14
         B_temp1 = Command_b(3) + 1
         W_temp2 = Lookup(B_temp1, Tones)
         Memorycontent_b(W_temp1) = W_temp2_h
         Incr W_temp1
         Memorycontent_b(W_temp1) = W_temp2_l
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
309:
   Mem_function = 8
   Gosub S_Read_mem
Return
30A:
   ' Frequncy SPLIT
   If Commandpointer >= 7 Then
      If Command_b(3) < 100 Then
         D_temp2 = 69970000
         B_temp5 = 4
         B_temp4 = 1
         Gosub S_frequency
         If Temps <> "" Then
            ' Copy Frequency to Memorycontent
            W_temp1 = Command_b(3) * 39
            W_temp1 = W_temp1 + 16
            For B_temp1 = 1 To 4
               Memorycontent_b(W_temp1) = Temps_b(B_temp1)
               Incr W_temp1
            Next B_temp1
            B_temp1 = 1
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
30B:
   Mem_function = 9
   Gosub S_Read_mem
Return
30C:
   ' mode SPLIT
   If Commandpointer >= 4 Then
      If Command_b(3) < 100 And Command_b(4) < 8 Then
         W_temp1 = Command_b(3) * 39
         W_temp1 = W_temp1 + 21
         If Command_b(4) > 5 Then Incr Command_b(4)
         Memorycontent_b(W_temp1) = Command_b(4)
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
30D:
   Mem_function = 10
   Gosub S_Read_mem
Return
30E:
   If Commandpointer >= 4 Then
      'filter SPLIT
      If Command_b(3) < 100 And Command_b(4) < 3 Then
         W_temp1 = Command_b(3) * 39
         W_temp1 = W_temp1 + 22
         Memorycontent_b(W_temp1) = Command_b(4) + 1
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
30F:
   Mem_function = 11
   Gosub S_Read_mem
Return
310:
   If Commandpointer >= 4 Then
      'Tone SPLIT
      If Command_b(3) < 100 And Command_b(4) < 3 Then
         W_temp1 = Command_b(3) * 39
         W_temp1 = W_temp1 + 23
         Memorycontent_b(W_temp1) = Memorycontent_b(W_temp1) And &HF0
         Memorycontent_b(W_temp1) = Memorycontent_b(W_temp1)  Or Command_b(4)
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
311:
   Mem_function = 12
   Gosub S_Read_mem
Return
312:
   If Commandpointer >= 4 Then
      'Data Mode SPLIT
      If Command_b(3) < 100 And Command_b(4) < 2 Then
         W_temp1 = Command_b(3) * 39
         W_temp1 = W_temp1 + 23
         Memorycontent_b(W_temp1) = Memorycontent_b(W_temp1) And &H0F
         Shift Command_b(4), Left,4
         Memorycontent_b(W_temp1) = Memorycontent_b(W_temp1) Or Command_b(4)
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
313:
   Mem_function = 13
   Gosub S_Read_mem
Return
314:
   If Commandpointer >= 4 Then
      'Tone frequency SPLIT
      If Command_b(3) < 100 And Command_b(4) < 50 Then
         W_temp1 = Command_b(3) * 39
         W_temp1 = W_temp1 + 25
         B_temp1 = Command_b(3) + 1
         W_temp2 = Lookup(B_temp1, Tones)
         Memorycontent_b(W_temp1) = W_temp2_h
         Incr W_temp1
         Memorycontent_b(W_temp1) = W_temp2_l
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
315:
   Mem_function = 14
   Gosub S_Read_mem
Return

316:
   If Commandpointer >= 4 Then
      'Tone frequency SPLIT
      If Command_b(3) < 100 And Command_b(4) < 50 Then
         W_temp1 = Command_b(3) * 39
         W_temp1 = W_temp1 + 28
         B_temp1 = Command_b(3) + 1
         W_temp2 = Lookup(B_temp1, Tones)
         Memorycontent_b(W_temp1) = W_temp2_h
         Incr W_temp1
         Memorycontent_b(W_temp1) = W_temp2_l
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
317:
   Mem_function = 15
   Gosub S_Read_mem
Return
318:
   If Commandpointer >= 4 Then
      ' name
      If Command_b(4) > 0 Then
         If Command_b(4) < 11 Then
            B_temp1 = Command_b(4) + 4
            If Commandpointer >= B_temp1  Then
               W_temp1 = Command_b(3) * 39
               W_temp1 = W_temp1 + 30
               B_temp1 = B_temp1 - 4
               For B_temp2 = 1 To 10
                  If B_temp2 <= B_temp1 Then
                     Memorycontent_b(W_temp1) = Command_b(B_temp2 + 4)
                  Else
                     Memorycontent_b(W_temp1) = &H20
                  End If
                  Incr W_temp1
               Next B_temp2
               B_temp1 = 1
               Gosub Mem_to_civ
            End If
         Else
            Parameter_error
            Gosub Command_received
         End If
      End If
   End If
Return
319:
   Mem_function = 16
   Gosub S_Read_mem
Return
31A:
   If Commandpointer >= 4 Then
      'select
      If Command_b(3) < 4 Then
         W_temp1 = Command_b(3) * 39
         Memorycontent_b(W_temp1) = Command_b(4)
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
31B:
   Mem_function = 1
   Gosub S_Read_mem
Return
31C:
   If Commandpointer >= 4 Then
      If Command_b(3) < 2 And Command_b(4) < 11 Then
         Temps_b(1) = &H1A
         Temps_b(2) = &H01
         Temps_b(3) = Command_b(4) + 1
         Temps_b(4) = Command_b(3) + 2
         Civ_len = 4
         Copy_band_stack = Temps_b(3)
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
31D:
   If Commandpointer >= 3 Then
      If Command_b(3) < 9 Then
         Temps_b(1) = &H28
         Temps_b(2) = &H00
         Temps_b(3) = Command_b(3)
         Civ_len = 3
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
31E:
   Temps = Chr(&H15)
   Temps_b(2) = &H07
   Civ_len = 2
   Gosub Civ_print
Return
31F:
   Tx_b(1) = &H03
   Tx_b(2) = &H0F
   Tx_b(3)= Vfo_mem
   Tx_write_pointer = 4
   Gosub Print_tx
Return