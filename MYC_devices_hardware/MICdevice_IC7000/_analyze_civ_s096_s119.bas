' Analyze_civ Civ_sub_cmd: s096 - s119
' 20200221
'
s96:
   Tx_b(1) = 2:
   Tx_b(2) = &H32
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s97:
   Tx_b(1) = 2:
   Tx_b(2) = &H34
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s98:
   Tx_b(1) = 2:
   Tx_b(2) = &H36
   Tx_b(3) = Civ_in_b(9) - 1
   Tx_write_pointer = 4
'
s99:
   Tx_b(1) = 2:
   Tx_b(2) = &H38
   W_temp1 = Makedec(Civ_in_b(9))
   W_temp1 = W_temp1 * 100
   W_temp1 = W_temp1 + Makedec(Civ_in_b(10))
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
'
s100:
   Tx_b(1) = 2:
   Tx_b(2) = &H3A
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_write_pointer = 4
'
s101:
   Tx_b(1) = 2:
   Tx_b(2) = &H3C
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_b(3) = Tx_b(3) - 28
   Tx_write_pointer = 4
'
s102:
   Tx_b(1) = 2:
   Tx_b(2) = &H3E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s103:
   Tx_b(1) = 2:
   Tx_b(2) = &H40
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s104:
   Tx_b(1) = 2:
   Tx_b(2) = &H42
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s105:
   Tx_b(1) = 2:
   Tx_b(2) = &H44
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s106:
   Tx_b(1) = 2:
   Tx_b(2) = &H46
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s107:
   Tx_b(1) = 2:
   Tx_b(2) = &H48
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s108:
   Tx_b(1) = 2:
   Tx_b(2) = &H4A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s109:
   Tx_b(1) = 2:
   Tx_b(2) = &H4C
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s110:
   Tx_b(1) = 2:
   Tx_b(2) = &H4E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s111:
   Tx_b(1) = 2:
   Tx_b(2) = &H50
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s112:
   Tx_b(1) = 2:
   Tx_b(2) = &H52
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
'
s113:
   Tx_b(1) = 2:
   Tx_b(2) = &H54
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
'
s114:
   Tx_b(1) = 2:
   Tx_b(2) = &H56
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_write_pointer = 4
'
s115:
   Tx_b(1) = 2:
   Tx_b(2) = &H58
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
'
s116:
   Tx_b(1) = 2:
   Tx_b(2) = &H5A
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
'
s117:
   Tx_b(1) = 2:
   Tx_b(2) = &H5C
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_write_pointer = 4
'
s118:
   Tx_b(1) = 2:
   Tx_b(2) = &H5E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
'
s119:
   Tx_b(1) = 2:
   Tx_b(2) = &H60
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
'