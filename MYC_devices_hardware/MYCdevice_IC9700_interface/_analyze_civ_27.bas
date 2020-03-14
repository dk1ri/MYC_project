' Analyze_civ Civ_sub_cmd: 27
' 20200312
'
      Tx_b(1) = 4
      Select Case Civ_in_b(6)
         Case &H10
            Tx_b(2) = &HAB
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case &H11
            Tx_b(2) = &HAD
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case &H12
            Tx_b(2) = &HAF
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case &H14
            Tx_b(2) = &HB1
            Tx_b(3) = Civ_in_b(7)
            Tx_b(4) = Civ_in_b(8)
            Tx_write_pointer = 5
         Case &H15
            Tx_b(2) = &HB3
            Tx_b(3) = Civ_in_b(7)
            W_temp1 = Makedec(Civ_in_b(10)) * 100
            W_temp1 = W_temp1 + Makedec(Civ_in_b(9))
            Select Case W_temp1
               Case 25
                  Tx_b(4) = 0
               Case 50
                  Tx_b(4) = 1
               Case 100
                  Tx_b(4) = 2
               Case 250
                  Tx_b(4) = 3
               Case 500
                  Tx_b(4) = 4
               Case 1000
                  Tx_b(4) = 5
               Case 2500
                  Tx_b(4) = 6
               Case 5000
                  Tx_b(4) = 7
            End Select
            Tx_write_pointer = 5
         Case &H16
            Tx_b(2) = &HB5
            Tx_b(3) = Civ_in_b(7)
            Tx_b(4) = Civ_in_b(8) - 1
            Tx_write_pointer = 5
         Case &H17
            Tx_b(2) = &HB7
            Tx_b(3) = Civ_in_b(7)
            Tx_b(4) = Civ_in_b(8) - 1
            Tx_write_pointer = 5
         Case &H19
            Tx_b(2) = &HB9
            Tx_b(3) = Civ_in_b(7)
            B_temp1 = Makedec(Civ_in_b(8)) * 2
            If Civ_in_b(10) = 0 Then
               Tx_b(4) = B_Temp1 + 40
               If Civ_in_b(9) = &H50 Then Incr Tx_b(4)
            Else
               Tx_b(4) = 40 - B_Temp1
               If Civ_in_b(9) = &H50 Then Decr Tx_b(4)
            End If
            Tx_write_pointer = 5
         Case &H1A
            Tx_b(2) = &HBB
            Tx_b(3) = Civ_in_b(7)
            Tx_b(4) = Civ_in_b(8)
            Tx_write_pointer = 5
         Case &H1B
            Tx_b(2) = &HBD
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case &H1C
            Tx_b(2) = &HBF
            Tx_b(3) = Civ_in_b(7)
            Tx_write_pointer = 4
         Case &H1D
            Tx_b(2) = &HC1
            Tx_b(3) = Civ_in_b(7)
            Tx_b(4) = Civ_in_b(8)
            Tx_write_pointer = 4
      End Select
'