' Analyze_civ Ci_cmd: &H1E- &H26
' 20200312
'
   Tx_b(1) = 4
   Select Case Civ_in_b(5)
      Case &H21
         Select Case Civ_in_b(6)
            Case 0
               Tx_b(2) = &H8A
               W_temp1 = Makedec(Civ_in_b(8)) * 100
               W_temp2 = Makedec(Civ_in_b(7))
               W_temp1 = W_temp1 + W_temp2
               If Civ_in_b(9) = 0 Then
                  W_temp1 = W_temp1 + 9999
               Else
                  W_temp1 = 9999 - W_temp1
               End If
               Tx_b(3) = W_temp1_h
               Tx_b(4) = W_temp1_l
               Tx_write_pointer = 5
            Case 1
               Tx_b(2) = &H8C
               Tx_b(3) = Civ_in_b(7)
               Tx_write_pointer = 4
         End Select
      Case 22
         Select Case Civ_in_b(6)
            Case 0
               Tx_b(2) = &H8E
               B_temp2 = Civ_pointer - 7
               Tx_b(3) = B_temp2
               B_temp3 = 7
               B_temp2 = B_temp2 + 4
               For B_temp1 = 4 To B_temp2
                  Tx_b(B_temp1) = Civ_in_b(B_temp3)
                  Incr B_temp3
               Next B_temp1
               Tx_write_pointer = B_temp2 + 4
            Case 1
               If Civ_in_b(7) =0 Then
                  Tx_b(2) = &H90
                  Tx_b(3) = Civ_in_b(8)
                  Tx_write_pointer = 4
               Else
                   Tx_b(2) = &H92
                   B_temp2 = Civ_pointer - 7
                   Tx_b(3) = B_temp2
                   B_temp3 = 8
                   B_temp2 = B_temp2 + 4
                   For B_temp1 = 4 To B_temp2
                      Tx_b(B_temp1) = Civ_in_b(B_temp3)
                      Incr B_temp3
                   Next B_temp1
                   Tx_write_pointer = B_temp2 + 4
               End If
            Case 2
               Tx_b(2) = &H94
               Tx_b(3) = Civ_in_b(7)
               Tx_write_pointer = 4
            Case 3
               Tx_b(2) = &H96
               Tx_b(3) = Civ_in_b(7)
               Tx_write_pointer = 4
            Case 4
               Tx_b(2) = &H98
               Tx_b(3) = Civ_in_b(7)
               Tx_write_pointer = 4
            Case 5
               Tx_b(2) = &H9A
               Tx_b(3) = Makedec(Civ_in_b(7))
               Tx_write_pointer = 4
         End Select
      Case 23
         Select Case Civ_in_b(6)
            Case 0
               Nop
            Case 1
               Tx_b(2) = &H9E
               Tx_b(3) = Civ_in_b(7)
               If Tx_b(3) > 0 Then Decr Tx_b(3)
               Tx_write_pointer = 4
            Case 2
               Tx_b(2) = &HA0
               Gosub Rx_position
         End Select
      Case 24
         If Civ_in_b(7) = 0 Then
            Tx_b(2) = &HA2
         Else
            Tx_b(2) = &HA4
         End If
         Tx_b(3) = Civ_in_b(7)
         Tx_write_pointer = 4
      Case &H25
         Tx_b(2) = &HA6
         Tx_b(3) = Civ_in_b(6)
         B_temp5 = 7
         Tx_write_pointer = 4
         Gosub Rx_frequency
      Case &H26
         Tx_b(2) = &HA8
         Tx_b(3) = Civ_in_b(6)
         Tx_b(4) = Civ_in_b(7)
         Tx_b(5) = Civ_in_b(9) - 1
         If Tx_b(4) > 5 Then Tx_b(4) = Tx_b(4)  - 1
         Tx_write_pointer = 6
      Case 28
         Tx_b(1) = &H03
         Tx_b(2) = &H1F
         Tx_b(3) = Civ_in_b(7)
         Tx_write_pointer = 4
   End Select
'