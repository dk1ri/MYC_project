' additional comands
' 20230515
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
      'reset always
      Gosub Reset_load
      Temp_dw_b1 = command_b(4)
      'low byte first
      Temp_dw_b2 = command_b(3)
      Temp_dw_b3 = command_b(2)
      Temp_dw_b4 = 0
      Temp_dw = Temp_dw + 400
      Temp_single = Temp_dw / 1000
      If Temp_dw < Component_u Then
         If Active_fets > 0 Then
            Required_v = Temp_single
            If Voltage > Required_v Then
               El_mode = 1
               Temp_single = Required_v * Hyst
               Required_v_p  = Required_v + Temp_single
               If Required_v_p > Component_u Then Required_v_p = Component_u
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
      'reset always
      Gosub Reset_load
      Temp_dw = 0
      Temp_dw_b1 = command_b(4)
      'low byte first
      Temp_dw_b2 = command_b(3)
      Temp_dw_b3 = command_b(2)
      Temp_dw_b4 = 0
      Temp_single = Temp_dw / 1000
      If Temp_single <= Component_i Then
         If Temp_dw > 0 Then
            If Voltage > Minimum_voltage Then
               If Active_fets > 0 Then
                  Required_i = Temp_single
                  If Required_i < Max_total_current Then
                     El_mode = 2
                     Temp_single = Required_i * Hyst
                     Required_i_p  = Required_i + Temp_single
                     If Required_i_p > Max_total_current Then Required_i_p = Max_total_current
                     Required_i_m  = Required_i - Temp_single
                     If Required_i_m < 0 Then Required_i_m = 0
                     Gosub Dac_startup
                  Else
                     Required_current_too_high
                     Required_i = 0
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
      'reset always
      Gosub Reset_load
      Temp_dw = 0
      Temp_dw_b1 = command_b(4)
      'low byte first
      Temp_dw_b2 = command_b(3)
      Temp_dw_b3 = command_b(2)
      Temp_single = Temp_dw / 1000
      If Temp_single <= Component_p Then
         If Temp_dw > 0 Then
            If Voltage > Minimum_voltage Then
               If Active_fets > 0 Then
                  If Temp_dw > 0 Then
                     Required_p = Temp_dw / 1000
                     If Required_p < Power_of_all_fets And Required_p < Max_cooling Then
                        El_mode = 3
                        Temp_single = 1 + Hyst
                        Required_p_p  = Required_p * Temp_single
                        If Required_p_p > Power_of_all_fets  Then Required_p_p = Power_of_all_fets
                        Temp_single = 1 - Hyst
                        Required_p_m  = Required_p * Temp_single
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
      'reset always
      Gosub Reset_load
      Temp_dw_b1 = command_b(5)
      'low byte first
      Temp_dw_b2 = command_b(4)
      Temp_dw_b3 = command_b(3)
      Temp_dw_b4 = Command_b(2)
      If Temp_dw < 119999990 Then
         If Voltage > Minimum_voltage Then
               If Active_fets > 0 Then
                  Temp_dw = Temp_dw + 10
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
      Temp_w = Temp_w + Command_b(3)
      If Temp_w < 1000 Then
         On_off_time = Temp_w
         On_off_time = On_off_time * On_off_time_default_
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
   Tx_time = 1
   Tx_b(1) = &H13
   Tx_b(2) =  El_mode
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
14:
   Gosub Reset_load
   Gosub Command_received
Return
'
15:
   If Commandpointer >= 2 Then
      If Command_b(2) < 100 Then
         ' in %
         Hyst = Command_b(2)
         Hyst = Hyst / 1000
         Hyst_eeram = Hyst
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
16:
   Tx_time = 1
   Temp_single = Hyst * 1000
   B_temp1 = Temp_single
   Tx_b(1) = &H16
   Tx_b(2) = B_temp1
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
17:
   If Commandpointer >= 2 Then
      If Command_b(2) <= Max_number_of_fets Then
         B_temp4 = Command_b(2) + 2
         If Commandpointer >= B_temp4 Then
            Active_fets = 0
            B_temp2 = 3
            B_temp3 = 1
            For B_temp1 = 1 to Command_b(2)
               If Command_b(B_temp2) = "x" Then
                  Active_fets = Active_fets + B_temp3
               End If
               B_temp2 = B_temp2 + 1
               Shift B_temp3, Left, 1
            Next B_temp1
         End If
         Gosub Count_number_of_active_fets
         Gosub Reset_load
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
18:
   Tx_time = 1
   Tx_b(1) = &H18
   Tx_b(2) = 7
   B_temp2 = 3
   For B_temp1 = 0 To 6
      If Active_fets.B_temp1 = 1 Then
         B_temp3 = B_temp1 + 49
         Tx_b(B_temp2) = B_temp3
      Else
         Tx_b(B_temp2) = "_"
      End If
      B_temp2 = B_temp2 + 1
   Next B_temp1
   Tx_write_pointer = 10
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
19:
   Tx_time = 1
   Tx_b(1) = &H19
   Tx_b(2) = 1
   Tx_b(3) = Number_of_active_fets + 48
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
1A:
   If Commandpointer >= 2 Then
      ' W
      If Command_b(2) <= Component_pp Then
         Max_power = Command_b(2)
         Max_power_eeram = Max_power
         Gosub Reset_load
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1B:
   Tx_time = 1
   B_temp1 = Max_power
   Tx_b(1) = &H1B
   Tx_b(2) = B_temp1
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
1C:
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
1D:
   If Commandpointer >= 2 Then
      If Command_b(2) < 7 Then
         Gosub Is_fet_active
         If Error_req = 0 Then
            Tx_time = 1
            Tx_b(1) = &H1D
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
1E:
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
1F:
   Temp_single = Calibrate_u
   Temp_single = Temp_single * 1000
   Temp_single = Temp_single - 20000
   Temp_dw = Temp_single
   Tx_time = 1
   Tx_b(1) = &H1F
   Tx_b(2) = Temp_dw_b3
   Tx_b(3) = Temp_dw_b2
   Tx_b(4) = Temp_dw_b1
   Tx_write_pointer = 5
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
20:
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
21:
   Tx_time = 1
   Temp_single = Correction_u + 0.2
   Temp_single =  Correction_u * 10000
   Temp_single = Temp_single - 8000
   If Temp_single < 0 Then Temp_single = 0
   Temp_w = Temp_single
   Tx_b(1) = &H21
   Tx_b(2) = High(Temp_w)
   Tx_b(3) = Low(Temp_w)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
22:
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
23:
   Temp_single =  Calibrate_i * 1000
   Temp_w = Temp_single
   Temp_w = Temp_w - 2000
   Tx_time = 1
   Tx_b(1) = &H23
   Tx_b(2) = High(Temp_w)
   Tx_b(3) = Low(Temp_w)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
24:
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
25:
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
26:
   If Commandpointer >= 2 Then
      If Command_b(2) < 7 Then
         Tx_time = 1
         B_temp1 = Command_b(2) + 1
         Temp_single = Correction_i(B_temp1)
         Temp_single = Temp_single * 10000
         Temp_single =Temp_single - 8000
         If Temp_single < 0 Then Temp_single = 0
         Temp_w = Temp_single
         Tx_b(1) = &H26
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