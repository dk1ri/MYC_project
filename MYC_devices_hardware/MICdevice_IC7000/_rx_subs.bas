' Rx subs
' 20200221
'
Memory_read:
Return
'
Rx_frequency:
'convert 5 byte of Civ_in bcd bytes to Tx: lower byte -> higher byte;
' work up to 4.2GHz
' Start civ_in with byte B_temp5
' Tx start with Byte Tx_write_pointer
D_temp1 = 0
B_temp1 = Civ_in_b(B_temp5)
B_temp1 = Makedec(B_temp1)
D_temp1 = B_temp1
Incr  B_temp5
B_temp1 = Civ_in_b(B_temp5)
B_temp1 = Makedec(B_temp1)
D_temp2 = B_temp1 * 100
D_temp1 = D_temp1 + D_temp2
Incr  B_temp5
B_temp1 = Civ_in_b(B_temp5)
B_temp1 = Makedec(B_temp1)
D_temp2 = B_temp1 * 10000
D_temp1 = D_temp1 + D_temp2
Incr  B_temp5
B_temp1 = Civ_in_b(B_temp5)
B_temp1 = Makedec(B_temp1)
D_temp2 = B_temp1 * 1000000
D_temp1 = D_temp1 + D_temp2
Incr  B_temp5
B_temp1 = Civ_in_b(B_temp5)
B_temp1 = Makedec(B_temp1)
D_temp2 = B_temp1 * 100000000
D_temp1 = D_temp1 + D_temp2

D_temp1 = D_temp1 - 30000
For B_temp1 = 4 To 1 Step - 1
   Tx_b(Tx_write_pointer) = D_temp1_b(b_Temp1)
   Incr Tx_write_pointer
Next B_temp1
Return
'
Rx_band_edge:
' B_temp5 is start within Civ_in
If Civ_in_b(7) < &HFF Then
   Tx_b(3) = Civ_in_b(7) - 1
   ' low edge
   B_temp4 = B_temp5 + 4
   D_temp1 = Makedec(Civ_in_b(B_temp4)) * 100000000
   B_temp4 = B_temp5 + 3
   D_temp2 = Makedec(Civ_in_b(B_temp4)) * 1000000
   D_temp1 = D_temp1 + D_temp2
   B_temp4 = B_temp5 + 2
   D_temp2 = Makedec(Civ_in_b(B_temp4)) * 10000
   D_temp1 = D_temp1 + D_temp2
   B_temp4 = B_temp5 + 1
   D_temp2 = Makedec(Civ_in_b(B_temp4)) * 100
   D_temp1 = D_temp1 + D_temp2
   D_temp1 = D_temp1 + Makedec(Civ_in_b(B_temp5))
   Tx_b(4) = D_temp1_b(4)
   Tx_b(5) = D_temp1_b(3)
   Tx_b(6) = D_temp1_b(2)
   Tx_b(7) = D_temp1_b(1)
   ' high edge
   B_temp4 = B_temp5 +  10
   D_temp1 = Makedec(Civ_in_b(B_temp4)) * 100000000
   B_temp4 = B_temp5 +  9
   D_temp2 = Makedec(Civ_in_b(B_temp4)) * 1000000
   D_temp1 = D_temp1 + D_temp2
   B_temp4 = B_temp5 + 8
   D_temp2 = Makedec(Civ_in_b(B_temp4)) * 10000
   D_temp1 = D_temp1 + D_temp2
   B_temp4 = B_temp5 +  7
   D_temp2 = Makedec(Civ_in_b(B_temp4)) * 100
   D_temp1 = D_temp1 + D_temp2
   B_temp4 = B_temp5 + 6
   D_temp1 = D_temp1 + Makedec(Civ_in_b(B_temp4))
   Tx_b(8) = D_temp1_b(4)
   Tx_b(9) = D_temp1_b(3)
   Tx_b(10) = D_temp1_b(2)
   Tx_b(11) = D_temp1_b(1)
   Tx_write_pointer = 12
Else
   Not_valid_at_this_time
   Tx_write_pointer = 1
End If
Return
'
