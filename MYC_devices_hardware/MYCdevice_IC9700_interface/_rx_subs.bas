' Rx subs
' 20200314
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
   B_temp1 = Civ_in_b(8) * 100
   B_temp2 = Makedec(Civ_in_b(9))
   B_temp1 = B_temp1 + B_temp2
   ' memory number
   Decr B_temp1
   W_Temp1 = B_temp1 * 114
   ' start with 1, 115,...
   Incr W_temp1
   If Mem_function > 0 Then
      If Civ_in_b(8) <> &HFF Then
         Tx_b(3)= B_temp1
         Select Case Mem_function
         Case 1
            ' sel
            Tx_b(1) = &H01
            Tx_b(2) = &HC3
            Tx_b(4) = Memorycontent_b(W_Temp1 + 4)
            Tx_write_pointer = 5
         Case 2
            ' frequency
            Tx_b(1) = &H01
            Tx_b(2) = &H81
            ' start in Civ_in
            B_temp5 = 11
            Tx_write_pointer = 4
            Gosub Rx_frequency
         Case 3
            ' mode
            Tx_b(1) = &H01
            Tx_b(2) = &H83
            Tx_b(4) = Memorycontent_b(W_Temp1 + 10)
            If Tx_b(4) > 5 Then Tx_b(4) = Tx_b(4) - 1
            If Tx_b(4) > &H16 Then Tx_b(4) = 8
            If Tx_b(4) > &H22 Then Tx_b(4) = 9
            Tx_write_pointer = 5
         Case 4
            ' filter
            Tx_b(1) = &H01
            Tx_b(2) = &H85
            Tx_b(4) = Memorycontent_b(W_Temp1 + 11) - 1
            Tx_write_pointer = 5
         Case 5
            ' Data mode
            Tx_b(1) = &H01
            Tx_b(2) = &H87
            Tx_b(4) = Memorycontent_b(W_Temp1 + 12)
            Tx_write_pointer = 5
         Case 6
            ' tone
            Tx_b(1) = &H01
            Tx_b(2) = &H89
            Tx_b(4) = Memorycontent_b(W_Temp1 + 13)
            Tx_b(4) = Tx_b(4) And &H0F
            Tx_write_pointer = 5
         Case 7
            ' duplex
            Tx_b(1) = &H01
            Tx_b(2) = &H8B
            Tx_b(4) = Memorycontent_b(W_Temp1 + 13)
            Tx_b(4) = Tx_b(4) And &HF0
            Shift Tx_b(4), Right, 4
            Tx_write_pointer = 5
         Case 8
            ' digital squelch
            Tx_b(1) = &H01
            Tx_b(2) = &H8D
            Tx_b(4) = Memorycontent_b(W_Temp1 + 14)
            Tx_write_pointer = 5
         Case 9
            ' tone frequency
            Tx_b(1) = &H01
            Tx_b(2) = &H8F
            W_Temp1 = W_Temp1 + 15
            W_temp2_h = Memorycontent_b(W_Temp1)
            Incr W_Temp1
            W_temp2_l = Memorycontent_b(W_Temp1)
            B_temp1= Lookdown(W_temp2, Tones, 51)
            Tx_b(4) = B_temp1 - 2
            Tx_write_pointer = 5
         Case 10
            ' tone frequency
            Tx_b(1) = &H01
            Tx_b(2) = &H91
            W_Temp1 = W_Temp1 + 18
            W_temp2_h = Memorycontent_b(W_Temp1)
            Incr W_Temp1
            W_temp2_l = Memorycontent_b(W_Temp1)
            B_temp1= Lookdown(W_temp2, Tones, 51)
            Tx_b(4) = B_temp1 - 2
            Tx_write_pointer = 5
         Case 11
            ' DCTS Frequncy
            Tx_b(1) = &H01
            Tx_b(2) = &H93
            W_Temp1 = W_Temp1 + 22
            W_temp1 = Memorycontent_b(W_Temp1) * 64
            Incr W_temp1
            B_temp1 = Memorycontent_b(W_Temp1) And &HF0
            Shift B_temp1, Right, 4
            B_temp1 = B_temp1 * 8
            W_temp1 = W_temp1 + B_temp1
            B_temp1 = Memorycontent_b(W_Temp1) And &H0F
            W_temp1 = W_temp1 + B_temp1
            Tx_b(4) = W_temp1_h
            Tx_b(5) = W_temp1_l
            Tx_write_pointer = 6
         Case 12
            ' DTCS polarity
            Tx_b(1) = &H01
            Tx_b(2) = &H95
            Tx_b(4) = Memorycontent_b(W_Temp1 + 19) And &HF0
            Shift Tx_b(4), Right, 4
            Tx_b(5) = Memorycontent_b(W_Temp1 + 19) And &H0F
            Tx_write_pointer = 6
         Case 13
            ' DV code squelch
            Tx_b(1) = &H01
            Tx_b(2) = &H97
            Tx_b(4) = Makedec(Memorycontent_b(W_Temp1 + 22))
            Tx_write_pointer = 5
         Case 14
            ' duplex offset
            Tx_b(1) = &H01
            Tx_b(2) = &H99
            W_temp1 = W_temp1 + 25
            Frequenz = Makedec(Memorycontent_b(W_Temp1)) * 100
            Decr W_temp1
            W_temp1 = Makedec(Memorycontent_b(W_Temp1)) * 100
            Frequenz =  Frequenz + W_temp1
            Decr W_temp1
            Frequenz =  Frequenz + Makedec(Memorycontent_b(W_Temp1))
            Tx_b(4) = Frequenz_b(3)
            Tx_b(5) = Frequenz_b(2)
            Tx_b(6) = Frequenz_b(1)
            Tx_write_pointer = 7
         Case 15
            ' UR
            Tx_b(1) = &H01
            Tx_b(2) = &H9B
            Tx_b(4) = 8
            W_Temp1 = W_Temp1 + 23
            For B_temp1 = 1 To 8
               Tx_b(B_temp1 + 4) = Memorycontent_b(W_Temp1)
               Incr W_temp1
            Next B_temp1
            Tx_write_pointer = 15
         Case 16
            ' R1
            Tx_b(1) = &H01
            Tx_b(2) = &H9D
            Tx_b(4) = 8
            W_Temp1 = W_Temp1 + 31
            For B_temp1 = 1 To 8
               Tx_b(B_temp1 + 4) = Memorycontent_b(W_Temp1)
               Incr W_temp1
            Next B_temp1
            Tx_write_pointer = 15
         Case 17
            ' R2
            Tx_b(1) = &H01
            Tx_b(2) = &H9F
            Tx_b(4) = 8
            W_Temp1 = W_Temp1 + 39
            For B_temp1 = 1 To 8
               Tx_b(B_temp1 + 4) = Memorycontent_b(W_Temp1)
               Incr W_temp1
            Next B_temp1
            Tx_write_pointer = 15
         Case 18
            ' frequency
            Tx_b(1) = &HA1
            Tx_b(2) = &H81
            ' start in Civ_in
            B_temp5 = 11
            Tx_write_pointer = 4
            Gosub Rx_frequency
         Case 19
            ' mode
            Tx_b(1) = &H01
            Tx_b(2) = &HA3
            Tx_b(4) = Memorycontent_b(W_Temp1 + 10)
            If Tx_b(4) > 5 Then Tx_b(4) = Tx_b(4) - 1
            If Tx_b(4) > &H16 Then Tx_b(4) = 8
            If Tx_b(4) > &H22 Then Tx_b(4) = 9
            Tx_write_pointer = 5
         Case 20
            ' filter
            Tx_b(1) = &H01
            Tx_b(2) = &HA5
            Tx_b(4) = Memorycontent_b(W_Temp1 + 11) - 1
            Tx_write_pointer = 5
         Case 21
            ' Data mode
            Tx_b(1) = &H01
            Tx_b(2) = &HA7
            Tx_b(4) = Memorycontent_b(W_Temp1 + 12)
            Tx_write_pointer = 5
         Case 22
            ' tone
            Tx_b(1) = &H01
            Tx_b(2) = &HA9
            Tx_b(4) = Memorycontent_b(W_Temp1 + 13)
            Tx_b(4) = Tx_b(4) And &H0F
            Tx_write_pointer = 5
         Case 23
            ' duplex
            Tx_b(1) = &H01
            Tx_b(2) = &HAB
            Tx_b(4) = Memorycontent_b(W_Temp1 + 13)
            Tx_b(4) = Tx_b(4) And &HF0
            Shift Tx_b(4), Right, 4
            Tx_write_pointer = 5
         Case 24
            ' digital squelch
            Tx_b(1) = &H01
            Tx_b(2) = &HAD
            Tx_b(4) = Memorycontent_b(W_Temp1 + 14)
            Tx_write_pointer = 5
         Case 25
            ' tone frequency
            Tx_b(1) = &H01
            Tx_b(2) = &HAF
            W_Temp1 = W_Temp1 + 15
            W_temp2_h = Memorycontent_b(W_Temp1)
            Incr W_Temp1
            W_temp2_l = Memorycontent_b(W_Temp1)
            B_temp1= Lookdown(W_temp2, Tones, 51)
            Tx_b(4) = B_temp1 - 2
            Tx_write_pointer = 5
         Case 26
            ' tone frequency
            Tx_b(1) = &H01
            Tx_b(2) = &HB1
            W_Temp1 = W_Temp1 + 18
            W_temp2_h = Memorycontent_b(W_Temp1)
            Incr W_Temp1
            W_temp2_l = Memorycontent_b(W_Temp1)
            B_temp1= Lookdown(W_temp2, Tones, 51)
            Tx_b(4) = B_temp1 - 2
            Tx_write_pointer = 5
         Case 27
            ' DCTS Frequncy
            Tx_b(1) = &H01
            Tx_b(2) = &HB3
            W_Temp1 = W_Temp1 + 22
            W_temp1 = Memorycontent_b(W_Temp1) * 64
            Incr W_temp1
            B_temp1 = Memorycontent_b(W_Temp1) And &HF0
            Shift B_temp1, Right, 4
            B_temp1 = B_temp1 * 8
            W_temp1 = W_temp1 + B_temp1
            B_temp1 = Memorycontent_b(W_Temp1) And &H0F
            W_temp1 = W_temp1 + B_temp1
            Tx_b(4) = W_temp1_h
            Tx_b(5) = W_temp1_l
            Tx_write_pointer = 6
         Case 28
            ' DTCS polarity
            Tx_b(1) = &H01
            Tx_b(2) = &HB5
            Tx_b(4) = Memorycontent_b(W_Temp1 + 19) And &HF0
            Shift Tx_b(4), Right, 4
            Tx_b(5) = Memorycontent_b(W_Temp1 + 19) And &H0F
            Tx_write_pointer = 6
         Case 29
            ' DV code squelch
            Tx_b(1) = &H01
            Tx_b(2) = &HB7
            Tx_b(4) = Makedec(Memorycontent_b(W_Temp1 + 22))
            Tx_write_pointer = 5
         Case 30
            ' duplex offset
            Tx_b(1) = &H01
            Tx_b(2) = &HB9
            W_temp1 = W_temp1 + 25
            Frequenz = Makedec(Memorycontent_b(W_Temp1)) * 100
            Decr W_temp1
            W_temp1 = Makedec(Memorycontent_b(W_Temp1)) * 100
            Frequenz =  Frequenz + W_temp1
            Decr W_temp1
            Frequenz =  Frequenz + Makedec(Memorycontent_b(W_Temp1))
            Tx_b(4) = Frequenz_b(3)
            Tx_b(5) = Frequenz_b(2)
            Tx_b(6) = Frequenz_b(1)
            Tx_write_pointer = 7
         Case 31
            ' UR
            Tx_b(1) = &H01
            Tx_b(2) = &HBB
            Tx_b(4) = 8
            W_Temp1 = W_Temp1 + 23
            For B_temp1 = 1 To 8
               Tx_b(B_temp1 + 4) = Memorycontent_b(W_Temp1)
               Incr W_temp1
            Next B_temp1
            Tx_write_pointer = 13
         Case 32
            ' R1
            Tx_b(1) = &H01
            Tx_b(2) = &HBD
            Tx_b(4) = 8
            W_Temp1 = W_Temp1 + 31
            For B_temp1 = 1 To 8
               Tx_b(B_temp1 + 4) = Memorycontent_b(W_Temp1)
               Incr W_temp1
            Next B_temp1
            Tx_write_pointer = 13
         Case 33
            ' R2
            Tx_b(1) = &H01
            Tx_b(2) = &HBF
            Tx_b(4) = 8
            W_Temp1 = W_Temp1 + 39
            For B_temp1 = 1 To 8
               Tx_b(B_temp1 + 4) = Memorycontent_b(W_Temp1)
               Incr W_temp1
            Next B_temp1
            Tx_write_pointer = 13
         Case 34
            ' name
            Tx_b(1) = &H01
            Tx_b(2) = &HC1
            Tx_b(4) = 16
            W_Temp1 = W_Temp1 + 99
            For B_temp1 = 1 To 16
               Tx_b(B_temp1 + 4) = Memorycontent_b(W_Temp1)
               Incr W_temp1
            Next B_temp1
            Tx_write_pointer = 21
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
'
Rx_position:
Tx_b(3) = Makedec(Civ_in_b(9))
W_temp1 = Makedec(Civ_in_b(10)) * 10000
W_temp2 = Makedec(Civ_in_b(11)) * 100
W_temp1 = W_temp1 + W_temp2
W_temp1 = W_temp1 + Makedec(Civ_in_b(12))
Temps_b(4) = W_temp1_h
Temps_b(5) =W_temp1_l
Temps_b(6) = Civ_in_b(13)
'
Temps_b(7) = Civ_in_b(14) * 100
Temps_b(7) = Temps_b(7) +Civ_in_b(15)
W_temp1 = Makedec(Civ_in_b(15)) * 10000
W_temp2 = Makedec(Civ_in_b(16)) * 100
W_temp1 = W_temp1 + W_temp2
W_temp1 = W_temp1 + Makedec(Civ_in_b(17))
Temps_b(8) = W_temp1_h
Temps_b(9) =W_temp1_l
Temps_b(10) = Civ_in_b(17)
'
W_temp1 = Makedec(Civ_in_b(18)) * 10000
W_temp2 = Makedec(Civ_in_b(19)) * 100
W_temp1 = W_temp1 + W_temp2
W_temp1 = W_temp1 + Makedec(Civ_in_b(20))
Temps_b(11) = W_temp1_h
Temps_b(12) =W_temp1_l
Temps_b(13) = Civ_in_b(21)
Tx_write_pointer = 14
Return
'
Rx_text:
Tx_b(3) = Civ_pointer - 9
B_temp2 = 4
For B_temp1 = 9 To Civ_pointer
   Temps_b(B_temp2) = Civ_in_b(B_temp1)
   Incr B_temp2
Next
Tx_write_pointer = Civ_pointer -6
Return
'