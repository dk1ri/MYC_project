' Analyze_civ Civ_sub_cmd: 1a06 .. 1a0a
' 20200212
'
      Tx_b(1) = 4
      Select Case Civ_in_b(6)
         Case 6
            Tx_b(2) = &H6C
            If Civ_in_b(7) = 0 Then
               Tx_b(3) =0
            Else
               Tx_b(3) = Civ_in_b(8)
            End If
            Tx_write_pointer = 4
         Case 7
            NOP
         Case 8
            Tx_b(2) = &H6E
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case 9
            Tx_b(2) = &H6F
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case &H0A
            Tx_b(2) = &H70
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
      End Select
'