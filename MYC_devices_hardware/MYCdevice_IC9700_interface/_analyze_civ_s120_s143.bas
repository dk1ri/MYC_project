' Analyze_civ Civ_sub_cmd: s120 - s143
' 20200303
'
s120:
   Tx_b(1) = 2:
   Tx_b(2) = &HC0
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s121:
   Tx_b(1) = 2:
   Tx_b(2) = &HC3
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s122:
   Tx_b(1) = 2:
   Tx_b(2) = &HC5
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s123:
   Tx_b(1) = 2:
   Tx_b(2) = &HC7
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s124:
   Tx_b(1) = 2:
   Tx_b(2) = &HC9
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s125:
   Tx_b(1) = 2:
   Tx_b(2) = &HCB
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s126:
   Tx_b(1) = 2:
   Tx_b(2) = &HCD
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s127:
   Tx_b(1) = 2:
   Tx_b(2) = &HCF
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s128:
   Tx_b(1) = 2:
   Tx_b(2) = &HD1
   Tx_b(3) = 100 * Civ_in_b(9)
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s129:
   Tx_b(1) = 2:
   Tx_b(2) = &HD3
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s130:
   Tx_b(1) = 2:
   Tx_b(2) = &HD5
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s131:
   Tx_b(1) = 2:
   Tx_b(2) = &HD7
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s132:
   Tx_b(1) = 2:
   Tx_b(2) = &HD9
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s133:
   Tx_b(1) = 2:
   Tx_b(2) = &HDB
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s134:
   Tx_b(1) = 2:
   Tx_b(2) = &HDD
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s135:
   Tx_b(1) = 2:
   Tx_b(2) = &HDF
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s136:
   Tx_b(1) = 2:
   Tx_b(2) = &HE1
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s137:
   Tx_b(1) = 2:
   Tx_b(2) = &HE3
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s138:
   Tx_b(1) = 2:
   Tx_b(2) = &HE5
   Tx_b(3) = Civ_in_b(9)
   Tx_b(4) = Civ_in_b(10)
   Tx_b(5) = Civ_in_b(11)
   Tx_b(6) = Civ_in_b(12) -1
   Tx_write_pointer = 7
Return
'
s139:
   Tx_b(1) = 2:
   Tx_b(2) = &HE6
   Tx_b(3) = Civ_in_b(9)
   Tx_b(4) = Civ_in_b(10)
   Tx_b(5) = Civ_in_b(11)
   Tx_b(6) = Civ_in_b(12) -1
   Tx_write_pointer = 7
Return
'
s140:
   Tx_b(1) = 2:
   Tx_b(2) = &HE8
   Tx_b(3) = Makedec(Civ_in_b(9) - 1)
   Tx_write_pointer = 4
Return
'
s141:
   Tx_b(1) = 2:
   Tx_b(2) = &HEA
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
s142:
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
s143:
   Tx_b(1) = 2:
   Tx_b(2) = &HEE
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