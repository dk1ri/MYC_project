' Analyze_civ 00 - 16
' 20200314
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
            If Tx_b(3) = &H17 Then
               Tx_b(3) = 8
            Else
               If Tx_b(3) = &H22 Then
                  Tx_b(3) = 9
               Else
                  If Tx_b(3) > 5 Then Incr Tx_b(3)
               End If
            End If
            Tx_b(4) = Civ_in_b(7) - 1
            Tx_Write_pointer = 5
            If Read_memory_counter < 104 Then
               Incr Read_memory_counter
               Block_read_mem_command = 0
            End If
'
         Case &H07
            Tx_b(2) = &H08
            Tx_b(3) = Civ_in_b(7)
            Tx_Write_pointer = 4
'
         Case &H0F
            Tx_b(2) = &H17
            Tx_b(3) = Civ_in_b(6)
            If Civ_in_b(6) > 1 Then Tx_b(3) = Civ_in_b(6) - &H0F
            Tx_Write_pointer = 4
'
         Case &H10
            Tx_b(2) = &H19
            Tx_b(3) = Makedec(Civ_in_b(6)) - 1
            Tx_Write_pointer = 4
'
         Case &H11
            Tx_b(2) = &H1B
            Tx_b(3) = 0
            If Civ_in_b(6) = &H10 Then Tx_b(3) = 1
            Tx_Write_pointer = 4
'
         Case &H14
            B_temp2 = &H18
            B_temp1 = Civ_in_b(6) * 2
            If Civ_in_b(6) < 4 Then
               Nop
            Else
               If Civ_in_b(6) < &H10 Then
                  B_temp1 = B_temp1 - 4
                  ' 4 5 missing
               Else
                  If Civ_in_b(6) < &H13 Then
                     B_temp1 = B_temp1 - 8
                     ' 10, 11 missing
                  Else
                     If Civ_in_b(6) < &H19 Then
                        B_temp1 = B_temp1 - 12
                     Else
                        B_temp1 = B_temp1 - 14
                     End If
                  End If
               End If
            End If
            Tx_b(2) = B_temp2 + B_temp1
            B_temp1 = Civ_in_b(7) * 100
            B_temp2 = Makedec(Civ_in_b(8))
            Tx_b(3) = B_temp1 + B_temp2
            Tx_Write_pointer = 4
'
         Case &H15
            Select Case Civ_in_b(6)
               Case &H01
                  Tx_b(2) = &H41
                  Tx_b(3) = Civ_in_b(7)
               Case &H02
                  Tx_b(2) = &H42
                  Tx_b(3) = Civ_in_b(7) * 100
                  B_temp1 = Makedec(Civ_in_b(8))
                  Tx_b(3) = Tx_b(3) + B_temp1
               Case &H05
                  Tx_b(2) = &H43
                  Tx_b(3) = Civ_in_b(7)
               Case &H07
                  Tx_b(2) = &H44
                  Tx_b(3) = Civ_in_b(7)
               Case &H11 To &H16
                  B_temp1 = Civ_in_b(6) - &H11
                  Tx_b(2) = &H44 + B_temp1
                  Tx_b(3) = Civ_in_b(7) * 100
                  B_temp1 = Makedec(Civ_in_b(8))
                  Tx_b(3) = Tx_b(3) + B_temp1
            End Select
            Tx_Write_pointer = 4
'
         Case &H16
            Select Case Civ_in_b(6)
               Case &H02
                  Tx_b(2) = &H4C
               Case &H12
                  Tx_b(2) = &H4E
               Case &H22
                  Tx_b(2) = &H50
               Case &H40 To &H48
                  B_temp1 = Civ_in_b(6) - &H40
                  B_temp1 = B_temp1 * 2
                  Tx_b(2) = &H52 + B_temp1
               Case &H4A
                  Tx_b(2) = &H64
               Case &H4B
                  Tx_b(2) = &H66
               Case &H4F
                  Tx_b(2) = &H68
               Case &H50
                  Tx_b(2) = &H6A
               Case &H56 To &H5D
                  B_temp1 = Civ_in_b(6) - &H58
                  B_temp1 = B_temp1 * 2
                  Tx_b(2) = &H6C + B_temp1
               Case &H65
                  Tx_b(2) = &H7C
            End Select
            Tx_b(3) = Civ_in_b(7)
            Tx_Write_pointer = 4
            If Civ_in_b(6)  = &H5A Then Satellite_mode = Civ_in_b(7)
            If Civ_in_b(6)  = &H5D And Civ_in_b(7) > 3 Then Tx_b(3) = Tx_b(3) - 2
'
         Case &H19
            Tx_b(2) = &H7F
            Tx_b(3) = Civ_in_b(6)
            Tx_Write_pointer = 4
      End Select
'