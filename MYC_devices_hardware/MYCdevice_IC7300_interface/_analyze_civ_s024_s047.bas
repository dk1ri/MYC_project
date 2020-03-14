' Ic7300 Analyze_civ Civ_sub_cmd: s024 - s047
' 191117
'
      Tx_b(1) = 1
      Select Case Civ_sub_cmd
         Case 24
            Tx_b(2) = &HA4
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 25
            Tx_b(2) = &HA6
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 26
            Tx_b(2) = &HA8
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 27
            Tx_b(2) = &HAA
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 28
            Tx_b(2) = &HAC
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 29
            Tx_b(2) = &HAE
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 30
            Tx_b(2) = &HB0
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 31
            Tx_b(2) = &HB2
            Gosub RX_offset
         Case 32
            Tx_b(2) = &HB4
            Gosub RX_offset
         Case 33
            Tx_b(2) = &HB6
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 34
            Tx_b(2) = &HB8
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 35
            Tx_b(2) = &HBA
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 36
            Tx_b(2) = &HBC
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 37
            Tx_b(2) = &HBE
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 38
            Tx_b(2) = &HC0
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 39
            Tx_b(2) = &HC2
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 40
            Tx_b(2) = &HC4
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 41
            Tx_b(2) = &HC6
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 42
            Tx_b(2) = &HC8
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 43
            Tx_b(2) = &HCA
            Tx_b(3) = 100 * Civ_in_b(9)
            Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
            Tx_write_pointer = 4
         Case 44
            Tx_b(2) = &HCC
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 45
            Tx_b(2) = &HCE
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 46
            Tx_b(2) = &HD0
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 47
            Tx_b(2) = &HD2
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
      End Select
'