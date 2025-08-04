' additional time dependent conditions
' 202231017
Incr Check_time
' every second
If Check_time > 2000 Then
  Gosub Read_data
  Check_time = 0
End If