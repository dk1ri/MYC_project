' Commands
' 20240405
'
01:
' NB / WB
   If Command_pointer >= 2 Then
      If Command_b(2) <> NB_WB_ Then
         If Command_b(2) < 4 Then
            NB_WB_ = Command_b(2)
            Select Case NB_WB_
               Case 0:
                  Gosub Switch_off
               Case 1
                  ' Upconverter was off before -> no blockrequest
                  Gosub Switch_off
                  Gosub Start_nb
                  ' 2 s for serial switch on
                  Stop Watchdog
                  Wait 2
                  Start Watchdog
               Case 2:
                  Gosub Switch_off
                  ' 13cm PA will be powered but not switched on (requires 13cmPA_ptt_on)
                  Gosub Start_WB
               Case 3:
                  Gosub Switch_off
                  Gosub Start_DATV_RX
            End Select
         Else
            Parameter_error
         End If
      End If
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
      If Command_b(2) < 2 Then
        If NB_WB_ = 1 Or NB_WB_ = 2 Then
           If Command_b(2) <> Ptt_ Then
              If  Command_b(2) = 0 Then
                 Gosub End_transmit
              Else
                 Gosub Start_transmit
              End If
           End If
        Else
           Not_valid_at_this_time
        End If
      Else
         Parameter_error
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
' Upconverter Temp
' Upconverter result is +xx&H0D (x are 0 to 9)
   If NB_WB_ = 1 Then
      B_temp1 = &H74
      Gosub Get_serial_2
      If Ser2_valid = 1 Then
         Tx_b(1) = &H05
         B_temp1 = Up_string_b(2)
         Gosub Check_number
         Tx_b(2) = B_temp1 * 10
         B_temp1 = Up_string_b(3)
         Gosub Check_number
         Tx_b(2) = Tx_b(2) + B_temp1
         Gosub Read_2
      Else
         Com2_error
      End If
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
Return
'
06:
' Upconverter forward
' Upconverter result is xxx&H0D (x are 0 to 9)
   If NB_WB_ = 1 Then
      B_temp1 = &H66
      Gosub Get_serial_2
      If Ser2_valid = 1 Then
         B_temp2 = 1
         B_temp1 = Up_pointer
         If B_temp1 > 3 Then B_temp1 = 3
         Up_f = 0
         While B_temp1 > 0
            B_temp1 = Up_string_b(B_temp2)
            Gosub Check_number
            Up_f = Up_f * 10
            Up_f = Up_f + B_temp1
            B_temp2 = B_temp2 + 1
            B_temp1 = B_temp1 - 1
         Wend
         Tx_b(1) = &H06
         Tx_b(2) = Up_r
         Gosub Read_2
      Else
         Com2_error
      End If
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
Return
'
07:
' Upconverter reflected
' Upconverter result is xxx&H0d (x are 0 to 9)
   If NB_WB_ = 1 Then
      B_temp1 = &H72
      Gosub Get_serial_2
      If Ser2_valid = 1 Then
         B_temp2 = 1
         B_temp1 = Up_pointer
         If B_temp1 > 3 Then B_temp1 = 3
         Up_r = 0
         While B_temp1 > 0
            B_temp1 = Up_string_b(B_temp2)
            Gosub Check_number
            Up_r = Up_r * 10
            Up_r = Up_r + B_temp1
            B_temp2 = B_temp2 + 1
            B_temp1 = B_temp1 - 1
         Wend
         Tx_b(1) = &H07
         Tx_b(2) = Up_r
         Gosub Read_2
      Else
         Com2_error
      End If
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
Return
'
08:
' Upconverte GPS locked
   If NB_WB_ = 1 Then
      B_temp1 = &H6C
      Gosub Get_serial_2
      If Ser2_valid = 1 Then
         Tx_b(1) = &H08
         B_temp1 = Up_string_b(1)
         Gosub Check_number
         Tx_b(2) = B_temp1
         Gosub Read_2
      Else
         Com2_error
      End If
      Start Watchdog
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
Return
'
09:
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
      Tx_b(1) = &H09
      Tx_b(2) = B_temp1
      Gosub Read_2
   Else
      Not_valid_at_this_time
   End If
Return
'
10:
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
   Tx_b(1) = &H0A
   Tx_b(2) = High(Temperature)
   Tx_b(3) = Low(Temperature)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
11:
   W_temp1 = Getadc(1)
   Tx_time = 1
   Tx_b(1) = &H0B
   Tx_b(2) = High(W_temp1)
   Tx_b(3) = Low(W_temp1)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
12:
   W_temp1 = Getadc(2)
   Tx_time = 1
   Tx_b(1) = &H0C
   Tx_b(2) = High(W_temp1)
   Tx_b(3) = Low(W_temp1)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
13:
   W_temp1 = Getadc(3)
   Tx_time = 1
   Tx_b(1) = &H0D
   Tx_b(2) = High(W_temp1)
   Tx_b(3) = Low(W_temp1)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
14:
   Tx_time = 1
   Tx_b(1) = &H0E
   Tx_b(2) = Kerr
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
15:
   W_temp1 = Getadc(4)
   Tx_time = 1
   Tx_b(1) = &H0F
   Tx_b(2) = High(W_temp1)
   Tx_b(3) = Low(W_temp1)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
16:
   Tx_time = 1
   Tx_b(1) = &H10
   Tx_b(2) = PA1
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
17:
   Tx_time = 1
   Tx_b(1) = &H11
   Tx_b(2) = PA2_1
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
18:
   Tx_time = 1
   Tx_b(1) = &H12
   Tx_b(2) = PA2_2
   Tx_write_pointer = 3
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