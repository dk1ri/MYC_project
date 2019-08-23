' additional init
' 190711
'
Ccw_0_voltage = Ccw_0_voltage_eeram
Cw_360_voltage = Cw_360_voltage_eeram
Voltage_range_0_360 = Ccw_0_voltage - Cw_360_voltage
'actual voltage range for 360 degree
Antenna_limit_direction = Antenna_limit_direction_eeram
Preset_pos_antenna = Preset_pos_antenna_eeram
If Preset_pos_antenna < Antenna_limit_direction Then
   Preset_rotor = 360 -Antenna_limit_direction
   Preset_rotor = Preset_rotor + Preset_pos_antenna
Else
   Preset_rotor = Preset_pos_antenna - Antenna_limit_direction
End If
If Preset_rotor < Antenna_deviation Then Preset_rotor = Antenna_deviation
Temp_w = 359 - Antenna_deviation
If Preset_rotor > Temp_w Then Preset_rotor = Temp_w
Preset_active = 0
Hw_limit_detected = 0
Off_limit = 0
Preset_out_limits = 1
Preset_active = 0
'manual
Gosub Stop_all