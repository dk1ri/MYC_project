' additional init
' 190611
'
Set Gon
Correction_u = Correction_u_eeram
For B_temp1 = 1 To 7
   Correction_i(B_temp1) = Correction_i_eeram(B_temp1)
Next B_temp1
Max_power = Max_power_eeram
Max_power_save = Max_power * Save_factor
On_off_mode = 0
On_off_time = On_off_time_eeram
Active_fets = Active_fets_eeram
Gosub Count_Number_of_active_fets
Calibrate_u = 0
Calibrate_i = 0
Gosub Reset_load