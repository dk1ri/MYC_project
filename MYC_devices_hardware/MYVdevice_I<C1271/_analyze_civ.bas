' name: _analyze_civ.bas
' 20200213
'
Analyze_civ:
'CiV received, analyze data
' some commands do answer with ok /nok only!!
'Civ_in contain the complete answer with header and trailer
'Civ_pointer points to last element before trailer (&HFD)
'Civ code 0 and 1 appear with transceive = on on radio only
'Correct Length of Civ string is not checked
'
      Select Case Civ_in_b(5)
         Case 2
            ' should delived &H05&H00&H00 only
            Tx_b(1) = 5
            ' low edge
            D_temp1 = Makedec(Civ_in_b(10)) * 100000000
            D_temp2 = Makedec(Civ_in_b(9)) * 1000000
            D_temp1 = D_temp1 + D_temp2
            D_temp2 = Makedec(Civ_in_b(8)) * 10000
            D_temp1 = D_temp1 + D_temp2
            D_temp2 = Makedec(Civ_in_b(7)) * 100
            D_temp1 = D_temp1 + D_temp2
            D_temp1 = D_temp1 + Makedec(Civ_in_b(6))
            D_temp1 = D_temp1 - 1240000000
            Tx_b(2) = D_temp1_b(4)
            Tx_b(3) = D_temp1_b(3)
            Tx_b(4) = D_temp1_b(2)
            Tx_b(5) = D_temp1_b(1)
            ' high edge
            D_temp1 = Makedec(Civ_in_b(16)) * 100000000
            D_temp2 = Makedec(Civ_in_b(15)) * 1000000
            D_temp1 = D_temp1 + D_temp2
            D_temp2 = Makedec(Civ_in_b(14)) * 10000
            D_temp1 = D_temp1 + D_temp2
            D_temp2 = Makedec(Civ_in_b(13)) * 100
            D_temp1 = D_temp1 + D_temp2
            D_temp1 = D_temp1 - 1300000000
            D_temp1 = D_temp1 + Makedec(Civ_in_b(12))
            Tx_b(6) = D_temp1_b(4)
            Tx_b(7) = D_temp1_b(3)
            Tx_b(8) = D_temp1_b(2)
            Tx_b(9) = D_temp1_b(1)
            Tx_write_pointer = 10
'
         Case 3
            Tx_b(1) = 2
            'convert 5 byte of Civ_in bcd bytes to Tx: lower byte -> higher byte;
            ' work up to 4.2GHz
            D_temp1 = Makedec(Civ_in_b(6))
            '
            D_temp2 = Makedec(Civ_in_b(7)) * 100
            D_temp1 = D_temp1 + D_temp2
            '
            D_temp2 = Makedec(Civ_in_b(8)) * 10000
            D_temp1 = D_temp1 + D_temp2
            '
            D_temp2 = Makedec(Civ_in_b(9)) * 1000000
            D_temp1 = D_temp1 + D_temp2
            '
            D_temp2 = Makedec(Civ_in_b(10)) * 100000000
            D_temp1 = D_temp1 + D_temp2

            D_temp1 = D_temp1 - 1240000000
            Tx_write_pointer = 2
            Tx_b(2) = D_temp1_b(4)
            Tx_b(3) = D_temp1_b(3)
            Tx_b(4) = D_temp1_b(2)
            Tx_b(5) = D_temp1_b(1)
            ' 3 Bytes of frequncy necessary only
            Tx_write_pointer = 5
'
         Case 4
            Tx_b(1) = &H04
            Tx_b(2) = Civ_in_b(6)
            If Tx_b(2) > 5 Then Decr Tx_b(2)
            Tx_b(3) = Civ_in_b(7) - 1
            Tx_Write_pointer = 4
'
         Case &H0C
            Tx_b(1) = &H0B
            D_temp1 = Makedec(Civ_in_b(8)) * 10000
            W_temp2 = Makedec(Civ_in_b(7)) * 100
            D_temp1 = D_temp1 + W_temp2
            D_temp1 = D_temp1 + Makedec(Civ_in_b(6))
            W_temp1 = D_temp1
            Tx_b(2) = W_temp1_h
            Tx_b(3) = W_temp1_l
            Tx_write_pointer = 3
      End Select
Return
'