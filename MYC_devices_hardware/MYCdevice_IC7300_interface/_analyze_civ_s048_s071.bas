' Ic7300 Analyze_civ Civ_sub_cmd: s048 - s071
' 191117
'
      Tx_b(1) = 1
      Select Case Civ_sub_cmd
         Case 48
            Tx_b(2) = &HD4
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 49
            Tx_b(2) = &HD6
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 50
            Tx_b(2) = &HD8
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 51
            Tx_b(2) = &HDA
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 52
            Tx_b(2) = &HDC
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 53
            Tx_b(2) = &HDE
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 54
            Tx_b(2) = &HE0
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 55
            Tx_b(2) = &HE2
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 56
            Tx_b(2) = &HE4
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 57
            Tx_b(2) = &HE6
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 58
            Tx_b(2) = &HE8
            Tx_b(3) = 100 * Civ_in_b(9)
            Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
            Tx_write_pointer = 4
         Case 59
            Tx_b(2) = &HEA
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 60
            Tx_b(2) = &HEC
            Tx_b(3) = 100 * Civ_in_b(9)
            Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
            Tx_write_pointer = 4
         Case 61
            Tx_b(2) = &HEE
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 62
            Tx_b(2) = &HF0
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 63
            Tx_b(2) = &HF2
            Tx_b(3) = 100 * Civ_in_b(9)
            Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
            Tx_write_pointer = 4
         Case 64
            Tx_b(2) = &HF4
            Tx_b(3) = 100 * Civ_in_b(9)
            Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
            Tx_write_pointer = 4
         Case 65
            Tx_b(2) = &HF6
            Tx_b(3) = 100 * Civ_in_b(9)
            Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
            Tx_write_pointer = 4
         Case 66
            Tx_b(2) = &HF8
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 67
            Tx_b(2) = &HFA
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 68
            Tx_b(2) = &HFC
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 69
            Tx_b(2) = &HFE
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 70
             Tx_b(1) = 2
            Tx_b(2) = &H00
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
         Case 71
            Tx_b(1) = 2
            Tx_b(2) = &H02
            Tx_b(3) =  Civ_in_b(9)
            Tx_write_pointer = 4
      End Select
'