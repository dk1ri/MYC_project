' Analyze_civ Civ_sub_cmd: 1a06 - ...
' 20200221
'
Select Case Civ_in_b(6)
   Case 6
      Tx_b(1) = 2:
      Tx_b(2) = &H62
      Tx_b(3) = Civ_in_b(7)
      Tx_write_pointer = 4
   Case 7
      Tx_b(1) = 2:
      Tx_b(2) = &H64
      Tx_b(3) = Civ_in_b(7)
      Tx_write_pointer = 4
   Case 8
      Tx_b(1) = 2:
      Tx_b(2) = &H66
      Tx_b(3) = Civ_in_b(7)
      Tx_write_pointer = 4
   Case 9
      Tx_b(1) = 2:
      Tx_b(2) = &H68
      Tx_b(3) = Civ_in_b(7)
      Tx_write_pointer = 4
   Case &H0A
      Tx_b(1) = 2:
      Tx_b(2) = &H6A
      Tx_b(3) = Civ_in_b(7)
      Tx_write_pointer = 4
   Case &H0B
      Tx_b(1) = 2:
      If Civ_in_b(7) < 2 Then
         ' repeater tone
         W_temp1 = Makedec(Civ_in_b(9)) * 100
         W_temp1 = W_temp1 + Makedec(Civ_in_b(10))
         Tx_b(3) = W_temp1_h
         Tx_b(4) = W_temp1_l
      Else
         ' DTCSS
         DTCSS_b(1) = Civ_in_b(8)
         DTCSS_b(2) = Civ_in_b(9)
         DTCSS_b(3) = Civ_in_b(10)
         If Last_command = &H0270 Then
            B_temp1 = Civ_in_b(10) And &H0F
            B_temp2 = Civ_in_b(10) And &HF0
            Shift B_temp2 , Right, 1
            B_temp1 = B_temp1 Or B_temp2
            W_temp1 = Civ_in_b(9) And &H0F
            Shift W_temp1, Left,6
            W_temp2 = Civ_in_b(9) And &HF0
            Shift W_temp2, Left, 9
            W_temp1 = W_temp1  Or W_temp2
            W_temp1  = W_temp1  Or B_temp1
            Tx_b(3) = W_temp1_h
            Tx_b(4) = W_temp1_l
         Else
            B_Temp1 = Civ_in_b(8)
            Shift B_temp1, Right, 4
            Tx_b(3) = B_temp1
            Tx_b(4) =  Civ_in_b(8) And &H0F
         End If
      End If
      Tx_b(3) = W_temp1_h
      Tx_b(4) = W_temp1_l
      Select Case Civ_in_b(7)
         Case 0
            Tx_b(2) = &H6C
         Case 1
            Tx_b(2) = &H6E
         Case 2
            Tx_b(2) = &H70
      End Select

      Tx_write_pointer = 5
   Case &H0C
      Tx_b(1) = 2:
      If Civ_in_b(7) = 0 Then
         Tx_b(2) = &H72
      Else
         Tx_b(2) = &H74
      End If
      Tx_b(3) = Civ_in_b(8)
      Tx_write_pointer = 4
   End Select
'