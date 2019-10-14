'-----------------------------------------------------------------------
'name : morse_sender.bas
'Version V04.0, 20191014
'Can be used with hardware i2c_rs232_interface Version V05.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,7 must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.7\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
'-----------------------------------------------------
' Inputs Outputs: see __config file
' Morseout at OCA Timer1 pin
' For announcements and rules see Data section at the end
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'
' Detailed description
'
'----------------------------------------------------
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.7\_Processor.bas"
'
'----------------------------------------------------
' 8: for 8/32pin, ATMEGAx8; 4 for 40/44pin, ATMEGAx4 packages
' used for reset now: different portnumber of SPI SS pin
Const Processor = "8"
Const Command_is_2_byte    = 0
'1...127:
Const I2c_address = 36
Const No_of_announcelines = 15
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
Const All_chars_ = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.,:;?-_()'=+/@"
Const Cystal = 20000000
Const Initial_speed = 7
Const Initial_frequency = 6
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
'----------------------------------------------------
'
' Specific Variables
Dim A As Byte
Dim L As Byte
Dim Morse_mode As Byte
Dim Morse_mode_eeram As Eram Byte
Dim Morse_code As Byte
Dim Morse_string As String * 10
Dim Morse_part as String * 3
Dim Morse_length As Byte
Dim Morse_index As Byte
Dim Speed As Byte
Dim Speed_eeram As Eram Byte
Dim Speed1 As Byte
Dim Dot As Word
Dim Dash As Word
Dim Dash_time_ms As Word
Dim Word_space As Word
Dim Number_of_loops As  Word
Dim Frequ As Byte
Dim Frequ_eeram As Eram Byte
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
Dim Morse_buffer As String * Stringlength
Dim Morse_buffer_pointer As Byte
Dim Morse_buffer_b(stringlength) As Byte At Morse_buffer Overlay
'
'----------------------------------------------------
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
Config PinB.2 = Input
Reset__ Alias PinB.2
$include "common_1.7\_Config.bas"
'
'----------------------------------------------------
'
' procedures at start
'
'
'----------------------------------------------------
$include "common_1.7\_Main.bas"
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
'
'----------------------------------------------------
'Specific actions
'
Select Case Morse_mode
   Case 1
      A = Ischarwaiting()
      If A = 1 Then
         A = Inkey()
         If Commandpointer < 2 Then
         'commandtoken?
            If A < 9 or A > 239 Then
               'is command
               Gosub Serial_command
            Else
               If A = Lf Then
                  Decr Morse_buffer_pointer
                  If Morse_buffer_pointer > 0 Then
                     For b_Temp2 = 1 to Morse_buffer_pointer
                        b_Temp3 = Morse_buffer_b(b_Temp2)
                        Gosub Send_morse_code
                        If b_Temp2 < Morse_buffer_pointer Then Waitms Dash_time_ms
                     Next b_Temp2
                     Morse_buffer_pointer = 1
                  End If
               Else
                  If Morse_buffer_pointer < Stringlength Then
                     Morse_buffer_b(Morse_buffer_pointer) = A
                     Incr Morse_buffer_pointer
                  End If
               End If
            End If
         Else
            ' is any command parameter
            Gosub Serial_command
         End If
      End If
   Case 0
      A = Ischarwaiting()
      If A = 1 Then
         A = Inkey()
         Gosub Serial_command
      End If
   Case Else
      A = Ischarwaiting()
      If A = 1 Then
         A = Inkey()
         Gosub Serial_command
      End If
      'groups of 5
      'send 1 character
      b_Temp3 = Rnd(char_num)
      b_Temp1 = Adder + b_Temp3
      One_char = Mid(All_chars,b_Temp1,1)
      b_Temp3 = Asc(One_char)
      Gosub Send_morse_code
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
End Select
'
'----------------------------------------------------
$include "common_1.7\_I2c.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.7\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.7\_Init.bas"
'
'----------------------------------------------------
$include "common_1.7\_Subs.bas"
$include "common_1.7\_Sub_reset_i2c.bas"
'
'----------------------------------------------------
'
Serial_command:
   Command_b(commandpointer) = A
   If Cmd_watchdog = 0 Then Incr Cmd_watchdog
   Command_mode = 1
   Gosub Commandparser
Return
'
Send_morse_code:
   'send 1 morse character
   Stop Watchdog:
   Morse_code = 255
   b_Temp3 = Ucase(b_Temp3)
   Select Case b_Temp3
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
      morse_code = b_Temp3 - 34
      '0 - 9      14 - 25
   Case  65 to 90
      morse_code = b_Temp3 - 41
      'A-Z       24-
   Case 32
      Waitms Word_space
      'space
   End Select
   If Morse_code < 255 Then
      Printbin b_Temp3
      Morse_string = Lookupstr(morse_code , Morse)
      Morse_length = Len(morse_string)
      For Morse_index = 1 To Morse_length
         Morse_part = Mid(morse_string , Morse_index , 1)
         If Morse_part = "." Then
            Sound Morse_pin , Dot , Number_of_loops
            ' number of waves, number of cycles for 1/2 wave (-> frequncy)
         Else
            Sound Morse_pin , Dash , Number_of_loops
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
'----------------------------------------------------
$include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
'
      Case 1
'Befehl  &H01 <s>
'I2C / serial String als Morse senden
'send I2C / serial String as Morse
'Data "1;oa,send morse;250,{.,\,,:,\;,?,-,_,(,),',=,+,/,@,0 to 10,a to z, A to Z}"
         If Commandpointer >= 2 Then
            If Command_b(2) = 0 Or Command_b(2) > 250 Then
               Gosub Command_received
            Else
               L = Command_b(2) + 2
               If Commandpointer >= L Then
                  'string finished
                  b_Temp1 = Command_b(2) + 2
                  For b_Temp2 = 3 To b_Temp1
                     b_Temp3 = Command_b(b_Temp2)
                     Gosub Send_morse_code
                     If b_Temp2 < b_Temp1 Then Waitms Dash_time_ms
                  Next b_Temp2
                  Gosub Command_received
               Else_Incr_Commandpointer
            End If
         Else_Incr_Commandpointer
'
      Case 2
'Befehl  &H02 0 to 19
'Geschwindigkeit schreiben
'write speed
'Data "2;op,write morse speed;1;20,{5 to 100};lin;Wpm"
         If Commandpointer >= 2 Then
            If Command_b(2) < 20 Then
               Speed = Command_b(2)
               Speed_eeram = Speed
               Gosub Set_speed_frequency
            Else_Parameter_error
            Gosub Command_received
         Else_Incr_Commandpointer
'
      Case 3
'Befehl  &H03
'Geschwindigkeit lesen
'read speed
'Data "3;ap,as2"
         Tx_b(1) = &H03
         Tx_b(2) = Speed
         Tx_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_tx
         Gosub Command_received
'
      Case 4
'Befehl  &H04
'Frequenz schreiben 100 - 2000Hz
'write frequency
'Data "4;op,write morse frequency;1;20,{100 to 2000};lin;Hz"
         If Commandpointer >= 2 Then
            If Command_b(2) < 20 Then
               Frequ = Command_b(2)
               Frequ_eeram = Frequ
               Gosub Set_speed_frequency
            Else_Parameter_error
            Gosub Command_received
         Else_Incr_Commandpointer
'
      Case 5
'Befehl  &H05
'Frequenz lesen
'read frequency
'Data "5;ap,read morse frequency,as4"
         Tx_b(1) = &H05
         Tx_b(2) = Frequ
         Tx_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_tx
         Gosub Command_received
'
      Case 6
'Befehl  &H06
'Mode einstellen, Myc, direkteingabe, 5er Gruppen
'set mode
'Data "6;os,set mode;1;0,myc mode;1,morse input;2,0 to 9;3,a to f;4,g to l;5,m to s;6,t to z;7,special;8,all"
         If Commandpointer >= 2 Then
            If Command_b(2) < 9 Then
               Morse_buffer_pointer = 1
               Morse_mode = Command_b(2)
               Morse_mode_eeram = Morse_mode
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
            Else_Parameter_error
            Gosub Command_received
         Else_Incr_Commandpointer
'
      Case 7
'Befehl  &H07
'Morse mode lesen
'read morse mode
'Data "7;as,as6"
         Tx_b(1) = &H07
         Tx_b(2) = Morse_mode
         Tx_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_tx
         Gosub Command_received
'
'-----------------------------------------------------
$include "common_1.7\_Command_240.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_252.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_253.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_254.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_255.bas"
'
'-----------------------------------------------------
$include "common_1.7\_End.bas"
'
' ---> Rules announcements
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
Data "0;m;DK1RI;morse sender;V04.0;1;190;1;15;1-1"
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
Data "240;ln,ANNOUNCEMENTS;190;15"
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
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,SERIAL,1"
'
Announce12:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'
Announce13:
Data "R !* IF $6&1"
'
Announce14:
Data "R &6 IF $6&1"
'