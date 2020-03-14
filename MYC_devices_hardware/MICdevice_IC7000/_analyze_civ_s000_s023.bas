' Analyze_civ Civ_sub_cmd: s000 - s023
' 20200229
'
s03:
   Tx_b(1) = 1:
   Tx_b(2) = &H78
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s04:
   Tx_b(1) = 1:
   Tx_b(2) = &H7A
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_b(4) = Makedec(Civ_in_b(10)) - 5
   Tx_write_pointer = 4
Return
'
s05:
   Tx_b(1) = 1:
   Tx_b(2) = &H7C
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s06:
   Tx_b(1) = 1:
   Tx_b(2) = &H7E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s07:
   Tx_b(1) = 1:
   Tx_b(2) = &H80
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_b(4) = Makedec(Civ_in_b(10)) - 5
   Tx_write_pointer = 5
Return
'
s08:
   Tx_b(1) = 1:
   Tx_b(2) = &H82
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s09:
   Tx_b(1) = 1:
   Tx_b(2) = &H84
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s10:
   Tx_b(1) = 1:
   Tx_b(2) = &H86
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_b(4) = Makedec(Civ_in_b(10)) - 5
   Tx_write_pointer = 5
Return
'
s11:
   Tx_b(1) = 1:
   Tx_b(2) = &H88
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s12:
   Tx_b(1) = 1:
   Tx_b(2) = &H8A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s13:
   Tx_b(1) = 1:
   Tx_b(2) = &H8C
   Tx_b(3) = Civ_in_b(9) * 100
   B_temp1 = Makedec(Civ_in_b(10))
   Tx_b(3) = Tx_b(3) + B_temp1
   Tx_write_pointer = 4
Return
'
s14:
   Tx_b(1) = 1:
   Tx_b(2) = &H8E
   Tx_b(3) = Civ_in_b(9) * 100
   B_Temp1 = Makedec(Civ_in_b(10))
   Tx_b(3) = Tx_b(3) + B_temp1
   Tx_write_pointer = 4
Return
'
s15:
   Tx_b(1) = 1:
   Tx_b(2) = &H90
   Tx_b(3) = Civ_in_b(9) * 100
   B_Temp1 = Makedec(Civ_in_b(10))
   Tx_b(3) = Tx_b(3) + B_temp1
   Tx_write_pointer = 4
Return
'
s16:
   Tx_b(1) = 1:
   Tx_b(2) = &H92
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s17:
   Tx_b(1) = 1:
   Tx_b(2) = &H94
   Tx_b(3) = Civ_in_b(9) * 100
   B_Temp1 = Makedec(Civ_in_b(10))
   Tx_b(3) = Tx_b(3) + B_temp1
   Tx_write_pointer = 4
Return
'
s18:
   Tx_b(1) = 1:
   Tx_b(2) = &H96
   Tx_b(3) = Civ_in_b(9) * 100
   B_Temp1 = Makedec(Civ_in_b(10))
   Tx_b(3) = Tx_b(3) + B_temp1
   Tx_write_pointer = 4
Return
'
s19:
   Tx_b(1) = 1:
   Tx_b(2) = &H98
   Tx_b(3) = Civ_in_b(9) * 100
   B_Temp1 = Makedec(Civ_in_b(10))
   Tx_b(3) = Tx_b(3) + B_temp1
   Tx_write_pointer = 4
Return
'
s20:
   Tx_b(1) = 1:
   Tx_b(2) = &H9A
   Tx_b(3) = Civ_in_b(9) * 100
   B_Temp1 = Makedec(Civ_in_b(10))
   Tx_b(3) = Tx_b(3) + B_temp1
   Tx_write_pointer = 4
Return
'
s21:
   Tx_b(1) = 1:
   Tx_b(2) = &H9C
   Tx_b(3) = Civ_in_b(9) * 100
   B_Temp1 = Makedec(Civ_in_b(10))
   Tx_b(3) = Tx_b(3) + B_temp1
   Tx_write_pointer = 4
Return
'
s22:
   Tx_b(1) = 1:
   Tx_b(2) = &H9E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s23:
   Tx_b(1) = 1:
   Tx_b(2) = &HA0
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'