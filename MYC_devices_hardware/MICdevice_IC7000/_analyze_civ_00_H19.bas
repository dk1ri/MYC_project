' Analyze_civ 00 - 16
' 202003114
'
      Tx_b(1) = 1
      Select Case Civ_in_b(5)
         Case 2
            Tx_b(2) = 4
            B_temp5 = 6
            Gosub Rx_band_edge
'
         Case 3
            Tx_b(2) = 1
            B_temp5 = 6
            Tx_write_pointer = 3
            Gosub Rx_frequency
'
         Case 4
            Tx_b(2) = 3
            Tx_b(3) = Civ_in_b(6)
            If Tx_b(3) > 5 Then Decr Tx_b(3)
            Tx_b(4) = Civ_in_b(7) - 1
            Tx_Write_pointer = 5
            If Read_memory_counter < 104 Then
               Incr Read_memory_counter
               Block_read_mem_command = 0
            End If
'
         Case &H0C
            Tx_b(2) = &H0E
            D_temp1 = Makedec(Civ_in_b(8)) * 10000
            D_temp2 = Makedec(Civ_in_b(7)) * 100
            D_temp1 = D_temp1 + D_temp2
            D_temp2 = D_temp2 + Makedec(Civ_in_b(6))
            Tx_b(3) = D_temp2.3
            Tx_b(4) = D_temp2.2
            Tx_b(5) = D_temp2.1
            Tx_Write_pointer = 6
'
         Case &H11
            Tx_b(2) = &H16
            Tx_b(3) = 0
            If Civ_in_b(6) = &H12 Then Tx_b(3) = 1
            Tx_Write_pointer = 4
'
         Case &H14
            B_temp2 = &H17
            B_temp1 = Civ_in_b(6) * 2
            B_Temp2 = B_temp2 + B_temp1
            If Civ_in_b(6) > 3 Then
               B_Temp2 = B_temp2  - 4
               If Civ_in_b(6) > &H0F Then
                  B_Temp2 = B_temp2  - 4
                  If Civ_in_b(6) > &H12 Then
                     B_Temp2 = B_temp2  - 4
                  End If
               End If
            End If
            Tx_b(2) = B_temp2
            B_temp1 = Civ_in_b(7) * 100
            B_temp2 = Makedec(Civ_in_b(8))
            Tx_b(3) = B_temp1 + B_temp2
            Tx_Write_pointer = 4
'
         Case &H15
            Select Case Civ_in_b(6)
               Case &H01
                  Tx_b(2) = &H40
                  Tx_b(3) = Civ_in_b(7)
               Case &H02
                  Tx_b(2) = &H41
                  Tx_b(3) = Civ_in_b(7) * 100
                  B_temp1 = Makedec(Civ_in_b(8))
                  Tx_b(3) = Tx_b(3) + B_temp1
               Case &H11 To &H14
                  B_temp1 = Civ_in_b(6) - &H11
                  Tx_b(2) = &H42 + B_temp1
                  Tx_b(3) = Civ_in_b(7) * 100
                  B_temp1 = Makedec(Civ_in_b(8))
                  Tx_b(3) = Tx_b(3) + B_temp1
            End Select
            Tx_Write_pointer = 4
'
         Case &H16
            Select Case Civ_in_b(6)
               Case &H02
                  Tx_b(2) = &H47
               Case &H12
                  Tx_b(2) = &H49
               Case &H22
                  Tx_b(2) = &H4B
               Case &H40 To &H48
                  B_temp1 = Civ_in_b(6) - &H40
                  B_temp1 = B_temp1 * 2
                  Tx_b(2) = &H4D + B_temp1
               Case &H4B
                  Tx_b(2) = &H5F
               Case &H4C
                  Tx_b(2) = &H61
               Case &H4F
                  Tx_b(2) = &H63
               Case &H50
                  Tx_b(2) = &H65
               Case &H51
                  Tx_b(2) = &H67
            End Select
            Tx_b(3) = Civ_in_b(7)
            If Tx_b(3) = &H12 Then Decr Tx_b(3)
            Tx_Write_pointer = 4
'
         Case &H19
            Tx_b(2) = &H68
            Tx_b(3) = Civ_in_b(6)
            Tx_Write_pointer = 4
      End Select
'