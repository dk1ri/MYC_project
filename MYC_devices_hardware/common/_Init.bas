' init
'1.7.0, 190512
'
Init:
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram
I2C_active = I2C_active_eeram
Serial_active = Serial_active_eeram
Command_no = 1
Error_cmd_no = 0
Send_line_gaps = 0
Command_mode = 1
Gosub Command_received
Gosub Reset_tx
Gosub Reset_i2c
I = 0
J = 0
'
$include  "__init.bas"
'
Return