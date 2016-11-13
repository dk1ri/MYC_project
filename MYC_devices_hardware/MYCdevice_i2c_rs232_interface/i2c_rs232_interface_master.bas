'-----------------------------------------------------------------------
'name : rs232_i2c_interface_master.bas
'Version V04.2, 20161110
'purpose : Programm for serial to i2c Interface for test of MYC devices
'This Programm workes as I2C master
'Can be used with hardware rs232_i2c_interface Version V03.0 by DK1RI
'The Programm supports the MYC protocol
'The I2C master can send 252 Bytes as maximum
'Please modify clock frequncy and processor type, if necessary
'
'micro : ATMega88 or higher
'Fuse Bits :
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
'$PROG &HFF,&HC6,&HDF,&HF9' generated. Take care that the chip supports all fuse bytes.
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
' Inputs Outputs : see below
' I/O : I2C , RS232
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:

'-----------------------------------------------------------------------
'$regfile = "m88pdef.dat"
' for ATmega8P
$regfile = "m88def.dat"
' for ATmega8
'$regfile ="m328pdef.dat"
$crystal = 20000000
' used crystal frequency
$baud = 19200
' use baud rate
$hwstack = 64
'default use 32 for the hardware stack
$swstack = 20
'default use 10 for the SW stack
$framesize = 50
'default use 40 for the frame space
'
' Simulation!!!!
' $sim
'
'**************** libs
'force HW I2C as Master:
$lib "i2c_twi.lbx"
'use byte library for smaller code
'$lib "mcsbyte.lbx"
'$lib "i2c_twi.lbx"
'
'**************** Variables
Const Lf = 10
Const Stringlength = 252
'that is maximum
Const Cmd_watchdog_time = 65000
'Number of main loop before command reset
Const Blinktime = 3000
Const No_of_announcelines = 20
'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte
'first run after reset
Dim L As Byte
'Temps and local
Dim L1 As Byte
Dim L2 As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim I As Integer
'Blinkcounter
Dim J As Integer
Dim Temps_b(20) As Byte At Temps Overlay
Dim Rs232_in As String * Stringlength
'RS232 input
Dim A As Byte
'actual input
Dim Announceline As Byte
'notifier for multiple announcelines
Dim A_line As Byte
'actual announline
Dim Dev_name As String * 20
Dim Dev_name_eeram As Eram String * 20
Dim Dev_name_b(20) As Byte At Dev_name Overlay
Dim Dev_number As Byte
Dim Dev_number_eeram As Eram Byte
Dim Adress As Byte
'I2C adress
Dim Adress_eeram As Eram Byte
'Buffer
Dim Buffer As String * Stringlength
Dim Buffer_b(stringlength) As Byte At Buffer Overlay
Dim Buffer_pointer As Byte
Dim Buffer_length As Byte
Dim Command As String * Stringlength
'Command Buffer
Dim Command_b(stringlength) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
Dim Twi_status As Byte
'HW I2C
Dim Twi_control As Byte
Dim Last_error As String * 30
'Error Buffer
Dim Last_error_b(30) As Byte At Last_error Overlay
Dim Error_no As Byte
Dim Cmd_watchdog As Word
'Watchdog notifier
Dim RS232_active As Byte
Dim RS232_active_eeram As Eram Byte
Dim USB_active As Byte
Dim Usb_active_eeram As Eram Byte
Dim Radio_active As Byte
Dim Radio_active_eeram As Eram Byte
Dim Send_lines As Byte
Dim Number_of_lines As Byte
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
Led3 Alias Portd.3
'life LED
Led4 Alias Portd.2
'on if cmd activ, off, when cmd finished
'
'Use HW TWI
Config Twi = 400000
Config Sda = Portc.4
'must for master
Config Scl = Portc.5
I2cinit
'

Config Watchdog = 2048
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
If Reset__ = 0 Then Gosub Reset_
'
If First_set <> 5 Then Gosub Reset_
'
Gosub Init
''
Master_loop:
Gosub Blink_
'
Start Watchdog
'Loop must be less than 2s
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
'   Print Chr(a) ;
'echo
'write to buffer
   Command_b(commandpointer) = A
   If Cmd_watchdog = 0 Then
      Cmd_watchdog = 1
      ' start watchdog
      Reset Led3
      'LED on
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
'unsigned , set at first use
Dev_number = 1
Dev_number_eeram = Dev_number
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 2
Adress_eeram = Adress
Myc_mode = 0
Myc_mode_eeram = Myc_mode
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
Radio_active = 1
Radio_active_eeram = Radio_active
Return
'
Init:
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram
RS232_active = RS232_active_eeram
Usb_active = Usb_active_eeram
Radio_active = Radio_active_eeram
Portc.3 = 1
Set Led3
Set Led4
I = 0
J = 0
Command_no = 1
Announceline = 255
'no multiple announcelines
Buffer = String(stringlength , 0)
'will delete buffer and restart ponter
Buffer_length = 1
'should not be 0 at any time
Buffer_pointer = 2
Last_error = " No Error"
Error_no = 255
'No Error
Gosub Command_received
Gosub Command_finished
'master will read 0 without a command
Return
'
Cmd_watch:
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong coomands will be deleted
If Cmd_watchdog = Cmd_watchdog_time Then
   Error_no = 3
   Gosub Last_err
   Gosub Command_received
   'reset commandinput
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
      I2cstart
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
Twsr = 0
'status und Prescaler auf 0
Twdr = &HFF
'default
Twar = Adress
'Slaveadress
Twcr = &B01000100
Return
'
Command_received:
Commandpointer = 1
Command = String(stringlength , 0)
'no multiple announcelines, if not finished
Cmd_watchdog = 0
Gosub Command_finished
If Error_no <> 3 Then Set Led3
If Error_no < 255 Then Gosub Last_err
Incr Command_no
Return
'
I2c_receive_string:
I2creceive Adress , L
If L <> 0 Then
   I2creceive Adress , Buffer_b(1) , 0 , L
   If Err <> 0 Then
      Error_no = 1
      Gosub Last_err
   End If
   Gosub Print_line
Else
   Printbin 0
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
   Error_no = 255
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
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
'Data "0;m;DK1RI;RS232_I2C_interface Master;V04.2;1;170;1;20"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
   Case 1
'Befehl &H01 <s>
'string an angeschlossenes device schicken, Myc_mode = 0
'write string to device
'Data "1;oa;252"
      If Myc_mode = 0 Then
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            If Commandpointer = 2 Then
               L = Command_b(2)
               'stringlength
               L1 = L + 2
               'endposition
               Incr Commandpointer
               If L = 0 Then Gosub Command_finished             '
               'no string
            Else
                  If Commandpointer = L1 Then
                  'string finished
                  If Myc_mode = 0 Then
                     I2csend Adress , Command_b(3) , L
                     If Err <> 0 Then
                        Error_no = 1
                     End If
                  Else
                     Error_no = 0
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            End If
         End If
      Else
         Error_no = 0
         Gosub Command_received
      End If
'
   Case 2
'Befehl &H02
'string von angeschlossenem device lesen, Myc_mode = 0
'read string from device
'Data "2;aa,as1"
      If Myc_mode = 0 Then
         If Commandpointer = 2 Then
            L = Command_b(2)
            I2creceive Adress , Buffer_b(1) , 0 , L
            If Err <> 0 Then
               Error_no = 1
            Else
               Gosub Print_line
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      Else
         Error_no = 0
         Gosub Command_received
      End If
'
   Case 16
'Befehl &H10
'übersetzes 0 des slave Myc_mode = 1
'translated 0 of slave
'Data "16;m;DK1RI;RS232_I2C_interface Slave;V04.0;1;170;8;13"
      If Myc_mode = 1 Then
         A_line = 3
         Gosub Sub_restore
      Else
         Error_no = 0
      End If
      Gosub Command_received
'
   Case 17
'Befehl &H11 <s>
'übersetzes 1 des slave Myc_mode = 1 I2C nach RS232
'translated 1 of slave I2C to RS232
'Data "17,oa;252"
      If Myc_mode = 1 Then
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            If Commandpointer = 2 Then
               L = Command_b(commandpointer)
               'length of string
               If L = 0 Then
                  Gosub Command_received
               Else
                  Incr Commandpointer
                  L1 = L + 2
                  'position of last byte
               End If
            Else
               If Commandpointer = L1 Then
               'string finished
                  Command_b(1) = 1
                  I2csend Adress , Command_b(1) , L1
                  'forward command , legth, and data
                  If Err <> 0 Then
                  'write command as 1st byte
                     Error_no = 1
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            End If
         End If
      Else
         Error_no = 0
         Gosub Command_received
      End If
'
   Case 18
'Befehl &H12
'übersetzes 2 des slave Myc_mode = 1 , RS232 nach I2C
'translated 2 of slave, RS232 to I2C
'Data "18,aa,as17"
      If Myc_mode = 1 Then
         Tempb = 2
         'read command to slave
         I2csend Adress , Tempb
         Stop Watchdog
         Waitms 3
         'needed for i2creceive !?!
         Start Watchdog
         Gosub I2c_receive_string
      Else
          Error_no = 0
          Gosub Last_err
      End If
      Gosub Command_received
'
   Case 19
'Befehl &H13
'übersetzes 252 des slave Myc_mode = 1
'ranslated 252 of slave,
'Data "19;aa,LAST ERROR;20,last_error"
      If Myc_mode = 1 Then
         Tempc = 252
         I2csend Adress , Tempc , 1
         If Err <> 0 Then Error_no = 1
      Else
         Error_no = 0
      End If
      Gosub Command_received
'
   Case 20
'Befehl &H14
'übersetzes 253 des slave Myc_mode = 1
'translated 253 of slave,
'Data "20;aa,MYC INFO;b,ACTIVE"
      If Myc_mode = 1 Then
         Buffer_b(1) = 253
         I2csend Adress , Buffer_b(1)
         If Err <> 0 Then Error_no = 1
      Else
         Error_no = 0
      End If
      Gosub Command_received
'
   Case 21
'Befehl &H15 <n>
'übersetzes 255 des slave Myc_mode = 1
'translated 255 of slave,
'Data "21;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127}"
'
      If Commandpointer = 2 Then
         Select Case Command_b(2)
            Case 0
                Buffer = Dev_name
               L = Len(dev_name)
               Gosub Print_line
            Case 1
               Tempb = 1
               'Devicenumber
               Printbin Tempb
            Case 2
               Tempb = 1
               'I2cactiv
               Printbin Tempb
            Case 3
               Tempb = 1
               'Adress
               Printbin Tempb
            Case Else
               Error_no = 4
               'ignore anything else
         End Select
         Gosub Command_received
      End If
   Case 236
'Befehl &HEC <0..127>
'Adresse zum Senden speichern
'write send adress
'Data "236;oa,I2C adress;b,{0 to 127}"                                               '
      If Commandpointer = 1 Then
         Incr Commandpointer
      Else
         If Command_b(2) < 128 Then
            Adress = Command_b(2) * 2
            Adress_eeram = Adress
         Else
            Error_no = 4
         End If
         Gosub Command_received
      End If
'
   Case 237
'Befehl &HED
'Adresse zum Senden lesen
'read send adress
'Data "237;aa,as236"
      Tempb = Adress / 2
      Printbin Tempb
      Gosub Command_received                                '
'
   Case 238
'Befehl &HEE 0|1
'MYC_mode speichern
'write myc_mod
'Data "238;oa,MYC Mode;a"                                               '
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
         End Select
         Gosub Command_received
      End If
'
   Case 239
'Befehl &HEF
'MYC_mode lesen
'read myc_mod
'Data "239;aa,as238"
      Printbin myc_mode
      Gosub Command_received                                '
'
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;100;20"
         If Commandpointer = 3 Then
            If Command_b(2) < No_of_announcelines And Command_b(3) <= No_of_announcelines Then
                If Command_b(3) > 0 Then
                  Send_lines = 1
                  Number_of_lines = Command_b(3)
                  A_line = Command_b(2)
                  Gosub Sub_restore
                  Decr Number_of_lines
                  While  Number_of_lines > 0
                     Decr Number_of_lines
                     Incr A_line
                     If A_line >= No_of_announcelines Then
                        A_line = 0
                     End If
                     Gosub Sub_restore
                  Wend
               End If
            Else
               Error_no = 4
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
'Data "252;aa,LAST ERROR;20,last_error"
         Buffer = String(stringlength , 0)
         Temps = Str(command_no)
         L = Len (Temps)
         For Tempb = 1 To L
            Buffer_b(tempb + 1) = Temps_b(tempb)
            '+1: leave space for length
         Next Tempb
         Incr L
         Tempc = Len(last_error)
         For Tempb = 1 To Tempc
            Tempd = Tempb + L
            'write at the end
            Buffer_b(tempd) = Last_error_b(tempb)
         Next Tempb
         'last tempd is length
         Buffer_b(1) = Tempd
         'complete Length
         Tempc = Len(Buffer)
         For Tempb = 1 To Tempc
            Tempd = Buffer_b(Tempb)
            Printbin Tempd
         Next Tempb
         Gosub Command_received
'
       Case 253
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
'Data "253;aa,MYC INFO;b,ACTIVE"
         Printbin 4
         Gosub Command_received
'
      Case 254
'Befehl &HFE <n><data>:
'eigene Individualisierung schreiben
'write individualization
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1"
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
                        L = Command_b(3)
                        If L > 20 Then L = 20
                        L = L + 3
                        If Commandpointer = L Then
                           Dev_name = String(20 , 0)
                           For Tempb = 4 To L
                              Dev_name_b(tempb - 3) = Command_b(tempb)
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
                     If Command_b(3) > 1 Then Command_b(3) = 1
                     RS232_active = Command_b(3)
                     RS232_active_eeram = RS232_active
                     Gosub Command_received
                  End If
               Case 3
                  If Commandpointer < 3 Then
                     Incr Commandpointer
                  Else
                     If Command_b(3) > 1 Then Command_b(3) = 1
                     Usb_active = Command_b(3)
                     Usb_active_eeram = Usb_active
                     Gosub Command_received
                  End If
               Case Else
                  Error_no = 4
                  Gosub Command_received
            End Select
         Else
           Incr Commandpointer
         End If
'
      Case 255
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
         If Commandpointer = 2 Then
            Buffer = String(stringlength , 0)
            'delete buffer and restart ponter
            Select Case Command_b(2)
               Case 0
                  Buffer = Dev_name
                  L = Len(dev_name)
                  Gosub Print_line
               Case 1
                  Tempb = Dev_number
                  Printbin Tempb
               Case 2
                  Printbin RS232_active
               Case 3
                  Printbin 0
               Case 4
                  Print "8N1";
              Case 5
                  Printbin Usb_active
               Case 6
                  Printbin Radio_active
               Case Else
                  Error_no = 4
                  'ignore anything else
            End Select
            Gosub Command_received
         Else
               Incr Commandpointer
         End If
'
      Case Else
         Error_no = 0
         'ignore anything else
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
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;RS232_I2C_interface Master;V04.2;1;170;1;20"
'
Announce1:
'Befehl &H01 <s>
'string an angeschlossenes device schicken, Myc_mode = 0
'write string to device
Data "1;oa;252"
'
Announce2:
'Befehl &H02
'string von angeschlossenem device lesen, Myc_mode = 0
'read string from device
Data "2;aa,as1"
'
Announce3:
'Befehl &H10
'übersetzes 0 des slave Myc_mode = 1
'translated 0 of slave
Data "16;m;DK1RI;RS232_I2C_interface Slave;V04.0;1;170;8;13"
'
Announce4:
'Befehl &H11 <s>
'übersetzes 1 des slave Myc_mode = 1 I2C nach RS232
'translated 1 of slave I2C to RS232
Data "17,oa;252"
'
Announce5:
'Befehl &H12
'übersetzes 2 des slave Myc_mode = 1 , RS232 nach I2C
'translated 2 of slave, RS232 to I2C
Data "18,aa,as17"
'
Announce6:
'Befehl &H13
'übersetzes 252 des slave Myc_mode = 1
'translated 252 of slave,
Data "19;aa,LAST ERROR;20,last_error"
'
Announce7:
'Befehl &H14
'übersetzes 253 des slave Myc_mode = 1
'translated 253 of slave,
Data "20;aa,MYC INFO;b,ACTIVE"
'
Announce8:
'Befehl &H15 <n>
'übersetzes 255 des slave Myc_mode = 1
'translated 255 of slave,
Data "21;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127}"
'
Announce9:
'Befehl &HEC <0..127>
'Adresse zum Senden speichern
'write send adress
Data "236;oa,I2C adress;b,{0 to 127}"                                               '
'
Announce10:
'Befehl &HED
'Adresse zum Senden lesen
'read send adress
Data "237;aa,as236"
'
Announce11:
'Befehl &HEE 0|1
'MYC_mode speichern
'write myc_mode
Data "238;oa,MYC mode;a"                                               '
'
Announce12:
'Befehl &HEF
'MYC_mode lesen
'read myc_mode
Data "239;aa,as238"
'
Announce13:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;100;20"
'
Announce14:                                                 '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
 '
Announce15:                                                 '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce16:
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1"
'
Announce17:
'Befehl &HFF <n> :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
Announce18:
Data "R !($1 $2) IF $239=1"
'
Announce19:
Data "R !($16 $17 $18 $19 $20) IF $239=0"
'