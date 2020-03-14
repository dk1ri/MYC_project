' Ic7300 Analyze_civ
'
Analyze_civ:
'CiV received, analyze data
' some commands do answer with ok /nok only!!
'Civ_in contain the complete answer with header and trailer
'Civ_pointer points to last element before trailer (&HFD)
'Civ code 0 and 1 appear with transceive = on on radio only
'Correct Length of Civ string is not checked
'
If Civ_in_b(5) < &H1A Then
   $include _analyze_civ_00_H19.bas
Else
   If Civ_in_b(5) < &H1B Then
      If Civ_in_b(6) < &H05 Then
         '&H1A00 ... &H1A04
         Tx_b(1) = 1
         Select Case Civ_in_b(6)
            Case &H00
               If Read_memory_counter < 101 Then
                  Gosub Memory_read_and_fill
               Else
                  Gosub Memory_read
               End If
            Case &H01
               If Copy_band_stack > 0 Then
                  Temps = Chr(&H1A) + Chr(&H01)
                  Temps_b(3) = Copy_band_stack
                  ' copy to 1:
                  Temps_b(4) = 1
                  For B_temp1 = 1 To 14
                     Temps_b(B_temp1 + 4)= Civ_in_b(B_temp1 + 8)
                  Next B_temp1
                  print "test"
                  Civ_len = 18
                  Gosub Civ_print
                  Tx_write_pointer = 1
                  Copy_band_stack = 0
               End If
            Case &H02
                Tx_b(2) = &H6C
                Tx_b(3) = 0
                For B_temp1 = 7 To CiV_pointer
                   Tx_b(B_temp1 - 4) = CiV_in_b(B_temp1)
                   Incr Tx_b(3)
                Next B_temp1
                Tx_write_pointer = Tx_b(3) + 1
       '
            Case &H03
                Tx_b(2) = &H6E
                Tx_b(3) = Civ_in_b(7)
                Tx_write_pointer = 4
       '
             Case &H04
                Tx_b(2) = &H74
                Tx_b(3) = Civ_in_b(7)
                Tx_write_pointer = 4
          End Select
      Else
         If Civ_in_b(6) = &H05 Then
            '1A05
            Civ_sub_cmd = Civ_in_b(7) * 100
            Civ_sub_cmd = Civ_sub_cmd + Makedec(Civ_in_b(8))
            If Civ_sub_cmd < 96 Then
               If Civ_sub_cmd < 48 Then
               ' 24 commands each
                  If Civ_sub_cmd < 24 Then
                     $include _analyze_civ_s000_s023.bas
                  Else
                     $include _analyze_civ_s024_s047.bas
                  End If
               Else
                  If Civ_sub_cmd < 72 Then
                    $include _analyze_civ_s048_s071.bas
                  Else
                     $include _analyze_civ_s072_s095.bas
                  End If
               End If
            Else
               If Civ_sub_cmd < 144 Then
                  If Civ_sub_cmd < 120 Then
                     $include _analyze_civ_s096_s119.bas
                  Else
                     $include _analyze_civ_s120_s143.bas
                  End If
               Else
                  If Civ_sub_cmd < 168 Then
                     $include _analyze_civ_s144_s167.bas
                  Else
                     $include _analyze_civ_s168_s193.bas
                  End If
               End If
            End If
         Else
            $include _analyze_civ_1a06_1a07.bas
         End If
       End If
   Else
      Select Case Civ_in_b(5)
         Case &H1B
            $include _analyze_civ_1B.bas
         Case &H1C
            $include _analyze_civ_1C.bas
         Case &H27
            $include _analyze_civ_27.bas
         Case Else
            $include _analyze_civ_rest.bas
      End Select
   End If
End If
Return
'