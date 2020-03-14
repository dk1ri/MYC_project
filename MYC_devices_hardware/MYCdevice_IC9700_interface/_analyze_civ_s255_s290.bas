' Analyze_civ Civ_sub_cmd: s221 - s254
' 20200307
'
s255:
   Tx_b(1) = 3
   Tx_b(2) = &HC2
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s256:
   Tx_b(1) = 3
   Tx_b(2) = &HC4
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s257:
   Tx_b(1) = 3
   Tx_b(2) = &HC6
   Gosub Rx_position
Return
'
s258:
   Tx_b(1) = 3
   Tx_b(2) = &HC8
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s259:
   Tx_b(1) = 3
   Tx_b(2) = &H8A
   Gosub Rx_text
Return
'
s260:
   Tx_b(1) = 3
   Tx_b(2) = &HCC
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s261:
   Tx_b(1) = 3
   Tx_b(2) = &HCE
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s262:
   Tx_b(1) = 3
   Tx_b(2) = &HD0
   Gosub Rx_text
Return
'
s263:
   Tx_b(1) = 3
   Tx_b(2) = &HD2
   Gosub Rx_text
Return
'
s264:
   Tx_b(1) = 3
   Tx_b(2) = &HD4
   Gosub Rx_text
Return
'
s265:
   Tx_b(1) = 3
   Tx_b(2) = &HD6
   Gosub Rx_text
Return
'
s266:
   Tx_b(1) = 3:
   Tx_b(2) = &HD8
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s267:
   Tx_b(1) = 3:
   Tx_b(2) = &HDA
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s268:
   Tx_b(1) = 3
   Tx_b(2) = &HDC
   Gosub Rx_text
Return
'
s269:
   Tx_b(1) = 3
   Tx_b(2) = &HDE
   Gosub Rx_text
Return
'
s270:
   Tx_b(1) = 3
   Tx_b(2) = &HE0
   Gosub Rx_text
Return
'
s271:
   Tx_b(1) = 3
   Tx_b(2) = &HE2
   Gosub Rx_text
Return
'
s272:
   Tx_b(1) = 3:
   Tx_b(2) = &HE4
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s273:
   Tx_b(1) = 3:
   Tx_b(2) = &HE6
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s274:
   Tx_b(1) = 3:
   Tx_b(2) = &HE8
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s275:
   Tx_b(1) = 3:
   Tx_b(2) = &HEA
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s276:
   Tx_b(1) = 3:
   Tx_b(2) = &HEC
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s277:
   Tx_b(1) = 3:
   Tx_b(2) = &HEE
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s278:
   Tx_b(1) = 3:
   Tx_b(2) = &HF0
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s279:
   Tx_b(1) = 3
   Tx_b(2) = &HF2
   Gosub Rx_text
Return
'
s280:
   Tx_b(1) = 3:
   Tx_b(2) = &HF4
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s281:
   Tx_b(1) = 3
   Tx_b(2) = &HF6
   Gosub Rx_text
Return
'
s282:
   Tx_b(1) = 3
   Tx_b(2) = &HF8
   Gosub Rx_text
Return
'
s283:
   Tx_b(1) = 3
   Tx_b(2) = &HFA
   Gosub Rx_position
Return
'
s284:
   Tx_b(1) = 3:
   Tx_b(2) = &HFC
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s285:
   Tx_b(1) = 3:
   Tx_b(2) = &HFE
   W_temp1 = Makebcd(Civ_in_b(9)) * 100
   W_temp1 = W_temp1 + Makebcd(Civ_in_b(10))
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
Return
'
s286:
   Tx_b(1) = 4:
   Tx_b(2) = &H00
   W_temp1 = Makebcd(Civ_in_b(9)) * 100
   W_temp1 = W_temp1 + Makebcd(Civ_in_b(10))
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
Return
'
s287:
   Tx_b(1) = 4:
   Tx_b(2) = &H02
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s288:
   Tx_b(1) = 4:
   Tx_b(2) = &H04
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s289:
   Tx_b(1) = 4:
   Tx_b(2) = &H06
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s290:
   Tx_b(1) = 4:
   Tx_b(2) = &H08
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'