'-----------------------------------------------------------------------
'name : morse_tx_bascom.bas
'Version V03.0, 20180126
'purpose : Programm for sending MYC protocol as Morse Signals
'This Programm workes as I2C slave or can bei controlled by RS232 / USB
'Can be used with hardware rs232_i2c_interface Version V02.1 by DK1RI
'
'The Programm supports the MYC protocol
'Slave max length of I2C string is 250 Bytes.
'Please modify clock frequency and processor type, if necessary
'
'When doing modifying, please check / modify:
' Const No_of_announcelines =
' Const Aline_length (also in F0 command)
' number of announcements in the 0 and 240 command announcements
' add lines in Sub_restore
' IC2 Adress in reset and announcements
' check Const Tx_factor
'
'Fuse Bits :
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
'JTAG Disabled (if applicable)
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other right are affected, this programm can be used
'under GPL (Gnu public licence)
'-----------------------------------------------------------------------
'Templates:
'slave_core_V01.5
'-----------------------------------------------------------------------
'Used Hardware:
' RS232
' I2C
'-----------------------------------------------------------------------
' Inputs Outputs: see below
' Morseout at OCA Timer1 pin
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
$regfile = "m168def.dat"
'$regfile = "m328pdef.dat"
$crystal = 20000000
$baud = 19200
'use baud rate
$hwstack = 32
'default use 32 for the hardware stack
$swstack = 10
'default use 10 for the SW stack
$framesize = 40
'default use 40 for the frame space
'
' Simulation!!!!
' $sim
'
'**************** libs
'use byte library for smaller code
'$lib "mcsbyte.lbx"
'
'**************** Variables
Const Lf = 10
Const I2c_buff_length = 254
'that is maximum
Const Stringlength = I2c_buff_length - 4
'I2c_buff_length - command - parameter
Const Not_valid_cmd = &H80
'a non valid commandtoken
Const Cmd_watchdog_time = 200
'Number of main loop * 256  before command reset
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
Const Tx_timeout = 20
'ca 5s: 10 for 10MHZ 20 for 20 MHz
'Number of loops: 256 * 30 * Tx_timeout
'timeout, when I2c_Tx_b is cleared and new commands allowed
'
Const No_of_announcelines = 15
Const All_chars_ = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.,:;?-_()'=+/@"
Const Cystal = 20000000
'
'************************
Dim First_set As Eram Byte
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
Dim RS232_active As Byte
Dim RS232_active_eeram As Eram Byte
Dim USB_active As Byte
Dim Usb_active_eeram As Eram Byte
'
Dim L As Byte
Dim Tempa As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim Temps_b(20) As Byte At Temps Overlay
'
Dim I As Byte
Dim J As Byte

Dim A As Byte
'actual input
Dim Blw As Byte
'
Dim Announceline As Byte
'notifier for multiple announcelines
Dim A_line As Byte
' Announcline for 00 and F0 command
Dim Number_of_lines As Byte
Dim Send_lines As Byte
' Temporaray Marker
' 0: idle; 1: in work; 2: F0 command; 3 : 00 command
Dim I2c_tx As String * I2c_buff_length
Dim I2c_tx_b(I2c_buff_length) As Byte At I2c_tx Overlay
Dim I2c_pointer As Byte
Dim I2c_write_pointer As Byte
Dim I2c_tx_busy As Byte
' 0: new commands ok
' 2. answer in progress, new command wait, until data transfer finished or timeout
Dim Command As String * I2c_buff_length
'Command Buffer
Dim Command_b(I2c_buff_length) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
'
Dim Twi_status As Byte
'
Dim Error_no As Byte
Dim Error_cmd_no As Byte
Dim Cmd_watchdog As Word
'Watchdog for loop
'Watchdog for I2c sending
Dim Tx_time As Byte
Dim Command_mode As Byte
'0: I2C input 1: seriell
'
Dim Morse_mode As Byte
Dim Morse_mode_eeram As eram Byte
Dim Morse_code As Byte
Dim Morse_string As String * 10
Dim Morse_part as String * 3
Dim Morse_length As Byte
Dim Morse_index As Byte
Dim Speed As Byte
Dim Speed1 As Byte
Dim Dot As Word
Dim Dash As Word
Dim Dash_time_ms As Word
Dim Word_space As Word
Dim Number_of_loops As  Word
Dim Frequ As Byte
Dim Frequ1 As Word
Dim Period As Single
Dim Period_us As Single
Dim Number_of_loops_single As Single
Dim Dot_time_us As Single
Dim Dot_time_ms As Word
Dim Dot_number As Single
Dim Group As Byte
Dim Adder As Byte
Dim Char_num As Byte
Dim All_chars As String * 50
Dim One_char As String * 2
Dim Crystal_factor As Single
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'**************** Config / Init
Config PortB.2 = Input
PortB.2 = 1
Reset__ Alias PinB.2
Config  PORTB.1 = Output
Morse_pin Alias PortB.1
'
' Life LED:
Config Portd.2 = Output
Config Portd.3 = Output
Led3 Alias Portd.3
'life LED
Led4 Alias Portd.2
'on if cmd activ, off, when cmd finished
'
Config Watchdog = 2048
'
'****************Interrupts
'Enable Interrupts
' serialin not buffered!!
' serialout not buffered!!!
'
'**************** Main ***************************************************
'
If Reset__ = 0 Then Gosub Reset_
'
If First_set <> 5 Then Gosub Reset_
'
Gosub Init
'
Slave_loop:
Start Watchdog
'Loop must be less than 2s
'
'Blink and timeoout
Incr J
If J = 255 Then
   J = 0
   Incr I
   Select Case I
      Case 30
         If Tx_time > 0 Then
            Incr Tx_time
            If Tx_time > Tx_timeout Then
               Gosub Reset_i2c_tx
               Error_no = 6
               Error_cmd_no = Command_no
            End If
         End If
      Case 100
         Set Led4
      Case 200
         Reset Led4
      Case 255
         I = 0
         'twint set?
         If TWCR.7 = 0 Then Gosub Reset_i2c
   End Select
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong commands will be deleted
'commandbuffers is reset
   If Cmd_watchdog > 0 Then Incr Cmd_watchdog
      If Cmd_watchdog > Cmd_watchdog_time Then
      Error_no = 5
      Error_cmd_no = Command_no
      Gosub Command_received
   End If
End If
'
If Morse_mode > 1 Then
'groups of 5
'send 1 character
   Tempd = Rnd(char_num)
   Tempb = Adder + Tempd
   One_char = Mid(All_chars,Tempb,1)
   Tempd = Asc(One_char)
   Gosub Select_morse1
   Stop Watchdog
   Waitms Dash_time_ms
   Incr Group
   If Group = 6 Then
      Group = 1
      Printbin 32
      Waitms Word_space
      Waitms Word_space
   End If
   Start Watchdog
End If

'RS232 got data?
If Morse_mode = 1 Then
   Stop Watchdog
   Command = String(I2c_buff_length , 0)
   print"start"
   SERIN Command, 252, D, 0, 19200, 0, 8, 1
   print "ende"
   Start Watchdog
   If Command_b(1) = 6 And Command_b(2) < 9 Then
      'change morse_mode
      Commandpointer = 2
      Command_mode = 1
      Gosub Slave_commandparser
   Else
      'send as morse
      L = Len(command)
       For Tempc = 1 to L
         Tempd = Command_b(Tempc)
         Gosub Select_morse1
         If Tempc < Tempb Then Waitms Dash_time_ms
       Next Tempc
   End If
Else
   A = Ischarwaiting()
   If A = 1 Then
      A = Inkey()
      If Command_mode = 0 Then
         'restart if i2cmode
         Command_mode = 1
         Gosub  Command_received
      End If
      If I2c_tx_busy = 0 Then
         Command_b(Commandpointer) = A
         If RS232_active = 1 Or Usb_active = 1 Then
            Gosub Slave_commandparser
         Else
            'allow &HFE only
            If Command_b(1) <> 254 Then
               Gosub  Command_received
            Else
               Gosub Slave_commandparser
            End If
         End If
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
   End If
End If
'
'I2C
'This part should be executed as fast as possible to continue I2C:
'twint set?
If TWCR.7 = 1 Then
   'twsr 60 -> start, 80-> data, A0 -> stop
      Twi_status = TWSR And &HF8
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
      'slave send:
      'a slave send command must always be completed (or until timeout)
      'incoming commands are ignored as long as i2c_tx is not empty
      'for multi line F0 command I2c_tx may be loaded a few times if necessary.
      'multiple announcelines are loaded by line
      If I2c_write_pointer = 1 Or I2c_active = 0 Then
         'nothing to send
         Twdr = Not_valid_cmd
      Else
         If I2c_pointer < I2c_write_pointer Then
            'continue sending
            TWDR = I2c_tx_b(I2c_pointer)
            Incr I2c_pointer
            If I2c_pointer >= I2c_write_pointer Then
               If Number_of_lines > 0 Then
                  Gosub Sub_restore
               Else
                  Gosub Reset_i2c_tx
               End If
            End If
         End If
      End If
   Else
      If Twi_status = &H80 Or Twi_status = &H88 Then
         'I2C receives data and and interpret as commands.
         If I2c_tx_busy = 0 Then
            If Command_mode = 1 Then
            'restart if rs232mode
               Command_mode = 0
               'i2c mode
               Gosub  Command_received
            End If
            Command_b(Commandpointer) = TWDR
            If I2c_active = 0 And Command_b(1) <> 254 Then
               'allow &HFE only
               Gosub  Command_received
            Else
               Gosub Slave_commandparser
            End If
         Else
            Error_no = 7
            Error_cmd_no = Command_no
         End If
      End If
   End If
   Twcr = &B11000100
End If
'
Stop Watchdog                                               '
Goto Slave_loop
'
'===========================================
'
Reset_:
'This wait is necessary, because some programmers provide the chip
'with power for a short time after programming.
'This may start the reset_ sub, but stop before ending.
Wait 1
Dev_number = 1
Dev_number_eeram = Dev_number
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
'
Adress = 36
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
'
Morse_mode = 1
Morse_mode_eeram = Morse_mode
'This should be the last
First_set = 5
'set at first use
Return
'
Init:
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram
I2C_active = I2C_active_eeram
RS232_active = RS232_active_eeram
Usb_active = Usb_active_eeram
Command_no = 1
Error_cmd_no = 0
Send_lines = 0
Gosub Command_received
Gosub Reset_i2c_tx
Gosub Reset_i2c
I = 0
J = 0
Command_mode = 0
Announceline = 255
I2c_tx_busy = 0
'
Morse_mode = Morse_mode_eeram
Speed = 7
Frequ = 6
Morse_mode = Morse_mode_eeram
All_chars = All_chars_
Gosub Set_speed_frequency
Return
'
Reset_i2c:
Twsr = 0
'status und Prescaler auf 0
Twdr = Not_valid_cmd
'default
Twar = Adress
'Slaveadress
Twcr = &B01000100
Return
'
Reset_i2c_tx:
I2c_pointer = 1
I2c_write_pointer = 1
I2c_tx_busy = 0
Tx_time = 0
Return
'
Command_received:
Commandpointer = 1
Incr Command_no
If Command_no = 255 Then Command_no = 1
If Command_no = Error_cmd_no Then
   Error_cmd_no = 0
   Error_no = 255
End If
Cmd_watchdog = 0
Set Led3
Return
'
Sub_restore:
' read one line
Select Case Send_lines
   'select the start of text
   Case 1
      Tempd = 1
   Case 3
      Tempd = 2
   Case 2
      Tempd = 4
End Select
'
Select Case A_line
'
   Case 0
      Restore Announce0
   Case 1
      Restore Announce1
   Case 2
      Restore Announce2
   Case 3
      Restore Announce3
   Case 4
      Restore Announce4
   Case 5
      Restore Announce5
   Case 6
      Restore Announce6
   Case 7
      Restore Announce7
   Case 8
      Restore Announce8
   Case 9
      Restore Announce9
   Case 10
      Restore Announce10
   Case 11
      Restore Announce11
   Case 12
      Restore Announce12
   Case 13
      Restore Announce13
   Case 14
      Restore Announce14
   Case Else
         'will not happen
End Select
Read I2c_tx
Tempc = Len(I2c_tx)
For Tempb = Tempc To 1 Step - 1
   Tempa = Tempb + Tempd
   I2c_tx_b(Tempa) = I2c_tx_b(Tempb)
Next Tempb
Select Case Send_lines
   Case 1
      I2c_tx_b(1) = Tempc
      I2c_write_pointer = Tempc + 2
      'additional announcement lines
   Case 3
      'start basic announcement
      I2c_tx_b(1) = &H00
      I2c_tx_b(2) = Tempc
      I2c_write_pointer = Tempc + 3
      Send_lines = 1
   Case 2
      'start of announceline(s), send 3 byte first
      I2c_tx_b(1) = &HF0
      I2c_tx_b(2) = A_line
      I2c_tx_b(3) = Number_of_lines
      I2c_tx_b(4) = Tempc
      I2c_write_pointer = Tempc + 5
      Send_lines = 1
End Select
Incr A_line
If A_line >= No_of_announcelines Then A_line = 0
Decr Number_of_lines
'Else
'happens, for &HF=xx00
'send header only
I2c_pointer = 1
Return
'
Print_i2c_tx:
Decr  I2c_Write_pointer
For Tempb = 1 To I2c_Write_pointer
   Tempc = I2c_tx_b(Tempb)
   Printbin Tempc
Next Tempb
Gosub Reset_I2c_tx
Return
'
Select_morse1:
   'send 1 morse character
   Stop Watchdog:
   Morse_code = 255
   Tempd = Ucase(Tempd)
   Select Case Tempd
   Case 46
      Morse_code = 0    '.
   Case 44
      morse_code = 1    ',
   Case 58
      morse_code = 2    ',
   Case 59
      morse_code = 3    ';
   Case 63
      morse_code = 4    '?
   Case 45
      morse_code = 5    '-
   Case 91
      morse_code = 6    '_
   Case 40
      morse_code = 7    ' (
   Case 41
      morse_code = 8    ')
   Case 39
      morse_code = 9    ''
   Case 61
      morse_code = 10    '=
   Case 43
      morse_code = 11    '+
   Case 47
      morse_code = 12    '/
   Case 64
      morse_code = 13    '@
   Case 48 to 57
      morse_code = Tempd - 34
      '0 - 9      14 - 25
   Case  65 to 90
      morse_code = Tempd - 41
      'A-Z       24-
   Case 32
      Waitms Word_space
      'space
   End Select
   If Morse_code < 255 Then
      Printbin Tempd
      Morse_string = Lookupstr(morse_code , Morse)
      Morse_length = Len(morse_string)
      For Morse_index = 1 To Morse_length
         Morse_part = Mid(morse_string , Morse_index , 1)
         If Morse_part = "." Then
            sound Morse_pin , Dot , Number_of_loops
            ' number of waves, number of cycles for 1/2 wave (-> frequncy)
         Else
            sound Morse_pin , Dash , Number_of_loops
         End If
         If Morse_index < Morse_length Then Waitms Dot_time_ms
      Next Morse_index
      Waitms Dash_time_ms
   End If
   Start Watchdog
Return
'
Set_speed_frequency:
Speed1 = Speed + 1
'0 to 19 -> 5 to 100 Wpm
Speed1 = Speed1 * 5
Dot_time_us = 1200000 / Speed1
'in us; 1 Wpm = 50dits / min->  1 dit = 1.2 s =1200000 us
Dot_time_ms = 1200 / Speed1
'in ms:  240ms - 12ms
Dash_time_ms = Dot_time_ms * 3
Word_space = 7 * Dot_time_ms
'value for loopcouner for tonepulse width from frequency
Frequ1= Frequ + 1
'0: 100 Hz, 19: 2000Hz
'Frequ1 = Frequ1 * 100
Period = 1 / Frequ1
'length of full frequ-period (s)
'Period_us = Period * 1000000
'full period in
'loop is 4 20Mhz cycles -> 0.2us
'half Periodtime in 0.2 us: Period_us = 1000000 * (1/((Frequ +1)*100)) / 2 * 10 =50000 * 1/(Frequ+1)
Crystal_factor = Cystal / 4000
' 5000 for 20MHz
Period_us = Period * Crystal_factor
'half period time in us :5000 - 250
Number_of_loops_single = Period_us * 5
'5 0.2us cycles in a us
Number_of_loops = Number_of_loops_single
'above as word  25000 -  1250
'Number of tonepulse
Dot_number = Dot_time_us / Period_us
'number of Frequ-periods in a dot
Dot_number = Dot_number / 2
'period_us was half!!
Dot = Dot_number
'above as word  speed min: 24 -  480, Speed max: 1 - 24
Dash = 3 * Dot
Return
'
Slave_commandparser:
'checks to avoid commandbuffer overflow are within commands !!
'
'start watchdog if 0
Incr Cmd_watchdog
'
Select Case Command_b(1)
   Case 0
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
'Data "0;m;DK1RI;morse sender;V03.0;1;145;1;15;1-1"
      I2c_tx_busy = 2
      Tx_time = 1
      A_line = 0
      Number_of_lines = 1
      Send_lines = 3
      Gosub Sub_restore
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
      Case 1
'Befehl  &H01 <s>
'I2C / serial String als Morse senden
'send I2C / serial String as Morse
'Data "1;oa,send morse;250,{.,\,,:,\;,?,-,_,(,),',=,+,/,@,0 to 10,a to z, A to Z}"
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            If Commandpointer = 2 Then
               L = Command_b(Commandpointer)
               If L = 0 Then
                  Gosub command_received
               Else
                  Incr Commandpointer
                  L = Command_b(2) + 2
                  'Length
               End If
            Else
               If Commandpointer = L Then
                  'string finished
                  Tempb = Command_b(2) + 2
                  For Tempc = 3 to Tempb
                     Tempd = Command_b(Tempc)
                     Gosub Select_morse1
                     If Tempc < Tempb Then Waitms Dash_time_ms
                  Next Tempc
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            End If
         End If
'
      Case 2
'Befehl  &H02 0 to 19
'Geschwindigkeit schreiben
'write speed
'Data "2;op,write morse speed;1;20,{5 to 100};lin;Wpm"
         If Commandpointer = 2 Then
            If Command_b(2) < 20 Then
               Speed = Command_b(2)
               Gosub Set_speed_frequency
            Else
               Error_no = 4
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 3
'Befehl  &H03
'Geschwindigkeit lesen
'read speed
'Data "3;ap,as2"
         I2c_tx_busy = 2
         Tx_time = 1
         I2c_tx_b(1) = &H03
         I2c_tx_b(2) = Speed
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
         Gosub Command_received
'
      Case 4
'Befehl  &H04
'Frequenz schreiben 100 - 2000Hz
'write frequency
'Data "4;op,write morse frequency;1;20,{100 to 2000};lin;Hz"
         If Commandpointer = 2 Then
            If Command_b(2) < 20 Then
               Frequ = Command_b(2)
               Gosub Set_speed_frequency
            Else
               Error_no = 4
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 5
'Befehl  &H05
'Frequenz lesen
'read frequency
'Data "5;ap,read morse frequency,as4"
         I2c_tx_busy = 2
         Tx_time = 1
         I2c_tx_b(1) = &H05
         I2c_tx_b(2) = Frequ
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
         Gosub Command_received
'
      Case 6
'Befehl  &H06
'Mode einstellen, Myc, direkteingabe, 5er Gruppen
'set mode
'Data "6;os,set mode;1;0,myc mode;1,morse input;2,0 to 9;3,a to f;4,g to l;5,m to s;6,t to z;7,special;8,all"
         If Commandpointer = 2 Then
            If Command_b(2) < 9 Then
               Morse_mode = Command_b(2)
               Group = 1
               Select Case Morse_mode
                  Case 2 :
                     Char_num = 10
                     'figures
                     Adder = 0
                  Case 3 :
                     Char_num = 6
                     'a-f
                     Adder = 10
                  Case 4:
                     Char_num = 6
                     'g-l
                    Adder = 15
                  Case 5 :
                     Char_num = 7
                     'm-s
                     Adder = 21
                  Case 6 :
                     Char_num = 7
                     't-z
                    Adder = 28
                  Case 7 :
                     Char_num = 14
                     'special
                     Adder = 35
                  Case 8 :
                     Char_num = 50
                     'all
                     Adder = 0
                  Case Else
               End Select
            Else
               Error_no = 4
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 7
'Befehl  &H07
'Morse mode lesen
'read morse mode
'Data "7;as,as6"
         I2c_tx_busy = 2
         Tx_time = 1
         I2c_tx_b(1) = &H07
         I2c_tx_b(2) = Morse_mode
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
         Gosub Command_received
'
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
'Data "240;ln,ANNOUNCEMENTS;145;15"
      If Commandpointer >= 3 Then
         If Command_b(2) < No_of_announcelines And Command_b(3) < No_of_announcelines Then
            I2c_tx_busy = 2
            Tx_time = 1
            Send_lines = 2
            Number_of_lines = Command_b(3)
            A_line = Command_b(2)
            Gosub Sub_restore
            If Command_mode = 1 Then
               Gosub Print_i2c_tx
               While Number_of_lines > 0
                  Gosub Sub_restore
                  Gosub Print_i2c_tx
               Wend
            End If
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 252
'Befehl &HFC
'Liest letzten Fehler
'read last error
'Data 252;aa,LAST ERROR;20,last_error"
      I2c_tx_busy = 2
      Tx_time = 1
      Select Case Error_no
         Case 0
            I2c_tx = ": command not found: "
         Case 1
            I2c_tx = ": I2C error: "
         Case 3
            I2c_tx = ": Watchdog reset: "
         Case 4
            I2c_tx = ": parameter error: "
         Case 5
            I2c_tx = ": command watchdog: "
         Case 6
            I2c_tx = ": Tx timeout: "
         Case 7
            I2c_tx = ": not valid at that time: "
         Case 8
            I2c_tx = ": i2c_buffer overflow: "
         Case 255
            I2c_tx = ": No error: "
      End Select
      Tempc = Len (I2c_tx)
      For Tempb = Tempc To 1 Step - 1
         I2c_tx_b(Tempb + 5) = I2c_tx_b(Tempb)
      Next Tempb
      I2c_tx_b(1) = &HFC
      I2c_tx_b(2) = &H20
      I2c_tx_b(3) = &H20
      I2c_tx_b(4) = &H20
      I2c_tx_b(5) = &H20
      Temps = Str(Command_no)
      Tempd = Len (Temps)
      For Tempb = 1 To Tempd
         I2c_tx_b(Tempb + 2) = Temps_b(Tempb)
      Next Tempb
      I2c_write_pointer = Tempc + 6
      Temps = Str(Error_cmd_no)
      Tempd = Len (Temps)
      For Tempb = 1 To Tempd
         I2c_tx_b(I2c_write_pointer) = Temps_b(Tempb)
         Incr I2c_write_pointer
      Next Tempb
      Tempc = Tempc + 3
      I2c_tx_b(2) = Tempc + Tempd
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 253
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
'Data "253;aa,MYC INFO;b,ACTIVE"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &HFD
      I2c_tx_b(2) = 4
      'no info
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 254
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,18,{0 to 127};a,RS232,1;a,USB,1"
      If Commandpointer >= 2 Then
         Select Case Command_b(2)
            Case 0
               If Commandpointer < 3 Then
                  Incr Commandpointer
               Else
                  If Commandpointer = 3 Then
                     Incr Commandpointer
                     If Command_b(3) = 0 Then Gosub Command_received
                  Else
                     L = Command_b(3) + 3
                     If Commandpointer >= L Then
                        Dev_name = String(20 , 0)
                        If L > 23 Then L = 23
                        For Tempb = 4 To L
                           Dev_name_b(Tempb - 3) = Command_b(Tempb)
                        Next Tempb
                        Dev_name_eeram = Dev_name
                        Gosub Command_received
                     Else
                        Incr Commandpointer
                     End If
                  End If
               End If
            Case 1
               If Commandpointer = 3 Then
                  Dev_number = Command_b(3)
                  Dev_number_eeram = Dev_number
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            Case 2
               If Commandpointer < 3 Then
                  Incr Commandpointer
               Else
               'as per announcement: bit
                  If Command_b(3) < 2 Then
                     I2C_active = Command_b(3)
                     I2C_active_eeram = I2C_active
                  Else
                     Error_no = 4
                     Error_cmd_no = Command_no
                  End If
                  Gosub Command_received
               End If
            Case 3
               If Commandpointer = 3 Then
                  Tempb = Command_b(3)
                  If Tempb < 128 Then
                     Tempb = Tempb * 2
                     Adress = Tempb
                     Adress_eeram = Adress
                     Gosub Reset_i2c
                  Else
                     Error_no = 4
                     Error_cmd_no = Command_no
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            Case 4
               If Commandpointer = 3 Then
                  Tempb = Command_b(3)
                  If Tempb < 2 Then
                     Rs232_active = Tempb
                     Rs232_active_eeram = Rs232_active
                  Else
                     Error_no = 4
                     Error_cmd_no = Command_no
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            Case 5
               If Commandpointer = 3 Then
                  Tempb = Command_b(3)
                  If Tempb < 2 Then
                     Usb_active = Tempb
                     Usb_active_eeram = Usb_active
                  Else
                     Error_no = 4
                     Error_cmd_no = Command_no
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If

            Case Else
               Error_no = 4
               Error_cmd_no = Command_no
         End Select
      Else
        Incr Commandpointer
      End If
'
   Case 255
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
'Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,18,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
      If Commandpointer >= 2 Then
         I2c_tx_busy = 2
         Tx_time = 1
         If Command_b(2) < 8 Then
            I2c_tx_b(1) = &HFF
            I2c_tx_b(2) = Command_b(2)
            Select Case Command_b(2)
               Case 0
                  'Will send &HFF0000 for empty string
                  Tempc = Len(Dev_name)
                  I2c_tx_b(3) = Tempc
                  I2c_write_pointer = 4
                  Tempb = 1
                  While Tempb <= Tempc
                     I2c_tx_b(I2c_write_pointer) = Dev_name_b(tempb)
                     Incr I2c_write_pointer
                     Incr Tempb
                  Wend
               Case 1
                  I2c_tx_b(3) = Dev_number
                  I2c_write_pointer = 4
               Case 2
                  I2C_tx_b(3) = I2c_active
                  I2c_write_pointer = 4
               Case 3
                  Tempb = Adress / 2
                  I2c_tx_b(3) = Tempb
                  I2c_write_pointer = 4
               Case 4
                  I2c_tx_b(3) = Rs232_active
                  I2c_write_pointer = 4
               Case 5
                  I2c_tx_b(3) = 0
                  I2c_write_pointer = 4
               Case 6
                  I2c_tx_b(3) = 3
                  I2c_tx_b(4) = "8"
                  I2c_tx_b(5) = "N"
                  I2c_tx_b(6) = "1"
                  I2c_write_pointer = 7
               Case 7
                  I2c_tx_b(3) = Usb_active
                  I2c_write_pointer = 4
            End Select
         Else
            Error_no = 4
            Error_cmd_no = Command_no
            'ignore anything else
         End If
         If Command_mode = 1 Then Gosub Print_i2c_tx
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case Else
      Error_no = 0
      'ignore anything else
      Error_cmd_no = Command_no
      Gosub Command_received
End Select
Stop Watchdog
Return
'
'==================================================
'
End
'
Morse:
Data ".-.-.-"                                               '.     0
Data "--..--"                                               ',
Data "---..."                                               ':
Data "-.-.-."                                               ';
Data "..--.."                                               '?
Data "-....-"                                               '-
Data "..--.-"                                               '_
Data "-.--."                                                ' (
Data "-.--.-"                                               ' )
Data ".----."                                               ''
Data "-...-"                                                '=      10
Data ".-.-."                                                '+
Data "-..-."                                                '/
Data ".--.-."                                               '@
Data "-----"                                                '0      14
Data ".----"                                                '1
Data "..---"                                                '2
Data "...--"                                                '3
Data "....-"                                                '4
Data "....."                                                '5
Data "-...."                                                '6      20
Data "--..."                                                '7
Data "---.."                                                '8
Data "----."                                                '9
Data ".-"                                                   'A      24
Data "-..."                                                 'B
Data "-.-."                                                 'C
Data "-.."                                                  'D
Data "."                                                    'E
Data "..-."                                                 'F
Data "--."                                                  'G      30
Data "...."                                                 'H
Data ".."                                                   'I
Data ".---"                                                 'J
Data "-.-"                                                  'K
Data ".-.."                                                 'L
Data "--"                                                   'M
Data "-."                                                   'N
Data "---"                                                  'O
Data ".--."                                                 'P
Data "--.-"                                                 'Q      40
Data ".-."                                                  'R
Data "..."                                                  'S
Data "-"                                                    'T
Data "..-"                                                  'U
Data "...-"                                                 'V
Data ".--"                                                  'W
Data "-..-"                                                 'X
Data "-.--"                                                 'Y
Data "--.."                                                 'Z      49
'
'announce text
'
Announce0:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;morse sender;V03.0;1;145;1;15;1-1"
'
Announce1:
'Befehl  &H01 <s>
'I2C / serial String als Morse senden
'send I2C / serial String as Morse
Data "1;oa,send morse;250,{.,\,,:,\;,?,-,_,(,),',=,+,/,@,0 to 10,a to z, A to Z}"
'
Announce2:
'Befehl  &H02 0 to 19
'Geschwindigkeit schreiben
'write speed
Data "2;op,morse speed;1;20,{5 to 100};lin;Wpm"
'
Announce3:
'Befehl  &H03
'Geschwindigkeit lesen
'read speed
Data "3;ap,as2"
'
Announce4:
'Befehl  &H04
'Frequenz schreiben 100 - 2000Hz
'write frequency
Data "4;op,morse frequency;1;20,{100 to 2000};lin;Hz"
'
Announce5:
'Befehl  &H05
'Frequenz lesen
'read frequency
Data "5;ap,as4"
'
Announce6:
'Befehl  &H06
'Mode einstellen, Myc, direkteingabe, 5er Gruppen
'set mode
Data "6;os,mode;1;0,myc mode;1,morse input;2,0 to 9;3,a to f;4,g to l;5,m to s;6,t to z;7,special;8,all"
'
Announce7:
'Befehl  &H07
'Morse mode lesen
'read morse mode
Data "7;as,as6"
'
Announce8:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;ln,ANNOUNCEMENTS;145;15"
'
Announce9:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce10:                                          '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce11:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,18,{0 to 127};a,RS232,1;a,USB,1"
'
Announce12:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,18,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
Announce13:
Data "R !* IF $6&1"
'
Announce14:
Data "R &6 IF $6&1"
'