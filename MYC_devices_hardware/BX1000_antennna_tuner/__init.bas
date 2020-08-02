' additional init
' 20200725
'
Frequency_temp = 0
Cool = 0
Up_down = 0
Send_swr = 0
T1_ov = 0
' This set every relais 1 or 2 times to get a defined state:
L_value_old = 0
L_value = &H07FF
Gosub Set_l_drive
Gosub Send_data
L_value_old = &H07FF
Waitms 200
L_value = 0
Gosub Set_l_drive
Gosub Send_data
L_value_old = 0
Waitms 200
L_value = L_default
Gosub Set_l_drive
Gosub Send_data
L_value_old = L_default
Waitms 200
'
C_value_old = 0
C_value = &H0FFF
Gosub Set_C_drive
Gosub Send_data
C_value_old = &H0FFF
Waitms 200
C_value = 0
Gosub Set_C_drive
Gosub Send_data
C_value_old = 0
Waitms 200
C_value = C_default
Gosub Set_C_drive
Gosub Send_data
C_value_old = C_default
Waitms 200
'
Config_value = 4
Gosub Set_Config_drive
Gosub Send_data
Waitms 200
Config_value = 5
Gosub Set_Config_drive
Gosub Send_data
Waitms 200
Config_value = 0
Gosub Set_Config_drive
Gosub Send_data
Waitms 200
'
Relais_value = &HFF
Relais_value_old = 0
Gosub Set_relais_drive
Gosub Send_data
Relais_value = 0
Relais_value_old = &HFF
Gosub Set_relais_drive
Gosub Send_data
Relais_value = Relais_value_eram
Relais_value_old = 0
Gosub Set_relais_drive
Gosub Send_data
Relais_value_old = Relais_value
'
Frequency_temp = 14275
Frequency = 14275
Gosub Find_chanal_number_band
'
' chanalnumbers at bandedges:
Pos_start(1) = Chanal160_start
Pos_end(1) = Chanal160_start + Number_of_chanals_160
'
Pos_start(2) = Chanaln160_start
Pos_end(2) = Chanaln160_start + Number_of_chanals_n160
'
Pos_start(3) = Chanal80_start
Pos_end(3) = Chanal80_start + Number_of_chanals_80
'
Pos_start(4) = Chanaln80_start
Pos_end(4) = Chanaln80_start + Number_of_chanals_n80
'
Pos_start(5) = Chanal40_start
Pos_end(5) = Chanal40_start + Number_of_chanals_40
'
Pos_start(6) = Chanaln40_start
Pos_end(6) = Chanaln40_start + Number_of_chanals_n40
'
Pos_start(7) = Chanal30_start
Pos_end(7) = Chanal30_start + Number_of_chanals_30
'
Pos_start(8) = Chanaln30_start
Pos_end(8) = Chanaln30_start + Number_of_chanals_n30
'
Pos_start(9) = Chanal20_start
Pos_end(9) = Chanal20_start + Number_of_chanals_20
'
Pos_start(10) = Chanaln20_start
Pos_end(10) = Chanaln20_start + Number_of_chanals_n20
'
Pos_start(11) = Chanal17_start
Pos_end(11) = Chanal17_start + Number_of_chanals_17
'
Pos_start(12) = Chanaln17_start
Pos_end(12) = Chanaln17_start + Number_of_chanals_n17
'
Pos_start(13) = Chanal15_start
Pos_end(13) = Chanal15_start + Number_of_chanals_15
'
Pos_start(14) = Chanaln15_start
Pos_end(14) = Chanaln15_start + Number_of_chanals_n15
'
Pos_start(15) = Chanal12_start
Pos_end(15) = Chanal12_start + Number_of_chanals_12
'
Pos_start(16) = Chanaln12_start
Pos_end(16) = Chanaln12_start + Number_of_chanals_n12
'
Pos_start(17) = Chanal10_start
Pos_end(17) = Chanal10_start + Number_of_chanals_10
'