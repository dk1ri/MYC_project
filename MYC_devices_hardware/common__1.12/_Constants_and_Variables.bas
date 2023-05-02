' Constants and variables
' 20201123
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
'
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
Dim Serial_active_eeram As Eram Byte
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
'
Dim I As Byte
Dim J As Byte
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
Dim Command_mode As Byte
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
Dim No_myc As Byte
Dim No_myc_eeram As Eram Byte