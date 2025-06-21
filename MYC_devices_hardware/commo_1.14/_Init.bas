' init
' 191228
'
Init:
Interface_FU = InterfaceFU
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram
I2C_active = I2C_active_eeram
Serial_activ = Serial_activ_eeram
USB_active = USB_active_eeram
wireless_active = wireless_active_eram
Gosub Check_interfaces
Command_no = 1
Error_cmd_no = 0
Send_line_gaps = 0
Radio_type = Radio_type_eram
Radio_name = Radio_name_eram
#IF Use_command_received = 1
Gosub Command_received
#ENDIF
Tx_pointer = 1
Tx_write_pointer = 1
Tx_time = 0
#IF Use_reset_i2c = 1
Gosub Reset_i2c
#ENDIF
Timeout_I = 0
Timeout_J = 0

' for wireless
B_temp1 = Radiotype
Select Case B_temp1
   Case 0
      Radio_frequency = default_f_rfm95_900
End Select
#IF InterfaceFU = 0
   Rx_started = 1
   ' this is not set by reset, set after each reboot
   ' interface
   If Mode_in = 0 Then
      ' Myc mode
      wireless_activ_eram = 1
   Else
      'transparent
     wireless_activ_eram = 1
   End If
#ENDIF
'
If Mode_in = 0 Then
   ' Myc_mode or config Mode
   Interface_mode = 0
Else
   'transparen or normal mode
   Interface_mode = 1
End If
Spi_len = 0
Send_wireless = 0
Rx_bytes = 0
Commandpointer_old = 0
wireless_serial_rx_count = 0
Radio_type = Radiotype
wireless_rx_length = 0
Wait_for_rx_ready = 0
'
$include  "__init.bas"
'
Return