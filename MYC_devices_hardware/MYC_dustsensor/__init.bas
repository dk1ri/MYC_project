' additional init
' 20251209
'
M_timer = 0
Measure_time = Measure_time_eeram
M_time = M_time_eeram
Timer0 = 0
Gosub Clear_memory
Bs = 0
Cleaning_intervall = Cleaning_intervall_eeram
'
' start device
Gosub Start_sensor
Gosub Send_Cleaning_intervall