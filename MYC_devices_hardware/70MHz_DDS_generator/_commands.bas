' Commands
' 20210908
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
'
03:
' switch on
If Command_pointer >= 2 Then
  If Command_b(2) < 2 Then
     If Command_b(2) = 0 Then
        Freq_in_old = Freq_in
        Freq_in = 0
     Else
        Freq_in = Freq_in_old
     End If
     Gosub Dds_output
  Else
     Parameter_error
  End If
  Gosub Command_received
End If
Return
'
04:
' switch on
Tx_time = 1
Tx_b(1) = &H04
If Freq_in = 0 Then
   Tx_b(2) = 0
Else
   Tx_b(2) = 1
End if
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
05:
' calibrate
If Command_pointer >= 4 Then
   Correct = 65536 * Command_b(2)
   W_temp1 = 256 * Command_b(3)
   Correct = Correct + W_temp1
   Correct = Correct + Command_b(4)
   Gosub Dds_output
   Gosub Command_received
End If
Return
'
06:
' calibrate
Tx_time = 1
Tx_b(1) = &H06
D_temp1 = Correct
Tx_b(2) = D_temp1_b(3)
Tx_b(3) = D_temp1_b(2)
Tx_b(4) = D_temp1_b(1)
Tx_write_pointer = 5
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
07:
' store calibrate
Gosub Calc_temperature
Temp_measure_eeram = Temperature
Correct_eeram = Correct
Gosub Command_received
Return
'
08:
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
09:
' sensor available
Tx_time = 1
Tx_b(1) = &H09
Tx_b(2) = Sensor
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
10:
' temperature
If Sensor = 1 Then:
   Tx_time = 1
   Tx_b(1) = &H0A
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
11:
' Tk
If Command_pointer >= 3 Then
   Tk = Command_b(2) * 256
   Tk = Tk + Command_b(3)
   Tk_eeram = Tk
   Gosub Command_received
End If
Return
'
12:
' Tk
Tx_time = 1
Tx_b(1) = &H0C
Tx_b(2) = High(Tk)
Tx_b(3) = Low(Tk)
Tx_write_pointer = 4
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
13:
' Rc5 code
If Command_pointer >= 3 Then
    If Command_b(2) < 20 Then
       If Command_b(3) < 128 Then
         If Command_b(2) = 0 Then
            Rc5_adress_soll = Command_b(3)
            Rc5_adress_soll_eeram = Rc5_adress_soll
         Else
            B_temp1 = Command_b(2)
            Rc5_code(B_temp1) = Command_b(3)
            Rc5_code_eeram(B_temp1) = Command_b(3)
         End If
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
14:
' Rc5 code
If Command_pointer >= 2 Then
   If Command_b(2) < 20 Then
      Tx_time = 1
      Tx_b(1) = &H0E
      Tx_b(2) = Command_b(2)
      If Command_b(2) = 0 Then
         Tx_b(3) = Rc5_adress_soll
      Else
         Tx_b(3) = Rc5_code(Command_b(2))
      End If
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
15:
Gosub Command_received
Return
':
16:
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
17:
' relais
Tx_time = 1
Tx_b(1) = &H11
Tx_b(2) = Relais
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
18:
' Tk measurement
If Command_pointer >= 2 Then
   If Command_b(2) < 2 Then
      If command_b(2) = 0 Then
         Tk_measure = 0
      Else
         Tk_measure = 1
      End If
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
Tx_b(2) = Tk_measure
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'