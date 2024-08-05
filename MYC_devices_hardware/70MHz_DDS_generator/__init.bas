' additional init
' 20240730
'
Ir_mode = Ir_mode_e
Correct = Correct_eeram
Temp_measure = Temp_measure_eram
Tk = Tk_eeram
' tk measurement / calibrarate active
Tk_measure = 0
Sensor = Sensor_eeram
With_amp = With_amp_eram
Rc5_code(1) = Rc5_code_eeram(1)
Rc5_code(2) = Rc5_code_eeram(2)
Rc5_code(3) = Rc5_code_eeram(3)
Rc5_code(4) = Rc5_code_eeram(4)
Rc5_code(5) = Rc5_code_eeram(5)
Rc5_code(6) = Rc5_code_eeram(6)
Rc5_code(7) = Rc5_code_eeram(7)
Rc5_code(8) = Rc5_code_eeram(8)
Rc5_code(9) = Rc5_code_eeram(9)
Rc5_code(10) = Rc5_code_eeram(10)
Rc5_code(11) = Rc5_code_eeram(11)
Rc5_code(12) = Rc5_code_eeram(12)
Rc5_code(13) = Rc5_code_eeram(13)
Rc5_code(14) = Rc5_code_eeram(14)
Rc5_code(15) = Rc5_code_eeram(15)
Rc5_code(16) = Rc5_code_eeram(16)
Rc5_code(17) = Rc5_code_eeram(17)
Rc5_code(18) = Rc5_code_eeram(18)
Rc5_code(19) = Rc5_code_eeram(19)
Rc5_code(20) = Rc5_code_eeram(20)
Freq(1) = Freqe(1)
Freq(2) = Freqe(2)
Freq(3) = Freqe(3)
Freq(4) = Freqe(4)
Freq(5) = Freqe(5)
Freq(6) = Freqe(6)
Freq(7) = Freqe(7)
Freq(8) = Freqe(8)
Freq(9) = Freqe(9)
Freq(10) = Freqe(10)
Freq(11) = Freqe(11)
Freq(12) = Freqe(12)
Freq(13) = Freqe(13)
Freq(14) = Freqe(14)
Freq(15) = Freqe(15)
Freq(16) = Freqe(16)
Freq(17) = Freqe(17)
Freq(18) = Freqe(18)
Freq(19) = Freqe(19)
Freq(20) = Freqe(20)
Temperature = 250
Tmin = 250
Tmax = 250
' first measurement not accurate
W_temp1 = Getadc(0)
Gosub Calc_temperature
Rcc = 0
Rc5_command = 0
Rc5_last = "       "
Rc5_adress_soll = Rc5_adress_soll_eram
Rc5_address = Rc5_adress_soll
Rel_amp_pin = Rel_amp
' 10 MHz
Freq_in =  &H00989680
Gosub Init_dds
'
B_temp1 = 0
' at start switch on in IR mode and switch as "1" (off)
If With_amp = 1 Then
   If Ir_mode = 1 Then
      B_temp1 = 1
   Else
      If Rel_amp_pin = 1 Then
         B_temp1 = 1
      End If
    End If
    Gosub Switch_relais
End If
Rc5_last = "       "
'
Enable Interrupts