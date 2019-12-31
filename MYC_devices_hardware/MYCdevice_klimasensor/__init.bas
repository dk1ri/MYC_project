' additional init
' 191012
'
Reg_F2 = Reg_F2_eeram
Reg_F4 = Reg_F4_eeram
Reg_F5 = Reg_F5_eeram
Wait 1
'to start BM280
Gosub Start_BM280
Gosub Write_config
Gosub Read_correction