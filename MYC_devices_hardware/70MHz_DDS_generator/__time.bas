' additional time dependent conditions
' 20210629
'
Incr T_measure
If T_measure > T_measure_time Then
   ' every 30s abt
   Gosub Calc_temperature
   T_measure = 0
End If
'