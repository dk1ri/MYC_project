' Analyze_civ Civ_sub_cmd: s048 - s071
' 20200220
'
s48:
   Tx_b(1) = 1:
   Tx_b(2) = &HD2
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s49:
   Tx_b(1) = 1:
   Tx_b(2) = &HD4
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
'
s50:
   Tx_b(1) = 1:
   Tx_b(2) = &HD6
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s51:
   Tx_b(1) = 1:
   Tx_b(2) = &HD8
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s52:
   Tx_b(1) = 1:
   Tx_b(2) = &HDA
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s53:
   Tx_b(1) = 1:
   Tx_b(2) = &HDC
   W_temp1 = Civ_in_b(11) * 1000
   W_temp2 = Civ_in_b(10) * 10
   W_temp1 = W_temp1 + W_temp2
   W_temp2 = Civ_in_b(10) / 16
   W_temp1 = W_temp1 + W_temp2
   If Civ_in_b(12) = 1 Then W_temp1 = 10000 - W_temp1
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
'
s54:
   Tx_b(1) = 1:
   Tx_b(2) = &HDE
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s55:
   Tx_b(1) = 1:
   Tx_b(2) = &HE0
   W_temp1 = Civ_in_b(11) * 1000
   W_temp2 = Civ_in_b(10) * 10
   W_temp1 = W_temp1 + W_temp2
   W_temp2 = Civ_in_b(10) / 16
   W_temp1 = W_temp1 + W_temp2
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
'
s56:
   Tx_b(1) = 1:
   Tx_b(2) = &HE2
   W_temp1 = Civ_in_b(11) * 1000
   W_temp2 = Civ_in_b(10) * 10
   W_temp1 = W_temp1 + W_temp2
   W_temp2 = Civ_in_b(10) / 16
   W_temp1 = W_temp1 + W_temp2
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
'
s57:
   Tx_b(1) = 1:
   Tx_b(2) = &HE4
   W_temp1 = Civ_in_b(11) * 1000
   W_temp2 = Civ_in_b(10) * 10
   W_temp1 = W_temp1 + W_temp2
   W_temp2 = Civ_in_b(10) / 16
   W_temp1 = W_temp1 + W_temp2
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
'
s58:
   Tx_b(1) = 1:
   Tx_b(2) = &HE6
   W_temp1 = Civ_in_b(11) * 1000
   W_temp2 = Civ_in_b(10) * 10
   W_temp1 = W_temp1 + W_temp2
   W_temp2 = Civ_in_b(10) / 16
   W_temp1 = W_temp1 + W_temp2
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
'
s59:
   Tx_b(1) = 1:
   Tx_b(2) = &HE8
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s60:
   Tx_b(1) = 1:
   Tx_b(2) = &HEA
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s61:
   Tx_b(1) = 1:
   Tx_b(2) = &HEC
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s62:
   Tx_b(1) = 1:
   Tx_b(2) = &HEE
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s63:
   Tx_b(1) = 1:
   Tx_b(2) = &HF0
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s64:
   Tx_b(1) = 1:
   Tx_b(2) = &HF2
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s65:
   Tx_b(1) = 1:
   Tx_b(2) = &HF5
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
'
s66:
   Tx_b(1) = 1:
   Tx_b(2) = &HF6
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s67:
   Tx_b(1) = 1:
   Tx_b(2) = &HF8
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s68:
   Tx_b(1) = 1:
   Tx_b(2) = &HFA
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s69:
   Tx_b(1) = 1:
   Tx_b(2) = &HFC
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s70:
   Tx_b(1) = 1:
   Tx_b(2) = &HFE
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s71:
   Tx_b(1) = 2:
   Tx_b(2) = &H00
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'