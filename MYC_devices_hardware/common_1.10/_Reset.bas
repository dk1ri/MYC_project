' Reset
' 191228
'
Reset_:
'This wait is necessary, because some programmers provide the chip
'with power for a short time after programming.
'This may start the reset_ sub, but stop before ending.
Wait 1
Dev_number_eeram = 1
Dev_name_eeram = "Device 1"
Adress_eeram = I2c_address * 2
I2C_active_eeram = 1
Serial_active_eeram = 1
'
$include "__reset.bas"
'
'This should be the last of reset
First_set = 5
'set at first use
Return