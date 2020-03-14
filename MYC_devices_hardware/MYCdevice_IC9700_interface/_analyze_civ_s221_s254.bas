' Analyze_civ Civ_sub_cmd: s221 - s254
' 20200307
'
s221:
   Tx_b(1) = 3:
   Tx_b(2) = &H7E
   Tx_b(3) = Makedec(Civ_in_b(9)) * 256
   Tx_b(3) = Makedec(Civ_in_b(10)) + Tx_b(3)
   Tx_write_pointer = 4
Return
'
s222:
   Tx_b(1) = 3:
   Tx_b(2) = &H80
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s223:
   Tx_b(1) = 3:
   Tx_b(2) = &H82
   Tx_b(3) = Makedec(Civ_in_b(9)) - 1
   Tx_write_pointer = 4
Return
'
s224:
   Tx_b(1) = 3:
   Tx_b(2) = &H84
   Tx_b(3) = Makedec(Civ_in_b(9)) - 28
   Tx_write_pointer = 4
Return
'
s225:
   Tx_b(1) = 3:
   Tx_b(2) = &H86
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s226:
   Tx_b(1) = 3:
   Tx_b(2) = &H88
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s227:
   Tx_b(1) = 3:
   Tx_b(2) = &H8A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s228:
   Tx_b(1) = 3:
   Tx_b(2) = &H8C
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s229:
   Tx_b(1) = 3:
   Tx_b(2) = &H8E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s230:
   Tx_b(1) = 3:
   Tx_b(2) = &H90
   Gosub Color
Return
'
s231:
   Tx_b(1) = 3:
   Tx_b(2) = &H92
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s232:
   Tx_b(1) = 3:
   Tx_b(2) = &H94
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s233:
   Tx_b(1) = 3:
   Tx_b(2) = &H96
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s234:
   Tx_b(1) = 3:
   Tx_b(2) = &H98
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s235:
   Tx_b(1) = 3:
   Tx_b(2) = &H9A
   Gosub Color
Return
'
s236:
   Tx_b(1) = 3:
   Tx_b(2) = &H9C
   Gosub Color
Return
'
s237:
   Tx_b(1) = 3:
   Tx_b(2) = &H9E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s238:
   Tx_b(1) = 3:
   Tx_b(2) = &HA0
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s239:
   Tx_b(1) = 3:
   Tx_b(2) = &HA2
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s240:
   Tx_b(1) = 3:
   Tx_b(2) = &HA4
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s241:
   Tx_b(1) = 3:
   Tx_b(2) = &HA6
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s242:
   Tx_b(1) = 3:
   Tx_b(2) = &HA8
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s243:
   Tx_b(1) = 3:
   Tx_b(2) = &HAA
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s244:
   Tx_b(1) = 3:
   Tx_b(2) = &HAC
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s245:
   Tx_b(1) = 3:
   Tx_b(2) = &HAE
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s246:
   Tx_b(1) = 3:
   Tx_b(2) = &HB0
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s247:
   Tx_b(1) = 3:
   Tx_b(2) = &HB2
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s248:
   Tx_b(1) = 3:
   Tx_b(2) = &HB4
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s249:
   Tx_b(1) = 3:
   Tx_b(2) = &HB6
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s250:
   Tx_b(1) = 3:
   Tx_b(2) = &HB8
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s251:
   Tx_b(1) = 3:
   Tx_b(2) = &HBA
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s252:
   Tx_b(1) = 3:
   Tx_b(2) = &HBC
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s253:
   Tx_b(1) = 3:
   Tx_b(2) = &HBE
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s254:
   Tx_b(1) = 3:
   Tx_b(2) = &HC0
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'