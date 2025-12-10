' Constants and variables
' 20251207
'
'that is maximum
Const Stringlength = DIO_length - 4
'Tx_length - command - parameter
Const Not_valid_cmd = &H80
'a non valid commandtoken
'Number of main loop * 256 * 256  before reset:
Const Tx_watchdog = 4
'Number of wrong status to detect for completes restart: (abt12 seconds)
Const I2c_watchdog = 5
'
Const Cmd_watchdog_time = 2
'
Dim Eramdummy As Eram Byte
Dim Temps1 As String * 255
Dim Temps1_b(255) As Byte At Temps1 Overlay
Dim Temps2 As String * 254
Dim Temps2_b(255) As Byte At Temps2 Overlay
Dim B_temp1 As Byte
Dim B_temp2 As Byte
Dim B_temp3 As Byte
Dim B_temp4 As Byte
Dim B_temp5 As Byte
Dim B_temp6 As Byte
Dim W_temp1 As Word
Dim W_temp2 As Word
Dim W_temp3 As Word
Dim W_temp1_l As Byte At W_temp1 Overlay
Dim W_temp1_h As Byte At W_temp1 + 1 Overlay
Dim W_temp2_l As Byte At W_temp2 Overlay
Dim W_temp2_h As Byte At W_temp2 + 1 Overlay
Dim W_temp3_l As Byte At W_temp3 Overlay
Dim W_temp3_h As Byte At W_temp3 + 1 Overlay
Dim D_temp1 As Dword
Dim D_temp1_b(4) As Byte At D_temp1 Overlay
Dim D_temp2 As Dword
Dim D_temp2_b(4) As Byte At D_temp2 Overlay
Dim D_temp3 As Dword
Dim D_temp3_b(4) As Byte At D_temp3 Overlay
Dim Si_temp_w0 As Single
Dim Si_temp_w1 As Single
'
Dim First_set As Eram Byte
Dim Blw As Byte
Dim Dev_name As String * 20
Dim Dev_name_eeram As Eram String * 20
Dim Dev_name_b(20) As Byte At Dev_name Overlay
Dim Dev_number As Byte
Dim Dev_number_eeram As Eram Byte
'I2C adress
Dim Adress As Byte
Dim Adress_eeram As Eram Byte
Dim I2c_activ As Byte
Dim I2C_active As Byte
Dim I2C_active_eeram As Eram Byte
Dim I2C_started As Byte
Dim Watch_twi As Byte
Dim Serial_active As Byte
Dim Serial_activ As Byte
Dim Serial_active_eeram As Eram Byte
Dim Serial_print_started As Byte
Dim Baudrate As Byte
Dim Baudrate_eeram As Eram Byte
Dim Ser_mode As String * 3
Dim Ser_mode_b(3) As Byte At Ser_mode Overlay
Dim Ser_mode_eeram As Eram String * 3
Dim USB_active As Byte
Dim USB_active_eeram As Eram Byte
Dim Radio_active As Byte
Dim Radio_active_eeram As Eram Byte
Dim Timeout_I As Byte
Dim Timeout_J As Byte
Dim Command_allowed As Byte
'
Dim A_line As Word
Dim Number_of_lines As Word
Dim Commandpointer As Word
Dim Old_commandpointer As Word
' Temporary Marker
' 0: idle; 1: in work; 2: F0 command; 3 : 00 command
Dim Tx As String * DIO_length
Dim Tx_b(DIO_length) As Byte At Tx Overlay
Dim Command As String * DIO_length
Dim Command_b(DIO_length) As Byte At Command Overlay
Dim Tx_write_pointer As Word
' if not empty points to the next empty position
Dim Tx_pointer As Word
Dim Command_no As Byte
' 0: serial, 1:USB; 2 USB/serial, 3:I2C, 4:wireless
Dim Command_origin As Byte
'
Dim Error_no As Byte
Dim Error_cmd_no As Byte
' error occured with command
Dim Cmd_error As Byte
Dim Cmd_watchdog As Word
Dim Interface_transparent_active As Byte
Dim Radio_type As Byte
Dim Radio_type_eeram As Eram Byte
Dim Radio_type_old_eram As Eram Byte
Dim Radio_name As String * 5
Dim Radio_name_eeram As Eram String * 5
Dim Radio_name_b(5) As Byte At Radio_name Overlay
Dim Spi_len As Byte
Dim Spi_IO As String * 100
Dim Spi_IO_b(100) As Byte At Spi_IO Overlay
'
#IF Use_wireless = 1
'   Dim Send_wireless As Byte
   Dim wireless_tx_length As Byte
   Dim Radio_frequency0 As Dword
   Dim Radio_frequency0_b(4) As Byte At Radio_frequency0 Overlay
   Dim Radio_frequency0_eeram As Eram Dword
   Dim Radio_frequency4 As Dword
   Dim Radio_frequency4_b(4) As Byte At Radio_frequency4 Overlay
   Dim Radio_frequency4_eeram As Eram Dword
#ENDIF
'