' Commands
' 20231123
'
00:
Tx_time = 1
   A_line = 0
   Number_of_lines = 1
   Send_line_gaps = 2
   Gosub Sub_restore
   Gosub Print_tx
   Gosub Command_received
Return
'
01:
   Gosub Read_color_data
   Tx_time = 1
   Tx_b(1) = &H01
   Tx_b(2) = 36
   B_temp2 = 3
   For B_temp1 = 1 To 36
      Tx_b(B_temp2) = Co_b(B_temp1)
      Incr B_temp2
   Next B_temp1
   Tx_write_pointer = 39
   Gosub Print_tx
   Gosub Command_received
Return
'
02:
   V_reg = VIOLET_COR
   Gosub Read_one_color_cor
   If Data_valid = 1 Then
      Violet_data = Temp_single
   End If
   Tx_time = 1
   Tx_b(1) = &H02
   Tx_b(2) = High (Violet_data)
   Tx_b(3) = Low(Violet_data)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
03:
   V_reg = BLUE_COR
   Gosub Read_one_color_cor
   If Data_valid = 1 Then
      Blue_data = Temp_single
   End If
   Tx_time = 1
   Tx_b(1) = &H03
   Tx_b(2) = High(Blue_data)
   Tx_b(3) = Low(Blue_data)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
04:
   V_reg = GREEN_COR
   Gosub Read_one_color_cor
   If Data_valid = 1 Then
      Green_data = Temp_single
   End If
   Tx_time = 1
   Tx_b(1) = &H04
   Tx_b(2) = High(Green_data)
   Tx_b(3) = Low(Green_data)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
05:
   V_reg = YELLOW_COR
   Gosub Read_one_color_cor
   If Data_valid = 1 Then
      Yellow_data = Temp_single
   End If
   Tx_time = 1
   Tx_b(1) = &H05
   Tx_b(2) = High(Yellow_data)
   Tx_b(3) = Low(Yellow_data)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
06:
   V_reg = ORANGE_COR
   Gosub Read_one_color_cor
   If Data_valid = 1 Then
      Orange_data = Temp_single
   End If
   Tx_time = 1
   Tx_b(1) = &H06
   Tx_b(2) = High(Orange_data)
   Tx_b(3) = Low(Orange_data)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
07:
   V_reg = RED_COR
   Gosub Read_one_color_cor
   If Data_valid = 1 Then
      Red_data = Temp_single
   End If
   Tx_time = 1
   Tx_b(1) = &H07
   Tx_b(2) = High(Red_data)
   Tx_b(3) = Low(Red_data)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
08:
   Gosub Read_status
   Tx_time = 1
   Tx_b(1) = &H08
   Tx_b(2) = As_status
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
09:
   Gosub Read_control
   Tx_time = 1
   Tx_b(1) = &H09
   Tx_b(2) = As_mode
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
10:
   If Command_pointer >= 2 Then
      If Command_b(2) < 4 Then
         Bank = Command_b(2)
         Gosub Write_control
      Else
         Parameter_error
      End If
      Gosub  Command_received
   End If
Return
'
11:
   Gosub Read_control
   Tx_time = 1
   Tx_b(1) = &H0B
   Tx_b(2) = Bank
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
12:
   Tx_b(1) = &H0C
   Tx_time = 1
   V_reg= HW_VERSION
   Gosub Read_register
   B_temp1 = Dat(1)
   B_temp2 = 3
   Gosub Dat_to_String
   '
   Incr V_reg
   Gosub Read_register
    B_temp1 = Dat(1)
   Gosub Dat_to_String
   '
   Decr B_temp2
   Tx_b(2) = B_temp2 - 3
   Tx_write_pointer = B_temp2
   Gosub Print_tx
   Gosub Command_received
Return
'
13:
   Tx_b(1) = &H0D
   Tx_time = 1
   V_reg= FW_VERSION
   Gosub Read_register
   B_temp1 = Dat(1)
   Shift B_temp1, Right, 6
   B_temp2 = 3
   Gosub Dat_to_String
   '
   B_temp1 = Dat(1)
   B_temp1 = B_temp1 And &B00111111
   Gosub Dat_to_String
   '
   Incr V_reg
   Gosub Read_register
   B_temp1 = Dat(1)
   Shift B_temp1, Right, 4
   Gosub Dat_to_String
   '
   B_temp1 = Dat(1)
   B_temp1 = B_temp1 And &B00001111
   Gosub Dat_to_String
   '
   Decr B_temp2
   Tx_b(2) = B_temp2 - 3
   Tx_write_pointer = B_temp2
   Gosub Print_tx
   Gosub Command_received
Return
'
14:
   If Command_pointer >= 2 Then
      Integrate_time = Command_b(2)
      V_reg = IT
      To_send = Integrate_time
      Gosub Write_register_l
      Gosub Command_received
   End If
Return
'
15:
   V_reg = IT
   Gosub Read_register
   If Data_valid = 1 Then
      Integrate_time = Dat(1)
   End If
   Tx_time = 1
   Tx_b(1) = &H0F
   Tx_b(2) = Integrate_time
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
16:
   V_reg = TEMPERATURE
   Gosub Read_register
   If Data_valid = 1 Then
      Temp = Dat(1)
   End If
   Tx_time = 1
   Tx_b(1) = &H10
   Tx_b(2) = Temp
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
17:
   If Command_pointer >= 2 Then
      If Command_b(2) < 5 Then
        If Command_b(2) = 0 Then
           Led_on = 0
           Led_current = 0
        Else
           Led_on = 1
           Led_current = Command_b(2) - 1
        End If
        Gosub Write_led
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
18:
   Gosub Read_led
   Tx_time = 1
   Tx_b(1) = &H12
   If Led_on = 0 Then
      Tx_b(2) = 0
   Else
      Tx_b(2) = Led_current + 1
   End If
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
19:
   If Command_pointer >= 2 Then
      If Command_b(2) < 5 Then
        If Command_b(2) = 0 Then
           Led_ind = 0
           Led_ind_current = 0
        Else
           Led_ind = 1
           Led_ind_current = Command_b(2) - 1
        End If
        Gosub Write_led
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
20:
   Gosub Read_led
   Tx_time = 1
   Tx_b(1) = &H14
   If Led_ind = 0 Then
      Tx_b(2) = 0
   Else
      Tx_b(2) = Led_ind_current + 1
   End If
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
21:
   If Command_pointer >= 2 Then
      If command_b(2) < 4 Then
         Gain = Command_b(2)
         Gosub Write_control
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
22:
   Gosub Read_control
   Tx_time = 1
   Tx_b(1) = &H16
   Tx_b(2) = Gain
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
23:
   If Interface_mode = 0 Then
      If Commandpointer >= 2 Then
         If Command_b(2) < 4 Then
            If Radio_type <> Command_b(2) Then
               Radio_type = Command_b(2)
               Radio_type_eram = Command_b(2)
               Goto Restart
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
24:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H18
      Tx_b(2) = Radiotype
      Tx_write_pointer = 3
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
25:
   If Interface_mode = 0 Then
      If Commandpointer >= 2 Then
         B_temp1 = Command_b(2) + 1
         If B_temp1 <= Name_len Then
            If Commandpointer >= B_temp1 Then
               B_temp2 = 1
               For B_temp1 = 3 To B_temp1
                  Radio_name_b(B_temp2) = Command_b(B_temp1)
                  Incr B_temp2
               Next B_temp1
               Radio_name_eram = Radio_name
               Gosub Command_received
            End If
         Else
            Parameter_error
            Gosub Command_received
         End If
      End If
   Else
      Not_valid_at_this_time
   End If
Return
'
26:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H1A
      Tx_b(2) = len(Radio_name)
      B_temp2 = 3
      For B_temp1 = 1 to Tx_b(2)
          Tx_b(B_temp2) = Radio_name_b(B_temp1)
          Incr B_temp2
      Next B_temp1
      Tx_write_pointer = B_temp2
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
27:
   If Interface_mode = 0 Then
      If Commandpointer >= 3 Then
         Radio_frequency = Command_b(2) * 256
         Radio_frequency = Radio_frequency + Command_b(3)
         If Radio_frequency < 612903 Then
            Radio_frequency = Radio_frequency + 137000000
            Radio_frequency = Radio_frequency * 62
            Radio_frequency_eeram = Radio_frequency
            Select Case Radio_type
               Case 0
                  Gosub Set_radio_f0
            End Select
         Else
            Parameter_error
         End If
      End If
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
28:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H1C
      D_temp1 = Radio_frequency - 137000000
      D_temp1 = D_temp1 / 62
      Tx_b(2) = D_temp1_b(1)
      Tx_b(3) = D_temp1_b(2)
      Tx_write_pointer = 4
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
29:
   If Interface_mode = 0 Then
      If Commandpointer >= 4 Then
         Radio_frequency = Command_b(2) * 256
         Radio_frequency = Radio_frequency + Command_b(3)
         If Radio_frequency < 1854838 Then
            Radio_frequency = Radio_frequency + 410000000
            Radio_frequency = Radio_frequency * 62
            Radio_frequency_eeram = Radio_frequency
            Select Case Radio_type
               Case 0
                  Gosub Set_radio_f0
            End Select
         Else
            Parameter_error
         End If
      End If
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
30:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H1E
      D_temp1 = Radio_frequency - 410000000
      D_temp1 = D_temp1 / 62
      Tx_b(2) = D_temp1_b(1)
      Tx_b(3) = D_temp1_b(2)
      Tx_b(4) = D_temp1_b(3)
      Tx_write_pointer = 5
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
31:
   If Interface_mode = 0 Then
       If Commandpointer >= 4 Then
          Radio_frequency = Command_b(2) * 256
          Radio_frequency = Radio_frequency + Command_b(3)
          If Radio_frequency < 1019999 Then
             Radio_frequency = Radio_frequency + 820000000
             Radio_frequency = Radio_frequency * 62
             Radio_frequency_eeram = Radio_frequency
             Select Case Radio_type
                Case 0
                   Gosub Set_radio_f0
             End Select
          Else
             Parameter_error
          End If
       End If
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
32:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H20
      D_temp1 = Radio_frequency - 820000000
      D_temp1 = D_temp1 / 62
      Tx_b(2) = D_temp1_b(1)
      Tx_b(3) = D_temp1_b(2)
      Tx_b(4) = D_temp1_b(3)
      Tx_write_pointer = 5
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
33:
   Tx_time = 1
   Tx_b(1) = &H21
   Tx_b(2) = Interface_mode
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'