'-----------------------------------------------------------------------
'name : rs232_i2c_interface_master.bas
'Version V03.0, 20151117
'purpose : Programm for rs232 to i2c Interface for test of MYC devices
'This Programm workes as I2C master
'Can be used with hardware rs232_i2c_interface Version V01.9 by DK1RI
'The Programm supports the MYC protocol
'The I2C master can send 253 Bytes as maximum
'Please modify clock frequncy and processor type, if necessary
'
'20150506   basic announcement according to new rule
'20150621   HW 1.9
'
'micro : ATMega88 or higher
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
'-----------------------------------------------------------------------
'Templates:
' I2C_slave_1.0
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

'-----------------------------------------------------------------------
'$regfile = "m88pdef.dat"                                    ' for ATmega8P
'$regfile = "m88def.dat"                                     ' for ATmega8
$regfile ="m328pdef.dat"
$crystal = 20000000                                         ' used crystal frequency
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
'$lib "i2c_twi.lbx"
'
'**************** Variables
Const Lf = 10
Const Stringlength = 254                                    'that is maximum
Const Rs232length = 253                                     'must be smaller than Stringlength
Const Cmd_watchdog_time = 65000                             'Number of main loop before command reset
Const Blinktime = 3000
Const No_of_announcelines = 7                               'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte                                  'first run after reset
Dim L As Byte                                               'Temps and local
Dim L1 As Byte
Dim L2 As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim I As Integer                                            'Blinkcounter
Dim J As Integer
Dim Temps_b(20) As Byte At Temps Overlay
Dim Rs232_in As String * Stringlength                       'RS232 input
Dim Rs232_in_b(stringlength) As Byte At Rs232_in Overlay
Dim A As Byte                                               'actual input
Dim Rs232_pointer As Byte
Dim Announceline As Byte                                    'notifier for multiple announcelines
Dim A_line As Byte                                          'actual announline
Dim Dev_name As String * 20
Dim Dev_name_eeram As Eram String * 20
Dim Dev_name_b(20) As Byte At Dev_name Overlay
Dim Dev_number As Byte
Dim Dev_number_eeram As Eram Byte
Dim Adress As Byte                                          'I2C adress
Dim Adress_eeram As Eram Byte                               'Buffer
Dim Buffer As String * Stringlength
Dim Buffer_b(stringlength) As Byte At Buffer Overlay
Dim Buffer_pointer As Byte
Dim Buffer_length As Byte
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
Dim Myc_mode As Byte
Dim Myc_mode_eeram As Eram Byte
'
'**************** Config / Init
' Jumper:
Config PinB.2 = Input
PortB.2 = 1
Reset__ Alias Pinb.2
'
' Life LED:
Config Portd.2 = Output
Config Portd.3 = Output
'
Led3 Alias Portd.3                                          'life LED
Led4 Alias Portd.2                                        'on if cmd activ, off, when cmd finished
'
Config Sda = Portc.4                                        'must !!, otherwise error
Config Scl = Portc.5
'
Config Watchdog = 2048                                      'do nothing
'
'Mega8 has fixed parameter, processor will hang here, if uncommented:
'Config Com1 = 19200 , Databits = 8 Parity = None , Stopbits = 1                                                '
'
'****************Interrupts
'Enable INTERRUPTS
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
   Myc_mode = Myc_mode_eeram
End If
'
Gosub Init
'
If Reset__ = 0 Then Gosub Reset_
'
Master_loop:
Gosub Blink_
'
Start Watchdog                                              'Loop must be less than 1024 ms
'
Gosub Cmd_watch
'
' Commands from RS232 are handled.
' characters must be inputted as uncoded bytes
'
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
' uncomment, if you want echo
'   Print Chr(a) ;                                           'echo                                                   'write to buffer
   Command_b(commandpointer) = A
   If Cmd_watchdog = 0 Then
      Cmd_watchdog = 1                                      ' start watchdog
      Reset Led3                                            'LED on
   End If
   Gosub Master_commandparser
End If
Stop Watchdog
Goto Master_loop
'
'===========================================
'
Reset_:
First_set = 5
Dev_number = 1                                              'unsigned , set at first use                                 'obviously not yet set
Dev_number_eeram = Dev_number                               'default values
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 2
Adress_eeram = Adress
Myc_mode = 0
Myc_mode_eeram = Myc_mode
Return
'
Init:
Portc.3 = 1
Set Led3
Set Led4
I = 0
J = 0
Command_no = 1
Announceline = 255                                          'no multiple announcelines
Rs232_pointer = 1
Buffer = String(stringlength , 0)                           'will delete buffer and restart ponter
Buffer_length = 1                                           'should not be 0 at any time
Buffer_pointer = 2
Last_error = " No Error"
Error_no = 255                                              'No Error
Gosub Command_received
Gosub Command_finished                                      'master will read 0 without a command
Return
'
Cmd_watch:
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong coomands will be deleted
If Cmd_watchdog = Cmd_watchdog_time Then                    'one loop without command finishes
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
      Gosub Command_finished
      I2cstop
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
Blink_:
' Led Blinks To Show Life
J = J + 1
If J = Blinktime Then
   J = 0
   Select Case I
      set led4
   Case 3
      If Myc_mode = 1 Then
         I = 0
         reset led4
     End If
   Case 8
      I = 0
      Reset Led4
   End Select
   Incr I
End If
Return
'
Command_finished:
I2cinit
'Config Twi = 100000                                         ' twi 100KHz
'Twcr = &B00000100
'
Command = String(stringlength , 0)
Commandpointer = 1
Buffer = String(stringlength , 0)
Cmd_watchdog = 0
L = 0
If Error_no <> 3 Then Set Led3
Incr Command_no                                             'LED3 lits until next correct command
Return
'
Command_received:
Commandpointer = 1
Command = String(stringlength , 0)                          'no multiple announcelines, if not finished
Cmd_watchdog = 0
Incr Command_no
If Error_no <> 3 Then Set Led3
Return
'
I2c_receive_string:
Waitms 3                                                    ' needed for i2creceive !?!
I2creceive Adress , L
If L <> 0 Then
   I2creceive Adress , Buffer_b(1) , 0 , L
   If Err <> 0 Then
      Error_no = 1
      Gosub Last_err
   End If
   Gosub Print_line
End If
Return
'
Print_line:
Printbin L
For Tempb = 1 To L
   Tempc = Buffer_b(tempb)
   Printbin Tempc
Next Tempb
Return
'
Sub_restore:
   Error_no = 255                                           'no error
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
   Case Else
      Error_no = 0
      Gosub Last_err
End Select
If Error_no = 255 Then
   Read Buffer
   L = Len(buffer)
   Printbin L;
   Print Buffer;
End If
Return
'
Master_commandparser:
Select Case Command_b(1)
   Case 0
'Befehl &H00               basic annoumement wird gelesen
'                          basic announcement is read
'Data "0;m;DK1RI;RS232_I2C_interface Master;V03.0;1;170;15;20"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
   Case 1
'Befehl &H01 <s>           string an angeschlossenes device schicken, Myc_mode = 0
'                          write string to device
'Data "1;oa;253"
      If Myc_mode = 0 Then
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            If Commandpointer = 2 Then
               L = Command_b(2)                                'stringlength
               L1 = L + 2                                      'endposition
               Incr Commandpointer
               If L = 0 Then Gosub Command_finished            ' no string
            Else
                  If Commandpointer = L1 Then                     'string finished
                  If Myc_mode = 0 Then
                     I2csend Adress , Command_b(3) , L
                     If Err <> 0 Then
                        Error_no = 1
                        Gosub Last_err
                     End If
                  Else
                     Error_no = 0
                     Gosub Last_err
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            End If
         End If
      Else
         Error_no = 0
         Gosub Last_err
      End If
'
   Case 2
'Befehl &H01 <s>           string von angeschlossenem device lesen, Myc_mode = 0
'                          read string from device
'Data "2;aa;as1"
      If Myc_mode = 0 Then
         If Commandpointer = 2 Then
            If Myc_mode = 0 Then
               L = Command_b(2)
               I2creceive Adress , Buffer_b(1) , 0 , L
               If Err <> 0 Then
                  Error_no = 1
                  Gosub Last_err
               Else
                  Gosub Print_line
               End If
            Else
               Error_no = 0
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
   Case 16
'Befehl &H10               übersetzes 0 des slave Myc_mode = 1
'                          translated 0 of slave
'Data "16;m;DK1RI;RS232_I2C_interface Slave;V01.1.4;1;170;8"
      If Myc_mode = 1 Then
         A_line = 3
         Gosub Sub_restore
      Else
         Error_no = 0
         Gosub Last_err
      End If
      Gosub Command_received
'
   Case 17
'Befehl &H11 <s>           übersetzes 1 des slave Myc_mode = 1 I2C nach RS232
'                          translated 1 of slave I2C to RS232
'Data "17,oa;252"
      If Myc_mode = 1 Then
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            If Commandpointer = 2 Then
               L = Command_b(commandpointer)                   'length of string
               If L = 0 Then
                  Gosub Command_received
               Else
                  Incr Commandpointer
                  L1 = L + 2                                   'position of last byte
               End If
            Else
               If Commandpointer = L1 Then                     'string finished
                  Command_b(1) = 1
                  I2csend Adress , Command_b(1) , L1        'forward command , legth, and data
                  If Err <> 0 Then                        'write command as 1st byte
                     Error_no = 1
                     Gosub Last_err
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            End If
         End If
      Else
         Error_no = 0
         Gosub Last_err
      End If
'
   Case 18
'Befehl &H12               übersetzes 2 des slave Myc_mode = 1 , RS232 nach I2C
'                          translated 2 of slave, RS232 to I2C
'Data "18,aa;as17"
      If Myc_mode = 1 Then
         Tempb = 2                                          'read command to slave
         I2csend Adress , Tempb
         Gosub I2c_receive_string
      Else
          Error_no = 0
          Gosub Last_err
      End If
      Gosub Command_received
'
   Case 19
'Befehl &H13 <n>           übersetzes 240 des slave Myc_mode = 1 , Daten sind lokal wie bei einem commandrouter gespreichert
'                          translated 240 of slave,
'Data "19;am,ANNOUNCEMENTS;170;8"
      If Myc_mode = 1 Then
         If Commandpointer = 2 Then
            Select Case Command_b(2)
            Case 0 To 7
               A_line = Command_b(2) + 3
               Gosub Sub_restore
            Case 255
               A_line = 3
               Gosub Sub_restore
            Case 254
               For A_line = 3 To 10
                  Gosub Sub_restore
               Next A_line
            Case Else
               Error_no = 0
               Gosub Last_err
            End Select
            Gosub Command_received
         Else
               Incr Commandpointer
         End If
      Else
         Error_no = 3
         Gosub Last_err
         Gosub Command_received
      End If
'
   Case 20
'Befehl &H14               übersetzes 252 des slave Myc_mode = 1
'                          translated 252 of slave,
'Data "20;aa,LAST ERROR;20,last_error"
      If Myc_mode = 1 Then
         Tempc = 252
         I2csend Adress , Tempc , 1
         Gosub I2c_receive_string
      Else
         Error_no = 0
        Gosub Last_err
      End If
      Gosub Command_received
'
   Case 21
'Befehl &H15               übersetzes 253 des slave Myc_mode = 1
'                          translated 253 of slave,
'Data "21;af,MYC INFO;b,&H04"
      If Myc_mode = 1 Then
         Buffer_b(1) = 253
         I2csend Adress , Buffer_b(1)
         Waitms 3                                           'i2creceive need this wait !?!
         I2creceive Adress , Tempb , 0 , 1
         If Err <> 0 Then
            Error_no = 1
            Gosub Last_err
         Else
            Printbin Tempb
         End If
      Else
         Error_no = 0
         Gosub Last_err
      End If
      Gosub Command_received
'
   Case 22
'Befehl &H16 <n> <n>       übersetzes 254 des slave Myc_mode = 1
'                          translated 254 of slave,
'Data "22;oa,INDIVIDUALIZATION;NAME;20;Device 1;NUMBER;b;1;INTERFACETYPE;3;I2C;ADRESS;b;2"
      If Myc_mode = 1 Then
         If Commandpointer = 1 Then
             Incr Commandpointer
         Else
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
                        L = L + 3
                        Incr Commandpointer
                     End If
                  Else
                     If Commandpointer = L Then
                        Command_b(1) = 254
                        I2csend Adress , Command_b(1) , L
                        If Err <> 0 Then
                           Error_no = 1
                           Gosub Last_err
                        End If
                        Gosub Command_received
                     Else
                        Incr Commandpointer
                     End If
                  End If
               End If
            Case 1
               If Commandpointer = 2 Then
                  Incr Commandpointer
               Else
                  Command_b(1) = 254
                  I2csend Adress , Command_b(1) , 3
                  If Err <> 0 Then
                     Error_no = 1
                     Gosub Last_err
                  End If
                  Gosub Command_received
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
                        L = L + 3
                        Incr Commandpointer
                     End If
                  Else
                     If Commandpointer = L Then             'transmit  the data, but slave will do nothing
                        Command_b(1) = 254
                        I2csend Adress , Command_b(1) , L
                        If Err <> 0 Then
                           Error_no = 1
                           Gosub Last_err
                        End If
                        Gosub Command_received
                     Else
                        Incr Commandpointer
                     End If
                  End If
               End If
            Case 3
               If Commandpointer = 2 Then
                  Incr Commandpointer
               Else
                  Command_b(1) = 254
                  I2csend Adress , Command_b(1) , 3
                  If Err <> 0 Then
                     Error_no = 1
                     Gosub Last_err
                  End If
               End If
            Case Else
               Error_no = 0
               Gosub Last_err
               Gosub Command_received
            End Select
         End If
      Else
         Error_no = 0
        Gosub Last_err
        Gosub Command_received
      End If
'
   Case 23
'Befehl &H17 <n>           übersetzes 255 des slave Myc_mode = 1
'                          translated 255 of slave,
'Data "23;aa;as22"
      If Myc_mode = 1 Then
         If Commandpointer = 2 Then
            Tempb = Command_b(commandpointer)
            Tempc = 255
            Command_b(1) = 255
            I2csend Adress , Command_b(1) , 2
            Select Case Tempb
               Case 0
                  Gosub I2c_receive_string
               Case 1
                  Waitms 3
                  I2creceive Adress , Tempb , 0 , 1
                  If Err <> 0 Then
                     Error_no = 1
                     Gosub Last_err
                  End If
                  Printbin Tempb
               Case 2
                  Gosub I2c_receive_string
               Case 3
                  Waitms 3
                  I2creceive Adress , Tempb , 0 , 1
                  If Err <> 0 Then
                     Error_no = 1
                     Gosub Last_err
                  Else
                     Printbin Tempb
                  End If
               Case Else
                  Error_no = 0
                  Gosub Last_err
            End Select
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      Else
          Error_no = 0
          Gosub Last_err
          Gosub Command_received
      End If
'
   Case 238
'Befehl &HEE 0|1           MYC_mode speichern
'                          write myc_mod
'Data "238;oa;a"                                               '
      If Commandpointer = 1 Then
         Incr Commandpointer
      Else
         Select Case Command_b(2)
            Case 0
               Myc_mode = 0
               Myc_mode_eeram = 0
            Case 1
               Myc_mode = 1
               Myc_mode_eeram = 1
            Case Else
               Error_no = 4
               Gosub Last_err
         End Select
         Gosub Command_received
      End If
'
   Case 239
'Befehl &HEF               MYC_mode lesen
'                          read myc_mod
'Data "239;aa;as238"
      Print Chr(myc_mode);
      Gosub Command_received                                '
'
      Case 240
'Befehl &HF0 0-13,
'            253,254 255   announcement aller Befehle lesen
'                          read announcement lines
'Data "240;am,ANNOUNCEMENTS;170;20"
         If Commandpointer = 2 Then
            Select Case Command_b(2)
               Case 253
                  For A_line = 17 To 19
                     Gosub Sub_restore
                  Next A_line
               Case 254
                  For A_line = 0 To 19
                     Gosub Sub_restore
                  Next A_line
               Case 255
                  A_line = 0
                  Gosub Sub_restore
               Case 0 To 19
                  A_line = Command_b(2)
                  Gosub Sub_restore
            End Select
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 252
'Befehl &HFC               Liest letzen Fehler
'                          read last error
'Data "252;aa,LAST ERROR;20,last_error"
         Buffer = String(stringlength , 0)                  'will delete buffer and restart ponter
         Buffer_b(1) = 1                                    'so 1st byte <> 0!!
         Temps = Str(command_no)
         Buffer_length = Len(temps)
         For Tempb = 1 To Buffer_length                     'leave space for length
            Buffer_b(tempb + 1) = Temps_b(tempb)
         Next Tempb
         Incr Buffer_length                                 'because of 1 byte with length
         Tempb = Len(last_error)
         For Tempc = 1 To Tempb
            Tempd = Tempc + Buffer_length                   'write at the end
            Buffer_b(tempd) = Last_error_b(tempc)
         Next Tempc
         Buffer_length = Tempd                              'last tempd is length
         Decr Tempd
         Buffer_b(1) = Tempd
         Print Buffer;
         Gosub Command_received
'
       Case 253
'Befehl &HFD               geraet aktiv antwort
'                          Life signal
'Data "253;aa,MYC INFO;b,&H04,BUSY"
         Buffer = String(stringlength , 0)                  'will delete buffer and restart ponter
         Tempb = 4                                          'no info
         Printbin Tempb
         Gosub Command_received
'
      Case 254
'Befehl &HFE <n> <n>       Individualisierung schreiben
'                          write indivdualization
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;3,INTERFACETYPE,I2C;b,ADRESS,1;INTERFACETYPE,RS232;IF_PARAMETER1,19200Bd;IF_PARAMETER2,8n1;INTERFACETYPE,USB"
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
                  Error_no = 4
                  Gosub Last_err
                  Gosub Command_received
            End Select
         Else
           Incr Commandpointer
         End If
'
      Case 255
'Data "255;aa;as254"
         If Commandpointer = 2 Then
            Buffer = String(stringlength , 0)               'delete buffer and restart ponter
            Buffer_pointer = 1
            Select Case Command_b(2)
               Case 0
                  Buffer = Dev_name
                  L = Len(dev_name)
                  Gosub Print_line
               Case 1
                  Tempb = Dev_number
                  Printbin Tempb
               Case 2
                  Buffer = "{003}I2C"
                  L = 4
                  Gosub Print_line
               Case 3
                  Tempb = Adress / 2
                  Printbin Tempb
               Case Else
                  Error_no = 4                              'ignore anything else
                  Gosub Last_err
            End Select
            Gosub Command_received
         Else
               Incr Commandpointer
         End If
'
      Case Else
         Error_no = 0                                       'ignore anything else
         Gosub Last_err
         Gosub Command_received
      End Select

Return
'
'==================================================
'
End
'
'announce text
'
Announce0:
'Befehl &H00               basic annoumement wird gelesen
'                          basic announcement is read
Data "0;m;DK1RI;RS232_I2C_interface Master;V02.1;1;170;15;20"
'
Announce1:
'Befehl &H01 <s>           string an angeschlossenes device schicken Myc_mode = 0
'                          write string to device
Data "1;oa;253"
'
Announce2:
'Befehl &H01 <s>           string von angeschlossenem device lesen, Myc_mode = 0
'                          read string from device
Data "2;aa;as1"
'
Announce3:
'Befehl &H10               übersetzes 0 des slave Myc_mode = 1
'                          translated 0 of slave
Data "16;m;DK1RI;RS232_I2C_interface Slave;V01.1.4;1;170;8"
'
Announce4:
'Befehl &H11 <s>           übersetzes 1 des slave Myc_mode = 1 I2C nach RS232
'                          translated 1 of slave I2C to RS232
Data "17,oa;252"
'
Announce5:
'Befehl &H12               übersetzes 2 des slave Myc_mode = 1 , RS232 nach I2C
'                          translated 2 of slave, RS232 to I2C
Data "18,aa;as17"
'
Announce6:
'Befehl &H13 <n>           übersetzes 240 des slave Myc_mode = 1 , Daten sind lokal wie bei einem commandrouter gespreichert
'                          translated 240 of slave,
Data "19;am,ANNOUNCEMENTS;170;8"
'
Announce7:
'Befehl &H14               übersetzes 252 des slave Myc_mode = 1
'                          translated 252 of slave,
Data "20;aa,LAST ERROR;20,last_error"
'
Announce8:
'Befehl &H15               übersetzes 253 des slave Myc_mode = 1
'                          translated 253 of slave,
Data "21;af,MYC INFO;b,&H04"
'
Announce9:
'Befehl &H16 <n> <n>       übersetzes 254 des slave Myc_mode = 1
'                          translated 254 of slave,
Data "22;oa,INDIVIDUALIZATION;NAME;20;Device 1;NUMBER;b;1;INTERFACETYPE;3;I2C;ADRESS;b;2"
'
Announce10:
'Befehl &H17 <n>           übersetzes 255 des slave Myc_mode = 1
'                          translated 255 of slave,
Data "23;aa;as22"
'
Announce11:
'Befehl &HEE 0|1           MYC_mode speichern
'                          write myc_mod
Data "238;oa;a"
'
Announce12:
'Befehl &HEF               MYC_mode lesen
'                          read myc_mod
Data "239;aa;as238"
'
Announce13:
'Befehl &HF0 0-13,
'            253,254 255   announcement aller Befehle lesen
'                          read announcement lines
Data "240;am,ANNOUNCEMENTS;170;20"
'
Announce14:                                                 '
'Befehl &HFC               Liest letzen Fehler
'                          read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce15:                                                 '
'Befehl &HFD               geraet aktiv antwort
'                          Life signal
Data "253;aa,MYC INFO;b,&H04,BUSY"
'
Announce16:
'Befehl &HFE <n> <n>       Individualisierung schreiben
'                          write indivdualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;3,INTERFACETYPE,I2C;b,ADRESS,1;INTERFACETYPE,RS232;IF_PARAMETER1,19200Bd;IF_PARAMETER2,8n1;INTERFACETYPE,USB"
'
Announce17:
Data "255;aa,as254"
Announce18:
Data "R !($1 $2) IF $238=1"
Announce19:
Data "R !($10 $11 $12 $13 $14 $15 $16 $17) IF $238=0"
'