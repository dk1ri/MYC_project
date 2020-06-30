' additional comands
' 20200520
'
01:
   Tx_time = 1
   Temp_dw = Voltage * 1000
   Tx_b(1) = &H01
   Tx_b(2) = Temp_dw_b3
   Tx_b(3) = Temp_dw_b2
   Tx_b(4) = Temp_dw_b1
   Tx_write_pointer = 5
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
02:
   Tx_time = 1
   Temp_single = All_current * 1000
   Temp_dw = Temp_single
   Tx_b(1) = &H02
   Tx_b(2) = Temp_dw_b3
   Tx_b(3) = Temp_dw_b2
   Tx_b(4) = Temp_dw_b1
   Tx_write_pointer = 5
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
03:
   If Commandpointer >= 2 Then
      If Command_b(2) < 7 Then
         Tx_time = 1
         B_temp1 = Command_b(2) + 1
         Temp_single = Current(B_temp1) * 1000
         Temp_w = Temp_single
         Tx_b(1) = &H03
         Tx_b(2) = Command_b(2)
         Tx_b(3) = High(Temp_w)
         Tx_b(4) = Low(Temp_w)
         Tx_write_pointer = 5
         If Command_mode = 1 Then Gosub Print_tx
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
04:
   Tx_time = 1
   Temp_single = All_power * 1000
   Temp_dw = Temp_single
   Tx_b(1) = &H04
   Tx_b(2) = Temp_dw_b3
   Tx_b(3) = Temp_dw_b2
   Tx_b(4) = Temp_dw_b1
   Tx_write_pointer = 5
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
05:
   If Commandpointer >= 2 Then
      If Command_b(2) < 7 Then
         Tx_time = 1
         B_temp1 = Command_b(2) + 1
         Temp_single = Power_(B_temp1) * 1000
         Temp_w = Temp_single
         Tx_b(1) = &H05
         Tx_b(2) = Command_b(2)
         Tx_b(3) = High(Temp_w)
         Tx_b(4) = Low(Temp_w)
         Tx_write_pointer = 5
         If Command_mode = 1 Then Gosub Print_tx
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
06:
   Tx_time = 1
   Temp_single = Resistance * 1000
   Temp_dw = Temp_single
   Tx_b(1) = &H06
   Tx_b(2) = Temp_dw_b4
   Tx_b(3) = Temp_dw_b3
   Tx_b(4) = Temp_dw_b2
   Tx_b(5) = Temp_dw_b1
   Tx_write_pointer = 6
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
07:
   If Commandpointer >= 4 Then
      Temp_dw_b1 = command_b(4)
      'low byte first
      Temp_dw_b2 = command_b(3)
      Temp_dw_b3 = command_b(2)
      Temp_dw_b4 = 0
      If Temp_dw < 79600 Then
         If Active_fets > 0 Then
            Gosub Reset_load
            Required_v = Temp_dw / 1000
            Required_v = Required_v + 0.4
            If Voltage > Required_v Then
               El_mode = 1
               Temp_single = Required_v * Hyst
               Required_v_p  = Required_v + Temp_single
               Required_v_m  = Required_v - Temp_single
               If Required_v_m < 0 Then Required_v_m = 0
               Gosub Dac_startup
               Minimum_voltage = Minimum_voltage_v
            Else
               Voltage_too_high
            End If
         Else
            No_active_fet
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
08:
   Tx_time = 1
   Temp_single = Required_v - 0.4
   Temp_single = Temp_single * 1000
   Temp_dw = Temp_single
   Tx_b(1) = &H08
   Tx_b(2) = Temp_dw_b3
   Tx_b(3) = Temp_dw_b2
   Tx_b(4) = Temp_dw_b1
   Tx_write_pointer = 5
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
09:
   If Commandpointer >= 4 Then
      Temp_dw = 0
      Temp_dw_b1 = command_b(4)
      'low byte first
      Temp_dw_b2 = command_b(3)
      Temp_dw_b3 = command_b(2)
      Temp_dw_b4 = 0
      If Temp_dw <= 182000 Then
         If Temp_dw > 0 Then
            If Voltage > Minimum_voltage Then
               If Active_fets > 0 Then
                  Gosub Reset_load
                  If Temp_dw > 0 Then
                     Required_i = Temp_dw / 1000
                     If Required_i < Max_total_current Then
                        El_mode = 2
                        Temp_single = Required_i * Hyst
                        Required_i_p  = Required_i + Temp_single
                        Required_i_m  = Required_i - Temp_single
                        If Required_i_m < 0 Then Required_i_m = 0
                        Gosub Dac_startup
                     Else
                        Required_current_too_high
                        Required_i = 0
                     End If
                  End If
               Else
                  No_active_fet
               End If
            Else
               Voltage_too_low
            End If
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
0A:
   Tx_time = 1
   Temp_dw  = Required_i * 1000
   Tx_b(1) = &H0A
   Tx_b(2) = Temp_dw_b3
   Tx_b(3) = Temp_dw_b2
   Tx_b(4) = Temp_dw_b1
   Tx_write_pointer = 5
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
0B:
   If Commandpointer >= 4 Then
      Temp_dw = 0
      Temp_dw_b1 = command_b(4)
      'low byte first
      Temp_dw_b2 = command_b(3)
      Temp_dw_b3 = command_b(2)
      If Temp_dw <= 300000 Then
         If Temp_dw > 0 Then
            If Voltage > Minimum_voltage Then
               If Active_fets > 0 Then
                  Gosub Reset_load
                  If Temp_dw > 0 Then
                     Required_p = Temp_dw / 1000
                     If Required_p < Power_of_all_fets And Required_p < Max_cooling Then
                        El_mode = 3
                        Temp_single = Required_p * Hyst
                        Required_p_p  = Required_p + Temp_single
                        If Required_p_p > Power_of_all_fets  Then Required_p_p = Power_of_all_fets
                        Required_p_m  = Required_i - Temp_single
                        If Required_p_m < 0 Then Required_p_m = 0
                        Gosub Dac_startup
                     Else
                        Required_power_too_high
                        Required_p = 0
                     End If
                  End If
               Else
                  No_active_fet
               End If
            Else
               Voltage_too_low
            End If
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
0C:
   Tx_time = 1
   Temp_dw = Required_p * 1000
   Tx_b(1) = &H0C
   Tx_b(2) = Temp_dw_b3
   Tx_b(3) = Temp_dw_b2
   Tx_b(4) = Temp_dw_b1
   Tx_write_pointer = 5
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'

0D:
   If Commandpointer >= 5 Then
      Temp_dw_b1 = command_b(5)
      'low byte first
      Temp_dw_b2 = command_b(4)
      Temp_dw_b3 = command_b(3)
      Temp_dw_b4 = Command_b(2)
      If Temp_dw < 119999990 Then
         If Voltage > Minimum_voltage Then
               If Active_fets > 0 Then
                  Temp_dw = Temp_dw + 10
                  Gosub Reset_load
                  Required_r = Temp_dw / 1000
                  El_mode = 4
                  Temp_single = Required_r * Hyst
                  Required_r_p  = Required_r + Temp_single
                  If Required_r_p > 120000  Then Required_r_p = 120000
                  Required_r_m  = Required_r - Temp_single
                  If Required_r_m < 0.001 Then Required_r_m = 0.001
                  Gosub Dac_startup
               Else
                  No_active_fet
               End If
            Else
               Voltage_too_low
            End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
0E:
   Tx_time = 1
   Temp_dw = Required_r * 1000
   Temp_dw = Temp_dw - 10
   Tx_b(1) = &H0E
   Tx_b(2) = Temp_dw_b4
   Tx_b(3) = Temp_dw_b3
   Tx_b(4) = Temp_dw_b2
   Tx_b(5) = Temp_dw_b1
   Tx_write_pointer = 6
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
0F:
    If Commandpointer >= 2 Then
      If Command_b(2) < 3  Then
         If El_mode > 0 And El_mode < 5 Then
            On_off_mode = Command_b(2)
            On_off_counter = 0
            Off_on = 0
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
10:
   Tx_time = 1
   Tx_b(1) = &H10
   Tx_b(2) = On_off_mode
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
11:
   If Commandpointer >= 3 Then
      Temp_w = Command_b(2) * 256
      Temp_w = Temp_w + Command_b (3)
      If Temp_w < 1000 Then
         On_off_time = Temp_w + 1
         On_off_time = On_off_time * On_off_time_default_
         On_off_time_eeram = On_off_time
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
12:
   Tx_time = 1
   Temp_dw = On_off_time / On_off_time_default_
   Temp_w = Temp_dw -1
   Tx_b(1) = &H12
   Tx_b(2) = High(Temp_w)
   Tx_b(3) = Low(Temp_w)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
13:
   If Commandpointer >= 2 Then
      Tx_time = 1
      Tx_b(1) = &H13
      Tx_b(2) = Command_b(2)
      If Command_b(2) = 0 Then
         Tx_b(3) =  El_mode
         Tx_write_pointer = 4
      Else
         Select Case El_mode
            Case 0
               B_temp1 = 7
               Temps = "0: idle"
            Case 1
               B_temp1 = 15
               Temps = "1: voltage mode"
            Case 2
               B_temp1 = 15
               Temps = "2: current mode"
            Case 3
               B_temp1 = 13
               Temps = "3: power mode"
            Case 4
               B_temp1 = 16
               Temps = "4: resistor mode"
            Case 5
               B_temp1 = 12
               Temps = "5: test mode"
            Case 6
               B_temp1 = 22
               Temps = "6: voltage calibra"
            Case 7
               B_temp1 = 22
               Temps = "7: current calibra"
         End Select
         Tx_b(3) = B_temp1
         B_temp2 = 4
         For B_temp3 = 1 To B_temp1
            Tx_b(B_temp2) = Temps_b(B_Temp3)
            Incr B_Temp2
         Next B_Temp3
         Tx_write_pointer = B_temp1 + 4
      End If
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
   End If
Return
'
14:
   Gosub Reset_load
   Gosub Command_received
Return
'
15:
   If Commandpointer >= 2 Then
      If Command_b(2) < 2 Then
         Hyst_on = Command_b(2)
         Hyst_on_eeram = Hyst_on
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
16:
   Tx_time = 1
   Tx_b(1) = &H16
   Tx_b(2) = Hyst_on
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
17:
   If Commandpointer >= 2 Then
      If Command_b(2) < 100 Then
         Hyst = Command_b(2) + 1
         Hyst = Hyst / 1000
         Hyst_eeram = Hyst
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
18:
   Tx_time = 1
   Temp_single = Hyst * 1000
   Temp_single = Temp_single - 1
   Tx_b(1) = &H18
   Tx_b(2) = Temp_single
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
19:
   If Commandpointer >= 2 Then
      If Command_b(2) < 128 Then
         Active_fets = Command_b(2)
         Active_fets_eeram = Active_fets
         Gosub Count_number_of_active_fets
         Gosub Reset_load
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1A:
   Tx_time = 1
   Tx_b(1) = &H1A
   Tx_b(2) = Active_fets
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
1B:
   Tx_time = 1
   Tx_b(1) = &H1B
   Tx_b(2) = Number_of_active_fets
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
1C:
   Tx_time = 1
   Temp_dw = Max_power * 1000
   Tx_b(1) = &H1C
   Tx_b(2) = Temp_dw_b3
   Tx_b(3) = Temp_dw_b2
   Tx_b(4) = Temp_dw_b1
   Tx_write_pointer = 5
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
1D:
   If Commandpointer >= 4 Then
      Temp_dw = 0
      Temp_dw_b1 = command_b(4)
      'low byte first
      Temp_dw_b2 = command_b(3)
      Temp_dw_b3 = command_b(2)
      Temp_single = Temp_dw / 1000
      ' W
      If Temp_single <= 150000 Then
         Max_power = Temp_single
         Max_power_eeram = Max_power
         Gosub Reset_load
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1E:
   If Commandpointer >= 4 Then
      If Command_b(2) < 7 Then
         W_temp1 = Command_b(3) * 256
         W_temp1 = W_temp1 + Command_b(4)
         If W_temp1 <= Da_resolution Then
            Gosub Is_fet_active
            If Error_req = 0 Then
               Gosub Reset_load
               Fet_number = Command_b(2) + 1
               Dac_out_voltage(Fet_number) = W_temp1
               Gosub Send_to_fet
               El_mode = 5
            Else
               Fet_not_active
            End If
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1F:
   If Commandpointer >= 2 Then
      If Command_b(2) < 7 Then
         Gosub Is_fet_active
         If Error_req = 0 Then
            Tx_time = 1
            Tx_b(1) = &HE5
            Tx_b(2) = Command_b(2)
            B_temp1 = Command_b(2) + 1
            Tx_b(3) = High(Dac_out_voltage(B_temp1))
            Tx_b(4) = Low(Dac_out_voltage(B_temp1))
            Tx_write_pointer = 5
            If Command_mode = 1 Then Gosub Print_tx
         Else
            Fet_not_active
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
20:
   If Commandpointer >= 4 Then
      Temp_dw_b1 = command_b(4)
      'low byte first
      Temp_dw_b2 = command_b(3)
      Temp_dw_b3 = command_b(2)
      Temp_dw_b4 = 0
       'mV
      If Temp_dw < 70000 Then
         Temp_dw = Temp_dw + 20000
         Temp_single = Temp_dw
         Calibrate_u = Temp_single / 1000
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
21:
   Temp_single = Calibrate_u
   Temp_single = Temp_single * 1000
   Temp_single = Temp_single - 20000
   Temp_dw = Temp_single
   Tx_time = 1
   Tx_b(1) = &HE7
   Tx_b(2) = Temp_dw_b3
   Tx_b(3) = Temp_dw_b2
   Tx_b(4) = Temp_dw_b1
   Tx_write_pointer = 5
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
22:
   If Voltage > Minimum_voltage Then
      Gosub Reset_load
      El_mode = 6
      Gosub Next_fet_to_use
   Else
      Voltage_too_low
   End If
   Gosub Command_received
Return
'
23:
   Tx_time = 1
   Temp_single = Correction_u + 0.2
   Temp_single =  Correction_u * 10000
   Temp_single = Temp_single - 8000
   If Temp_single < 0 Then Temp_single = 0
   Temp_w = Temp_single
   Tx_b(1) = &HE9
   Tx_b(2) = High(Temp_w)
   Tx_b(3) = Low(Temp_w)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
24:
   If Commandpointer >= 3 Then
      Temp_w = Command_b(2) * 256
      Temp_w = Temp_w + Command_b(3)
      If Temp_w < 20000 Then
         Temp_w = Temp_w + 2000
         Temp_single = Temp_w
         Calibrate_i = Temp_single / 1000
         ' Ampere
      Else
         Calibrate_current_too_low
      End If
      Gosub Command_received
   End If
Return
'
25:
   Temp_single =  Calibrate_i * 1000
   Temp_w = Temp_single
   Temp_w = Temp_w - 2000
   Tx_time = 1
   Tx_b(1) = &HEB
   Tx_b(2) = High(Temp_w)
   Tx_b(3) = Low(Temp_w)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
26:
   If Commandpointer >= 2 Then
      If Command_b(2) < 7 Then
         Gosub Reset_load
         Gosub Is_fet_active
         If Error_req = 0 Then
            Fet_number = Command_b(2) + 1
            Dac_out_voltage(Fet_number) = 0
            Gosub Send_to_fet
            El_mode = 5
            Gosub Next_fet_to_use
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
27:
   If Commandpointer >= 2 Then
      If Command_b(2) < 7 Then
         Gosub Is_fet_active
         If Error_req = 0 Then
            Fet_number = Command_b(2) + 1
            El_mode = 7
         Else
            Fet_not_active
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
28:
   If Commandpointer >= 2 Then
      If Command_b(2) < 7 Then
         Tx_time = 1
         B_temp1 = Command_b(2) + 1
         Temp_single = Correction_i(B_temp1)
         Temp_single = Temp_single * 10000
         Temp_single =Temp_single - 8000
         If Temp_single < 0 Then Temp_single = 0
         Temp_w = Temp_single
         Tx_b(1) = &HEE
         Tx_b(2) = Command_b(2)
         Tx_b(3) = High(Temp_w)
         Tx_b(4) = Low(Temp_w)
         Tx_write_pointer = 5
         If Command_mode = 1 Then Gosub Print_tx
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'