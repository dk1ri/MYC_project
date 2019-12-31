' additional time dependent conditions
' 191012
'
If I = 30 Then
         Gosub Read_data
         Gosub Correct_temperature
         Gosub Correct_humidity
         Gosub Pressure_64
End If