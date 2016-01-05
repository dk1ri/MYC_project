'-----------------------------------------------------------------------
'name : morse_tx.bas
'Version V01.1, 20160104
'purpose : Programm for sending MYC protocol as DTMF Signals
'This Programm workes as I2C slave or can bei controlled by RS232 / USB
'Can be used with hardware rs232_i2c_interface Version V01.9 by DK1RI
'The Programm supports the MYC protocol
'Slave max length of  I2C string is 252 Bytes.
'Please modify clock frequncy and processor type, if necessary
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'If crystal frequency is modified, also Const Crystal_factor must be changed !!!!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'micro : ATMega168 or higher
'Fuse Bits :
'External Crystal, high frequency
'clock output enabled
'divide by 8 disabled
$PROG &HFF,&HC6,&HDF,&HF9' generated. Take care that the chip supports all fuse bytes.
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other right are affected, this programm can be used
'under GPL (Gnu public licence)
'-----------------------------------------------------------------------
'Templates:
' I2C_slave_2.0
'-----------------------------------------------------------------------
'Used Hardware:
' RS232
' I2C
'-----------------------------------------------------------------------
' Inputs: Reset: Pin B.0
' Outputs : Test LEDs D.3, D.2
' DTMFout at OCA Timer1 pin
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:
' hangs sometimes at start-> power reset
'-----------------------------------------------------------------------
'$regfile = "m88pdef.dat"                                    ' (for ATmega8P)
'$regfile = "m88def.dat"                                     ' (for ATmega8)
$regfile = "m328pdef.dat"                                   ' (for ATmega328)
$crystal = 20000000                                         ' DTMF need 10MHz max
$baud = 19200                                               ' use baud rate
$hwstack = 128                                               ' default use 32 for the hardware stack                            ' generated. Take care that the chip supports all fuse bytes.
$swstack = 30                                               ' default use 10 for the SW stack
$framesize = 60                                             ' default use 40 for the frame space
' Simulation!!!!
' $sim
'
'**************** libs
'use byte library for smaller code
'$lib "mcsbyte.lbx"
$lib "i2c_twi.lbx"
'
'**************** Variables
Const Lf = 10
Const Stringlength = 254                                    'that is maximum
Const Rs232length = 253                                     'must be smaller than Stringlength
Const Cmd_watchdog_time = 65000                             'Number of main loop before command reset
Const Blinktime = 3000
Const No_of_announcelines = 17                              'announcements start with 0
Const Cystal = 20000000
'                                                            'Crysta frequency
Dim First_set As Eram Byte                                 'first run after reset
Dim L As Byte                                               'Temps and local
Dim L1 As Byte
Dim L2 As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim I As Integer                                           'Blinkcounter  for tests
Dim J As Integer
Dim Temps_b(20) As Byte At Temps Overlay
Dim A As Byte                                               'actual input
Dim Announceline As Byte                                    'notifier for multiple announcelines
Dim A_line As Byte                                          'actual announline
Dim Dev_name As String * 20
Dim Dev_name_eeram As Eram String * 20
Dim Dev_name_b(20) As Byte At Dev_name Overlay
Dim Dev_number As Byte
Dim Dev_number_eeram As Eram Byte
Dim Adress As Byte                                          'I2C adress
Dim Adress_eeram As Eram Byte                              'I2C Buffer
Dim I2c_tx As String * Stringlength
Dim I2c_tx_b(stringlength) As Byte At I2c_tx Overlay
Dim I2c_pointer As Byte
Dim I2c_length As Byte
Dim Command As String * Stringlength                        'Command Buffer
Dim Command_b(stringlength) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
Dim Twi_status As Byte                                      'HW I2C
Dim Twi_control As Byte
Dim Last_error As String * 30                               'Error Buffer
Dim Last_error_b(30) As Byte At Last_error Overlay
Dim Error_no As Byte
Dim Cmd_watchdog As Word                                    'Watchdog notifier
'
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
Dim Command_mode As Byte                                    '0: rs232 input, 1: I2C input
Dim no_myc as byte
Dim no_myc_eeram as eram byte
Dim Btmp As Byte
Dim Number_of_loops As  Word
Dim Frequ As Byte
Dim Frequ1 As Word
Dim Period As Single
Dim Period_us As Single
Dim Number_of_loops_single As Single
Dim Dot_time_us As Single
Dim Dot_time_ms As Word
Dim Dot_number As Single
Dim Morse_mode As Byte
Dim Group As Byte
Dim Adder As Byte
Dim Char_num As Byte
Const All_chars_ = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.,:;?-_()'=+/@"
Dim All_chars As String * 50
Dim One_char As String * 2
Dim Crystal_factor As Single
Dim I2C_name As Byte
Dim I2C_name_eeram As Eram Byte
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
Led3 Alias Portd.3                                          'life LED
Led4 Alias Portd.2                                          'on if cmd activ, off, when cmd finished
'
Config Sda = Portc.4                                        'must !!, otherwise error
Config Scl = Portc.5
'
Config Watchdog = 2048
'
'Mega8 has fixed parameter, processor will hang here, if uncommented:
'Config Com1 = 19200 , Databits = 8 Parity = None , Stopbits = 1                                                '
'
'****************Interrupts
'Enable Interrupts
'Disable Pcint2
' serialin not buffered!!
' serialout not buffered!!!
'
'**************** Main ***************************************************
'
If First_set <> 5 Then
   Gosub Reset_
Else
   Dev_number = Dev_number_eeram
   Dev_name = Dev_name_eeram
   Adress = Adress_eeram
   no_myc=no_myc_eeram
   I2C_name= I2C_name_eeram
End If
'
Gosub Init
'
If Reset__ = 0 Then Gosub Reset_
'
Slave_loop:
'
Gosub Blink_                                                'for tests
'
Gosub Cmd_watch
'
'groups of 5
Group = 1
5erloop:                                                     'endless,interrupted by &H07
If Morse_mode > 0 Then
   Stop Watchdog
   A = Ischarwaiting()
   If A = 1 Then
      A = Waitkey()
      If A = 6 Then Morse_mode = 0
   End If
   If Twi_control = &H80 Then                                  'twsr 60 -> start, 80-> daten, A0 -> stop
      Twi_status = Twsr
      Twi_status = Twi_status And &HF8
      If Twi_status = &H80 Or Twi_status = &H88 Then
         Tempb = twdr
         If Tempb = 6 Then  Morse_mode = 0
         Twcr = &B11000100
      End If
   End If
   If Morse_mode > 0 Then
      Tempd = Rnd(char_num)
      Tempb = Adder + Tempd
      One_char = Mid(All_chars,Tempb,1)
      Tempd = Asc(One_char)
      Gosub Select_morse1
      Waitms Dash_time_ms
      Incr Group
      If Group = 6 Then
         Group = 1
         Waitms Word_space
         Waitms Word_space
         Printbin 32
      End If
   End If
End If
If Morse_mode > 0 Then Goto 5erloop

Start Watchdog
'
'RS232 got data?
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
   If no_myc = 1 Then
      If A = 8 Then                                         'switch to myc mode again
         no_myc=0
         no_myc_eeram = no_myc
         Gosub Command_received
      Else
         If Commandpointer = 1 Then Commandpointer =3         'first character  use commandbuffer as well
         If A = 10 Then
            Commandpointer = Commandpointer - 3
            Command_b(2) = Commandpointer
            Gosub Select_morse                                 'output morse
            Gosub Command_received
         Else
            Command_b(commandpointer) = A
            If Commandpointer < Stringlength Then Incr Commandpointer
         End If
      End If
   Else
      If Command_mode = 1 Then                              'restart if i2cmode
         Command_mode = 0
         Gosub  Command_received
      End If
      If Commandpointer < Stringlength Then                 'If Buffer is full, chars are ignored !!
         Command_b(commandpointer) = A
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1                                 ' start watchdog
            Reset Led3                                      'LED on
         End If
         Gosub Slave_commandparser
      End If
   End If
End If
'
'I2C
Twi_control = Twcr And &H80                                 'twint set?
If Twi_control = &H80 Then                                  'twsr 60 -> start, 80-> daten, A0 -> stop
   Twi_status = Twsr
   Twi_status = Twi_status And &HF8
'slave send:
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
      If I2c_pointer <= I2c_length Then
         Twdr = I2c_tx_b(i2c_pointer)
         Incr I2c_pointer
      Else
         If Announceline <= No_of_announcelines Then         'multiple lines to send
            Cmd_watchdog = 0                                 'command may take longer
            A_line = Announceline
            Gosub Sub_restore
            Incr Announceline
            Twdr = I2c_tx_b(i2c_pointer)
            Incr I2c_pointer
         Else
            Announceline = 255
            TWDR=&H00
            Set Led3
         End If                                             'for tests
      End If
   End If
'I2C receives data and and interpet as commands.
'slave receive:
   If Twi_status = &H80 Or Twi_status = &H88 Then
      If Command_mode = 0 Then                              'restart if rs232mode
         Command_mode = 1                                    'i2c mode
         Command = String(stringlength , 0)
         Commandpointer = 1
      End If
      Tempb = Twdr
      If Commandpointer <= Stringlength Then
         Command_b(commandpointer) = Tempb
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1                                 'start watchdog
            Reset Led3                                      'LED on  for tests
         End If                                             '
         Gosub Slave_commandparser
      End If
   End If
   Twcr = &B11000100
End If
Stop Watchdog
Goto Slave_loop
'
'===========================================
'
Reset_:
First_set = 5
Dev_number = 1                                               'unsigned , set at first use
Dev_number_eeram = Dev_number                                'default values
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 36
Adress_eeram = Adress
no_myc=0
no_myc_eeram = no_myc
I2C_name="1"
I2C_Name_eeram = I2C_name
Return
'
Init:
Led3 = 1
Led4  = 1
I = 0
J = 0
Command_no = 1
Announceline = 255                                           'no multiple announcelines
'Rs232_pointer = 1
I2c_tx = String(stringlength , 0)                           'will delete buffer and restart ponter
I2c_length = 0
I2c_pointer = 1
Last_error = " No Error"
Error_no = 255
Speed = 7
Frequ = 6
Morse_mode = 0
All_chars = All_chars_
Gosub Set_speed_frequency                                   'No Error
Gosub Command_received
Gosub Command_finished                                      'master will read 0 without a command
Return
'
Cmd_watch:
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong coomands will be deleted
If Cmd_watchdog > Cmd_watchdog_time Then
   Error_no = 3
   Gosub Last_err
   Gosub Command_received                                   'reset commandinput
Else
   If Cmd_watchdog <> 0 Then Incr Cmd_watchdog
End If
Return
'
Last_err:
Last_error = Str(0 , 30)
Select Case Error_no
   Case 0
      Last_error = ": command not found: "
   Case 1
      Last_error = ": I2C error: "
   Case 3
      Last_error = ": cmd Watchdog: "
   Case 4
      Last_error = ": parameter error: "
End Select
Temps = Str(command_no)
Tempb = Len(temps)
Tempc = Len(last_error)
For Tempd = 1 To Tempb
   Incr Tempc
   Insertchar Last_error , Tempc , Temps_b(tempd)
Next Tempd
Error_no = 255
Return
'
Blink_:                                                      'for tests
'Led Blinks To Show Life
J = J + 1
If J = Blinktime Then
   J = 0
   Select Case I
      Set Led4
   Case 8
      I = 0
      Reset Led4
   End Select
   Incr I
End If
Return
'
Command_finished:
'i2c reset, only after error, at start and multiple announcements
'I2cinit                                                     'may be not neccessary
'Config Twi = 100000                                         '100KHz
Twsr = 0                                                     'status und Prescaler auf 0
Twdr = &HFF                                                  'default
Twar = Adress                                                'Slaveadress
Twcr = &B01000100
Return
'
Command_received:
Commandpointer = 1
Command = String(stringlength , 0)
Cmd_watchdog = 0
Incr Command_no
If Error_no <> 3 Then Set Led3
Return
'
Sub_restore:
Error_no = 255                                               'no error
I2c_tx = String(stringlength , 0)                           'will delete buffer , read appear 0 at end ???
Select Case A_line
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
   Case 15
      Restore Announce15
   Case 16
      Restore Announce16
   Case Else
      Error_no = 0
      Gosub Last_err
End Select
If Error_no = 255 Then
   Read I2c_tx
   I2c_length = Len(i2c_tx)
   If Command_mode = 0 Then
      Printbin I2c_length
      Print I2c_tx;
   Else
      For Tempb = I2c_length To 1 Step -1                   'shift 1 pos right
         I2c_tx_b(tempb + 1) = I2c_tx_b(tempb)
      Next Tempb
      I2c_tx_b(1) = I2c_length
      Incr I2c_length
      I2c_pointer = 1                                        'complte length of string
   End If
End If
Return
'
Select_morse:
Tempb = Command_b(2) + 2
For Tempc = 3 to Tempb
   Tempd = Command_b(Tempc)
   Gosub Select_morse1
   If Tempc < Tempb Then Waitms Dash_time_ms
Next Tempc
Return
'
Select_morse1:
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
      morse_code = Tempd - 34                                '0 - 9      14 - 25
   Case  65 to 90
      morse_code = Tempd - 41                                'A-Z       24-
   Case 32
      Waitms Word_space                                       'space
   End Select
   If Morse_code < 255 Then
      Printbin Tempd
      Gosub  Send_morse
   End If
Return
'
Send_morse:
   Morse_string = Lookupstr(morse_code , Morse)
   Morse_length = Len(morse_string)
   For Morse_index = 1 To Morse_length
       Morse_part = Mid(morse_string , Morse_index , 1)
       If Morse_part = "." Then
          sound Morse_pin , Dot , Number_of_loops
       Else
         sound Morse_pin , Dash , Number_of_loops
       End If
       If Morse_index < Morse_length Then Waitms Dot_time_ms
   Next Morse_index
   Waitms Dash_time_ms
Return
'
Set_speed_frequency:
Speed1 = Speed + 1                                           '0 to 19 -> 5 to 100 Wpm
Speed1 = Speed1 * 5
Dot_time_us = 1200000 / Speed1                               'in us; 1 Wpm = 50dits / min->  1 dit = 1.2 s =1200000 us
Dot_time_ms = 1200 / Speed1                                  'in ms:  240ms - 12ms
Dash_time_ms = Dot_time_ms * 3
Word_space = 7 * Dot_time_ms
'value for loopcouner for tonepulse width from frequency
Frequ1= Frequ + 1                                            '0: 100 Hz, 19: 2000Hz
'Frequ1 = Frequ1 * 100
Period = 1 / Frequ1                                          'length of full frequ-period (s)
'Period_us = Period * 1000000                                'full period in us
                                                             'loop is 4 20Mhz cycles -> 0.2us
                                                             'half Periodtime in 0.2 us: Period_us = 1000000 * (1/((Frequ +1)*100)) / 2 * 10 =50000 * 1/(Frequ+1)
Crystal_factor = Cystal / 4000                               ' 5000 for 20MHz
Period_us = Period * Crystal_factor                          'half period time in us :5000 - 250
Number_of_loops_single = Period_us * 5                       '5 0.2us cycles in a us
Number_of_loops = Number_of_loops_single                     'above as word  25000 -  1250
'Number of tonepulse
Dot_number = Dot_time_us / Period_us                         'number of Frequ-periods in a dot
Dot_number = Dot_number / 2                                  'period_us was half!!
Dot = Dot_number                                             'above as word  speed min: 24 -  480, Speed max: 1 - 24
Dash = 3 * Dot
Return
'
Slave_commandparser:
If Commandpointer > 253 Then                                'Error, do nothing
   Gosub Command_received
Else
'
   Select Case Command_b(1)
      Case 0
'Befehl &H00            eigenes basic announcement lesen
'                       basic announcement is read to I2C or output
'Data "0;m;DK1RI;morse sender;V01.1;1;170;10;17"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl  &H01 <s>       I2C / RS232 String als Morse senden
'                       send I2C / RS232 String as Morse
'Data "1;oa,send morse;252,.\,,:\;,?,-,_,(,) ',=,+,/,@,0 to 10,a to z, A to Z"
        If Commandpointer = 2 Then
            L = Command_b(commandpointer)
            If L = 0 Then
               Gosub Command_finished
               Gosub command_received
            End If
            Incr Commandpointer
         Else
            L = Command_b(2) + 2                             'Length
            If Commandpointer = L Then                       'string finished
               Stop Watchdog
               Gosub Select_morse
               Start Watchdog
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         End If
'
      Case 2
'Befehl  &H02 0 to 19   Geschwindigkeit schreiben
'                       write speed
'Data "2;op,write morse speed;20;5 to 100;5;lin;Wpm"
         If Commandpointer = 2 Then
            If Command_b(2) < 20 Then
               Speed = Command_b(2)
               Gosub Set_speed_frequency
               Gosub Command_received
            Else
               Error_no = 4
               Gosub Last_err
            End If

         Else
            Incr Commandpointer
         End If
'
      Case 3
'Befehl  &H03           Geschwindigkeit lesen
'                       read speed
'Data "3;ap,read morse speed,as2"
         I2c_pointer = 1
         I2c_length = 1
         If Command_mode = 0 Then
            Printbin Speed
         Else
            I2c_tx = String(stringlength , 0)
            I2c_tx_b(1) = Speed
            I2c_length = 1
         End If
         Gosub Command_received
'
      Case 4
'Befehl  &H04 0 to 19   Frequenz schreiben 100 - 2000Hz
'                       write frequency
'Data "4;op,write morse frequency;20;100 to 2000;lin;Hz"
         If Commandpointer = 2 Then
            If Command_b(2) < 20 Then
               Frequ = Command_b(2)
               Gosub Set_speed_frequency
               Gosub Command_received
            Else
               Error_no = 4
               Gosub Last_err
            End If
         Else
            Incr Commandpointer
         End If
'
      Case 5
'Befehl  &H05           Frequenz lesen
'                       read frequency
'Data "5;ap,read morse frequency,as4"
         I2c_pointer = 1
         I2c_length = 1
         If Command_mode = 0 Then
            Printbin Frequ
         Else
            I2c_tx = String(stringlength , 0)
            I2c_tx_b(1) = Frequ
         End If
         Gosub Command_received
'
      Case 6
'Befehl  &H06 0 to 7    5-er Gruppen Mode einstellen
'                       set mode for groups of 5
'Data "6;os,set mode;0,morse input;1,figures;2,a-f;3,g-l;4,m-s;5,t-z;6,special;7,all"
         If Commandpointer = 2 Then
            If Command_b(2) < 8 Then
               Morse_mode = Command_b(2)
               Select Case Morse_mode
                  Case 1 :
                     Char_num = 10                            'figures
                     Adder = 0
                  Case 2 :
                     Char_num = 6                             'a-f
                     Adder = 10
                  Case 3:
                     Char_num = 6                             'g-l
                    Adder = 15
                  Case 4 :
                     Char_num = 7                             'm-s
                     Adder = 21
                  Case 5 :
                     Char_num = 7                             't-z
                    Adder = 28
                  Case 6 :
                     Char_num = 14                            'special
                     Adder = 35
                  Case 7 :
                     Char_num = 50                            'all
                     Adder = 0
                  Case Else
               End Select
               Gosub Command_received
            Else
               Error_no = 4
               Gosub Last_err
            End If
         Else
            Incr Commandpointer
         End If
'
      Case 7
'Befehl  &H07           mode lesen
'                       read mode
'Data "7;as,as6"
         I2c_pointer = 1
         I2c_length = 1
         If Command_mode = 0 Then
            Printbin Morse_mode
         Else
            I2c_tx = String(stringlength , 0)
            I2c_tx_b(1) = Morse_mode
         End If
         Gosub Command_received
'
      Case 8
'Befehl  &H08 0,1       myc_mode schreiben
'                       write myc_mode
'Data "8;os,write myc_mode;0,off;1;on"
         If Commandpointer = 2 Then
            If Command_b(2) < 2 Then
               no_myc = Command_b(2)
               no_myc_eeram = no_myc
            Else
               Error_no = 4
               Gosub Last_err
            End If
         Else
            Incr Commandpointer
         End If
'
      Case 9
'Befehl  &H09           myc_mode lesen
'                       read myc_mode
'Data "9;as,as8"
         I2c_pointer = 1
         I2c_length = 1
         If Command_mode = 0 Then
            Printbin no_myc
         Else
            I2c_tx = String(stringlength , 0)
            I2c_tx_b(1) = no_myc
            I2c_length = 1
         End If
         Gosub Command_received
'
      Case 240
'Befehl &HF0 :   0-13,
'                253,254 255        announcement aller Befehle in I2C Puffer kopieren
'                                   announcement lines are read to I2C  or output
'Data "240;am,ANNOUNCEMENTS;170;17"
         If Commandpointer = 2 Then
            Select Case Command_b(2)
               Case 254
                  Announceline = 1
                  If  Command_mode = 0  Then                 'RS232 multiple announcelines
                     For A_line = 0 to No_of_announcelines -1
                        Gosub  Sub_restore
                     Next A_line
                     Announceline = 255
                  Else
                     A_line = 0
                     Gosub Sub_restore
                  End If
               Case 255                                      'so more lines will be transmitted
                  A_line = 0
                  Gosub Sub_restore
               Case  Is < No_of_announcelines
                  A_line = Command_b(2)
                  Gosub Sub_restore
               Case Else
                  Error_no = 4
                  Gosub Last_err
            End Select
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 252
'Befehle &HFC                       Letzten Fehler in I2C Puffer kopieren oder ausgeben
'                                   read last error
'Data "252;aa,LAST ERROR;20,last_error"
         I2c_tx = String(stringlength , 0)                   'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = 1                                      'so 1st byte <> 0!!
         Temps = Str(command_no)
         I2c_length = Len(temps)
         For Tempb = 1 To I2c_length                         'leave space for length
            I2c_tx_b(tempb + 1) = Temps_b(tempb)
         Next Tempb
         Incr I2c_length                                     'because of 1 byte with length
         Tempb = Len(last_error)
         For Tempc = 1 To Tempb
             Tempd = Tempc + I2c_length                       'write at the end
             I2c_tx_b(tempd) = Last_error_b(tempc)
         Next Tempc
         I2c_length = Tempd                                   'last tempd is length
         Decr Tempd
         I2c_tx_b(1) = Tempd
         If Command_mode = 0 Then
            Print I2c_tx;
         Else
         End If
         Gosub Command_received
'
       Case 253
'Befehl &HFD :                      eigene activ Meldung in I2C Puffer kopieren (&H04) oder ausgeben
'                                   Life signal
'Data "253;aa,MYC INFO;b,BUSY"
         If Command_mode = 0 Then
            Printbin 4
         Else
            I2c_tx_b(1) = 4                                   'no info
            I2c_pointer = 1
            I2C_length = 1
         End If
         Gosub Command_received
'
      Case 254
'Befehl &HFE :        *         eigene Individualisierung schreiben
'                               Der Devicename &HFE00 kann maximal 20 Zeichen haben
'                               Anderer Adresstyp &HFE02 kann maximal 3 Zeichen haben.
'                               wird aber ignoriert.
'
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,18"
         If Commandpointer >= 2 Then
            Select Case Command_b(2)
               Case 0
                  If Commandpointer = 2 Then
                     Incr Commandpointer
                  Else
                     If Commandpointer = 3 Then
                        L = Command_b(3)
                        If L = 0 Then
                           Gosub Command_received
                        Else
                           If L > 20 Then L = 20
                           L = L + 3
                           Incr Commandpointer
                        End If
                     Else
                        If Commandpointer = L Then
                           Dev_name = String(20 , 0)
                           For Tempb = 4 To L
                              Dev_name_b(tempb -3) = Command_b(tempb)
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
                  If Commandpointer < 4 Then
                     Incr Commandpointer
                  Else                                                        'as per announcement: 1 byte string
                     I2C_name = Command_b(4)
                     i2C_name_eeram=I2C_name
                     Gosub Command_received
                  End If
               Case 3
                  If Commandpointer = 3 Then
                     Tempb = Command_b(3)
                     If Tempb < 129 Then
                        Tempb = Tempb * 2
                        Adress = Tempb
                        Adress_eeram = Adress
                     Else
                        Error_no = 4
                     Gosub Last_err
                     End If
                     Gosub Command_received
                  Else
                     Incr Commandpointer
                  End If
               Case Else
                  Error_no = 4
                  Gosub Last_err
            End Select
         Else
           Incr Commandpointer
         End If
'
      Case 255
'Befehl &HFF :        0 - 3         eigene Individualisierung lesen
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,18;1,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;1,USB,1"
         If Commandpointer = 2 Then
            I2c_tx = String(stringlength , 0)                'delete buffer and restart ponter
            I2c_pointer = 1
            Select Case Command_b(2)
               Case 0
                  I2c_length = Len(dev_name)
                  I2c_tx_b(1) = I2c_length
                  For Tempb = 1 To I2c_length
                     I2c_tx_b(tempb + 1) = Dev_name_b(tempb)
                  Next Tempb
                  Incr I2c_length
               Case 1
                  I2c_tx_b(1) = Dev_number
                  I2c_length = 1
               Case 2
                  I2C_tx="{001}"
                  I2C_tx_b(2) = I2C_name
                  I2c_length = 2
               Case 3
                  Tempb = Adress / 2
                  I2c_tx_b(1) = Tempb
                  I2c_length = 1
               Case 4
                  I2C_tx="{001}1"
                  I2c_length = 2
               Case 5
                  I2C_tx_b(1)=0
                  I2c_length = 1
               Case 6
                  I2C_tx="{003}1n8"
                  I2c_length = 4
               Case 7
                  I2C_tx="{001}1"
                  I2c_length = 2
               Case Else
                  Error_no = 4                                'ignore anything else
                  Gosub Last_err
            End Select
            If Command_mode = 0 Then
               For Tempb = 1 To I2c_length
                  Print Chr(i2c_tx_b(tempb)) ;
               Next Tempb
            End If
            Gosub Command_received
         Else
               Incr Commandpointer
         End If
'
      Case Else
         Error_no = 0                                         'ignore anything else
         Gosub Last_err
      End Select
End If
Return
'
'==================================================
'
End

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
'Befehl &H00            eigenes basic announcement lesen
'                       basic announcement is read to I2C or output
Data "0;m;DK1RI;morse sender;V01.1;1;170;10;17"
'
Announce1:
'Befehl  &H01 <s>       I2C / RS232 String als Morse senden
'                       send I2C / RS232 String as Morse
Data "1;oa,send morse;252,.\,,:\;,?,-,_,(,) ',=,+,/,@,0 to 10,a to z, A to Z"
'
Announce2:
'Befehl  &H02 0 to 19   Geschwindigkeit schreiben
'                       write speed
Data "2;op,write morse speed;20;5 to 100;5;lin;Wpm"
'
Announce3:
'Befehl  &H03           Geschwindigkeit lesen
'                       read speed
Data "3;ap,as2"
'
Announce4:
'Befehl  &H04 0 to 19   Frequenz schreiben 100 - 2000Hz
'                       write frequency
Data "4;op,write morse frequency;20;100 to 2000;lin;Hz"
'
Announce5:
'Befehl  &H05           Frequenz lesen
'                       read frequency
Data "5;ap,as4"
'
Announce6:
'Befehl  &H06 0 to7     5-er Gruppen Mode einstellen
'                       set mode for groups of 5
Data "6;os,set mode;0,morse input;1,figures;2,a-f;3,g-l;4,m-s;5,t-z;6,special;7,all"
'
Announce7:
'Befehl  &H07           mode lesen
'                       read mode
Data "7;as,as6"
'
Announce8:
'Befehl  &H08 0,1       myc_mode schreiben
'                       write myc_mode
Data "8;os,write myc_mode;0,off;1;on"
'
Announce9:
'Befehl  &H09           myc_mode lesen
'                       read myc_mode
Data "9;as,as8"
'
Announce10:
'Befehl &HF0 :   0-13,
'                253,254 255        announcement aller Befehle in I2C Puffer kopieren
'                                   announcement lines are read to I2C  or output
Data "240;am,ANNOUNCEMENTS;170;17"
'
Announce11:                                                  '
'Befehle &HFC                       Letzten Fehler in I2C Puffer kopieren oder ausgeben
'                                   read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce12:                                          '
'Befehl &HFD :                      eigene activ Meldung in I2C Puffer kopieren (&H04) oder ausgeben
'                                   Life signal
Data "253;aa,MYC INFO;b,BUSY"
'
Announce13:
'Befehl &HFE :        *         eigene Individualisierung schreiben
'                               Der Devicename &HFE00 kann maximal 20 Zeichen haben
'                               Anderer Adresstyp &HFE02 kann maximal 3 Zeichen haben.
'                               wird aber ignoriert.
'
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,18"
'
Announce14:
'Befehl &HFF :        0 - 3      eigene Individualisierung lesen
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,18;1,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;1,USB,1"
'
Announce15:                      'groups of 5 activ
Data "R $7 IF $6 > 0"
'
Announce16:
Data "R !$* IF $6 > 0"
'