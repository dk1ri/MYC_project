
' additional init
' 20210908
'
Correct = Correct_eeram
Tk = Tk_eeram
' tk measurement / calibrarate active
Tk_measure = 0
Sensor = Sensor_eeram
Temperature = 250
Tmin = 250
Tmax = 250
' first measurement not accurate
W_temp1 = Getadc(0)
Gosub Calc_temperature
Rc5_adress_soll = Rc5_adress_soll_eeram
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
Rc5_code(20) = Rc5_code_eeram(10)
Correct = Correct_default
Freq_in = F2
Freq_in_old = F1
Rc5_adress_soll= Rc5_adress_soll_eeram
Rcc = 0
Rc_command = 0
Rc_address = 0
IR_Myc_old = IR_Myc
' Myc mode
Ir_mode = 0
Gosub Init_dds
Waitms 100
F_out = 1
Gosub Dds_output
Reset Relais
'
Enable Interrupts