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
#IF Use_I2c = 1
Adress_eeram = I2c_address * 2
I2C_active_eeram = 1
#ENDIF
Serial_activ_eeram = 1
USB_active_eeram = 1
#IF InterfaceFU = 1
wireless_active_eram = 1
Interface_mode = 1
#ELSEIF InterfaceFU = 0
wireless_activ_eram = 0
#ENDIF
Radio_type_eram = Radiotype
Radio_name_eram = Radioname
'
$include "__reset.bas"
'
'This should be the last of reset
First_set = 5
Return