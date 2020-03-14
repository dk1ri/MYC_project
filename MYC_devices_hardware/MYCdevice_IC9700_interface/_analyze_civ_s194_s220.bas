' Analyze_civ Civ_sub_cmd: s168 - s193
' 20200305
'
s194:
   Tx_b(1) = 3:
   Tx_b(2) = &H54
   Gosub Color
Return
'
s195:
   Tx_b(1) = 3:
   Tx_b(2) = &H56
   Gosub Color
Return
'
s196:
   Tx_b(1) = 3:
   Tx_b(2) = &H58
   Gosub Color
Return
'
s197:
   Tx_b(1) = 3:
   Tx_b(2) = &H5A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s198:
   Tx_b(1) = 3:
   Tx_b(2) = &H5C
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s199:
   Tx_b(1) = 3:
   Tx_b(2) = &H5E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s200:
   Tx_b(1) = 3:
   Tx_b(2) = &H60
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s201:
   Tx_b(1) = 3:
   Tx_b(2) = &H62
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s202:
   Tx_b(1) = 3:
   Tx_b(2) = &H64
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s203:
   Tx_b(1) = 3:
   Tx_b(2) = &H64
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s204:
   Tx_b(1) = 3:
   Tx_b(2) = &H64
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s205:
   Tx_b(1) = 3:
   Tx_b(2) = &H66
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s206:
   Tx_b(1) = 3:
   Tx_b(2) = &H66
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s207:
   Tx_b(1) = 3:
   Tx_b(2) = &H66
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s208:
   Tx_b(1) = 3:
   Tx_b(2) = &H68
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s209:
   Tx_b(1) = 3:
   Tx_b(2) = &H68
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s210:
   Tx_b(1) = 3:
   Tx_b(2) = &H68
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s211:
   Tx_b(1) = 3:
   Tx_b(2) = &H6A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s212:
   Tx_b(1) = 3:
   Tx_b(2) = &H6C
   Gosub Color
Return
'
s213:
   Tx_b(1) = 3:
   Tx_b(2) = &H6E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s214:
   Tx_b(1) = 3:
   Tx_b(2) = &H70
   Gosub Color
Return
'
s215:
   Tx_b(1) = 3:
   Tx_b(2) = &H72
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s216:
   Tx_b(1) = 3:
   Tx_b(2) = &H74
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s217:
   Tx_b(1) = 3:
   Tx_b(2) = &H76
   Tx_b(3) = Makedec(Civ_in_b(9)) - 1
   Tx_write_pointer = 4
Return
'
s218:
   Tx_b(1) = 3:
   Tx_b(2) = &H78
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s219:
   Tx_b(1) = 3:
   Tx_b(2) = &H7A
   Tx_b(3) = Civ_in_b(9) - 1
   Tx_write_pointer = 4
Return
'
s220:
   Tx_b(1) = 3:
   Tx_b(2) = &H7A
   W_temp1 = 100 * Makedec(Civ_in_b(9))
   W_temp1 = W_temp1 + Makedec(Civ_in_b(10))
   Temps_b(3) = W_temp1_h
   Temps_b(4) = W_temp1_l
   Tx_write_pointer = 5
Return
'