' additional reset
' 190611
'
Max_power_eeram = Max_power_default
'50W
Active_fets_eeram = Active_fets_default
On_off_time_eeram = On_off_time_default
Correction_u_eeram = Correction_u_default
Hyst_eeram = Hyst_default
Hyst_on_eeram = Hyst_on_default
For B_Temp1 = 1 To 7
   Correction_i_eeram(B_temp1) = Correction_i_default
Next B_temp1