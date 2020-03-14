' Analyze_civ: &H1E
' 20200312
'
      Tx_b(1) = 4
      Select Case Civ_in_b(6)
         Case 0
            Tx_b(2) = &H7E
            Number_avail_TX_band = Makedec(Civ_in_b(7))
            Tx_b(3) = Number_avail_TX_band
            Tx_write_pointer = 4
            If Read_memory_counter < 104 Then
               Incr Read_memory_counter
               Block_read_mem_command = 0
            End If
         Case 1
            Tx_b(2) = &H7F
            B_temp5 = 8
            Gosub Rx_band_edge
         Case 2
            Tx_b(2) = &H80
            Tx_b(3) = Makedec(Civ_in_b(7))
            Tx_write_pointer = 4
         Case 3
            Tx_b(2) = &H82
            B_temp5 = 8
            Gosub Rx_band_edge
      End Select