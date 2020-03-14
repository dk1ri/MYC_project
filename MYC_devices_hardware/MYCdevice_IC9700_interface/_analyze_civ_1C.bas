' Analyze_civ Civ_cmd: 1C
' 20200214
'
      Tx_b(1) = 4
      Select Case Civ_in_b(6)
         Case 0
            Tx_b(2) = &H7A
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case 2
            Tx_b(2) = &H7C
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case 3
            Tx_b(2) = &H7D
            B_temp5 = 7
            Tx_write_pointer = 3
            Gosub Rx_frequency
      End Select
'