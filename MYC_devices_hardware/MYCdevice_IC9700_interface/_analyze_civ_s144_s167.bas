' Analyze_civ Civ_sub_cmd: s144 - s167
' 20200305
'
s144:
   Tx_b(1) = 2:
   Tx_b(2) = &HF0
   Tx_b(3) = Civ_pointer - 8
   B_temp2 = 4
   B_temp3 = 7
   For B_temp1 = 1 To Tx_b(3)
      Tx_b(B_temp2) = Civ_in_b(B_temp3)
      Incr B_temp2
      Incr B_temp3
   Next B_temp1
   Tx_write_pointer = Tx_b(3) + 3
Return
'
s145:
   Tx_b(1) = 2:
   Tx_b(2) = &HF2
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s146:
   Tx_b(1) = 2:
   Tx_b(2) = &HF4
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s147:
   Tx_b(1) = 2:
   Tx_b(2) = &HF6
   W_Temp1 = Makedec(Civ_in_b(9)) * 10000
   W_temp2 = Makedec(Civ_in_B(10)) * 100
   W_temp1 = W_temp1 + W_temp2
   W_temp1 = W_temp1 + Makedec(Civ_in_b(11))
   Decr W_temp1
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
Return
'
s148:
   Tx_b(1) = 2:
   Tx_b(2) = &HF8
   W_Temp1 = Makedec(Civ_in_b(9)) * 10000
   W_temp2 = Makedec(Civ_in_B(10)) * 100
   W_temp1 = W_temp1 + W_temp2
   W_temp1 = W_temp1 + Makedec(Civ_in_b(11))
   Decr W_temp1
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
Return
'
s149:
   Tx_b(1) = 2:
   Tx_b(2) = &HFA
   W_Temp1 = Makedec(Civ_in_b(9)) * 10000
   W_temp2 = Makedec(Civ_in_B(10)) * 100
   W_temp1 = W_temp1 + W_temp2
   W_temp1 = W_temp1 + Makedec(Civ_in_b(11))
   Decr W_temp1
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
Return
'
s150:
   Tx_b(1) = 2:
   Tx_b(2) = &HFC
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s151:
   Tx_b(1) = 2:
   Tx_b(2) = &HFE
   Tx_b(3) = Civ_pointer - 8
   B_temp2 = 4
   B_temp3 = 7
   For B_temp1 = 1 To Tx_b(3)
      Tx_b(B_temp2) = Civ_in_b(B_temp3)
      Incr B_temp2
      Incr B_temp3
   Next B_temp1
   Tx_write_pointer = Tx_b(3) + 3
Return
'
s152:
   Tx_b(1) = 3:
   Tx_b(2) = &H00
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s153:
   Tx_b(1) = 3:
   Tx_b(2) = &H02
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s154:
   Tx_b(1) = 3:
   Tx_b(2) = &H04
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s155:
   Tx_b(1) = 3:
   Tx_b(2) = &H06
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s156:
   Tx_b(1) = 3:
   Tx_b(2) = &H08
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s157:
   Tx_b(1) = 3:
   Tx_b(2) = &H0A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s158:
   Tx_b(1) = 3:
   Tx_b(2) = &H0C
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s159:
   Tx_b(1) = 3:
   Tx_b(2) = &H0E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s160:
   Tx_b(1) = 3:
   Tx_b(2) = &H10
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s161:
   Tx_b(1) = 3:
   Tx_b(2) = &H12
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s162:
   Tx_b(1) = 3:
   Tx_b(2) = &H14
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s163:
   Tx_b(1) = 3:
   Tx_b(2) = &H16
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s164:
   Tx_b(1) = 3:
   Tx_b(2) = &H18
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s165:
   Tx_b(1) = 3:
   Tx_b(2) = &H1A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s166:
   Tx_b(1) = 3:
   Tx_b(2) = &H1C
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s167:
   Tx_b(1) = 3:
   Tx_b(2) = &H1E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'