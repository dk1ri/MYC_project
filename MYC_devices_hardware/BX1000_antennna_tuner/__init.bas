' additional init
' 20230905
'
Cool = 0
Ntc_value = 0
Up_down = 0
Drive_enable = 1
Analyze_frequency = 0
Frequency_pointer = 1
'default frequency in kHz
Frequency_temp = 14200
Frequency = 14200
Gosub Find_chanal_number_band
' This set every relais 1 or 2 times to get a defined state:
L_value_old = 0
L_value = &H07FF
Gosub Set_l_drive
C_value_old = &H0FFF
C_value = 0
Gosub Set_C_drive
Config_value_old = 4
Config_value = 0
Gosub Set_Config_drive
Relais_value_old = &HFF
Relais_value = 0
Gosub Set_relais_drive
Gosub Send_data
Waitms 200
'
L_value_old = &H07FF
L_value = 0
Gosub Set_l_drive
C_value_old = &H0FFF
C_value = 0
Gosub Set_C_drive
Config_value_old = 0
Config_value = 4
Gosub Set_Config_drive
Relais_value_old = 0
Relais_value = &HFF
Gosub Set_relais_drive
Gosub Send_data
Waitms 200
'
L_value_old = 0
L_value = L_pos(Chanal_number)
L_value_last = L_value
Gosub Set_l_drive
C_value_old = 0
C_value = C_pos(Chanal_number)
Gosub Set_C_drive
Config_value_old = 4
Config_value = Config_default
Last_config = Config_value
Gosub Set_Config_drive
Relais_value_old = &HFF
Relais_value = 0
Gosub Set_relais_drive
Gosub Send_data
Waitms 200
'
' chanalnumbers at bandedgesand mid:
Pos_start(1) = Chanal160_start
Pos_mid(1) = Mid_chanal_160
Pos_end(1) = Chanal160_end
'
Pos_start(2) = Chanaln160_start
Pos_mid(2) = Mid_chanal_n160
Pos_end(2) = Chanaln160_end
'
Pos_start(3) = Chanal80_start
Pos_mid(3) = Mid_chanal_80
Pos_end(3) = Chanal80_end
'
Pos_start(4) = Chanaln80_start
Pos_mid(4) = Mid_chanal_n80
Pos_end(4) = Chanaln80_end
'
Pos_start(5) = Chanal40_start
Pos_mid(5) = Mid_chanal_40
Pos_end(5) = Chanal40_end
'
Pos_start(6) = Chanaln40_start
Pos_mid(6) = Mid_chanal_n40
Pos_end(6) = Chanaln40_end
'
Pos_start(7) = Chanal30_start
Pos_mid(7) = Mid_chanal_30
Pos_end(7) = Chanal30_end
'
Pos_start(8) = Chanaln30_start
Pos_mid(8) = Mid_chanal_n30
Pos_end(8) = Chanaln30_end
'
Pos_start(9) = Chanal20_start
Pos_mid(9) = Mid_chanal_20
Pos_end(9) = Chanal20_end
'
Pos_start(10) = Chanaln20_start
Pos_mid(10) = Mid_chanal_n20
Pos_end(10) = Chanaln20_end
'
Pos_start(11) = Chanal17_start
Pos_mid(11) = Mid_chanal_17
Pos_end(11) = Chanal17_end
'
Pos_start(12) = Chanaln17_start
Pos_mid(12) = Mid_chanal_n17
Pos_end(12) = Chanaln17_end
'
Pos_start(13) = Chanal15_start
Pos_mid(13) = Mid_chanal_15
Pos_end(13) = Chanal15_end
'
Pos_start(14) = Chanaln15_start
Pos_mid(14) = Mid_chanal_n15
Pos_end(14) = Chanaln15_end
'
Pos_start(15) = Chanal12_start
Pos_mid(15) = Mid_chanal_12
Pos_end(15) = Chanal12_end
'
Pos_start(16) = Chanaln12_start
Pos_mid(16) = Mid_chanal_n12
Pos_end(16) = Chanaln12_end
'
Pos_start(17) = Chanal10_start
Pos_mid(17) = Mid_chanal_10
Pos_end(17) = Chanal10_end
'