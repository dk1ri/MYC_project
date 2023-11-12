' Commands
' 20231110
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
                  Tcnt3 = Timer3_stop
               Case 2:
                  Gosub Switch_off
                  ' 13cm PA will be powered but not switched on (requires 13cmPA_ptt_on)
                  Gosub Start_WB
               Case 3:
                  Gosub Switch_off
                  Gosub Minitiouner_on
                  Wait_led = Wait_1s
                  NB_WB_ = 3
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
      Stop Watchdog
      Gosub Reset_ser
      B_temp1 = &H74
      Gosub Get_serial_2
      If Ser2_valid = 1 Then
         Error_flag = 0
         print Up_pointer
         If Up_pointer = 3 Then
            B_temp1 = Up_string_b(2)
            print B_temp1
            Gosub Check_number
            If Error_flag = 0 Then
               Up_temp = B_temp1 * 10
               B_temp1 = Up_string_b(3)
               Gosub Check_number
               If Error_flag = 0 Then
                  Up_temp =  Up_temp + B_temp1
                  ' + / -
                  B_temp1 = Up_string_b(1)
                  If B_temp1 = &H2D Then
                  ' -
                     If Up_temp > 20 Then Up_temp = 20
                     Up_temp = 20 - Up_temp
                  Elseif B_temp1 = &H2B Then
                     ' +
                     Up_temp = Up_temp + 20
                  Else
                     Error_flag = 1
                  End If
                  If Error_flag = 0 Then
                     Tx_time = 1
                     Tx_b(1) = &H05
                     Tx_b(2) = Up_temp
                     Gosub Read_2
                  End If
               End If
            End If
         Else
            Error_flag = 1
         End If
         If Error_flag = 1 Then
            Com2_parameter_error
         End If
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
06:
' Upconverter forward
' Upconverter result is xxx&H0D (x are 0 to 9)
   If NB_WB_ = 1 And Ptt_ = 1 Then
      Stop Watchdog
      Gosub Reset_ser
      printbin #2,&H66;&H0D;
      Gosub Get_serial_2
      If Ser2_valid = 1 Then
         Error_flag = 0
         If Up_pointer = 3 Then
            B_temp1 = Up_string_b(1)
            Gosub Check_number
            If Error_flag = 0 Then
               If B_temp1 < 2 Then
                  Up_f = B_temp1 * 100
                  B_temp1 = Up_string_b(2)
                  Gosub Check_number
                  If Error_flag = 0 Then
                     B_temp1 = B_temp1 * 10
                     Up_f = Up_f + B_temp1
                     B_temp1 = Up_string_b(2)
                     Gosub Check_number
                     If Error_flag = 0 Then
                        Up_f = Up_f + B_temp1
                        Tx_time = 1
                        Tx_b(1) = &H06
                        Tx_b(2) = Up_f
                        Gosub Read_2
                     End If
                  Else
                     Error_flag = 1
                  End If
               End If
            End If
         Else
             Error_flag = 1
         End If
         If Error_flag = 1 Then
            Com2_parameter_error
         End If
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
07:
' Upconverte reflected
' Upconverter result is xxx&H0d (x are 0 to 9)
   If NB_WB_ = 1 And Ptt_ = 1 Then
      Stop Watchdog
      Gosub Reset_ser
      printbin #2,&H72;&H0D;
      Gosub Get_serial_2
      If Ser2_valid = 1 Then
         Error_flag = 0
         If Up_pointer = 3 Then
            B_temp1 = Up_string_b(1)
            Gosub Check_number
            If Error_flag = 0 Then
               If B_temp1 < 2 Then
                  Up_r = B_temp1 * 100
                  B_temp1 = Up_string_b(2)
                  Gosub Check_number
                  If Error_flag = 0 Then
                     B_temp1 = B_temp1 * 10
                     Up_r = Up_r + B_temp1
                     B_temp1 = Up_string_b(3)
                     Gosub Check_number
                     If Error_flag = 0 Then
                        Up_r = Up_r + B_temp1
                        Tx_time = 1
                        Tx_b(1) = &H06
                        Tx_b(2) = Up_r
                        Gosub Read_2
                     End If
                  Else
                     Error_flag = 1
                  End If
               End If
            End If
         Else
             Error_flag = 1
         End If
         If Error_flag = 1 Then
            Com2_parameter_error
         End If
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
08:
' Upconverte GPS locked
   If NB_WB_ = 1 Then
      Stop Watchdog
      Gosub Reset_ser
      printbin #2,&H6C;&H0D;
      Gosub Get_serial_2
      If Ser2_valid = 1 Then
         If Up_string_b(1) = &H30 Or Up_string_b(1) = &H31 Then
            Up_locked = Up_string_b(1) - &H30
            Tx_time = 1
            Tx_b(1) = &H08
            Tx_b(2) = Up_locked
            Gosub Read_2
         Else
            Com2_parameter_error
         End If
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
Read_2:
   Tx_time = 1
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'