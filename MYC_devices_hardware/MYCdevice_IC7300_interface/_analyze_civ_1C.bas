' Ic7300 Analyze_civ Civ_cmd: 1C
' 191124
'
      Tx_b(1) = 2
      Select Case Civ_in_b(6)
         Case 0
            Tx_b(2) = &HCC
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case 1
            Tx_b(2) = &HCE
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
            Tx_write_pointer = 4
         Case 2
            Tx_b(2) = &HD0
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case 3
            Tx_b(2) = &HD1
            B_temp5 = 7
            Tx_write_pointer = 3
            Gosub Rx_frequency
         Case 4
            Tx_b(2) = &HD3
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
'
      End Select
'