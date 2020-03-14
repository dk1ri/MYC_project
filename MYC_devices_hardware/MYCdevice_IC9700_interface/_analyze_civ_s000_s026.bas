' Analyze_civ Civ_sub_cmd: s000 - s023
' 20200229
'
s01:
   Tx_b(1) = 1:
   Tx_b(2) = &HD3
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_b(4) = Makedec(Civ_in_b(10)) - 5
   Tx_write_pointer = 5
Return
'
s02:
   Tx_b(1) = 1:
   Tx_b(2) = &HD5
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_write_pointer = 4
Return
'
s03:
   Tx_b(1) = 1:
   Tx_b(2) = &HD7
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s04:
   Tx_b(1) = 1:
   Tx_b(2) = &HD9
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_b(4) = Makedec(Civ_in_b(10)) - 5
   Tx_write_pointer = 5
Return
'
s05:
   Tx_b(1) = 1:
   Tx_b(2) = &HDB
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s06:
   Tx_b(1) = 1:
   Tx_b(2) = &HDD
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s07:
   Tx_b(1) = 1:
   Tx_b(2) = &HDF
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_b(4) = Makedec(Civ_in_b(10)) - 5
   Tx_write_pointer = 5
Return
'
s08:
   Tx_b(1) = 1:
   Tx_b(2) = &HE1
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s09:
   Tx_b(1) = 1:
   Tx_b(2) = &HE3
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s10:
   Tx_b(1) = 1:
   Tx_b(2) = &HE5
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_b(4) = Makedec(Civ_in_b(10)) - 5
   Tx_write_pointer = 5
Return
'
s11:
   Tx_b(1) = 1:
   Tx_b(2) = &HE7
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s12:
   Tx_b(1) = 1:
   Tx_b(2) = &HE9
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s13:
   Tx_b(1) = 1:
   Tx_b(2) = &HEB
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_b(4) = Makedec(Civ_in_b(10)) - 5
   Tx_write_pointer = 5
Return
'
s14:
   Tx_b(1) = 1:
   Tx_b(2) = &HED
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_b(4) = Makedec(Civ_in_b(10)) - 5
   Tx_write_pointer = 5
Return
'
s15:
   Tx_b(1) = 1:
   Tx_b(2) = &HEF
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s16:
   Tx_b(1) = 1:
   Tx_b(2) = &HF1
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s17:
   Tx_b(1) = 1:
   Tx_b(2) = &HF3
   Gosub Rx_hpf_lpf
   Tx_write_pointer = 5
Return
'
s18:
   Tx_b(1) = 1:
   Tx_b(2) = &HF5
   Gosub Rx_hpf_lpf
   Tx_write_pointer = 5
Return
'
s19:
   Tx_b(1) = 1:
   Tx_b(2) = &HF7
   Gosub Rx_hpf_lpf
   Tx_write_pointer = 5
Return
'
s20:
   Tx_b(1) = 1:
   Tx_b(2) = &HF9
   Gosub Rx_hpf_lpf
   Tx_write_pointer = 5
Return
'
s21:
   Tx_b(1) = 1:
   Tx_b(2) = &HFB
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s22:
   Tx_b(1) = 1:
   Tx_b(2) = &HFD
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s23:
   Tx_b(1) = 1:
   Tx_b(2) = &HFF
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s24:
   Tx_b(1) = 2:
   Tx_b(2) = &H01
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s25:
   Tx_b(1) = 2:
   Tx_b(2) = &H03
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s26:
   Tx_b(1) = 2:
   Tx_b(2) = &H05
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'