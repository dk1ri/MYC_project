' Analyze_civ Civ_cmd: 1B
' 20200314
'
      Tx_b(1) = 4
      B_temp5 = 7
      Tx_write_pointer = 3
      Select Case Civ_in_b(6)
         Case 0
            Tx_b(2) = &H72
            B_temp5 = 8
            Gosub Rx_tone
         Case 1
            Tx_b(2) = &H74
            B_temp5 = 8
            Gosub Rx_tone
         Case 2
            Tx_b(2) = &H76
            Tx_b(4) = Civ_in_b(7) And &HF0
            B_temp1 = Civ_in_b(7)
            Shift B_temp1, Right, 4
            Tx_b(3) = B_temp1
            Tx_b(5) = Civ_in_b(8)
            B_temp1 = Civ_in_b(9)
            Shift B_temp1, Right, 4
            Tx_b(6) = B_temp1
            Tx_b(7) = Civ_in_b(10) And &HF0
            Tx_write_pointer = 8
         Case 7
            Tx_b(2) = &H78
            Tx_b(3) = Makedec(Civ_in_b(7))
            Tx_write_pointer = 4
      End Select
'