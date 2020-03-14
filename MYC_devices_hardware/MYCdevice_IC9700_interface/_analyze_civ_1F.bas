' Analyze_civ Ci_cmd: &H1F
' 20200312
'
   Tx_b(1) = 4
   Select Case Civ_in_b(6)
      Case 0
         Tx_b(2) = &H84
         B_temp2 = 7
         For B_temp1 = 3 To 26
            Tx_b(B_temp1) = Civ_in_b(B_temp2)
            Incr B_temp2
         Next B_temp1
         Tx_write_pointer = 27
      Case 1
         Tx_b(2) = &H86
         Tx_b(3) = Civ_in_b(7)
         Tx_write_pointer = 4
      Case 3
         Tx_b(2) = &H88
         B_temp2 = Civ_pointer - 7
         Tx_b(3) = B_temp2
         B_temp3 = 7
         B_temp2 = B_temp2 + 4
         For B_temp1 = 4 To B_temp2
            Tx_b(B_temp1) = Civ_in_b(B_temp3)
            Incr B_temp3
         Next B_temp1
         Tx_write_pointer = B_temp2 + 4
   End Select
'