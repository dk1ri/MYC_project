' Constants and variables
' 20250603
'
Const Lf = 10
Const Tx_length = 254
'that is maximum
Const Stringlength = Tx_length - 4
'Tx_length - command - parameter
Const Not_valid_cmd = &H80
'a non valid commandtoken
'Number of main loop * 256 * 256  before reset:
Const Command_watch = 4
Const Tx_watchdog = 4
'Number of wrong status to detect for completes restart: (abt12 seconds)
Const I2c_watchdog = 5
'
Const Cmd_watchdog_time = Command_watch * Tx_factor
Const Tx_timeout = Tx_watchdog * Tx_factor
Const Updateeprom=1
'
Dim Eramdummy As Eram Byte
Dim S_temp1 As String * 21
Dim S_temp1_b(20) As Byte at S_temp1 Overlay
Dim Temps As String * S_length
Dim Temps_b(S_length) As Byte At Temps Overlay
Dim First_set As Eram Byte
Dim Blw As Byte
Dim Dev_name As String * 20
Dim Dev_name_eeram As Eram String * 20
Dim Dev_name_b(20) As Byte At Dev_name Overlay
Dim Dev_number As Byte
Dim Dev_number_eeram As Eram Byte
Dim Adress As Byte
Dim Adress_eeram As Eram Byte
'I2C adress
Dim I2C_active As Byte
Dim I2C_active_eeram As Eram Byte
Dim Serial_active As Byte
Dim Serial_activ As Byte
Dim Serial_activ_eeram As Eram Byte
Dim USB_active As Byte
Dim USB_active_eeram As Eram Byte
Dim F0elements As Byte
Dim F0stop As Byte
'
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
Dim Timeout_I As Byte
Dim Timeout_J As Byte
Dim Watch_twi As Byte
'
Dim Serial_in As Byte
#If Command_is_2_byte = 0
   Dim A_line As Byte
   Dim Number_of_lines As Byte
#Else
    Dim A_line As Word
    Dim Number_of_lines As Word
    Dim Command_token_high As Byte
    Dim Command_token_low As Byte
#EndIf
' used in command_subs: Interrupt must not change this when command sub is working:
Dim Commandpointer As Byte
' used by Interrupt routines:
Dim Command_pointer As Byte
Dim Send_line_gaps As Byte
' Temporary Marker
' 0: idle; 1: in work; 2: F0 command; 3 : 00 command
Dim Tx As String * Tx_length
Dim Tx_b(Tx_length) As Byte At Tx Overlay
Dim Tx_pointer As Byte
Dim Tx_write_pointer As Byte
' block input, if Tx_write_pointer = 1
' if not empy points to the next empty position
Dim Command As String * Tx_length
'Command Buffer
Dim Command_b(Tx_length) As Byte At Command Overlay
Dim Command_no As Byte
' At least one interface is active
Dim New_data As Byte
'
Dim Twi_status As Byte
Dim Spi_status As Byte
Dim Spcr_ As Byte
'
Dim Error_no As Byte
Dim Error_cmd_no As Byte
Dim Cmd_watchdog As Word
'Watchdog for loop
Dim Tx_time As Byte
' for Interface 0: Myc_mode; 1 (no jumper): Transparent
' for FU 0: configure; 1 Normal mode
Dim Interface_mode As Byte
Dim Interface_FU As Byte
Dim wireless_active  As Byte
Dim wireless_active_eram As Byte
'additional variables for wireless
Dim Radio_type As Byte
Dim Radio_type_eram As Eram Byte
Dim Radio_name As String * 4
Dim Radio_name_eram As Eram String * 4
Dim Radio_name_b(4) As Byte At Radio_name Overlay
' radiorype selector
Dim R_type as Byte
Dim Rx_started As Byte
Dim Register As String * 5
Dim Register_b(4) As Byte At Register Overlay
'Dim SPI_string As String * 100
'Dim Spi_string_b(200) As Byte At Spi_string Overlay
Dim Spi_len As Byte
Dim Spi_in As String * 100
Dim Spi_in_b(100) As Byte At Spi_in Overlay
Dim Send_wireless As Byte
Dim Rx_bytes As Byte
Dim Commandpointer_old As Byte
Dim wireless_serial_rx_count As Byte
Dim wireless_rx_length As Byte
Dim wireless_tx_length As Byte
Dim Wait_for_rx_ready As Byte
Dim wirelesss_tx_in_progress As Byte
Dim Radio_frequency As Dword
Dim Radio_frequency_b(4) As Byte At Radio_frequency Overlay
Dim Radio_frequency_eeram As Eram Dword
'