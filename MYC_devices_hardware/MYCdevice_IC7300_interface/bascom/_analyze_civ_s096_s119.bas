' Ic7300 Analyze_civ Civ_sub_cmd: s096 - s119
' 191116
'
      Tx_b(1) = 2
      ' overwritten for Civ_sub_cmd 72, 91, 93, 94
      Tx_b(3) = Civ_in_b(9)
      Tx_write_pointer = 4
      Select Case Civ_sub_cmd
         Case 96
            Tx_b(2) = &H34
            W_temp1 = Makedec(Civ_in_b(9)) * 60
            W_temp1 = W_temp1 + Makedec(Civ_in_b(10))
            If Civ_in_b(11) = 0 Then
               ' 840 is "0"
               W_temp1 = W_temp1 + 840
            Else
               W_temp1 = 840 - W_temp1
            End If
            Tx_b(3) = W_temp1_h
            Tx_b(4) = W_temp1_l
            Tx_write_pointer = 5
         Case 97
            Tx_b(2) = &H36
         Case 98
            Tx_b(2) = &H38
         Case 99
            Tx_b(2) = &H3A
         Case 100
            Tx_b(2) = &H3C
         Case 101
            Tx_b(2) = &H3E
         Case 102
            Tx_b(2) = &H40
         Case 103
            Tx_b(2) = &H42
         Case 104
            Tx_b(2) = &H44
            Gosub Color
         Case 105
            Tx_b(2) = &H46
            Gosub Color
         Case 106
            Tx_b(2) = &H48
            Gosub Color
         Case 107
            Tx_b(2) = &H4A
         Case 108
            Tx_b(2) = &H4C
         Case 109
            Tx_b(2) = &H4E
         Case 110
            Tx_b(2) = &H50
         Case 111
            Tx_b(2) = &H52
         Case 112
            Tx_b(2) = &H54
            Tx_b(3) = &H00
            F_offset = 30
            Gosub Rx_scope_edge
         Case 113
            Tx_b(2) = &H54
            Tx_b(3) = &H01
            F_offset = 30
            Gosub Rx_scope_edge
         Case 114
            Tx_b(2) = &H54
            Tx_b(3) = &H02
            F_offset = 30
            Gosub Rx_scope_edge
         Case 115
            Tx_b(2) = &H55
            Tx_b(3) = &H00
            F_offset = 1600
            Gosub Rx_scope_edge
         Case 116
            Tx_b(2) = &H55
            Tx_b(3) = &H01
            F_offset = 1600
            Gosub Rx_scope_edge
         Case 117
            Tx_b(2) = &H55
            Tx_b(3) = &H02
            F_offset = 1600
            Gosub Rx_scope_edge
         Case 118
            Tx_b(2) = &H58
            Tx_b(3) = &H00
            F_offset = 2000
            Gosub Rx_scope_edge
         Case 119
            Tx_b(2) = &H58
            Tx_b(3) = &H01
            F_offset = 2000
            Gosub Rx_scope_edge
      End Select
'