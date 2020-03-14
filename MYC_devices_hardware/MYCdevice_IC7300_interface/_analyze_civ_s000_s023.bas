' Ic7300 Analyze_civ Civ_sub_cmd: s000 - s023
' 191114
'
      Tx_b(1) = 1
      Select Case Civ_sub_cmd
         Case 1
            Tx_b(2) = &H76
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_b(4) = Makedec(Civ_in_b(10)) - 5
            Tx_write_pointer = 5
         Case 2
            Tx_b(2) = &H78
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_write_pointer = 4
         Case 3
            Tx_b(2) = &H7A
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_write_pointer = 4
         Case 4
            Tx_b(2) = &H7C
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_b(4) = Makedec(Civ_in_b(10)) - 5
            Tx_write_pointer = 5
         Case 5
            Tx_b(2) = &H7E
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_write_pointer = 4
         Case 6
            Tx_b(2) = &H80
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_write_pointer = 4
         Case 7
            Tx_b(2) = &H82
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_b(4) = Makedec(Civ_in_b(10)) - 5
            Tx_write_pointer = 5
         Case 8
            Tx_b(2) = &H84
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_write_pointer = 4
         Case 9
            Tx_b(2) = &H86
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_write_pointer = 4
         Case 10
            Tx_b(2) = &H88
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_b(4) = Makedec(Civ_in_b(10)) - 5
            Tx_write_pointer = 5
         Case 11
            Tx_b(2) = &H8A
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_b(4) = Makedec(Civ_in_b(10)) - 5
            Tx_write_pointer = 5
         Case 12
            Tx_b(2) = &H8C
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_write_pointer = 4
         Case 13
            Tx_b(2) = &H8E
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_write_pointer = 4
         Case 14
            Tx_b(2) = &H90
            Gosub Rx_hpf_lpf
            Tx_write_pointer = 5
         Case 15
            Tx_b(2) = &H92
            Gosub Rx_hpf_lpf
            Tx_write_pointer = 5
         Case 16
            Tx_b(2) = &H94
            Gosub Rx_hpf_lpf
            Tx_write_pointer = 5
         Case 17
            Tx_b(2) = &H96
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_write_pointer = 4
         Case 18
            Tx_b(2) = &H98
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_write_pointer = 4
         Case 19
            Tx_b(2) = &H9A
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_write_pointer = 4
         Case 20
            Tx_b(2) = &H9C
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_write_pointer = 4
         Case 21
            Tx_b(2) = &H9E
            Tx_b(3) = 100 * Civ_in_b(9)
            Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
            Tx_write_pointer = 4
         Case 22
            Tx_b(2) = &HA0
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 23
            Tx_b(2) = &HA2
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
      End Select
'