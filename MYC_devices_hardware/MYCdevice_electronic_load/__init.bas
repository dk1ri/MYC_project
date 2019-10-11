' additional init
' 190716
'
Correction_u = Correction_u_eeram
Calc_u = Calc_u_ * Correction_u 
For B_temp1 = 1 To 7
   Correction_i(B_temp1) = Correction_i_eeram(B_temp1)
   Calc_i(B_temp1) = Calc_i_ * Correction_i(B_temp1)
Next B_temp1
Max_power = Max_power_eeram
Hyst = Hyst_eeram
Hyst_on = Hyst_on_eeram
On_off_mode = 0
On_off_time = On_off_time_eeram
Active_fets = Active_fets_eeram
Gosub Count_Number_of_active_fets
Gosub Reset_load
' After reset of load Gon can be switched on
Set Gon
Calibrate_u = 20.0
Calibrate_i = 2.0
Measure_v = 0