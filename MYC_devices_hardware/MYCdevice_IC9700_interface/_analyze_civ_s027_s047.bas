' Analyze_civ Civ_sub_cmd: s027 - s047
' 191117
'
s27:
   Tx_b(1) = 2:
   Tx_b(2) = &H07
   Tx_b(3) = 100 * Civ_in_b(9)
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s28:
   Tx_b(1) = 2:
   Tx_b(2) = &H09
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s29:
   Tx_b(1) = 2:
   Tx_b(2) = &H0B
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s30:
   Tx_b(1) = 2:
   Tx_b(2) = &H0D
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s31:
   Tx_b(1) = 2:
   Tx_b(2) = &H0F
   W_temp1 = Civ_in_b(9) * 100
   B_temp1 = Makedec(Civ_in_b(10))
   W_temp1 = W_temp1 + B_temp1
   Tx_b(3) = W_temp1 + &H50
   Tx_write_pointer = 4
Return
'
s32:
   Tx_b(1) = 2:
   Tx_b(2) = &H11
   W_temp1 = Civ_in_b(9) * 100
   B_temp1 = Makedec(Civ_in_b(10))
   W_temp1 = W_temp1 + B_temp1
   Tx_b(3) = W_temp1 + &H50
   Tx_write_pointer = 4
Return
'
s33:
   Tx_b(1) = 2:
   Tx_b(2) = &H13
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s34:
   Tx_b(1) = 2:
   Tx_b(2) = &H15
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s35:
   Tx_b(1) = 2:
   Tx_b(2) = &H17
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s36:
   Tx_b(1) = 2:
   Tx_b(2) = &H19
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s37:
   Tx_b(1) = 2:
   Tx_b(2) = &H1B
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s38:
   Tx_b(1) = 2:
   Tx_b(2) = &H1D
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s39:
   Tx_b(1) = 2:
   Tx_b(2) = &H1F
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s40:
   Tx_b(1) = 2:
   Tx_b(2) = &H21
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s41:
   Tx_b(1) = 2:
   Tx_b(2) = &H23
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s42:
   Tx_b(1) = 2:
   Tx_b(2) = &H25
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s43:
   Tx_b(1) = 2:
   Tx_b(2) = &H27
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s44:
   Tx_b(1) = 2:
   Tx_b(2) = &H29
   Gosub RX_offset
Return
'
s45:
   Tx_b(1) = 2:
   Tx_b(2) = &H2B
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s46:
   Tx_b(1) = 2:
   Tx_b(2) = &H2D
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s47:
   Tx_b(1) = 2:
   Tx_b(2) = &H2F
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'