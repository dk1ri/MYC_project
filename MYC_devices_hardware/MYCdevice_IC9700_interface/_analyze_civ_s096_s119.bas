' Analyze_civ Civ_sub_cmd: s096 - s119
' 20200302
'
s96:
   Tx_b(1) = 2:
   Tx_b(2) = &H91
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s97:
   Tx_b(1) = 2:
   Tx_b(2) = &H93
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_write_pointer = 4
Return
'
s98:
   Tx_b(1) = 2:
   Tx_b(2) = &H95
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s99:
   Tx_b(1) = 2:
   Tx_b(2) = &H97
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s100:
   Tx_b(1) = 2:
   Tx_b(2) = &H99
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s101:
   Tx_b(1) = 2:
   Tx_b(2) = &H9B
   Tx_b(3) = 100 * Civ_in_b(9)
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s102:
   Tx_b(1) = 2:
   Tx_b(2) = &H9D
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s103:
   Tx_b(1) = 2:
   Tx_b(2) = &H9F
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s104:
   Tx_b(1) = 2:
   Tx_b(2) = &HA1
   Tx_b(3) = 100 * Civ_in_b(9)
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s105:
   Tx_b(1) = 2:
   Tx_b(2) = &HA3
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s106:
   Tx_b(1) = 2:
   Tx_b(2) = &HA5
   Tx_b(3) = 100 * Civ_in_b(9)
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s107:
   Tx_b(1) = 2:
   Tx_b(2) = &HA7
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s108:
   Tx_b(1) = 2:
   Tx_b(2) = &HA9
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s109:
   Tx_b(1) = 2:
   Tx_b(2) = &HAB
   Tx_b(3) = 100 * Civ_in_b(9)
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s110:
   Tx_b(1) = 2:
   Tx_b(2) = &HAD
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s111:
   Tx_b(1) = 2:
   Tx_b(2) = &HAF
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s112:
   Tx_b(1) = 2:
   Tx_b(2) = &HB1
   Tx_b(3) = 100 * Civ_in_b(9)
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s113:
   Tx_b(1) = 2:
   Tx_b(2) = &HB3
   Tx_b(3) = 100 * Civ_in_b(9)
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s114:
   Tx_b(1) = 2:
   Tx_b(2) = &HB5
   Tx_b(3) = 100 * Civ_in_b(9)
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s115:
   Tx_b(1) = 2:
   Tx_b(2) = &HB7
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s116:
   Tx_b(1) = 2:
   Tx_b(2) = &HB9
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s117:
   Tx_b(1) = 2:
   Tx_b(2) = &HBB
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s118:
   Tx_b(1) = 2:
   Tx_b(2) = &HBD
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s119:
   Tx_b(1) = 2:
   Tx_b(2) = &HBF
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'