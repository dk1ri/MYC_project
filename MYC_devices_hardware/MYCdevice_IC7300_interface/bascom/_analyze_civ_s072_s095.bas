' Ic7300 Analyze_civ Civ_sub_cmd: s072 - s095
' 191116
'
      Tx_b(1) = 2
      ' overwritten for Civ_sub_cmd 72, 91, 93, 94
      Tx_b(3) = Civ_in_b(9)
      Tx_write_pointer = 4
      Select Case Civ_sub_cmd
         Case 72
            Tx_b(2) = &H04
            Tx_b(3) = 100 * Civ_in_b(9)
            Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
         Case 73
            Tx_b(2) = &H06
         Case 74
            Tx_b(2) = &H08
         Case 75
            Tx_b(2) = &H0A
         Case 76
            Tx_b(2) = &H0C
         Case 77
            Tx_b(2) = &H0E
         Case 78
            Tx_b(2) = &H10
         Case 79
            Tx_b(2) = &H12
         Case 80
            Tx_b(2) = &H14
         Case 81
            Tx_b(2) = &H16
            Tx_b(3) = 100 * Civ_in_b(9)
            Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
         Case 82
            Tx_b(2) = &H18
         Case 83
            Tx_b(2) = &H1A
         Case 84
            Tx_b(2) = &H1C
         Case 85
            Tx_b(2) = &H1E
         Case 86
            Tx_b(2) = &H20
         Case 87
            Tx_b(2) = &H22
         Case 88
            Tx_b(2) = &H24
         Case 89
            Tx_b(2) = &H26
         Case 90
            Tx_b(2) = &H28
         Case 91
            Tx_b(2) = &H2A
            ' length
            B_temp1 = Civ_pointer - 9
            Tx_b(3) = B_temp1
            For B_temp2 = 1 To B_temp1
               Tx_b(B_temp2 + 3) = Civ_in_b(B_temp2 + 9)
            Next B_temp2
            Tx_write_pointer = 4 + B_temp1
         Case 92
            Tx_b(2) = &H2C
         Case 93
            Tx_b(2) = &H2E
         Case 94
            Tx_b(2) = &H30
            Tx_b(3) =  Makedec(Civ_in_b(10))
            Tx_b(4) =  Makedec(Civ_in_b(11))
            Tx_b(5) =  Makedec(Civ_in_b(12))
            Tx_write_pointer = 6
         Case 95
            Tx_b(2) = &H32
            Tx_b(3) =  Makedec(Civ_in_b(9))
            Tx_b(4) =  Makedec(Civ_in_b(10))
            Tx_write_pointer = 5
      End Select
'