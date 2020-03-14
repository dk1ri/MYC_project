' Ic7300 Analyze_civ Civ_cmd: 1B
' 191123
'
      Tx_b(1) = 2
      B_temp5 = 7
      Tx_write_pointer = 3
      Select Case Civ_in_b(6)
         Case 0
            Tx_b(2) = &HC8
            B_temp5 = 8
            Gosub Rx_tone
         Case 1
            Tx_b(2) = &HCA
            B_temp5 = 8   
            Gosub Rx_tone
      End Select
'