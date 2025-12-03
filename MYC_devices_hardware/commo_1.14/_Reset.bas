' Reset
' 202509
'
Reset_:
'This wait is necessary, because some programmers provide the chip
'with power for a short time after programming.
'This may start the reset_ sub, but stop before ending.
Wait 1
Dev_number_eeram = 1
Dev_name_eeram = "Device 1"
Serial_active_eeram = 1
USB_active_eeram = 1
I2C_active_eeram = 0
Radio_name_eeram = Radioname_default
Radio_type_eeram = Radiotype_default
'
#IF Use_I2c = 1
   Adress_eeram = I2c_address * 2
   I2C_active_eeram = 1
#ENDIF
'
#IF Use_wireless = 1
   Select Case Radio_type_eeram
      Case 0
         Radio_frequency_eeram = Radio_frequency_default0
      Case 4
         Radio_frequency_eeram = Radio_frequency_default4
   End Select
#ENDIF
'
$include "__reset.bas"
'
'This should be the last of reset:
First_set = 5
Return