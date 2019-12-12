' Ic7300 Analyze_civ Ci_cmd: &H1E- &H26
' 191126
'
      Tx_b(1) = 2
      Select Case Civ_in_b(5)
         Case &H1E
            Select Case Civ_in_b(6)
               Case 0
                  Tx_b(2) = &HD4
                  Number_avail_TX_band = Makedec(Civ_in_b(7))
                  Tx_b(3) = Number_avail_TX_band
                  Tx_write_pointer = 4
                  If Read_memory_counter < 104 Then
                     Incr Read_memory_counter
                     Block_read_mem_command = 0
                  End If
               Case 1
                  Tx_b(2) = &HD5
                  B_temp5 = 8
                  Gosub Rx_band_edge
               Case 2
                  Tx_b(2) = &HD6
                  Tx_b(3) = Makedec(Civ_in_b(7))
                  Tx_write_pointer = 4
               Case 3
                  Tx_b(2) = &HD8
                  B_temp5 = 8
                  Gosub Rx_band_edge
            End Select
         Case &H21
            Select Case Civ_in_b(6)
               Case 0
                  Tx_b(2) = &HDA
                  W_temp1 = Makedec(Civ_in_b(8)) * 100
                  W_temp2 = Makedec(Civ_in_b(7))
                  W_temp1 = W_temp1 + W_temp2
                  If Civ_in_b(9) = 0 Then
                     W_temp1 = W_temp1 + 9999
                  Else
                     W_temp1 = 9999 - W_temp1
                  End If
                  Tx_b(3) = W_temp1_h
                  Tx_b(4) = W_temp1_l
                  Tx_write_pointer = 5
               Case 1
                  Tx_b(2) = &HDC
                  Tx_b(3) = Civ_in_b(7)
                  Tx_write_pointer = 4
               Case 2
                  Tx_b(2) = &HDE
                  Tx_b(3) = Civ_in_b(7)
                  Tx_write_pointer = 4
            End Select
         Case &H25
            Tx_b(2) = &HE0
            Tx_b(3) = Civ_in_b(6)
            B_temp5 = 7
            Tx_write_pointer = 4
            Gosub Rx_frequency
         Case &H26
            Tx_b(2) = &HE2
            Tx_b(3) = Civ_in_b(6)
            Tx_b(4) = Civ_in_b(7)
            Tx_b(5) = Civ_in_b(9) - 1
            If Civ_in_b(8) = 0 Then
               If Tx_b(4) > 5 Then Tx_b(4) = Tx_b(4)  - 1
            Else
               If Tx_b(4) = 5 Then
                  Tx_b(4) = 11
               Else
                  Tx_b(4) = Tx_b(4)  + 8
               End If
            End If
            Tx_write_pointer = 6
         Case 28
            Tx_b(1) = &H03
            Tx_b(2) = &H1F
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
      End Select
'