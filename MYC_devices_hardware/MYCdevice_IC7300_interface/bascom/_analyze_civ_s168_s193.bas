' Ic7300 Analyze_civ Civ_sub_cmd: s168 - s193
' 191123
'
      Tx_b(1) = 2
      Select Case Civ_sub_cmd
         Case 168
            Tx_b(2) = &H90
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 169
            Tx_b(2) = &H92
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 170
            Tx_b(2) = &H94
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 171
            Tx_b(2) = &H96
            Gosub Color
         Case 172
            Tx_b(2) = &H98
            Gosub Color
         Case 173
            Tx_b(2) = &H9a
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 174
            Tx_b(2) = &H9C
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 175
            Tx_b(2) = &H9E
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 176
            Tx_b(2) = &HA0
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 177
            Tx_b(2) = &HA2
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 178
            Tx_b(2) = &HA4
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 179
            Tx_b(2) = &HA6
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 180
            Tx_b(2) = &HA8
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 181
            Tx_b(2) = &HAA
            Tx_b(3) = Makedec(Civ_in_b(9))
            Decr Tx_b(3)
            Tx_write_pointer = 4
         Case 182
            Tx_b(2) = &HAC
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 183
            Tx_b(2) = &HAE
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 184
            Tx_b(2) = &HB0
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 185
            Tx_b(2) = &HB2
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 186
            Tx_b(2) = &HB4
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 187
            Tx_b(2) = &HB6
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 188
            Tx_b(2) = &HB8
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 189
            Tx_b(2) = &HBA
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 190
            Tx_b(2) = &HBC
            B_temp1 = Makedec(Civ_in_b(9)) * 100
            Tx_b(3) = B_temp1 + Makedec(Civ_in_b(10))
            Tx_write_pointer = 4
         Case 191
            Tx_b(2) = &HBE
            Tx_b(3) = Makedec(Civ_in_b(9))
            Tx_write_pointer = 4
         Case 192
            Tx_b(2) = &HC0
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
         Case 193
            Tx_b(2) = &HC2
            Tx_b(3) = Civ_in_b(9)
            Tx_write_pointer = 4
      End Select
'