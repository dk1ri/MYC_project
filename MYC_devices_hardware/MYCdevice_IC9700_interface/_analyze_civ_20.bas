' Analyze_civ Ci_cmd: &H20
' 20200312
'
   Tx_b(1) = 4
   Select Case Civ_in_b(6)
      Case 0
         Select Case Civ_in_b(7)
            Case 0
               Tx_b(2) = &H84
               Tx_b(3) = Civ_in_b(8)
               Tx_write_pointer = 4
         End Select
   End Select
'