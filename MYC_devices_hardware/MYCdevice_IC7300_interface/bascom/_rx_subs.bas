' Rx subs
' 191121
'
Memory_read_and_fill:
   B_temp1 = Civ_in_b(7) * 100
   B_temp2 = Makedec(Civ_in_b(8))
   B_temp1 = B_temp1 + b_temp2
   ' memory number
   Decr B_temp1
   W_Temp1 = B_temp1 * 39
   If CiV_in_b(9) = &HFF Then
      ' empty
      W_temp2 = W_temp1
      For B_temp1 = 1 To 39
         Memorycontent_b(W_temp2) = Memory_default_b(B_temp1)
         Incr W_temp2
      Next B_temp1
      Temps_b(1) = &H1A
      Temps_b(2) = &H00
      Temps_b(3) = Civ_in_b(7)
      Temps_b(4) = Civ_in_b(8)
      For B_temp1 = 5 To 43
         Temps_b(B_temp1) = Memorycontent_b(W_temp1)
         Incr W_temp1
      Next B_temp1
      Civ_len = 43
      Gosub Civ_print
   Else
      For B_temp2 = 1 To 39
         Memorycontent_b(W_Temp2) = Civ_in_b(B_temp2 + 8)
         Incr W_temp2
      Next B_temp2
   End If
   Read_memory_counter = Read_memory_counter + 1
   Block_read_mem_command = 0
Return'
'
Memory_read:
   B_temp1 = Civ_in_b(7) * 100
   B_temp2 = Makedec(Civ_in_b(8))
   B_temp1 = B_temp1 + B_temp2
   ' memory number
   Decr B_temp1
   W_Temp1 = B_temp1 * 39
   ' start with 1, 40,...
   Incr W_temp1
   If Mem_function > 0 Then
      If Civ_in_b(7) <> &HFF Then
         Tx_b(3)= B_temp1
         Select Case Mem_function
         Case 1
            ' sel
            Tx_b(1) = &H03
            Tx_b(2) = &H1B
            Tx_b(4) = Memorycontent_b(W_Temp1)
            Tx_write_pointer = 5
         Case 2
            ' frequency
            Tx_b(1) = &H02
            Tx_b(2) = &HFD
            ' start in Civ_in
            B_temp5 = 10
            Tx_write_pointer = 4
            Gosub Rx_frequency
         Case 3
            ' mode
            Tx_b(1) = &H02
            Tx_b(2) = &HFF
            Tx_b(4) = Memorycontent_b(W_Temp1 + 6)
            If Tx_b(4) > 5 Then Tx_b(4) = Tx_b(4) - 1
            Tx_write_pointer = 5
         Case 4
            ' filter
            Tx_b(1) = &H03
            Tx_b(2) = &H01
            Tx_b(4) = Memorycontent_b(W_Temp1 + 7) - 1
            Tx_write_pointer = 5
         Case 5
            ' tone
            Tx_b(1) = &H03
            Tx_b(2) = &H03
            Tx_b(4) = Memorycontent_b(W_Temp1 + 8)
            Tx_b(4) = Tx_b(4) And &H0F
            Tx_write_pointer = 5
         Case 6
            ' Data mode
            Tx_b(1) = &H03
            Tx_b(2) = &H05
            Tx_b(4) = Memorycontent_b(W_Temp1 + 8)
            Tx_b(4) = Tx_b(4) And &HF0
            Shift Tx_b(4), Right, 4
            Tx_write_pointer = 5
         Case 7
            ' tone frequency
            Tx_b(1) = &H03
            Tx_b(2) = &H07
            W_Temp1 = W_Temp1 + 9
            W_temp2_h = Memorycontent_b(W_Temp1)
            Incr W_Temp1
            W_temp2_l = Memorycontent_b(W_Temp1)
            W_temp1 =  &H0885%
            B_temp1= Lookdown(W_temp2, Tones, 51)
            Tx_b(4) = B_temp1 - 2
            Tx_write_pointer = 5
         Case 8
            ' tone frequency
            Tx_b(1) = &H03
            Tx_b(2) = &H09
            W_Temp1 = W_Temp1 + 12
            W_temp2_h = Memorycontent_b(W_Temp1)
            Incr W_Temp1
            W_temp2_l = Memorycontent_b(W_Temp1)
            W_temp1 =  &H0885%
            B_temp1= Lookdown(W_temp2, Tones, 51)
            Tx_b(4) = B_temp1 - 2
            Tx_write_pointer = 5
         Case 9
            ' frequency SPLIT
            Tx_b(1) = &H03
            Tx_b(2) = &H0B
            ' start in Civ_in
            B_temp5 = 24
            Tx_write_pointer = 4
            Gosub Rx_frequency
         Case 10
            ' mode SPIT
            Tx_b(1) = &H02
            Tx_b(2) = &H0D
            Tx_b(4) = Memorycontent_b(W_Temp1 + 20)
            If Tx_b(4) > 5 Then Tx_b(4) = Tx_b(4) - 1
            Tx_write_pointer = 5
         Case 11
            ' filter SPLIT
            Tx_b(1) = &H03
            Tx_b(2) = &H0F
            Tx_b(4) = Memorycontent_b(W_Temp1 + 21) - 1
            Tx_write_pointer = 5
         Case 12
            ' tone SPLIT
            Tx_b(1) = &H03
            Tx_b(2) = &H01
            Tx_b(4) = Memorycontent_b(W_Temp1 + 22)
            Tx_b(4) = Tx_b(4) And &H0F
            Tx_write_pointer = 5
         Case 13
            ' Data mode SPLIT
            Tx_b(1) = &H03
            Tx_b(2) = &H13
            Tx_b(4) = Memorycontent_b(W_Temp1 + 22)
            Tx_b(4) = Tx_b(4) And &HF0
            Shift Tx_b(4), Right, 4
            Tx_write_pointer = 5
         Case 14
            ' tone frequency SPLIT
            Tx_b(1) = &H03
            Tx_b(2) = &H15
            W_Temp1 = W_Temp1 + 23
            W_temp2_h = Memorycontent_b(W_Temp1)
            Incr W_Temp1
            W_temp2_l = Memorycontent_b(W_Temp1)
            W_temp1 =  &H0885%
            B_temp1= Lookdown(W_temp2, Tones, 51)
            Tx_b(3) = B_temp1 - 2
            Tx_write_pointer = 4
         Case 15
            ' tone frequency SPLIT
            Tx_b(1) = &H03
            Tx_b(2) = &H17
            W_Temp1 = W_Temp1 + 26
            W_temp2_h = Memorycontent_b(W_Temp1)
            Incr W_Temp1
            W_temp2_l = Memorycontent_b(W_Temp1)
            W_temp1 =  &H0885%
            B_temp1= Lookdown(W_temp2, Tones, 51)
            Tx_b(3) = B_temp1 - 2
            Tx_write_pointer = 4
         Case 16
            ' name
            Tx_b(1) = &H03
            Tx_b(2) = &H19
            Tx_b(3) = &H0A
            For B_temp1 = 4 To 14
               Tx_b(B_temp1) = Memorycontent_b(W_Temp1 + 29)
            Next B_temp1
            Tx_write_pointer = 15
         End Select
         Mem_function = 0
      Else
         Not_valid_at_this_time
      End If
   End If
Return
'
Rx_frequency:
'convert 5 byte of Civ_in bcd bytes to Tx: lower byte -> higher byte;
' work up to 4.2GHz
' Start civ_in with byte B_temp5
' Tx start with Byte Tx_write_pointer
D_temp1 = 0
B_temp1 = Civ_in_b(B_temp5)
B_temp1 = Makedec(B_temp1)
D_temp1 = B_temp1
Incr  B_temp5
B_temp1 = Civ_in_b(B_temp5)
B_temp1 = Makedec(B_temp1)
D_temp2 = B_temp1 * 100
D_temp1 = D_temp1 + D_temp2
Incr  B_temp5
B_temp1 = Civ_in_b(B_temp5)
B_temp1 = Makedec(B_temp1)
D_temp2 = B_temp1 * 10000
D_temp1 = D_temp1 + D_temp2
Incr  B_temp5
B_temp1 = Civ_in_b(B_temp5)
B_temp1 = Makedec(B_temp1)
D_temp2 = B_temp1 * 1000000
D_temp1 = D_temp1 + D_temp2
Incr  B_temp5
B_temp1 = Civ_in_b(B_temp5)
B_temp1 = Makedec(B_temp1)
D_temp2 = B_temp1 * 100000000
D_temp1 = D_temp1 + D_temp2

D_temp1 = D_temp1 - 30000
For B_temp1 = 4 To 1 Step - 1
   Tx_b(Tx_write_pointer) = D_temp1_b(b_Temp1)
   Incr Tx_write_pointer
Next B_temp1
Return
'
Rx_hpf_lpf:
Tx_b(3) = Civ_in_b(9) And &H0F
Tx_b(4) = Civ_in_b(9) And &HF0
Shift Tx_b(4), Right, 4
Return
'
RX_offset:
D_temp1 = Makedec(Civ_in_b(11)) * 10000
W_temp2 = Makedec(Civ_in_b(10)) * 100
D_temp1 = D_temp1 + W_temp2
D_temp1 = D_temp1 + Makedec(Civ_in_b(9))
D_temp1 = D_temp1 / 10
If Civ_in_b(12)   = 0 Then
   D_temp1 = D_temp1 + 9999
Else
   D_temp1 = 9999 - D_temp1
End If
W_temp1 = D_temp1
Tx_b(3) = W_temp1_h
Tx_b(4) = W_temp1_l
Tx_write_pointer = 5
Return
'
Rx_band_edge:
' B_temp5 is start within Civ_in
If Civ_in_b(7) < &HFF Then
   Tx_b(3) = Civ_in_b(7) - 1
   ' low edge
   B_temp4 = B_temp5 + 4
   D_temp1 = Makedec(Civ_in_b(B_temp4)) * 100000000
   B_temp4 = B_temp5 + 3
   D_temp2 = Makedec(Civ_in_b(B_temp4)) * 1000000
   D_temp1 = D_temp1 + D_temp2
   B_temp4 = B_temp5 + 2
   D_temp2 = Makedec(Civ_in_b(B_temp4)) * 10000
   D_temp1 = D_temp1 + D_temp2
   B_temp4 = B_temp5 + 1
   D_temp2 = Makedec(Civ_in_b(B_temp4)) * 100
   D_temp1 = D_temp1 + D_temp2
   D_temp1 = D_temp1 + Makedec(Civ_in_b(B_temp5))
   Tx_b(4) = D_temp1_b(4)
   Tx_b(5) = D_temp1_b(3)
   Tx_b(6) = D_temp1_b(2)
   Tx_b(7) = D_temp1_b(1)
   ' high edge
   B_temp4 = B_temp5 +  10
   D_temp1 = Makedec(Civ_in_b(B_temp4)) * 100000000
   B_temp4 = B_temp5 +  9
   D_temp2 = Makedec(Civ_in_b(B_temp4)) * 1000000
   D_temp1 = D_temp1 + D_temp2
   B_temp4 = B_temp5 + 8
   D_temp2 = Makedec(Civ_in_b(B_temp4)) * 10000
   D_temp1 = D_temp1 + D_temp2
   B_temp4 = B_temp5 +  7
   D_temp2 = Makedec(Civ_in_b(B_temp4)) * 100
   D_temp1 = D_temp1 + D_temp2
   B_temp4 = B_temp5 + 6
   D_temp1 = D_temp1 + Makedec(Civ_in_b(B_temp4))
   Tx_b(8) = D_temp1_b(4)
   Tx_b(9) = D_temp1_b(3)
   Tx_b(10) = D_temp1_b(2)
   Tx_b(11) = D_temp1_b(1)
   Tx_write_pointer = 12
Else
   Not_valid_at_this_time
   Tx_write_pointer = 1
End If
Return
'
Rx_scope_edge:
D_temp1 = Makedec(Civ_in_b(11)) * 1000
D_temp2 = Makedec(Civ_in_b(10)) * 10
D_temp1 = D_temp1 + D_temp2
B_temp1 = Civ_in_b(9)
Shift B_temp1, Right, 4
D_temp1 = D_temp1 + B_temp1
' subtract offset:
W_temp1 = D_temp1 - F_offset
Tx_b(4) = W_temp1_h
Tx_b(5) = W_temp1_l
'
D_temp3 = Makedec(Civ_in_b(14)) * 1000
D_temp2 = Makedec(Civ_in_b(13)) * 10
D_temp3 = D_temp3 + D_temp2
B_temp1 = Civ_in_b(12)
Shift B_temp1, Right, 4
D_temp3 = D_temp3 + B_temp1
'Span:
W_temp1 = D_temp3 - D_temp1
W_temp1 = W_temp1 - 5
Tx_b(6) = W_temp1_h
Tx_b(7) = W_temp1_l
Tx_write_pointer = 8
Return
'
Color:
Tx_b(3) = 100 * Civ_in_b(9)
Tx_b(3) = Tx_b(3) + Makedec(Civ_in_b(10))
Tx_b(4) = 100 * Civ_in_b(11)
Tx_b(4) = Tx_b(4) + Makedec(Civ_in_b(12))
Tx_b(5) = 100 * Civ_in_b(13)
Tx_b(5) = Tx_b(5) + Makedec(Civ_in_b(14))
Tx_write_pointer = 6
Return
'
Rx_tone:
' Start civ_in with byte B_temp5
' Tx start with Byte Tx_write_pointer
W_temp1 = 0
W_temp1_h = Civ_in_b(B_temp5)
W_temp1_l = Civ_in_b(B_temp5 + 1)
B_temp1 = Lookdown(W_temp1, Tones, 51)
Tx_b(Tx_write_pointer)= B_temp1 - 2
Incr Tx_write_pointer
Return