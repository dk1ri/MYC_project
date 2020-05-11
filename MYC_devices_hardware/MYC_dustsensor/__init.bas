' additional init
' 20200316
'
M_timer = 0
Measure_time = Measure_time_eeram
M_time = M_time_eeram
Timer0 = 0
Gosub Clear_memory
Bs = 0
Last_command = 0
'
' start device
Temps_b(1) = &H7E
Temps_b(2) = &H00
Temps_b(3) = &H00
Temps_b(4) = &H02
Temps_b(5) = &H01
Temps_b(6) = &H05
Temps_b(7) = &HF7
Temps_b(8) = &H7E
Send_len = 8
Gosub Send_data
Rx_started = 1