' Constants and variables
'1.7.0, 190512
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
Const I2c_watchdog = 50
'
Const Cmd_watchdog_time = Command_watch * Tx_factor
Const Tx_timeout = Tx_watchdog * Tx_factor
'
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
Dim Serial_active_eeram As Eram Byte
'
Dim b_Temp1 As Byte
Dim b_Temp2 As Byte
Dim b_Temp3 As Byte
Dim b_Temp4 As Byte
Dim b_Temp5 As Byte
Dim b_Temp6 As Byte
Dim w_Temp1 As Word
Dim w_Temp2 As Word
Dim w_Temp3 As Word
Dim d_Temp1 As Dword
Dim d_Temp1_b(4) As Byte At d_Temp1 Overlay
Dim d_Temp2 As Dword
Dim d_Temp3 As Dword
Dim Temps As String * 20
Dim Temps_b(20) As Byte At Temps Overlay
'
Dim I As Byte
Dim J As Byte
Dim Watch_twi As Byte
'
Dim Serial_in As Byte
#If Command_is_2_byte
        Dim A_line As Byte
        Dim Number_of_lines As Byte
#Else
        Dim A_line As Word
        Dim Number_of_lines As Word
#EndIf
Dim Send_line_gaps As Byte
' Temporary Marker
' 0: idle; 1: in work; 2: F0 command; 3 : 00 command
Dim Tx As String * Tx_length
Dim Tx_b(Tx_length) As Byte At Tx Overlay
Dim Tx_pointer As Byte
Dim Tx_write_pointer As Byte
Dim Tx_busy As Byte
' 0: new commands ok
' 2. answer in progress, new command wait, until data transfer finished or timeout
Dim Command As String * Tx_length
'Command Buffer
Dim Command_b(Tx_length) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
Dim Command_mode As Byte
'
Dim Twi_status As Byte
Dim Spi_status As Byte
Dim Spcr_ As Byte
'
Dim Error_no As Byte
Dim Error_cmd_no As Byte
Dim Cmd_watchdog As Word
'Watchdog for loop
Dim Tx_time As Word
Dim No_Myc As Byte
Dim No_myc_eeram As Eram Byte