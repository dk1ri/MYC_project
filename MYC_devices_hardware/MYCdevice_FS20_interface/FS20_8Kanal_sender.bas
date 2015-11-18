'-----------------------------------------------------------------------
'name : Fs20_8_kanal_sender.bas
'Version V02.0, 20151117
'purpose : Programm for sending FS20 Signals
'This Programm workes as I2C slave and with RS232
'Can be used with hardware FS20_interface Version V01.2 by DK1RI
'The Programm supports the MYC protocol
'Please modify clock frequncy and processor type, if necessary
'
'When modifying the number of commands or type of interface, please modify:
' Const No_of_announcelines =
' number of announcements in the 0 and 240 command announcements
' add lines in Sub_restore
' IC2 Adress
'
'micro : ATMega88
'Fuse Bits :
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
$PROG &HFF,&HC6,&HDF,&HF9' generated. Take care that the chip supports all fuse bytes.
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other right are affected, this programm can be used
'under GPL (Gnu public licence)
'Use on own risk, there is absolute no warrenty on this program
'-----------------------------------------------------------------------
'Templates:
' DTMF_sender V02.0
'-----------------------------------------------------------------------
'Used Hardware:
' RS232
' I2C
'-----------------------------------------------------------------------
' Inputs: Reset: Pin B.0
' Outputs: PD2 - PD7, PB0, PB1
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
$regfile = "m88pdef.dat"                                    ' for ATmega8P
'$regfile = "m88def.dat"                                     ' (for ATmega8)
$crystal = 20000000                                         '
$baud = 19200                                               ' use baud rate
$hwstack = 64                                               ' default use 32 for the hardware stack                            ' generated. Take care that the chip supports all fuse bytes.
$swstack = 20                                               ' default use 10 for the SW stack
$framesize = 50                                             ' default use 40 for the frame space
'
'**************** libs
'use byte library for smaller code
'$lib "mcsbyte.lbx"
$lib "i2c_twi.lbx"
'
'**************** Variables
Const Lf = 10
Const Stringlength = 254                                    'that is maximum
Const Cmd_watchdog_time = 65000                             'Number of main loop before command reset
Const No_of_announcelines = 17                              'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte                                  'first run after reset
Dim L As Byte                                               'Temps and local
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
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
'
Dim Command_mode As Byte                                    '0: rs232 input, 1: I2C input
Dim Kanal_mode as Byte                                      '0, 4 Kanal, 1 8 Kanal
Dim Kanal_mode_eeram as Eram Byte
Dim Medium As Bit
'
'**************** Config / Init   pin of FS20-S8M Sender
Config PortB.0 = Input
PortB.0 = 1
Reset__ Alias PinB.1
Config POrtd.2 = Output           'are use as output, but temporarily only; avoid shortcut if switch is pressed
Portd.2 = 1
Port1 Alias Pind.2               '2
Config Portd.3 = Output
Portd.3 = 1
Port2 Alias Pind.3               '4
Config Portd.4 = Output
Portd.4 = 1
Port3 Alias Pind.4               '6
Config Portd.5 = Output
Portd.5 = 1
Port4 Alias Portd.5               '8
Config Portd.6 = Output
Portd.6 = 1
Port5 Alias Portd.6              '10
Config Portd.7 = Output
Portd.7 = 1
Port6 Alias Portd.7              '12
Config PortB.0 = Output
Portb.0 = 1
Port7 Alias Portb.1              '164
Config Portb.1 = Output
Portb.1 = 1
Port8 Alias Portb.1              '16
'
'
Config Sda = Portc.4                                        'must !!, otherwise error
Config Scl = Portc.5
'
Config Watchdog = 1024
'
'Mega8 has fixed parameter, processor will hang here, if uncommented:
'Config Com1 = 19200 , Databits = 8 Parity = None , Stopbits = 1                                                '
'
'****************Interrupts
'Enable Interrupts
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
   Kanal_mode = Kanal_mode_eeram
End If
'
If Reset__ = 0 Then Gosub Reset_
'
Gosub Init
'
If Kanal_mode = 0 Then
   Gosub L14
Else
   Gosub L23
End If
'
Slave_loop:
Start Watchdog                                              'Loop must be less than 512 ms (disabled , when data sent to FS20
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
      If Cmd_watchdog = 0 Then Cmd_watchdog = 1             ' start watchdog
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
         If Announceline < No_of_announcelines Then            'multiple lines to send
            Cmd_watchdog = 0                                   'command may take longer
            A_line = Announceline
            Gosub Sub_restore
            Incr Announceline
            Twdr = I2c_tx_b(i2c_pointer)
            Incr I2c_pointer
         Else
            Announceline = 255
            TWDR=&H00
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
Dev_number = 1                                                 'unsigned , set at first use                                 'obviously not yet set
Dev_number_eeram = Dev_number                                  'default values
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 24
Adress_eeram = Adress
Kanal_mode = 0
Kanal_mode_eeram = Kanal_mode
Return
'
Init:
Portc.3 = 1
Command_no = 1
Announceline = 255                                             'no multiple announcelines
'Rs232_pointer = 1
I2c_tx = String(stringlength , 0)                              'will delete buffer and restart ponter
I2c_length = 0
I2c_pointer = 1
Last_error = " No Error"
Error_no = 255                                                 'No Error
Medium = 0
Gosub Command_received
Gosub Command_finished                                         'master will read 0 without a command
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
   Case 3
      Last_error = ": cmd Watchdog: "
   Case 4
      Last_error = ": paramter error: "
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
Command_finished:
'i2c reset, only after error, at start
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
Medium = 0
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
S1:
Reset Portd.2
Waitms 110
If Medium = 1 Then Waitms 350
Set Portd.2
Return
'
S2:
Reset Portd.3
Waitms 110
If Medium = 1 Then Waitms 350
Set Portd.3
Return
'
S3:
Reset Portd.4
Waitms 110
If Medium = 1 Then Waitms 350
Set Portd.4
Return
'

S4:
Reset Portd.5
Waitms 110
If Medium = 1 Then Waitms 350
Set Portd.5
Return
'
S5:
Reset PortD.6
Waitms 110
If Medium = 1 Then Waitms 350
Set Portd.6
Return
'
S6:
Reset Portd.7
Waitms 110
If Medium = 1 Then Waitms 350
Set Portd.7
Return
'

S7:
Reset PortB.0
Waitms 110
If Medium = 1 Then Waitms 350
Set PortB.0
Return
'
S8:
Reset PortB.1
Waitms 110
If Medium = 1 Then Waitms 350
Set PortB.1
Return
'
M12:
Reset Portd.2
Reset Portd.3
Waitms 1100
Set Portd.2
Set Portd.3
Return
'
M34:
Reset Portd.4
Reset Portd.5
Waitms 1100
Set Portd.4
Set Portd.5
Return
'
M56:
Reset Portd.6
Reset Portd.7
Waitms 1100
Set Portd.6
Set Portd.7
Return
'
M78:
Reset PortB.0
Reset PortB.1
Waitms 110
Set PortB.0
Set PortB.1
Return
'
T1:
Reset Portd.2
Reset Portd.3
Waitms 1100
Set Portd.3
Waitms 200
Set Portd.2
Return
'
T2:
Reset Portd.2
Reset Portd.3
Waitms 1100
Set Portd.2
Waitms 200
Set Portd.3
Return
'
T3:
Reset Portd.4
Reset Portd.5
Waitms 1100
Set Portd.5
Waitms 200
Set Portd.4
Return
'
T4:
Reset Portd.4
Reset Portd.5
Waitms 1100
Set Portd.4
Waitms 200
Set Portd.5
Return
'
T5:
Reset Portd.6
Reset Portd.7
Waitms 1100
Set Portd.7
Waitms 200
Set Portd.6
Return
'
T6:
Reset Portd.6
Reset Portd.7
Waitms 1100
Set Portd.6
Waitms 200
Set Portd.7
Return
'
T7:
Reset PortB.0
Reset PortB.1
Waitms 1100
Set PortB.1
Waitms 200
Set PortB.0
Return
'
T8:
Reset PortB.0
Reset PortB.1
Waitms 110
Set PortB.0
Waitms 200
Set PortB.1
Return
'
L14:
Reset Portd.2
Reset Portd.5
Waitms 6100
Set Portd.2
Set Portd.5
Return
'
L23:
Reset Portd.3
Reset Portd.4
Waitms 6100
Set Portd.3
Set Portd.4
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
'Data "0;m;DK1RI;FS20 8 chanal sender;V02.0;1;170;12;19"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
     Case 1
'Befehl &H01             schaltet kanäle aus
'                        switch chanals off
'Data "1;or,Aus;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
         If Kanal_mode = 0 Then
            If Commandpointer = 2 Then
               If Command_b(2) < 4 Then
                  Stop Watchdog
                  If Command_b(2) = 0 Then Gosub S1
                  If Command_b(2) = 1 Then Gosub S3
                  If Command_b(2) = 2 Then Gosub S5
                  If command_b(2) = 3 Then Gosub S7
                  Start Watchdog
               Else
                  Error_no = 4
                  Gosub Last_err
               End If
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         Else
            Error_no = 0
            Gosub Last_err
         End If
'
      Case 2
'Befehl &H02            schaltet kanäle  ein
'                       switch chanals on
'Data "2;or,Ein;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
         If Kanal_mode = 0 Then
            If Commandpointer = 2 Then
               If Command_b(2) < 4 Then
                  Stop Watchdog
                  If Command_b(2) = 0 Then Gosub S2
                  If Command_b(2) = 1 Then Gosub S4
                  If Command_b(2) = 2 Then Gosub S6
                  If command_b(2) = 3 Then Gosub S8
                  Start Watchdog
               Else
                  Error_no = 4
                  Gosub Last_err
               End If
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         Else
            Error_no = 0
            Gosub Last_err
         End If
'
      Case 3
'Befehl &H03             schaltet kanäle an / aus
'                        switch chanals on / off
'Data "3;or,Ein/Aus;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
         If Kanal_mode = 1 Then
            If Commandpointer = 2 Then
               If Command_b(2) < 8 Then
                  Stop Watchdog
                  If Command_b(2) = 0 Then Gosub S1
                  If Command_b(2) = 1 Then Gosub S2
                  If Command_b(2) = 2 Then Gosub S3
                  If command_b(2) = 3 Then Gosub S4
                  If Command_b(2) = 4 Then Gosub S5
                  If Command_b(2) = 5 Then Gosub S6
                  If Command_b(2) = 6 Then Gosub S7
                  If command_b(2) = 7 Then Gosub S8
                  Start Watchdog

               Else
                  Error_no = 4
                  Gosub Last_err
               End If
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         Else
            Error_no = 0
            Gosub Last_err
         End If
'

      Case 4
'Befehl &H04             dimmt kanäle ab
'                        dim chanals down
'Data "1;or,dimmt ab;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
         If Kanal_mode = 0 Then
            If Commandpointer = 2 Then
               If Command_b(2) < 4 Then
                  Stop Watchdog
                  Medium = 1
                  If Command_b(2) = 0 Then Gosub S1
                  If Command_b(2) = 1 Then Gosub S3
                  If Command_b(2) = 2 Then Gosub S5
                  If command_b(2) = 3 Then Gosub S7
                  Start Watchdog
               Else
                  Error_no = 4
                  Gosub Last_err
               End If
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         Else
            Error_no = 0
            Gosub Last_err
         End If
'
      Case 5
'Befehl &H05            dimmt kanäle  auf
'                       dims chanals up
'Data "5;or,dimmt auf;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
         If Kanal_mode = 0 Then
            If Commandpointer = 2 Then
               If Command_b(2) < 4 Then
                  Stop Watchdog
                  Medium = 1
                  If Command_b(2) = 0 Then Gosub S2
                  If Command_b(2) = 1 Then Gosub S4
                  If Command_b(2) = 2 Then Gosub S6
                  If command_b(2) = 3 Then Gosub S8
                  Start Watchdog
               Else
                  Error_no = 4
                  Gosub Last_err
               End If
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         Else
            Error_no = 0
            Gosub Last_err
         End If
'
      Case 6
'Befehl &H06            dimmt kanäle  auf/ab
'                       dims chanals up/down
'Data "6;or,dimmt auf/ab;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
         If Kanal_mode = 1 Then
            If Commandpointer = 2 Then
               If Command_b(2) < 8 Then
                  Stop Watchdog
                  Medium = 1
                  If Command_b(2) = 0 Then Gosub S1
                  If Command_b(2) = 1 Then Gosub S2
                  If Command_b(2) = 2 Then Gosub S3
                  If command_b(2) = 3 Then Gosub S4
                  If Command_b(2) = 4 Then Gosub S5
                  If Command_b(2) = 5 Then Gosub S6
                  If Command_b(2) = 6 Then Gosub S7
                  If command_b(2) = 7 Then Gosub S8
                  Start Watchdog
               Else
                  Error_no = 4
                  Gosub Last_err
               End If
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         Else
            Error_no = 0
            Gosub Last_err
         End If
'
      Case 7
'Befehl &H07             Timer für 4 Kanal Mode
'                        Timer for 4 chanal mode
'Data "7;or,Timer start/stop;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4""
         If Commandpointer = 2 Then
            If Command_b(2) < 4 Then
               If Kanal_mode = 0 Then
                  Stop Watchdog
                  If Command_b(2) = 0 Then Gosub M12
                  If Command_b(2) = 1 Then Gosub M34
                  If Command_b(2) = 2 Then Gosub M56
                  If command_b(2) = 3 Then Gosub M78
                  Start Watchdog
               Else
                  Error_no = 0
                  Gosub Last_err
               End If
            Else
               Error_no = 4
               Gosub Last_err
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 8
'Befehl &H08             Timer für 8 Kanal Mode
'                        Timer for 8 chanal modef
'Data "8;or,Timer start/stop;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8""
         If Commandpointer = 1 Then
            If Command_b(2) < 8 Then
               If Kanal_mode = 1 Then
                  Stop Watchdog
                  If Command_b(2) = 0 Then Gosub T1
                  If Command_b(2) = 1 Then Gosub T2
                  If Command_b(2) = 2 Then Gosub T3
                  If command_b(2) = 3 Then Gosub T4
                  If Command_b(2) = 4 Then Gosub T5
                  If Command_b(2) = 5 Then Gosub T6
                  If Command_b(2) = 6 Then Gosub T7
                  If command_b(2) = 7 Then Gosub T8
                  Start Watchdog
               Else
                  Error_no = 0
                  Gosub Last_err
               End If
               Gosub Command_received
            Else
               Error_no = 4
               Gosub Last_err
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'

      Case 9
'Befehl &H09            schreiben 0: 4 / 1: 8 Kanalmode
'                       write 0: 4 / 1:8 chanalmode
'Data "9;os;0,4 Kanal;1,8 Kanal"
         If Commandpointer = 2 Then
            If Command_b(2) < 2 Then
               Stop Watchdog
               If Command_b(2) = 0 Then
                  If Kanal_mode = 1 Then
                     Kanal_mode = Command_b(2)
                     Kanal_mode_eeram = Kanal_mode
                     Gosub L23                           '8
                  End If
               Else
                  If Kanal_mode = 0 Then
                     Kanal_mode = Command_b(2)
                     Kanal_mode_eeram = Kanal_mode
                     Gosub L14
                  End If
               End If
               Start Watchdog
               Gosub Command_received
            Else
               Error_no = 4
               Gosub Last_err
            End If
         Else
            Incr Commandpointer
         End If
'
      Case 10
'Befehl &H0A             lesen 4 / 8 Kanalmodemode
'                        read 4 / 8 chanal mode
'Data "10;as;as9"
         I2c_tx = String(stringlength , 0)                     'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = Kanal_mode
         I2c_length = 1
         If Command_mode = 0 Then
            Printbin  Kanal_mode
            I2c_length = 0
         End If
         Gosub Command_received
'
      Case 11
'Befehl &H0B             Reset
'                        reset
'Data "11;ot;0,reset "
            Stop Watchdog
            Reset Portd.3
            Reset Portd.5
            Waitms 8000
            Set Portd.3
            Set Portd.5
            Waitms 200
            Reset Portd.3                                  'input
            Waitms 200
            Set Portd.3
            Start Watchdog
            Gosub Command_received

      Case 240
'announcement lines are read to I2C
'annoumement Zeilen werden von die I2C Schnittstelle gelesen
'Data "240;am,ANNOUNCEMENTS;170;19"
         If Commandpointer = 2 Then
            Select Case Command_b(2)
               Case 254
                  Announceline = 1
                  If  Command_mode = 0  Then                   'RS232 multiple announcelines
                     For A_line = 0 to No_of_announcelines
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
'read last error
'Liest letzen Fehler
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
'Life signal
'geraet aktiv antwort
'Data "253;aa,MYC INFO;b,BUSY"
         I2c_tx = String(stringlength , 0)                     'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = 4                                        'no info
         I2c_length = 1
         If Command_mode = 0 Then
            Printbin 4
            I2c_length = 0
         End If
         Gosub Command_received
'
      Case 254
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;3,INTERFACETYPE,I2C;b,ADRESS,12;INTERFACETYPE,RS232;IF_PARAMETER1,19200Bd;IF_PARAMETER2,8n1"
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
                  If Commandpointer = 2 Then
                     Incr Commandpointer
                  Else
                     If Commandpointer = 3 Then
                        L = Command_b(3)
                        If L = 0 Then
                           Gosub Command_received
                        Else
                           If L > 3 Then L = 3
                           L = L + 3
                           Incr Commandpointer
                        End If
                     Else
                        If Commandpointer = L Then
                        Gosub Command_received
                        Else
                           Incr Commandpointer
                        End If
                     End If
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
'Data "255;aa;as254"
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
                  I2c_tx = "{003}I2C"
                  I2c_length = 4
               Case 3
                  Tempb = Adress / 2
                  I2c_tx_b(1) = Tempb
                  I2c_length = 1
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
Data "0;m;DK1RI;FS20 8 chanal sender;V02.0;1;170;12;19"
'
Announce1:
'Befehl &H01             schaltet kanäle aus
'                        switch chanals off
Data "1;or,Aus;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
Announce2:
'Befehl &H02            schaltet kanäle  ein
'                       switch chanals on
Data "2;or,Ein;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
Announce3:
'Befehl &H03             schaltet kanäle an / aus
'                       switch chanals on / off
Data "3;or,Ein/Aus;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
'
Announce4:
'Befehl &H04             dimmt kanäle ab
'                        dim chanals down
Data "1;or,dimmt ab;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
Announce5:
'Befehl &H05            dimmt kanäle  auf
'                       dims chanals up
Data "5;or,dimmt auf;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
Announce6:
'Befehl &H06            dimmt kanäle  auf/ab
'                       dims chanals up/down
Data "6;or,dimmt auf/ab;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
'
Announce7:
'Befehl &H07             Timer für 4 Kanal Mode
'                        Timer for 4 chanal mode
Data "7;or,Timer start/stop;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4""
'
Announce8:
'Befehl &H08             Timer für 8 Kanal Mode
'                        Timer for 8 chanal modef
Data "8;or,Timer start/stop;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8""
'
Announce9:
'Befehl &H09            schreiben 0: 4 / 1: 8 Kanalmode
'                       write 0: 4 / 1:8 chanalmode
Data "9;os;0,4 Kanal;1,8 Kanal"
'
Announce10:
'Befehl &H0A             lesen 4 / 8 Kanalmodemode
'                        read 4 / 8 chanal mode
Data "10;as;as9"
'
Announce11:
'Befehl &H0B             Reset
'                        reset
Data "11;ot;0,reset "
'
Announce12:
'announcement lines are read to I2C
'annoumement Zeilen werden von die I2C Schnittstelle gelesen
Data "240;am,ANNOUNCEMENTS;170;19"
'
Announce13:
'read last error
'Liest letzen Fehler
Data "252;aa,LAST ERROR;20,last_error"
'
Announce14:
'Life signal
'geraet aktiv antwort
Data "253;aa,MYC INFO;b,BUSY"
'
Announce15:
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;3,INTERFACETYPE,I2C;b,ADRESS,12;INTERFACETYPE,RS232;IF_PARAMETER1,19200Bd;IF_PARAMETER2,8n1"
'
Announce16:
Data "255;aa;as254"
'
Announce17:
Data "R !$1 !$2 !$4 !$5 !$7 If $9=1"
Announce18:
Data "R !$3 !$6 !$8 IF $9=0"