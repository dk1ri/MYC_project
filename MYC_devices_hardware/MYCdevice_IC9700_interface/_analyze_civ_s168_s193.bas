' Analyze_civ Civ_sub_cmd: s168 - s193
' 20200305
'
s168:
   Tx_b(1) = 3:
   Tx_b(2) = &H20
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s169:
   Tx_b(1) = 3:
   Tx_b(2) = &H22
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s170:
   Tx_b(1) = 3:
   Tx_b(2) = &H24
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s171:
   Tx_b(1) = 3:
   Tx_b(2) = &H26
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s172:
   Tx_b(1) = 3:
   Tx_b(2) = &H28
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s173:
   Tx_b(1) = 3:
   Tx_b(2) = &H2A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s174:
   Tx_b(1) = 3:
   Tx_b(2) = &H2C
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s175:
   Tx_b(1) = 3:
   Tx_b(2) = &H2E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s176:
   Tx_b(1) = 3:
   Tx_b(2) = &H30
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s177:
   Tx_b(1) = 3:
   Tx_b(2) = &H32
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s178:
   Tx_b(1) = 3:
   Tx_b(2) = &H34
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s179:
   Tx_b(1) = 3:
   Tx_b(2) = &H36
   Tx_b(3) =  Makedec(Civ_in_b(10))
   Tx_b(4) =  Makedec(Civ_in_b(11))
   Tx_b(5) =  Makedec(Civ_in_b(12))
   Tx_write_pointer = 6
Return
'
s180:
   Tx_b(1) = 3:
   Tx_b(2) = &H38
   Tx_b(3) =  Makedec(Civ_in_b(10))
   Tx_b(4) =  Makedec(Civ_in_b(11))
   Tx_write_pointer = 6
Return
'
s181:
   Tx_b(1) = 3:
   Tx_b(2) = &H3A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s182:
   Tx_b(1) = 2:
   Tx_b(2) = &HEC
   If Civ_pointer = 8 Then
      ' emptry
      Tx_b(3) = 0
      Tx_b(4) = 0
      Tx_b(5) = 0
      Tx_b(6) = 0
   Else
      Tx_b(3) = Civ_in_b(9)
      Tx_b(4) = Civ_in_b(10)
      Tx_b(5) = Civ_in_b(11)
      Tx_b(6) = Civ_in_b(12) -1
   End If
   Tx_write_pointer = 7
Return
'
s183:
   Tx_b(1) = 3:
   Tx_b(2) = &H3E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s184:
   Tx_b(1) = 3:
   Tx_b(2) = &H40
   W_temp1 = Makedec(Civ_in_b(9)) * 60
   W_temp1 = W_temp1 + Makedec(Civ_in_b(10))
   If Civ_in_b(11) = 0 Then
      ' 840 is "0"
      W_temp1 = W_temp1 + 840
   Else
      W_temp1 = 840 - W_temp1
   End If
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
Return
'
s185:
   Tx_b(1) = 3:
   Tx_b(2) = &H42
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s186:
   Tx_b(1) = 3:
   Tx_b(2) = &H44
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s187:
   Tx_b(1) = 3:
   Tx_b(2) = &H46
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s188:
   Tx_b(1) = 3:
   Tx_b(2) = &H48
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s189:
   Tx_b(1) = 3:
   Tx_b(2) = &H4A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s190:
   Tx_b(1) = 3:
   Tx_b(2) = &H4C
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s191:
   Tx_b(1) = 3:
   Tx_b(2) = &H4E
   Tx_b(3) = Civ_in_b(9)
   Tx_b(4) = Civ_in_b(10)
   Tx_write_pointer = 5
Return
'
s192:
   Tx_b(1) = 3:
   Tx_b(2) = &H50
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s193:
   Tx_b(1) = 3:
   Tx_b(2) = &H52
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'