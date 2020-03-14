' Ic7300 Analyze_civ Civ_sub_cmd: s144 - s167
' 191118
'
      Tx_b(1) = 2
      Select Case Civ_sub_cmd
         Case 144
            Tx_b(2) = &H68
            Tx_b(3) = &H02
            W_temp1 = 30000
            Gosub Rx_scope_edge
         Case 145
            Tx_b(2) = &H6A
            Tx_b(3) = &H00
            W_temp1 = 45000
            Gosub Rx_scope_edge
         Case 146
            Tx_b(2) = &H6A
            Tx_b(3) = &H01
            W_temp1 = 45000
            Gosub Rx_scope_edge
         Case 147
            Tx_b(2) = &H6A
            Tx_b(3) = &H02
            W_temp1 = 45000
            Gosub Rx_scope_edge
         Case 148
            Tx_b(2) = &H6C
            Tx_b(3) = &H00
            W_temp1 = 60000
            Gosub Rx_scope_edge
         Case 149
            Tx_b(2) = &H6C
            Tx_b(3) = &H01
            W_temp1 = 60000
            Gosub Rx_scope_edge
         Case 150
            Tx_b(2) = &H6C
            Tx_b(3) = &H02
            W_temp1 = 60000
            Gosub Rx_scope_edge
         Case 151
            Tx_b(2) = &H6E
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 152
            Tx_b(2) = &H70
            Gosub Color
         Case 153
            Tx_b(2) = &H72
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 154
            Tx_b(2) = &H74
            Gosub Color
         Case 155
            Tx_b(2) = &H76
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 156
            Tx_b(2) = &H78
            Tx_b(3) = Civ_in_b(9) - 1
            Tx_write_pointer = 4
         Case 157
            Tx_b(2) = &H7A
            W_temp1 = Makedec(Civ_in_b(9)) * 100
            W_temp1 = W_temp1 + Makedec(Civ_in_b(10))
            Decr W_temp1
            Tx_b(3) = W_temp1_h
            Tx_b(4) = W_temp1_l
            Tx_write_pointer = 5
         Case 158
            Tx_b(2) = &H7C
            B_temp1 = Makedec(Civ_in_b(9)) * 100
            Tx_b(3) = B_temp1 + Makedec(Civ_in_b(10))
            Tx_write_pointer = 4
         Case 159
            Tx_b(2) = &H7E
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 160
            Tx_b(2) = &H80
            Tx_b(3) = Makedec(Civ_in_b(9)) - 1
            Tx_write_pointer = 4
         Case 161
            Tx_b(2) = &H82
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_b(3) = Tx_b(3) - 28
            Tx_write_pointer = 4
         Case 162
            Tx_b(2) = &H84
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 163
            Tx_b(2) = &H86
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 164
            Tx_b(2) = &H88
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 165
            Tx_b(2) = &H8A
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 166
            Tx_b(2) = &H8C
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 167
            Tx_b(2) = &H8E
            Gosub Color
      End Select
'