' Analyze_civ Civ_sub_cmd: s291 - s339
' 20200310
'
s291:
   Tx_b(1) = 4
   Tx_b(2) = &H0A
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_write_pointer = 4
Return
'
s292:
   Tx_b(1) = 4
   Tx_b(2) = &H0C
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s293:
   Tx_b(1) = 4
   Tx_b(2) = &H0E
   Gosub Rx_text
Return
'
s294:
   Tx_b(1) = 4
   Tx_b(2) = &H10
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s295:
   Tx_b(1) = 4
   Tx_b(2) = &H12
   Gosub Rx_text
Return
'
s296:
   Tx_b(1) = 4
   Tx_b(2) = &H14
   Gosub Rx_text
Return
'
s297:
   Tx_b(1) = 4
   Tx_b(2) = &H16
   Gosub Rx_position
Return
'
s298:
   Tx_b(1) = 4
   Tx_b(2) = &H18
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s299:
   Tx_b(1) = 4
   Tx_b(2) = &H1A
   W_temp1 = Makedec(Civ_in_b(9)) * 100
   W_temp1 = W_temp1 + Makedec(Civ_in_b(10))
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
Return
'
s300:
   Tx_b(1) = 4
   Tx_b(2) = &H1C
   W_temp1 = Makedec(Civ_in_b(9)) * 100
   W_temp1 = W_temp1 + Makedec(Civ_in_b(10))
   Tx_b(3) = W_temp1_h
   Tx_b(4) = W_temp1_l
   Tx_write_pointer = 5
Return
'
s301:
   Tx_b(1) = 4
   Tx_b(2) = &H1E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s302:
   Tx_b(1) = 4
   Tx_b(2) = &H20
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s303:
   Tx_b(1) = 4
   Tx_b(2) = &H22
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s304:
   Tx_b(1) = 4
   Tx_b(2) = &H24
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s305:
   Tx_b(1) = 4
   Tx_b(2) = &H26
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_write_pointer = 4
Return
'
s306:
   Tx_b(1) = 4
   Tx_b(2) = &H28
   Gosub Rx_text
Return
'
s307:
   Tx_b(1) = 4
   Tx_b(2) = &H2A
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_write_pointer = 4
Return
'
s308:
   Tx_b(1) = 4
   Tx_b(2) = &H2C
   Gosub Rx_text
Return
'
s309:
   Tx_b(1) = 4:
   Tx_b(2) = &H2E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s310:
   Tx_b(1) = 4
   Tx_b(2) = &H30
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s311:
   Tx_b(1) = 4
   Tx_b(2) = &H32
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s312:
   Tx_b(1) = 4
   Tx_b(2) = &H34
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s313:
   Tx_b(1) = 4
   Tx_b(2) = &H36
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s314:
   Tx_b(1) = 4
   Tx_b(2) = &H38
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s315:
   Tx_b(1) = 4
   Tx_b(2) = &H3A
   Gosub Rx_text
Return
'
s316:
   Tx_b(1) = 4
   Tx_b(2) = &H3C
   Gosub Rx_text
Return
'
s317:
   Tx_b(1) = 4
   Tx_b(2) = &H3E
   W_temp1 = Makedec(Civ_in_b(9)) * 10000
   W_temp2 = Makedec(Civ_in_b(9)) * 100
   W_temp1 = W_temp1 + W_temp2
   W_temp1 = W_temp1 + Makedec(Civ_in_b(11))
   W_temp1 = W_temp1 / 10
   Temps_b(3) = W_temp2_h
   Temps_b(4) = W_temp1_l
   Tx_write_pointer = 5
Return
'
s318:
   Tx_b(1) = 4
   Tx_b(2) = &H40
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s319:
   Tx_b(1) = 4
   Tx_b(2) = &H42
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s320:
   Tx_b(1) = 4
   Tx_b(2) = &H44
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s321:
   Tx_b(1) = 4
   Tx_b(2) = &H46
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s322:
   Tx_b(1) = 4
   Tx_b(2) = &H48
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s323:
   Tx_b(1) = 4
   Tx_b(2) = &H4A
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s324:
   Tx_b(1) = 4
   Tx_b(2) = &H4C
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s325:
   Tx_b(1) = 4
   Tx_b(2) = &H4E
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s326:
   Tx_b(1) = 4
   Tx_b(2) = &H50
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s327:
   Tx_b(1) = 4
   Tx_b(2) = &H52
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s328:
   Tx_b(1) = 4
   Tx_b(2) = &H54
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s329:
   Tx_b(1) = 4
   Tx_b(2) = &H56
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s330:
   Tx_b(1) = 4
   Tx_b(2) = &H58
   Tx_b(3) = Makedec(Civ_in_b(9))
   Tx_write_pointer = 4
Return
'
s331:
   Tx_b(1) = 4
   Tx_b(2) = &H5A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s332:
   Tx_b(1) = 4
   Tx_b(2) = &H5C
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s333:
   Tx_b(1) = 4
   Tx_b(2) = &H5E
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s334:
   Tx_b(1) = 4
   Tx_b(2) = &H60
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s335:
   Tx_b(1) = 4
   Tx_b(2) = &H62
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s336:
   Tx_b(1) = 4
   Tx_b(2) = &H64
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s337:
   Tx_b(1) = 4
   Tx_b(2) = &H66
   Tx_b(3) = Civ_in_b(9) * 100
   Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
   Tx_write_pointer = 4
Return
'
s338:
   Tx_b(1) = 4
   Tx_b(2) = &H68
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'
s339:
   Tx_b(1) = 4
   Tx_b(2) = &H6A
   Tx_b(3) = Civ_in_b(9)
   Tx_write_pointer = 4
Return
'