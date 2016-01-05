'name : infrarot_tx _philips_tv_2908.bas
'Version V02.1, 20160104
'most copied from infrarot tx 1.0
'purpose : Programm to send RC5 Codes to Philips TV 2908
'This Programm workes as I2C slave or serial interface
'Can be used with hardware rs232_i2c_interface Version V01.9 by DK1RI
'The Programm supports the MYC protocol
'Please modify clock frequncy and processor type, if necessary
'
'When modifying the number of commands or type of interface, please modify:
' Const No_of_announcelines =
' number of announcements in the 0 and 240 command announcements
' add lines in Sub_restore
' IC2 Adress in reset and announcements
'
'micro : ATMega88 oder grösser
'Fuse Bits :
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
$PROG &HFF,&HC6,&HDF,&HF8' generated. Take care that the chip supports all fuse bytes.
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other right are affected, this programm can be used
'under GPL (Gnu public licence)
'-----------------------------------------------------------------------
'Templates:
'DTMF Sender V02.0
'-----------------------------------------------------------------------
'Used Hardware:
' RS232
' I2C
'-----------------------------------------------------------------------
' Inputs: Reset: PinB.2 ,
' Outputs : Test LEDs D.3, D.2
' I/O : I2C , RS232
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:
' hangs sometimes at start-> power reset
'-----------------------------------------------------------------------
$regfile = "m88pdef.dat"                                    ' for ATmega8P
'$regfile = "m88def.dat"                                     ' for ATmega8
$crystal = 10000000                                         ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 64                                               ' default use 32 for the hardware stack                            ' generated. Take care that the chip supports all fuse bytes.
$swstack = 20                                               ' default use 10 for the SW stack
$framesize = 50                                             ' default use 40 for the frame space
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
Const No_of_announcelines = 47                              'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte                                  'first run after reset
Dim L As Byte                                               'Temps and local
Dim L1 As Byte
Dim L2 As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim I As Integer                                            'Blinkcounter  for tests
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
Dim Adress_eeram As Eram Byte                               'I2C Buffer
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
Dim I2C_name As Byte
Dim I2C_name_eeram As Eram Byte
'
Dim Togglebit As Byte
Dim Rc5_adress As Byte
Dim Command_mode As Byte
'
'**************** Config / Init
Config PinB.2 = Input
PortB.2 = 1
Reset__ Alias PinB.2
Config  PORTB.1 = Output
'
' Life LED:
Config Portd.2 = Output
Config Portd.3 = Output
Led3 Alias Portd.3                                          'life LED
Led4 Alias Portd.2                                        'on if cmd activ, off, when cmd finished
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
Enable Interrupts
'**************** Main ***************************************************
'
If First_set <> 5 Then
   Gosub Reset_
Else
   Dev_number = Dev_number_eeram
   Dev_name = Dev_name_eeram
   Adress = Adress_eeram
      I2C_name= I2C_name_eeram
End If
'
Gosub Init
'
If Reset__ = 0 Then Gosub Reset_
'
Slave_loop:
Start Watchdog                                              'Loop must be less than 512 ms
'
Gosub Blink_                                                'for tests
'
Gosub Cmd_watch
'
'RS232 got data?
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
   If Command_mode = 1 Then                                 'restart if i2cmode
      Command_mode = 0
      Gosub  Command_received
   End If
   If Commandpointer < Stringlength Then                    'If Buffer is full, chars are ignored !!
      Command_b(commandpointer) = A
      If Cmd_watchdog = 0 Then
         Cmd_watchdog = 1                                   ' start watchdog
         Reset Led3                                         'LED on
      End If                                                '
      Gosub Slave_commandparser
   End If
End If
'
'I2C
Twi_control = Twcr And &H80                                     'twint set?
If Twi_control = &H80 Then                                     'twsr 60 -> start, 80-> daten, A0 -> stop
   Twi_status = Twsr
   Twi_status = Twi_status And &HF8
'slave send:
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
      If I2c_pointer <= I2c_length Then
         Twdr = I2c_tx_b(i2c_pointer)
         Incr I2c_pointer
      Else
         If Announceline <= No_of_announcelines Then            'multiple lines to send
            Cmd_watchdog = 0                                   'command may take longer
            A_line = Announceline
            Gosub Sub_restore
            Incr Announceline
            Twdr = I2c_tx_b(i2c_pointer)
            Incr I2c_pointer
         Else
            Announceline = 255
            TWDR=&H00
            Set Led3
         End If                                                'for tests
      End If
   End If
'I2C receives data and and interpet as commands.
'slave receive:
   If Twi_status = &H80 Or Twi_status = &H88 Then
      If Command_mode = 0 Then                                 'restart if rs232mode
         Command_mode = 1                                      'i2c mode
         Command = String(stringlength , 0)
         Commandpointer = 1
      End If
      Tempb = Twdr
      If Commandpointer <= Stringlength Then
         Command_b(commandpointer) = Tempb
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1                                   'start watchdog
            Reset Led3                                         'LED on  for tests
         End If                                             '
         Gosub Slave_commandparser
      End If
   End If
   Twcr = &B11000100
End If
Stop Watchdog                                               '
Goto Slave_loop
'
'===========================================
'
Reset_:
First_set = 5
Dev_number = 1                                              'unsigned , set at first use                                 'obviously not yet set
Dev_number_eeram = Dev_number                               'default values
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 30
Adress_eeram = Adress
I2C_name="1"
I2C_Name_eeram = I2C_name
Return
'
Init:
Portc.3 = 1
Set Led3                                                     'for tests
Set Led4
I = 0
J = 0
Command_no = 1
Announceline = 255                                          'no multiple announcelines
I2c_tx = String(stringlength , 0)                           'will delete buffer and restart ponter
I2c_length = 0                                              'should not be 0 at any time
I2c_pointer = 1
Last_error = " No Error"
Error_no = 255                                              'No Error
Rc5_adress = 1
Togglebit = 0
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
   Gosub Command_received                                      'reset commandinput
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
'      Gosub Command_finished
   Case 3
      Last_error = ": cmd Watchdog: "
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
Blink_:                                                          'for tests
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
'I2cinit                                                       'may be not neccessary
'Config Twi = 100000                                           '100KHz
Twsr = 0                                                       'status und Prescaler auf 0
Twdr = &HFF                                                    'default
Twar = Adress                                                  'Slaveadress
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
Error_no = 255                                                 'no error
I2c_tx = String(stringlength , 0)                              'will delete buffer , read appear 0 at end ???
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
   Case 17
      Restore Announce17
   Case 18
      Restore Announce18
   Case 19
      Restore Announce19
   Case 20
      Restore Announce20
  Case 21
      Restore Announce21
   Case 22
      Restore Announce22
   Case 23
      Restore Announce23
   Case 24
      Restore Announce24
   Case 25
      Restore Announce25
   Case 26
      Restore Announce26
   Case 27
      Restore Announce27
   Case 28
      Restore Announce28
   Case 29
      Restore Announce29
   Case 30
      Restore Announce30
  Case 31
      Restore Announce31
   Case 32
      Restore Announce32
   Case 33
      Restore Announce33
   Case 34
      Restore Announce34
   Case 35
      Restore Announce35
   Case 36
      Restore Announce36
   Case 37
      Restore Announce37
   Case 38
      Restore Announce38
   Case 39
      Restore Announce39
   Case 40
      Restore Announce40
  Case 41
      Restore Announce41
   Case 42
      Restore Announce42
   Case 43
      Restore Announce43
   Case 44
      Restore Announce44
   Case 45
      Restore Announce45
   Case 46
      Restore Announce46
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
      I2c_pointer = 1                                         'complte length of string
   End If
End If
Return
'
Send_rc5:
Rc5send Togglebit , Rc5_adress , Tempb
Return
'
Slave_commandparser:
If Commandpointer > 253 Then                                   'Error, do nothing
   Gosub Command_received
Else
'
   Select Case Command_b(1)
      Case 0
'Befehl &H00            eigenes basic announcement lesen
'                       basic announcement is read to I2C or output
'Data "0;m;DK1RI;philips_tv_2908;V02.1;1;160;42;47"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl &H01            an / aus
'                       on / off
'Data "1;ou,An/Aus;0;1,An/Aus"
         Tempb = &H0C
         Gosub Send_rc5
         Gosub Command_received
'
      Case 2
'Befehl &H02            o
'                       o
'Data "2;ou,o;0;1,o"
         Tempb = &H18
         Gosub Send_rc5
         Gosub Command_received
'
      Case 3
'Befehl &H03            ||
'                       ||
'Data "3;ou,||;0;1,||"
         Tempb = &H31
         Gosub Send_rc5
         Gosub Command_received
'
      Case 4
'Befehl &H04            <<
'                       <<
'Data "4;ou,<<;0;1,<<"
         Tempb = &H1B
         Gosub Send_rc5
         Gosub Command_received
'
      Case 5
'Befehl &H05            >
'                       >
'Data "5;ou,>;0;1,>"
         Tempb = &H19
         Gosub Send_rc5
         Gosub Command_received
'
      Case 6
'Befehl &H06            >>
'                       >>
'Data "6;ou,>>;0;1,>>"
         Tempb = &H1C
         Gosub Send_rc5
         Gosub Command_received
'
      Case 7
'Befehl &H07            source
'                       source
'Data "7;ou,source;0;1,source"
         Tempb = &H38
         Gosub Send_rc5
         Gosub Command_received
'
      Case 8
'Befehl &H08            tv
'                       tv
'Data "8;ou,tv;0;1,tv"
         Tempb = &H3F
         Gosub Send_rc5
         Gosub Command_received
'
      Case 9
'Befehl &H09            format
'                       format
'Data "9;ou,format;0;1,format"
         Tempb = &H0B
         Gosub Send_rc5
         Gosub Command_received
'
      Case 10
'Befehl &H0A            home
'                       home
'Data "10;ou,home;0;1,home"
         Tempb = &H30
         Gosub Send_rc5
         Gosub Command_received
'
      Case 11
'Befehl &H0B            list
'                       list
'Data "11;ou,list;0;1,list"
         Tempb = &H26
         Gosub Send_rc5
         Gosub Command_received
'
      Case 12
'Befehl &H0C            info
'                       info
'Data "12;ou,info;0;1,info"
         Tempb = &H12
         Gosub Send_rc5
         Gosub Command_received
'
      Case 13
'Befehl &H0D            adjust
'                       adjust
'Data "13;ou,adjust;0;1,adjust"
         Tempb = &H33
         Gosub Send_rc5
         Gosub Command_received
'
      Case 14
'Befehl &H0E            options
'                       options
'Data "14;ou,options;0;1,options"
         Tempb = &H0F
         Gosub Send_rc5
         Gosub Command_received
'
      Case 15
'Befehl &H0F            auf
'                       up
'Data "15;ou,up;0;1,up"
         Tempb = &H14
         Gosub Send_rc5
         Gosub Command_received
'
      Case 16
'Befehl &H10            links
'                       left
'Data "16;ou,left;0;1,left"
         Tempb = &H15
         Gosub Send_rc5
         Gosub Command_received
'
      Case 17
'Befehl &H11            rechts
'                       right
'Data "17;ou,right;0;1,right"
         Tempb = &H16
         Gosub Send_rc5
         Gosub Command_received
'
      Case 18
'Befehl &H12            ab
'                       down
'Data "18;ou,down;0;1,down"
         Tempb = &H13
         Gosub Send_rc5
         Gosub Command_received
'
      Case 19
'Befehl &H13            zurueck
'                       back
'Data "19;ou,back;0;1,back"
         Tempb = &H0A
         Gosub Send_rc5
         Gosub Command_received
'
      Case 20
'Befehl &H14            ch-
'                       ch-
'Data "20;ou,ch-;0;1,ch-"
         Tempb = &H21
         Gosub Send_rc5
         Gosub Command_received
'
      Case 21
'Befehl &H15            ch+
'                       ch+
'Data "21;ou,ch+;0;1,ch+"
         Tempb = &H20
         Gosub Send_rc5
         Gosub Command_received
'
      Case 22
'Befehl &H16            laut-
'                       loud-
'Data "22;ou,loud-;0;1,loud-"
         Tempb = &H11
         Gosub Send_rc5
         Gosub Command_received
'
      Case 23
'Befehl &H17            Ton aus
'                       loud off
'Data "23;ou,loud off;0;1,loud off"
         Tempb = &H0D
         Gosub Send_rc5
         Gosub Command_received
'
      Case 24
'Befehl &H18            laut+
'                       loud+
'Data "24;ou,loud+;0;1,loud+"
         Tempb = &H10
         Gosub Send_rc5
         Gosub Command_received
'
      Case 25
'Befehl &H19            rot
'                       red
'Data "25;ou,red;0;1,red"
         Tempb = &H37
         Gosub Send_rc5
         Gosub Command_received
'
      Case 26
'Befehl &H1A            gruen
'                       green
'Data "26;ou,green;0;1,green"
         Tempb = &H36
         Gosub Send_rc5
         Gosub Command_received
'
      Case 27
'Befehl &H1B            gelb
'                       yellow
'Data "27;ou,yellow;0;1,yellow"
         Tempb = &H32
         Gosub Send_rc5
         Gosub Command_received
'
      Case 28
'Befehl &H1C            blau
'                       blue
'Data "28;ou,blue;0;1,blue"
         Tempb = &H34
         Gosub Send_rc5
         Gosub Command_received
'
      Case 29
'Befehl &H1D            1
'                       1
'Data "29;ou,1;0;1,1"
         Tempb = &H01
         Gosub Send_rc5
         Gosub Command_received
'
      Case 30
'Befehl &H1E            2
'                       2
'Data "30;ou,2;0;1,2"
         Tempb = &H02
         Gosub Send_rc5
         Gosub Command_received
'
      Case 31
'Befehl &H1F            3
'                       3
'Data "31;ou,3;0;1,3"
         Tempb = &H03
         Gosub Send_rc5
         Gosub Command_received
'
      Case 32
'Befehl &H20            4
'                       4
'Data "32;ou,4;0;1,4"
         Tempb = &H04
         Gosub Send_rc5
         Gosub Command_received
'
      Case 33
'Befehl &H21            5
'                       5
'Data "33;ou,5;0;1,5"
         Tempb = &H05
         Gosub Send_rc5
         Gosub Command_received
'
      Case 34
'Befehl &H22            6
'                       6
'Data "34;ou,6;0;1,6"
         Tempb = &H06
         Gosub Send_rc5
         Gosub Command_received
'
      Case 35
'Befehl &H23            7
'                       7
'Data "35;ou,7;0;1,7"
         Tempb = &H07
         Gosub Send_rc5
         Gosub Command_received
'
      Case 36
'Befehl &H24            8
'                       8
'Data "36;ou,8;0;1,8"
         Tempb = &H08
         Gosub Send_rc5
         Gosub Command_received
'
      Case 37
'Befehl &H25            9
'                       9
'Data "37;ou,9;0;1,9"
         Tempb = &H09
         Gosub Send_rc5
         Gosub Command_received
'
      case 38
'Befehl &H26            0
'                       0
'Data "38;ou,0;0;1,0"
         Tempb = &H00
         Gosub Send_rc5
         Gosub Command_received
'
      case 39
'Befehl &H27            subtitle
'                       subtitle
'Data "39;ou,0;subtitle;1,subtitle"
         Tempb = &H1F
         Gosub Send_rc5
         Gosub Command_received
'
      case 40
'Befehl &H28            text
'                       text
'Data "40;ou,0;text;1,text"
         Tempb = &H3C
         Gosub Send_rc5
         Gosub Command_received
'
      case 41
'Befehl &H29            ok
'                       ok
'Data "41;ou,0;ok;1,ok"
         Tempb = &H35
         Gosub Send_rc5
         Gosub Command_received
'
      Case 240
'Befehl &HF0 :   0-13,
'                253,254 255        announcement aller Befehle in I2C Puffer kopieren
'                                   announcement lines are read to I2C  or output
'Data "240;am,ANNOUNCEMENTS;160;47"
         If Commandpointer = 2 Then
            Select Case Command_b(2)
               Case 254
                  Announceline = 1
                  If  Command_mode = 0  Then                   'RS232 multiple announcelines
                     For A_line = 0 to No_of_announcelines - 1
                        Gosub  Sub_restore
                     Next A_line
                     Announceline = 255
                  Else
                     A_line = 0
                     Gosub Sub_restore
                  End If
               Case 255                                        'so more lines will be transmitted
                  A_line = 0
                  Gosub Sub_restore
               Case  Is < No_of_announcelines
                  A_line = Command_b(2)
                  Gosub Sub_restore
               Case Else
                  Error_no = 0
                  Gosub Last_err
            End Select
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 252
'Befehle &HF0                       Letzten Fehler in I2C Puffer kopieren oder ausgeben
'                                   read last error
'Data "252;aa,LAST ERROR;20,last_error"
         I2c_tx = String(stringlength , 0)                     'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = 1                                        'so 1st byte <> 0!!
         Temps = Str(command_no)
         I2c_length = Len(temps)
         For Tempb = 1 To I2c_length                           'leave space for length
            I2c_tx_b(tempb + 1) = Temps_b(tempb)
         Next Tempb
         Incr I2c_length                                       'because of 1 byte with length
         Tempb = Len(last_error)
         For Tempc = 1 To Tempb
            Tempd = Tempc + I2c_length                         'write at the end
            I2c_tx_b(tempd) = Last_error_b(tempc)
         Next Tempc
         I2c_length = Tempd                                    'last tempd is length
         Decr Tempd
         I2c_tx_b(1) = Tempd
         If Command_mode = 0 Then
            Print I2c_tx;
            I2c_length = 0
         End If
         Gosub Command_received
'
       Case 253
'Befehl &HFD :                      eigene activ Meldung in I2C Puffer kopieren (&H04) oder ausgeben
'                                   Life signal
'Data "253;aa,MYC INFO;b,BUSY"
         I2c_tx = String(stringlength , 0)                     'will delete buffer and restart ponter
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
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,15"
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
                  Error_no = 0
                  Gosub Last_err
            End Select
         Else
           Incr Commandpointer
         End If
'
      Case 255
'Befehl &HFF :        0 - 3         eigene Individualisierung lesen
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,15;1,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;1,USB,1"
         If Commandpointer = 2 Then
            I2c_tx = String(stringlength , 0)                  'delete buffer and restart ponter
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
                  Error_no = 0                                 'ignore anything else
                  Gosub Last_err
            End Select
            If Command_mode = 0 Then
               For Tempb = 1 To I2c_length
                  Print Chr(i2c_tx_b(tempb)) ;
               Next Tempb
               I2c_length = 0
            End If
            Gosub Command_received
         Else
               Incr Commandpointer
         End If
'
      Case Else
         Error_no = 0                                          'ignore anything else
         Gosub Last_err
      End Select
End If
Return
'
'==================================================
'
End
'announce text
'
Announce0:
'Befehl &H00            eigenes basic announcement lesen
'                       basic announcement is read to I2C or output
Data "0;m;DK1RI;philips_tv_2908;V02.1;1;160;42;47"
'
Announce1:
'Befehl &H01            an / aus
'                       on / off
Data "1;ou,An/Aus;0;1,An/Aus"
'
Announce2:
'Befehl &H02            o
'                       o
Data "2;ou,o;0;1,o"
'
Announce3:
'Befehl &H03            ||
'                       ||
Data "3;ou,||;0;1,||"
'
Announce4:
'Befehl &H04            <<
'                       <<
'Data "4;ou,<<;0;1,<<"
'
Announce5:
'Befehl &H05            >
'                       >
Data "5;ou,>;0;1,>"
'
Announce6:
'Befehl &H06            >>
'                       >>
Data "6;ou,>>;0;1,>>"
'
Announce7:
'Befehl &H07            source
'                       source
Data "7;ou,source;0;1,source"
'
Announce8:
'Befehl &H08            tv
'                       tc
Data "8;ou,tv;0;1,tv"
'
Announce9:
'Befehl &H09            format
'                       format
Data "9;ou,format;0;1,format"
'
Announce10:
'Befehl &H0A            home
'                       home
Data "10;ou,home;0;1,home"
'
Announce11:
'Befehl &H0B            list
'                       list
Data "11;ou,list;0;1,list"
'
Announce12:
'Befehl &H0C            info
'                       info
Data "12;ou,info;0;1,info"
'
Announce13:
'Befehl &H0D            adjust
'                       adjust
Data "13;ou,adjust;0;1,adjust"
'
Announce14:
'Befehl &H0E            options
'                       options
Data "14;ou,options;0;1,options"
'
Announce15:
'Befehl &H0F            up
'                       up
Data "15;ou,up;0;1,up"
'
Announce16:
'Befehl &H10            left
'                       left
Data "16;ou,left;0;1,left"
'
Announce17:
'Befehl &H11            rechts
'                       right
Data "17;ou,right;0;1,right"
'
Announce18:
'Befehl &H12            ab
'                       down
Data "18;ou,down;0;1,down"
'
Announce19:
'Befehl &H13            zurueck
'                       back
Data "19;ou,back;0;1,back"
'
Announce20:
'Befehl &H14            ch-
'                       ch-
Data "20;ou,ch-;0;1,ch-"
'
Announce21:
'Befehl &H15            ch+
'                       ch+
Data "21;ou,ch+;0;1,ch+"
'
Announce22:
'Befehl &H16            laut-
'                       loud-
Data "22;ou,loud-;0;1,loud-"
'
Announce23:
'Befehl &H17            Ton aus
'                       loud off
Data "23;ou,loud off;0;1,loud off"
'
Announce24:
'Befehl &H18            laut+
'                       loud+
Data "24;ou,loud+;0;1,loud+"
'
Announce25:
'Befehl &H19            rot
'                       red
Data "25;ou,red;0;1,red"
'
Announce26:
'Befehl &H1A            gruen
'                       green
Data "26;ou,green;0;1,green"
'
Announce27:
'Befehl &H1B            gelb
'                       yellow
Data "27;ou,yellow;0;1,yellow"
'
Announce28:
'Befehl &H1C            blau
'                       blue
Data "28;ou,blue;0;1,blue"
'
Announce29:
'Befehl &H1D            1
'                       1
Data "29;ou,1;0;1,1"
'
Announce30:
'Befehl &H1E            2
'                       2
Data "30;ou,2;0;1,2"
'
Announce31:
'Befehl &H1F            3
'                       3
Data "31;ou,3;0;1,3"
'
Announce32:
'Befehl &H20            4
'                       4
Data "32;ou,4;0;1,4"
'
Announce33:
'Befehl &H21            5
'                       5
Data "33;ou,5;0;1,5"
'
Announce34:
'Befehl &H22            6
'                       6
Data "34;ou,6;0;1,6"
'
Announce35:
'Befehl &H23            7
'                       7
Data "35;ou,7;0;1,7"
'
Announce36:
'Befehl &H24            8
'                       8
Data "36;ou,8;0;1,8"
'
Announce37:
'Befehl &H25            9
'                       9
Data "37;ou,9;0;1,9"
'
Announce38:
'Befehl &H26            0
'                       0
Data "38;ou,0;0;1,0"
'
Announce39:
'Befehl &H27            subtitle
'                       subtitle
Data "39;ou,0;subtitle;1,subtitle"
'
Announce40:'
'Befehl &H28            text
'                       text
Data "40;ou,0;text;1,text"
'
Announce41:
'Befehl &H29            ok
'                       ok
Data "41;ou,0;ok;1,ok"
'
Announce42:                                              '
'Befehl &HF0 :   0-13,
'                253,254 255        announcement aller Befehle in I2C Puffer kopieren
'                                   announcement lines are read to I2C  or output
Data "240;am,ANNOUNCEMENTS;160;47"
'
Announce43:                                                  '
'Befehle &HF0                       Letzten Fehler in I2C Puffer kopieren oder ausgeben
'                                   read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce44:
'Befehl &HFD :                      eigene activ Meldung in I2C Puffer kopieren (&H04) oder ausgeben
'                                   Life signal
Data "253;aa,MYC INFO;b,BUSY"
'
Announce45:
'Befehl &HFE :        *         eigene Individualisierung schreiben
'                               Der Devicename &HFE00 kann maximal 20 Zeichen haben
'                               Anderer Adresstyp &HFE02 kann maximal 3 Zeichen haben.
'                               wird aber ignoriert.
'
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,15"
'
Announce46:
'Befehl &HFF :        0 - 3         eigene Individualisierung lesen
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,15;1,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;1,USB,1"
'