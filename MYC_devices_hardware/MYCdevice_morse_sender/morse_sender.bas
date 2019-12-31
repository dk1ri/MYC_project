'-----------------------------------------------------------------------
'name : morse_sender.bas
'Version V04.1, 20191227
'Can be used with hardware i2c_rs232_interface Version V05.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,7 must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.8\_Introduction_master_copyright.bas"
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
$include "common_1.8\_Processor.bas"
'
'----------------------------------------------------
' 8: for 8/32pin, ATMEGAx8; 4 for 40/44pin, ATMEGAx4 packages
' used for reset now: different portnumber of SPI SS pin
Const Processor = "8"
Const Command_is_2_byte    = 0
'2...254:
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
$include "common_1.8\_Constants_and_variables.bas"
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
Dim Morse_read_pointer As Byte
Dim Morse_buffer_b(stringlength) As Byte At Morse_buffer Overlay
'
'----------------------------------------------------
$include "common_1.8\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.8\_Config.bas"
'
'----------------------------------------------------
'
' procedures at start
'
'----------------------------------------------------
$include "common_1.8\_Main.bas"
'
'----------------------------------------------------
$include "common_1.8\_Loop_start.bas"
'
'----------------------------------------------------
'Specific actions
'
If Morse_mode > 1 Then
   'send groups of 5
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
End If
'
If Morse_read_pointer > 0 Then
   b_Temp3 = Morse_buffer_b(Morse_read_pointer)
   Gosub Send_morse_code
   Incr Morse_read_pointer
   If Morse_read_pointer > Morse_buffer_pointer Then
      Morse_read_pointer = 0
      Morse_buffer_pointer = 0
   End If
End If
'
If New_data > 0 Then
   If Tx_write_pointer > 1 Then
      Commandpointer = 0
      Not_valid_at_this_time
   Else
      Select Case Morse_mode
         Case 1
            ' Commandpointer is >= 1
            If Command_b(1) > 9 And Command_b(1) < 239 Then
               ' find Lf
               B_temp1 = 1
               B_temp2 = Commandpointer + 1
               While B_temp1 <= B_temp2 And Command_b(B_temp1) <> Lf
                  Incr B_temp1
               Wend
               If B_temp1 < B_temp2 Then
                  ' LF found
                  For B_temp1 = 1 To Commandpointer
                     If Morse_buffer_pointer < Stringlength Then
                        Incr Morse_buffer_pointer
                        Morse_buffer_b(Morse_buffer_pointer) = Command_b(B_temp1)
                     End If
                  Next B_temp1
                  Morse_read_pointer = 1
                  Gosub Commandparser
               End If
            Else
               ' is any command parameter
               If Command_b(1) <> 254 And Serial_active = 0 And I2c_active = 0 Then
                  Commandpointer = 0
               Else
                  Gosub Commandparser
               End If
            End If
         Case Else
            If Command_b(1) <> 254 And Serial_active = 0 And I2c_active = 0 Then
               Commandpointer = 0
            Else
               Gosub Commandparser
            End If
      End Select
   End If
   New_data = 0
End If
'
If Tx_pointer > Tx_write_pointer Then
   Gosub Reset_tx
   If Number_of_lines > 0 Then Gosub Sub_restore
End If
'
Stop Watchdog                                               '
Goto Loop_
'----------------------------------------------------
' not used:
'$include "common_1.8\_Main_end.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.8\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.8\_Init.bas"
'
'----------------------------------------------------
$include "common_1.8\_Subs.bas"
'
'----------------------------------------------------
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
   $include "_Commands.bas"
'
Commandparser:
'checks to avoid commandbuffer overflow are within commands !!
#IF Command_is_2_byte = 1
   $include "common_1.8\_Commandparser.bas"
#ENDIF
'
   If Command_b(1) < &HF0 Then
      On Command_b(1) Gosub 00,01,02,03,04,05,06,07
   Else
      Select Case Command_b(1)
'
'-----------------------------------------------------
$include "common_1.8\_Command_240.bas"
'
'-----------------------------------------------------
$include "common_1.8\_Command_252.bas"
'
'-----------------------------------------------------
$include "common_1.8\_Command_253.bas"
'
'-----------------------------------------------------
$include "common_1.8\_Command_254.bas"
'
'-----------------------------------------------------
$include "common_1.8\_Command_255.bas"
'
'-----------------------------------------------------
$include "common_1.8\_End.bas"
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
Announce:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;morse sender;V04.0;1;190;1;15;1-1"
'
'Announce1:
'Befehl  &H01 <s>
'I2C / serial String als Morse senden
'send I2C / serial String as Morse
Data "1;oa,send morse;250,{.,\,,:,\;,?,-,_,(,),',=,+,/,@,0 to 10,a to z, A to Z}"
'
'Announce2:
'Befehl  &H02 0 to 19
'Geschwindigkeit schreiben
'write speed
Data "2;op,morse speed;1;20,{5 to 100};lin;Wpm"
'
'Announce3:
'Befehl  &H03
'Geschwindigkeit lesen
'read speed
Data "3;ap,as2"
'
'Announce4:
'Befehl  &H04
'Frequenz schreiben 100 - 2000Hz
'write frequency
Data "4;op,morse frequency;1;20,{100 to 2000};lin;Hz"
'
'Announce5:
'Befehl  &H05
'Frequenz lesen
'read frequency
Data "5;ap,as4"
'
'Announce6:

'Befehl  &H06
'Mode einstellen, Myc, direkteingabe, 5er Gruppen
'set mode
Data "6;os,mode;1;0,myc mode;1,morse input;2,0 to 9;3,a to f;4,g to l;5,m to s;6,t to z;7,special;8,all"
'
'Announce7:
'Befehl  &H07
'Morse mode lesen
'read morse mode
Data "7;as,as6"
'
'Announce8:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;ln,ANNOUNCEMENTS;190;15"
'
'Announce9:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
'Announce10:                                          '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
'Announce11:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,SERIAL,1"
'
'Announce12:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'
'Announce13:
Data "R !* IF $6&1"
'
'Announce14:
Data "R &6 IF $6&1"
'