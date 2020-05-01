' init
' 191228
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
#IF Use_command_received = 1
Gosub Command_received
#ENDIF
Tx_pointer = 1
Tx_write_pointer = 1
Tx_time = 0
#IF Use_reset_i2c = 1
Gosub Reset_i2c
#ENDIF
I = 0
J = 0
'
$include  "__init.bas"
'
Return