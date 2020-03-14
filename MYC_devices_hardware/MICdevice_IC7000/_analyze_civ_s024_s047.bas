' Analyze_civ Civ_sub_cmd: s024 - s047
' 20200219
'
s24:
   Tx_b(1) = 1:
   Tx_b(2) = &HA2
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s25:
   Tx_b(1) = 1:
   Tx_b(2) = &HA4
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s26:
   Tx_b(1) = 1:
   Tx_b(2) = &HA6
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s27:
   Tx_b(1) = 1:
   Tx_b(2) = &HA8
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s28:
   Tx_b(1) = 1:
   Tx_b(2) = &HAA
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s29:
   Tx_b(1) = 1:
   Tx_b(2) = &HAC
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s30:
   Tx_b(1) = 1:
   Tx_b(2) = &HAE
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s31:
   Tx_b(1) = 1:
   Tx_b(2) = &HB0
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s32:
   Tx_b(1) = 1:
   Tx_b(2) = &HB2
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s33:
   Tx_b(1) = 1:
   Tx_b(2) = &HB4
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s34:
   Tx_b(1) = 1:
   Tx_b(2) = &HB6
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s35:
   Tx_b(1) = 1:
   Tx_b(2) = &HB8
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s36:
   Tx_b(1) = 1:
   Tx_b(2) = &HBA
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s37:
   Tx_b(1) = 1:
   Tx_b(2) = &HBC
   Tx_b(3) = Civ_pointer
   For B_temp1 = 11 To Civ_pointer
      Tx_b(B_temp1 + 3) = Civ_in_b( B_temp1)
   Next B_temp1
   Tx_write_pointer = 4 + Civ_pointer
Return
'
s38:
   Tx_b(1) = 1:
   Tx_b(2) = &HBE
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s39:
   Tx_b(1) = 1:
   Tx_b(2) = &HC0
   Tx_b(3) = Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s40:
   Tx_b(1) = 1:
   Tx_b(2) = &HC2
   Tx_b(3) = Makedec(Civ_in_b(9)) - 1
   Tx_b(4) = Makedec(Civ_in_b(10)) - 1
   Tx_write_pointer = 5
Return
'
s41:
   Tx_b(1) = 1:
   Tx_b(2) = &HC4
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_b(4) = Makedec(Civ_in_b(10))
   Tx_write_pointer = 5
Return
'
s42:
   Tx_b(1) = 1:
   Tx_b(2) = &HC6
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s43:
   Tx_b(1) = 1:
   Tx_b(2) = &HC8
   W_temp1 = Makedec(Civ_in_b(9)) * 60
   W_temp1 = W_temp1 + Makedec(Civ_in_b(10))
   If Civ_in_b(11) = 1 Then W_temp1 = 1140 - W_temp1
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
Return
'
s44:
   Tx_b(1) = 1:
   Tx_b(2) = &HCA
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s45:
   Tx_b(1) = 1:
   Tx_b(2) = &HCC
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s46:
   Tx_b(1) = 1:
   Tx_b(2) = &HCE
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
'
s47:
   Tx_b(1) = 1:
   Tx_b(2) = &HD0
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'