' Ic7300 Analyze_civ Civ_sub_cmd: s168 - s193
' 191123
'
      Tx_b(1) = 2
      Select Case Civ_in_b(6)
         Case &H10
            Tx_b(2) = &HE5
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case &H11
            Tx_b(2) = &HE7
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case &H12
            Tx_b(2) = &HE8
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case &H13
            Tx_b(2) = &HE9
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case &H14
         print "x"
            Tx_b(2) = &HEB
            Tx_b(3) = Civ_in_b(8)
            Tx_write_pointer = 4
         Case &H15
            Tx_b(2) = &HED
            W_temp1 = Makedec(Civ_in_b(10)) * 100
            W_temp1 = W_temp1 + Makedec(Civ_in_b(9))
            Select Case W_temp1
               Case 25
                  Tx_b(3) = 0
               Case 50
                  Tx_b(3) = 1
               Case 100
                  Tx_b(3) = 2
               Case 250
                  Tx_b(3) = 3
               Case 500
                  Tx_b(3) = 4
               Case 1000
                  Tx_b(3) = 5
               Case 2500
                  Tx_b(3) = 6
               Case 5000
                  Tx_b(3) = 7
            End Select
            Tx_write_pointer = 4
         Case &H16
            Tx_b(2) = &HEF
            Tx_b(3) = Civ_in_b(8) - 1
            Tx_write_pointer = 4
         Case &H17
            Tx_b(2) = &HF1
            Tx_b(3) = Civ_in_b(8)
            Tx_write_pointer = 4
         Case &H19
            Tx_b(2) = &HF3
            B_temp1 = Makedec(Civ_in_b(8)) * 2
            If Civ_in_b(10) = 0 Then
               Tx_b(3) = B_Temp1 + 40
               If Civ_in_b(9) = &H50 Then Incr Tx_b(3)
            Else
               Tx_b(3) = 40 - B_Temp1
               If Civ_in_b(9) = &H50 Then Decr Tx_b(3)
            End If
            Tx_write_pointer = 4
         Case &H1A
            Tx_b(2) = &HF5
            Tx_b(3) = Civ_in_b(8)
            Tx_write_pointer = 4
         Case &H1B
            Tx_b(2) = &HF7
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case &H1C
            Tx_b(2) = &HF9
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case &H1D
            Tx_b(2) = &HFB
            Tx_b(3) = Civ_in_b(8)
            Tx_write_pointer = 4
      End Select
'