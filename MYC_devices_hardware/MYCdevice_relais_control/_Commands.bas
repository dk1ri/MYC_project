' additional commands
' 20200501
'
01:
Tx_b(2) = Inp1
Answer1
Return
'
02:
Tx_b(2) = Inp2
Answer1
Return
'
03:
Tx_b(2) = Inp3
Answer1
Return
'
04:
Tx_b(2) = Inp4
Answer1
Return
'
05:
Tx_b(2) = Inp5
Answer1
Return
'
06:
Tx_b(2) = Inp6
Answer1
Return
'
07:
Tx_b(2) = Inp7
Answer1
Return
'
08:
Tx_b(2) = Inp8
Answer1
Return
'
09:
Tx_b(2) = Inp9
Answer1
Return
'
10:
Tx_b(2) = Inp10
Answer1
Return
'
11:
Tx_b(2) = Inp11
Answer1
Return
'
12:
Gosub Send_input_2
Return
'
13:
Gosub Send_input_2
Return
'
14:
Gosub Send_input_2
Return
'
15:
Gosub Send_input_2
Return
'
16:
b_Temp1 = 0
If Inp1 = 1 Then b_Temp1 = 1
If Inp2 = 1 Then b_Temp1 = b_Temp1 + 2
If Inp3 = 1 Then b_Temp1 = b_Temp1 + 4
If Inp4 = 1 Then b_Temp1 = b_Temp1 + 8
If Inp5 = 1 Then b_Temp1 = b_Temp1 + 16
If Inp6 = 1 Then b_Temp1 = b_Temp1 + 32
If Inp7 = 1 Then b_Temp1 = b_Temp1 + 64
If Inp8 = 1 Then b_Temp1 = b_Temp1 + 128
Tx_b(1) = &H10
Tx_b(3) = b_Temp1
b_Temp1 = 0
If Inp9 = 1 Then b_Temp1 = 1
If Inp10 = 1 Then b_Temp1 = b_Temp1 + 2
If Inp11 = 1 Then b_Temp1 = b_Temp1 + 4
Tx_b(2) = b_Temp1
'
Tx_time = 1
Tx_write_pointer = 4
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
17:
If Commandpointer > 1 Then
   If Command_b(2) = 1 Then
      Set Relais1
   Else
      Reset Relais1
   End If
   Gosub Command_received
End If
Return
'
18:
Tx_b(2) = Relais1
Answer1
Return
'
19:
If Commandpointer > 1 Then
   If Command_b(2) = 1 Then
      Set Relais2
   Else
      Reset Relais2
   End If
   Gosub Command_received
End If
Return
'
20:
Tx_b(2) = Relais2
Answer1
Return
'
21:
If Commandpointer > 1 Then
   If Command_b(2) = 1 Then
      Set Relais3
   Else
      Reset Relais3
   End If
   Gosub Command_received
End If
Return
'
22:
Tx_b(2) = Relais3
Answer1
Return
'
23:
If Commandpointer > 1 Then
   If Command_b(2) = 1 Then
      Set Relais4
   Else
      Reset Relais4
   End If
   Gosub Command_received
End If
Return
'
24:
Tx_b(2) = Relais4
Answer1
Return
'
25:
If Commandpointer > 1 Then
   Select Case Command_b(2)
      Case 0
         Adc_reference = 0
         Adc_reference_eeram = Adc_reference
         Config Adc = Single , Prescaler = Auto , Reference = Avcc
      Case 1
         Adc_reference = 1
         Adc_reference_eeram = Adc_reference
         Config Adc = Single , Prescaler = Auto , Reference = Internal_1.1
      Case Else
         Parameter_error
   End Select
   Gosub Command_received
End If
Return
'
26:
Tx_b(2) = Adc_reference
Answer1
Return                     '
'