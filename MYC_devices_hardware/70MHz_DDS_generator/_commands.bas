' Commands
' 20240731
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
      Freq_in = Freq_in + 1
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
D_temp1 = Freq_in - 1
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
' relais
If Command_pointer >= 2 Then
   If Command_b(2) < 2 Then
      ' myc mode only
      If Ir_mode = 0 Then
         If With_amp = 1 Then
            B_temp1 = Command_b(2)
            Gosub Switch_relais
         Else
            Not_valid_at_this_time
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
04:
' relais
Tx_time = 1
Tx_b(1) = &H04
Tx_b(2) = Rel
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
05:
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
06:
' sensor available
Tx_time = 1
Tx_b(1) = &H06
Tx_b(2) = Sensor
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
07:
' temperature
If Sensor = 1 Then:
      Gosub Calc_temperature
      Tx_time = 1
      Tx_b(1) = &H07
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
08::
' calibrate
If Command_pointer >= 5 Then
   If Ir_mode = 0 Then
      'MYC mode only
      D_temp1_b(4) = Command_b(2)
      D_temp1_b(3) = Command_b(3)
      D_temp1_b(2) = Command_b(4)
      D_temp1_b(1) = Command_b(5)
      If D_temp1 <= F_max Then
         Si_temp1 = D_temp1 / Freq_in
         Si_temp1 = Si_temp1 - 1
         ' usual value: up to +-100ppm -> limit set to +-1000ppm
         If Si_temp1 > -0.001 Then
            If Si_temp1 < 0.001 Then
               Si_temp1 = Si_temp1 * -1
               Correct = 1 + Si_temp1
               Correct_eeram = Correct
               If Sensor = 1 Then
                  Temp_measure_eram = Temperature
               End If
            End If
         End If
      Else
         Parameter_error
      End If
   Else
      Command_not_found
   End If
   Gosub Command_received
End If
Return
'
09:
' calibrate  read
If Ir_mode = 0 Then
   Tx_time = 1
   Tx_b(1) = &H09
   Si_temp1 = Correct - 1
   Si_temp1 = Si_temp1 * 1000000
   ' alway s < 10000
   Si_temp1 = Si_temp1 + 1000
   W_temp1 = Si_temp1
   Tx_b(2) = High(W_temp1)
   Tx_b(3) = Low(W_temp1)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Else
      Command_not_found
   End If
Gosub Command_received
Return
'
10:
' Tc measurement
If Command_pointer >= 2 Then
   If Ir_mode = 0 Then
        If Sensor = 1 Then
            If Command_b(2) < 2 Then
               If command_b(2) = 0 Then
                  Tk_measure = 0
               Else
                  Tk_measure = 1
               End If
            Else
               Parameter_error
            End If
         Else
         Not_valid_at_this_time
      End If
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
End If
Return
'
11:
' Tc  measurement Temp
If Command_pointer >= 2 Then
   If Ir_mode = 0 Then
      If Sensor = 1 Then
         IF Tk_measure = 1 Then
            If Command_b(2) < 3 Then
               If Command_b(2) = 1 Then
                  Tmin = Temperature
               Else
                  If Command_b(2) = 3 Then
                     Tmax = Temperature
                  End If
               End If
            Else
               Parameter_error
            End If
         Else
            Not_valid_at_this_time
         End If
      Else
         Not_valid_at_this_time
      End If
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
End If
Return
'
12:
' Tc measurement F_at_tmin
If Command_pointer >= 5 Then
   If Ir_mode = 0 Then
      If Sensor = 1 Then
         If Tk_measure = 1 Then
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
      Else
         Not_valid_at_this_time
      End If
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
End If
Return
'
13:
' Tc measurement F_at_tmax
If Command_pointer >= 5 Then
   If Ir_mode = 0 Then
      If Sensor = 1 Then
         If Tk_measure = 1 Then
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
      Else
         Not_valid_at_this_time
      End If
   Else
      Not_valid_at_this_time
   End If
   Gosub Command_received
End If
Return
'
14:
' store Tk
If Ir_mode = 0 Then
   If Sensor = 1 Then
      If Tk_measure = 1 Then
        Si_temp1 = F_at_tmax - F_at_tmin
        Si_temp1 = Si_temp1 / Freq_in
        Si_temp1 = Si_temp1 - 1
        W_temp1 = Tmax - Tmin
        If W_temp1 <> 0 Then
              Si_temp1 = Si_temp1 / W_temp1
              ' usual value is < +-1ppm/K ; limit: +-2.5 ppm/K   -> 2500ppb/K
              If Si_temp1 > -0.0000025 Then
                 If Si_temp1 < 0.0000025 Then
                    '   -0.0000025 < Tk < 0.0000025
                    Si_temp1 = Si_temp1 * - 1
                    Tk = 1 + Si_temp1
                    Tk_eeram = Tk
                 End If
              End If
           Else
               Parameter_error
            End If
      Else
         Not_valid_at_this_time
      End If
   Else
         Not_valid_at_this_time
   End If
Else
      Not_valid_at_this_time
End If
Gosub Command_received
Return
'
15:
' Tk
Tx_time = 1
Tx_b(1) = &H0F
Si_temp1 = Tk - 1
Si_temp1 = Si_temp1 * 1000000000
' value always < 5000
If Si_temp1 <= 0 Then
   Si_temp1 = 2500 - Si_temp1
Else
   Si_temp1 = 2500 + Si_temp1
End If
W_temp1 = Si_temp1
Tx_b(2) = High(W_temp1)
Tx_b(3) = Low(W_temp1)
Tx_write_pointer = 4
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
16:
' read last rc5 adress and code
Tx_time = 1
Tx_b(1) = &H10
Tx_b(2) = Len(Rc5_last)
B_temp2 = 3
For B_temp1 = 1 To Len(Rc5_last)
   Tx_b(B_temp2) = Rc5_last_b(B_temp1)
   Incr B_temp2
Next B_temp1
Tx_write_pointer = len(Rc5_last)
Tx_write_pointer = Tx_write_pointer + 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
17:
' Rc5 adress
If Command_pointer >= 2 Then
     Rc5_adress_soll = Command_b(2)
     Rc5_adress_soll_eram = Rc5_adress_soll
    Gosub Command_received
End If
Return
'
18:
Tx_time = 1
Tx_b(1) = &H12
Tx_b(2) = Rc5_adress_soll
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
19:
' Rc5 code
If Command_pointer >= 3 Then
   If Command_b(2) < 20 Then
      B_temp1 = Command_b(2) + 1
      If Command_b(3) < 128 Then
         Rc5_code(B_temp1) = Command_b(3)
         Rc5_code_eeram(B_temp1) = Command_b(3)
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
End If
Return
'
20:
If Command_pointer >= 2 Then
   If Command_b(2) < 20 Then
      B_temp1 = Command_b(2) + 1
      Tx_time = 1
      Tx_b(1) = &H14
      Tx_b(2) =  Command_b(2)
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
21:
' mode
Gosub Command_received
return
If Command_pointer >= 2 Then
   If Command_b(2) < 2 Then
      Ir_mode = command_b(2)
      Ir_mode = Ir_mode_e
      If Ir_mode = 1 Then
         B_temp1 = 1
         Gosub Switch_relais
      End If
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
22:
' mode
Gosub Command_received
return
Tx_time = 1
Tx_b(1) = &H16
Tx_b(2) = Ir_mode
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'
23:
' predefined frequencies
If Command_pointer >= 2 Then
   If Command_b(2) < 20 Then
         Select Case Command_b(2):
           Case 0:
              Freq_in = Freq(1)
           Case 1:
              Freq_in = Freq(2)
           Case 2:
              Freq_in = Freq(3)
           Case 3:
              Freq_in = Freq(4)
           Case 4:
              Freq_in = Freq(5)
           Case 5:
              Freq_in = Freq(6)
           Case 6:
              Freq_in = Freq(7)
           Case 7:
              Freq_in = Freq(8)
           Case 8:
              Freq_in = Freq(9)
           Case 8:
              Freq_in = Freq(10)
           Case 10:
              Freq_in = Freq(11)
           Case 11:
              Freq_in = Freq(12)
           Case 12:
              Freq_in = Freq(13)
           Case 13:
              Freq_in = Freq(14)
           Case 14:
              Freq_in = Freq(15)
           Case 15:
              Freq_in = Freq(16)
           Case 16:
              Freq_in = Freq(17)
           Case 17:
              Freq_in = Freq(18)
           Case 18:
              Freq_in = Freq(19)
           Case 19:
              Freq_in = Freq(20)
         End Select
         Gosub Dds_output
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
24:
If Command_pointer >= 6 Then
   If Command_b(2) < 20 Then
      D_temp1_b(4) = Command_b(3)
      D_temp1_b(3) = Command_b(4)
      D_temp1_b(2) = Command_b(5)
      D_temp1_b(1) = Command_b(6)
      If D_temp1 <= F_max Then
         B_temp1 = Command_b(2) + 1
         Freq(B_temp1) = D_temp1
         Freqe(B_temp1) = D_temp1
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
25:
If Command_pointer >= 2 Then
   If Command_b(2) < 20 Then
      B_temp1 = Command_b(2) + 1
      Tx_time = 1
      D_temp1 = Freq(B_temp1)
      Tx_b(1) = &H19
      Tx_b(2) = Command_b(2)
      Tx_b(3) = D_temp1_b(4)
      Tx_b(4) = D_temp1_b(3)
      Tx_b(5) = D_temp1_b(2)
      Tx_b(6) = D_temp1_b(1)
      Tx_write_pointer = 7
      If Command_mode = 1 Then Gosub Print_tx
   Else
         Parameter_error
   End If
   Gosub Command_received
End If
Return
'
26:
If Command_pointer >= 2 Then
   If Command_b(2) < 2 Then
      If Command_b(2) = 0 Then
         With_amp = 1
         With_amp_eram = With_amp
      Else
         With_amp = 0
         With_amp_eram = With_amp
      End If
   Else
         Parameter_error
   End If
   Gosub Command_received
End If
Return
'
27:
Tx_time = 1
Tx_b(1) = &H1B
If With_amp = 0 Then
   Tx_b(2) = 1
Else
   Tx_b(2) = 0
End If
Tx_write_pointer = 3
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'