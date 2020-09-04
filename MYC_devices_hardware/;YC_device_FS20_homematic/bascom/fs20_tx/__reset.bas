' additional reset
' 200104
'
Kanal_mode = 0
Kanal_mode_eeram = Kanal_mode
' Housecode 11111111
Housecode = "00000000"
Housecode_eeram = Housecode
Set4 = 1
Set4_eeram = Set4
Set8 = 1
' for Code Array: 1 to 10
Set8_eeram = Set8
Code4 = String(160, 49)
' first set (16 Byte) 1111 to 1114
For B_temp1 = 0 To 3
   B_temp3 = B_temp1 * 4
   Incr B_temp3
   Code4_b(B_temp3) = 49
   Incr  B_temp3
   Code4_b(B_temp3) = 49
   Incr  B_temp3
   Code4_b(B_temp3) = 49
   Incr  B_temp3
   Code4_b(B_temp3) = B_temp1 + 49
Next B_temp1
Code4_eeram = Code4
'
Code8 = String(320, 49)
' first set (32 Byte) 1111 to 1124
For B_temp1 = 0 To 1
   For B_temp2 = 0 To 3
      B_temp3 = B_temp1 * 16
      B_temp4 = B_temp2 * 4
      B_temp3 = B_temp3 + B_temp4
      Incr B_temp3
      Code8_b(B_temp3) = 49
      Incr  B_temp3
      Code8_b(B_temp3) = 49
      Incr  B_temp3
      Code8_b(B_temp3) = B_temp1 + 49
      Incr  B_temp3
      Code8_b(B_temp3) = B_temp2 + 49
      B_temp4 = Code8_b(B_temp3)
   Next B_temp2
Next B_temp1
Code8_eeram = Code8