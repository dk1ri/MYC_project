' Commands
' 20230901
'
01:
' NB / WB
   If Command_pointer >= 2 Then
      If Command_b(2) <> NB_WB_ Then
         Select Case Command_b(2)
            Case 0:
               Gosub Switch_off
            Case 1
               ' Upconverter was off before -> no blockrequest
               Gosub Switch_off 
               Gosub Start_nb
               ' 2 s for serial switch on
               Tcnt3 = Timer3_stop
               Start Timer3
            Case 2:
               Gosub Switch_off
               ' 13cm PA will be powered but not switched on (requires 13cmPA_ptt_on)
               Gosub Start_WB
            Case Else:
               Parameter_error
         End Select
      End If
      Started = 2
      Gosub Command_received
   End If
Return
'
02:
' Nb / Wb
   Tx_b(1) = &H02
   Tx_b(2) = NB_WB_
   Gosub Read_2
Return
'
03:
' PTT
   If Command_pointer >= 2 Then
      If Command_b(2) > 1 Then
         Parameter_error
      Else
         If Started = 2 Then
           If NB_WB_ > 0 Then
              If Command_b(2) <> Ptt_ Then
                 If  Command_b(2) = 0 Then
                    Block_request = 3
                 Else
                    Block_request = 2
                 End If
              End If
           Else
              Not_valid_at_this_time
           End If
         Else
            Not_valid_at_this_time
         End If
      End If
      Gosub Command_received
   End If
Return
'
04:
' PTT
   Tx_b(1) = &H04
   Tx_b(2) = Ptt_
   Gosub Read_2
Return
'
05:
' ready
   Tx_b(1) = &H05
   Tx_b(2) = Started
   Gosub Read_2
Return
'
06:
' Upconverter Temp
   If NB_WB_ = 1 Then
      Tx_time = 1
      Tx_b(1) = &H06
      Tx_b(2) = Up_temp
      Gosub Read_2
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
Return
'
07:
' Upconverter forward
   If NB_WB_ = 1 Then
      Tx_time = 1
      Tx_b(1) = &H07
      Tx_b(2) = Up_f
      Gosub Read_2
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
Return
'
08:
' Upconverte reflected
   If NB_WB_ = 1 Then
      Tx_time = 1
      Tx_b(1) = &H08
      Tx_b(2) = Up_r
      Gosub Read_2
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
Return
'
09:
' Upconverte GPS locked
   If NB_WB_ = 1 Then
      Tx_time = 1
      Tx_b(1) = &H09
      Tx_b(2) = Up_locked
      Gosub Read_2
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
Return
'
10:
'23cmPA forward
   If NB_WB_ = 2 Then
      Adc_value = Getadc(4)
       Adc_value = Getadc(4)
      ' 0 W -> 0.5V to 3V -> 60W abt
      ' 60W / 2,5V = 24W/V
      ' 2.5V -> 512 count   -> 0.11718 W / count
      If Adc_value < 100 Then
         B_temp1 = 0
      Else
         Adc_value = Adc_value - 100
         Si_temp1 = Adc_value * 0.11718
         B_temp1 = Si_temp1
      End If
      Tx_time = 1
      Tx_b(1) = &H0A
      Tx_b(2) = B_temp1
      Gosub Read_2
   Else
      Not_valid_at_this_time
   End If
Return
'
11:
'external Temperatur sensor
' LM35Z 0 -> 0 degc; 10mV / degc  < 150 degc
' adc resolution 5V / 1024  -> 5mV abt  -> 0.5 degc resolution
'
 ' Temp: external Temp sensor of 23cm PA
   'T / degC = W_temp1 * (5V / 1024)/(10mV /degK)
   W_temp1 = Getadc(0)
   'T / degC = W_temp1 * (5V / 1024)/(1mV /degK) - 2731
   ' 2731: due to resolution of 1/10 deg
   Si_temp1 = W_temp1 * 5000
   ' mV:
   Si_temp1 = Si_temp1 / 1024
   Si_temp1 = Si_temp1 - 2731.5
   ' thenth deg:
   Temperature = Si_temp1
   Tx_time = 1
   Tx_b(1) = &H0B
   Tx_b(2) = High(Temperature)
   Tx_b(3) = Low(Temperature)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
Read_2:
   Tx_time = 1
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'