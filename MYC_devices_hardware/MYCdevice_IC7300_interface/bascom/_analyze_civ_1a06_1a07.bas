' Ic7300 Analyze_civ Civ_sub_cmd: s168 - s193
' 191123
'
      Tx_b(1) = 2
      Select Case Civ_in_b(6)
         Case 6
            Tx_b(2) = &HC4
            If Civ_in_b(7) = 0 Then
               Tx_b(3) =0
            Else
               Tx_b(3) = Civ_in_b(8)
            End If
            Tx_write_pointer = 4
         Case 7
            Tx_b(2) = &HC6
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
      End Select
'