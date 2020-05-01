' additional commands
' 20200430
'
01:
      If Commandpointer = 2 Then
         If Command_b(2) < 2 Then
            If Command_b(2) = 0 Then
               Reset Controlon
               Gosub Stop_all
            Else
               Set Controlon
            End If
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
Return
'
02:
      Tx_time = 1
      Tx_b(1) = &H02
      Tx_b(2) =  High(pos_antenna)
      Tx_b(3) =  Low(pos_antenna)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
03:
'Befehl &H03 0|1
'Manual / Preset switch
'Data "3;os;1;0,manual;1,preset"
      If Commandpointer = 2 Then
         If Controlon = 1 Then
            If Command_b(2) < 2 Then
               If Command_b(2) = 0 Then
                  Gosub Stop_all
                  Preset_active = 0
               Else
                  Preset_active = 1
                  Preset_out_limits = 1
               End If
            Else
               Error_no = 4
               Error_cmd_no = Command_no
            End If
         Else
            Error_no = 7
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
Return
'
04:
      If Commandpointer = 3 Then
         Temp_w = Command_b(2) * 256
         'word, MSB first
         Temp_w = Temp_w + Command_b(3)
         'preset antenna direction
         If Temp_w < 360 Then
            Preset_pos_antenna = Temp_w
            Preset_pos_antenna_eeram = Preset_pos_antenna
            If Preset_pos_antenna < Antenna_limit_direction Then
               Preset_rotor = 360 -Antenna_limit_direction
               Preset_rotor = Preset_rotor + Preset_pos_antenna
            Else
               Preset_rotor = Preset_pos_antenna - Antenna_limit_direction
            End If
            If Preset_rotor < Antenna_deviation Then Preset_rotor = Antenna_deviation
            Temp_w = 359 - Antenna_deviation
            If Preset_rotor > Temp_w Then Preset_rotor = Temp_w
            Preset_out_limits = 1
            'if preset_active:start again
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
Return
'
05:
      Preset_active = 0
      If Controlon = 1 Then
      'rule 1
         Gosub Motor_ccw_on
         If Hw_limit_detected = 1 Then Hw_limit_detected = 2
      Else
         Error_no = 0
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
Return
'
06:
      Gosub Stop_all
      Preset_active = 0
      Gosub Command_received
Return
'
07:
      Preset_active = 0
      If Controlon = 1 Then
      'rule 1
         Gosub Motor_cw_on
         If Hw_limit_detected = 1 Then Hw_limit_detected = 2
      Else
         Error_no = 0
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
Return
'
08:
      If Commandpointer = 3 Then
         Temp_w = Command_b(2) * 256
         'word, MSB first
         Temp_w = Temp_w + Command_b(3)
         'preset antenna direction
         '0 to 359
         If Temp_w < 360 Then
            Antenna_limit_direction = Temp_w
            Antenna_limit_direction_eeram = Antenna_limit_direction
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
Return
'
09:
      Tx_time = 1
      Tx_b(1) = &H09
      Tx_b(2) =  High(Antenna_limit_direction)
      Tx_b(3) =  Low(Antenna_limit_direction)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
10:
      If Commandpointer = 2 Then
         If Command_b(2) < 6 Then
            Tx_time = 1
            Select Case Command_b(2)
                Case 0
                   Tx_b(2) = Controlon
                Case 1
                   Tx_b(2) = Preset_active
                Case 2
                   Tx_b(2) = Motor_cw
                Case 3
                   Tx_b(2) = Motor_ccw
                Case 4
                   Tx_b(2) = Not_limit
                Case 5
                   Tx_b(2) = Preset_out_limits
            End Select
            Tx_b(1) = &H0A
            Tx_write_pointer = 3
            If Command_mode = 1 Then Gosub Print_tx
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
Return
'
11:
      If Commandpointer = 2 Then
         If Command_b(2) < 5 Then
            Tx_time = 1
            Select Case Command_b(2)
               Case 0
                  Tx_b(2) = High(Preset_pos_antenna)
                  Tx_b(3) = Low(Preset_pos_antenna)
               Case 1
                  Tx_b(2) = High(ccw_0_voltage)
                  Tx_b(3) = Low(ccw_0_voltage)
               Case 2
                  Tx_b(2) = High(cw_360_voltage)
                  Tx_b(3) = Low(cw_360_voltage)
               Case 3
                  Tx_b(2) = High(Dir_rotor)
                  Tx_b(3) = Low(Dir_rotor)
               Case 4
                  Tx_b(2) = High(Preset_rotor)
                  Tx_b(3) = Low(Preset_rotor)
            End Select
            Tx_b(1) = &H0B
            Tx_write_pointer = 3
            If Command_mode = 1 Then Gosub Print_tx
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
Return
'
12:
      Ccw_0_voltage_temp = Pos_rotator_voltage
      'voltage, should be near 1024 for ccw position
      'corrected values
      Gosub Command_received
Return
'
13:
      Cw_360_voltage_temp = Pos_rotator_voltage
      'voltage, should be near 0 for cw position  !!
      If Cw_360_voltage_temp < 100 And Ccw_0_voltage_temp > 900 Then
         Ccw_0_voltage = Ccw_0_voltage_temp
         Cw_360_voltage = Cw_360_voltage_temp
         Ccw_0_voltage_eeram = Ccw_0_voltage
         Cw_360_voltage_eeram = Cw_360_voltage
         Voltage_range_0_360 = Ccw_0_voltage - Cw_360_voltage
         'actual voltage range for 360 degree
      End If
      Gosub Command_received
Return
'
14:
      Tx_time = 1
      Tx_b(1) = &H0E
      Tx_b(2) = Not_limit
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
15:
      Tx_time = 1
      Tx_b(1) = &H09
      Tx_b(2) = Controlon
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'