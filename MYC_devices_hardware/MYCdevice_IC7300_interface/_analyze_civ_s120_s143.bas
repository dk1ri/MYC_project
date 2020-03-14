' Ic7300 Analyze_civ Civ_sub_cmd: s120 - s143
' 191118
'
      Tx_b(1) = 2
      Select Case Civ_sub_cmd
         Case 120
            Tx_b(2) = &H58
            Tx_b(3) = &H02
            W_temp1 = 2000
            Gosub Rx_scope_edge
         Case 121
            Tx_b(2) = &H5A
            Tx_b(3) = &H00
            W_temp1 = 6000
            Gosub Rx_scope_edge
         Case 122
            Tx_b(2) = &H5A
            Tx_b(3) = &H01
            W_temp1 = 6000
            Gosub Rx_scope_edge
         Case 123
            Tx_b(2) = &H5A
            Tx_b(3) = &H02
            W_temp1 = 6000
            Gosub Rx_scope_edge
         Case 124
            Tx_b(2) = &H5C
            Tx_b(3) = &H00
            W_temp1 = 8000
            Gosub Rx_scope_edge
         Case 125
            Tx_b(2) = &H5C
            Tx_b(3) = &H01
            W_temp1 = 8000
            Gosub Rx_scope_edge
         Case 126
            Tx_b(2) = &H5C
            Tx_b(3) = &H02
            W_temp1 = 8000
            Gosub Rx_scope_edge
         Case 127
            Tx_b(2) = &H5E
            Tx_b(3) = &H00
            W_temp1 = 11000
            Gosub Rx_scope_edge
         Case 128
            Tx_b(2) = &H5E
            Tx_b(3) = &H01
            W_temp1 = 11000
            Gosub Rx_scope_edge
         Case 129
            Tx_b(2) = &H5E
            Tx_b(3) = &H02
            W_temp1 = 11000
            Gosub Rx_scope_edge
         Case 130
            Tx_b(2) = &H60
            Tx_b(3) = &H00
            W_temp1 = 15000
            Gosub Rx_scope_edge
         Case 131
            Tx_b(2) = &H60
            Tx_b(3) = &H01
            W_temp1 = 15000
            Gosub Rx_scope_edge
         Case 132
            Tx_b(2) = &H60
            Tx_b(3) = &H02
            W_temp1 = 15000
            Gosub Rx_scope_edge
         Case 133
            Tx_b(2) = &H62
            Tx_b(3) = &H00
            W_temp1 = 20000
            Gosub Rx_scope_edge
         Case 134
            Tx_b(2) = &H62
            Tx_b(3) = &H01
            W_temp1 = 20000
            Gosub Rx_scope_edge
         Case 135
            Tx_b(2) = &H62
            Tx_b(3) = &H02
            W_temp1 = 20000
            Gosub Rx_scope_edge
         Case 136
            Tx_b(2) = &H64
            Tx_b(3) = &H00
            W_temp1 = 22000
            Gosub Rx_scope_edge
         Case 137
            Tx_b(2) = &H64
            Tx_b(3) = &H01
            W_temp1 = 22000
            Gosub Rx_scope_edge
         Case 138
            Tx_b(2) = &H64
            Tx_b(3) = &H02
            W_temp1 = 22000
            Gosub Rx_scope_edge
         Case 139
            Tx_b(2) = &H66
            Tx_b(3) = &H00
            W_temp1 = 26000
            Gosub Rx_scope_edge
         Case 140
            Tx_b(2) = &H66
            Tx_b(3) = &H01
            W_temp1 = 26000
            Gosub Rx_scope_edge
         Case 141
            Tx_b(2) = &H66
            Tx_b(3) = &H02
            W_temp1 = 26000
            Gosub Rx_scope_edge
         Case 142
            Tx_b(2) = &H68
            Tx_b(3) = &H00
            W_temp1 = 30000
            Gosub Rx_scope_edge
         Case 143
            Tx_b(2) = &H68
            Tx_b(3) = &H01
            W_temp1 = 30000
            Gosub Rx_scope_edge
      End Select
'