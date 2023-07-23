' Commands
' 20230707
'
01:
' frequency
If Command_pointer >= 5 Then
   D_temp1_b(4) = Command_b(2)
   D_temp1_b(3) = Command_b(3)
   D_temp1_b(2) = Command_b(4)
   D_temp1_b(1) = Command_b(5)
   If D_temp1 <= F_max Then
      Freq_in = D_temp1
      Gosub Dds_output
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
02:
'  frequency
Tx_time = 1
D_temp1 = Freq_in
Tx_b(1) = &H02
Tx_b(2) = D_temp1_b(4)
Tx_b(3) = D_temp1_b(3)
Tx_b(4) = D_temp1_b(2)
Tx_b(5) = D_temp1_b(1)
Tx_write_pointer = 6
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
03:
' switch on after switch off do dont work for unknown reason -> dropped
Return
'
04:
' switch on after switch off do dont work for unknown reason -> dropped
Return
'
05:
' relais
If Command_pointer >= 2 Then
   If Command_b(2) < 2 Then
      If command_b(2) = 0 Then
         Reset Relais
      Else
         Set Relais
      End If
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
06:
' relais
Tx_time = 1
Tx_b(1) = &H06
Tx_b(2) = Relais
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
07:
' sensor available
If Command_pointer >= 2 Then
   If Command_b(2) < 2 Then
      Sensor = Command_b(2)
      Sensor_eeram = Sensor
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
08:
' sensor available
Tx_time = 1
Tx_b(1) = &H08
Tx_b(2) = Sensor
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
09:
' temperature
If Sensor = 1 Then:
   Gosub Calc_temperature
   Tx_time = 1
   Tx_b(1) = &H09
   Tx_b(2) = High(Temperature)
   Tx_b(3) = Low(Temperature)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
Else
   Command_not_found
End If
Gosub Command_received
Return
'
10::
' calibrate
If Command_pointer >= 5 Then
   W_temp1_h = Command_b(2)
   W_temp1_l = Command_b(3)
   If W_temp1 < 40000 Then
      Correct = W_temp1
      Gosub Dds_output
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
11:
' calibrate
Tx_time = 1
Tx_b(1) = &H0B
D_temp1 = Correct
Tx_b(2) = High(Correct)
Tx_b(3) = Low(Correct)
Tx_write_pointer = 4
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
12:
' store calibrate
Gosub Calc_temperature
Temp_measure_eeram = Temperature
Correct_eeram = Correct
Gosub Command_received
Return
'
13:
' Tc measurement
If Command_pointer >= 2 Then
   If Command_b(2) < 2 Then
      If Sensor = 1 Then
         If command_b(2) = 0 Then
            Tk_measure = 0
         Else
            Tk_measure = 1
         End If
      Else
         Not_valid_at_this_time
      End If
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
14:
' Tc  measurement Temp
If Command_pointer >= 2 Then
   If Command_b(2) < 2 Then
      If Sensor = 1 Then
         Gosub Calc_temperature
         If Command_b(2) = 0 Then
            Tmin = Temperature
         Else
            Tmax = Temperature
         End If
      Else
         Not_valid_at_this_time
      End If
   Else
      Parameter_error
   End If
End If

Gosub Command_received
Return
'
15:
' Tc measurement F_at_tmin
If Command_pointer >= 5 Then
   If Sensor = 1 Then
      D_temp1_b(4) = Command_b(2)
      D_temp1_b(3) = Command_b(3)
      D_temp1_b(2) = Command_b(4)
      D_temp1_b(1) = Command_b(5)
      If D_temp1 <= F_max Then
         F_at_tmin = D_temp1
      Else
       Parameter_error
      End If
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
End If
Return
'
16:
' Tc measurement F_at_tmin
If Command_pointer >= 5 Then
   If Sensor = 1 Then
      D_temp1_b(4) = Command_b(2)
      D_temp1_b(3) = Command_b(3)
      D_temp1_b(2) = Command_b(4)
      D_temp1_b(1) = Command_b(5)
      If D_temp1 <= F_max Then
         F_at_tmax = D_temp1
      Else
         Parameter_error
      End If
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
End If
Return
'
17:
' Tc
Tx_time = 1
Tx_b(1) = &H11
Si_temp1 = Tk
Si_temp1 = Si_temp1 * 70000000
' value always < 65536
If Si_temp1 <= 0 Then
   Si_temp1 = Si_temp1 + 32768
End If
W_temp1 = Si_temp1
Tx_b(2) = High(W_temp1)
Tx_b(3) = Low(W_temp1)
Tx_write_pointer = 4
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
18:
' Rc5 adress
If Command_pointer >= 2 Then
    If Command_b(2) < 128 Then
       Rc5_adress_soll = Command_b(2)
       Rc5_adress_soll_eeram = Rc5_adress_soll
    Else
       Parameter_error
    End If
    Gosub Command_received
End If
Return
'
19:
Tx_time = 1
Tx_b(1) = &H13
Tx_b(2) = Rc5_adress_soll
Rc5_adress_soll_eeram = Rc5_adress_soll
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
20:
' Rc5 code
If Command_pointer >= 3 Then
    If Command_b(2) < 19 Then
       If Command_b(3) < 128 Then
         B_temp1 = Command_b(2)
         Rc5_code(B_temp1) = Command_b(3)
         Rc5_code_eeram(B_temp1) = Command_b(3)
       Else
         Parameter_error
       End If
    Else
       Parameter_error
    End If
    Gosub Command_received
End If
Return
'
21:
If Command_pointer >= 2 Then
   If Command_b(2) < 20 Then
   B_temp1 = Command_b(2)
      Tx_time = 1
      Tx_b(1) = &H15
      Tx_b(2) = B_temp1
      Tx_b(3) = Rc5_Code(B_temp1)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
22:
' mode
If Command_pointer >= 2 Then
   If Command_b(2) < 2 Then
      If command_b(2) = 0 Then
         Ir_mode = 0
      Else
         Ir_mode = 1
      End If
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
23:
' mode
Tx_time = 1
Tx_b(1) = &H17
Tx_b(2) = Ir_mode
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
24:
' predefined frequencies
If Command_pointer >= 2 Then
   If Command_b(2) < 19 Then
      F_code = Command_b(2)
      Gosub Predefined_f
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return