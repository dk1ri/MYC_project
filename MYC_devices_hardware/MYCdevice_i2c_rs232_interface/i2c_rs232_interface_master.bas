'-----------------------------------------------------------------------
'name : rs232_i2c_interface_master.bas
'Version V05.0, 20180127
'purpose : Programm for serial to i2c Interface for test of MYC devices
'This Programm workes as I2C master
'Can be used with hardware rs232_i2c_interface Version V02.0 by DK1RI
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
' Inputs Outputs : see below
' I/O : I2C , RS232
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:

'-----------------------------------------------------------------------
' for ATmega8P
$regfile = "m88def.dat"
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
'=================================================================
'force HW I2C as Master:
$lib "i2c_twi.lbx"
'=================================================================
'
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
Const No_of_announcelines = 20
'announcements start with 0 -> minus 1
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
Dim Myc_mode As Byte
Dim Myc_mode_eeram As Eram Byte
'Dim I2c_reset_counter As Byte
'                    t
'**************** Config / Init
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
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
Config Twi = 100000
Config Sda = Portc.4
'must for master
Config Scl = Portc.5
'
Config Watchdog = 1024

I2cinit
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
'
Master_loop:
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
If I2c_write_pointer > 1 Then Gosub Print_i2c_tx
'
'characters must be inputted as uncoded bytes
'
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
' uncomment, if you want echo
'   Print Chr(A) ;
'write to buffer
   Command_b(commandpointer) = A
   If Cmd_watchdog = 0 Then
      Cmd_watchdog = 1
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
'This wait is necessary, because some programmers provide the chip
'with power for a short time after programming.
'This may start the reset_ sub, but stop before ending.
Wait 1
Dev_number = 1
Dev_number_eeram = Dev_number
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
'
Adress = 2
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
'
Myc_mode = 0
Myc_mode_eeram = Myc_mode
'This should be the last:
Set Led3
'
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
Master_commandparser:
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
'Data "0;m;DK1RI;RS232_I2C_interface Master;V05.0;1;120;1;20;1-1"
      I2c_tx_busy = 2
      Tx_time = 1
      A_line = 0
      Number_of_lines = 1
      Send_lines = 3
      Gosub Sub_restore
      Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 1
'Befehl &H01 <s>
'string an angeschlossenes device schicken, Myc_mode = 0
'write string to device
'Data "1;oa;250"
      If Myc_mode = 0 Then
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            If Commandpointer = 2 Then
               L = Command_b(2)
               'stringlength
               If L = 0 Then
                  Gosub Command_received            '
                  'no string
               Else
                  If L > Stringlength Then
                     Error_no = 4
                     Error_cmd_no = Command_no
                     Gosub Command_received
                  Else
                     Incr Commandpointer
                  End If
               End If
            Else
               Tempb = L + 2
               If Commandpointer >= Tempb Then
                  'string finished
                  I2csend Adress , Command_b(3) , L
                  If Err <> 0 Then
                    Error_no = 1
                    Error_cmd_no = Command_no
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            End If
         End If
      Else
         Error_no = 0
         Error_cmd_no = Command_no
         Gosub Command_received
      End If
'
   Case 2
'Befehl &H02
'string von angeschlossenem device lesen, Myc_mode = 0
'read string from device
'Data "2;aa,as1"
      If Myc_mode = 0 Then
         If Commandpointer > 1 Then
            L = Command_b(2)
            I2c_tx_b(1) = 2
            I2c_tx_b(2) = L
            I2creceive Adress, I2c_tx_b(3), 0, L
            If Err <> 0 Then
               Error_no = 1
               Error_cmd_no = Command_no
            Else
               I2c_write_pointer = L + 3
               Gosub Print_i2c_tx
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      Else
         Error_no = 0
         Error_cmd_no = Command_no
         Gosub Command_received
      End If
'
   Case 16
'Befehl &H10
'übersetzes 0 des slave Myc_mode = 1
'translated 0 of slave
'Data "16;m;DK1RI;RS232_I2C_interface Slave;V04.0;1;90;1;8:1-1"
      If Myc_mode = 1 Then
         I2c_tx_busy = 2
         Tx_time = 1
         A_line = 4
         Number_of_lines = 1
         Send_lines = 2
         Gosub Sub_restore
      Else
         Error_no = 0
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 17
'Befehl &H11 <s>
'übersetzes 1 des slave Myc_mode = 1 I2C nach RS232
'translated 1 of slave I2C to RS232
'Data "17,oa;250"
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
                  If L > Stringlength Then
                     Error_no = 4
                     Error_cmd_no = Command_no
                     Gosub Command_received
                  Else
                     Incr Commandpointer
                     L = L + 2
                     'position of last byte
                  End If
               End If
            Else
               If Commandpointer = L Then
                  'string finished
                  Command_b(1) = 1
                  I2csend Adress , Command_b(1) , L
                  'forward command , legth, and data
                  If Err > 0 Then
                     Error_no = 1
                     Error_cmd_no = Command_no
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            End If
         End If
      Else
         Error_no = 0
         Error_cmd_no = Command_no
         Gosub Command_received
      End If
'
   Case 18
'Befehl &H12
'übersetzes 2 des slave Myc_mode = 1 , RS232 nach I2C
'translated 2 of slave, RS232 to I2C
'Data "18,aa,as17"
      If Myc_mode = 1 Then
         I2c_tx_busy = 2
         Tx_time = 1
         Command_b(1) = 2
         'read command to slave
         I2csend Adress , Command_b(1), 1
         If Err > 0 Then
            Error_no = 1
            Error_cmd_no = Command_no
         Else
            Waitms 10
            I2creceive Adress , I2c_tx_b(1) , 0 , 2
            If Err > 0 Then
               Error_no = 1
               Error_cmd_no = Command_no
            Else
               L = I2c_tx_b(2)
               Waitms 10
            Reset Watchdog
             '  Buffer = String(Stringlength , 0)
               I2c_tx_b(1) = &H12
               I2c_tx_b(2) = L
               I2creceive Adress , I2c_tx_b(3) , 0 , L
               If Err > 0 Then
                  Error_no = 1
                  Error_cmd_no = Command_no
               Else
                  I2c_write_pointer = L+2
                  Gosub Print_i2c_tx
               End If
            End If
         End If
      Else
         Error_no = 0
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 19
'Befehl &H13
'übersetzes 252 des slave Myc_mode = 1
'translated 252 of slave,
'Data "19;aa,LAST ERROR;20,last_error"
      If Myc_mode = 1 Then
         I2c_tx_busy = 2
         Tx_time = 1
         Tempc = &HFC
         I2csend Adress , Tempc
         If Err <> 0 Then
            Error_no = 1
            Error_cmd_no = Command_no
         Else
            Waitms 10
            I2creceive Adress , I2c_tx_b(1) , 0 , 2
            If Err > 0 Then
               Error_no = 1
               Error_cmd_no = Command_no
            Else
               L = I2c_tx_b(2)
               Waitms 10
               'needed for i2creceive !?!
              ' Buffer = String(Stringlength , 0)
               Reset Watchdog
               I2c_tx_b(1) = &H13
               I2c_tx_b(2) = L +2
               I2creceive Adress , I2c_tx_b(3) , 0 , L
               If Err > 0 Then
                  Error_no = 1
                  Error_cmd_no = Command_no
               Else
                  I2c_write_pointer = L + 2
                  Gosub Print_i2c_tx
               End If
            End If
         End If
      Else
         Error_no = 0
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 20
'Befehl &H14
'übersetzes 253 des slave Myc_mode = 1
'translated 253 of slave,
'Data "20;aa,MYC INFO;b,ACTIVE"
      If Myc_mode = 1 Then
         I2c_tx_busy = 2
         Tx_time = 1
         I2c_tx_b(1) = 253
         I2csend Adress , I2c_tx_b(1), 1
         If Err <> 0 Then
            Error_no = 1
            Error_cmd_no = Command_no
         Else
            Waitms 100
            I2creceive Adress , I2c_tx_b(2), 0, 2
            'expect 1 byte
            If Err <> 0 Then
               Error_no = 1
               Error_cmd_no = Command_no
            Else
               I2c_tx_b (1) = &H14
               I2c_write_pointer = 3
               Gosub Print_i2c_tx
            End If
         End If
      Else
         Error_no = 0
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 236
'Befehl &HEC <0..127>
'Adresse zum Senden speichern
'write send adress
'Data "236;oa,I2C adress;b,{0 to 127}"                                               '
      If Commandpointer = 1 Then
         Incr Commandpointer
      Else
         If Command_b(2) < 128 And Command_b(2) > 0 Then
            Adress = Command_b(2) * 2
            Adress_eeram = Adress
            Gosub Reset_i2c
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      End If
'
   Case 237
'Befehl &HED
'Adresse zum Senden lesen
'read send adress
'Data "237;aa,as236"
      printbin &HED
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
               Error_cmd_no = Command_no
         End Select
         Gosub Command_received
      End If
'
   Case 239
'Befehl &HEF
'MYC_mode lesen
'read myc_mod
'Data "239;aa,as238"
      Printbin &HEF
      Printbin myc_mode
      Gosub Command_received                                '
'
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
'Data "240;ln,ANNOUNCEMENTS;120;20"
      If Commandpointer >= 3 Then
         If Command_b(2) < No_of_announcelines And Command_b(3) < No_of_announcelines Then
            I2c_tx_busy = 2
            Tx_time = 1
            Send_lines = 2
            Number_of_lines = Command_b(3)
            A_line = Command_b(2)
            Gosub Sub_restore
            Gosub Print_i2c_tx
            While Number_of_lines > 0
               Gosub Sub_restore
               Gosub Print_i2c_tx
            Wend
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
      Gosub Print_i2c_tx
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
      Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 254
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1"
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
            Case 3
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
'Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
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
                  I2c_tx_b(3) = Rs232_active
                  I2c_write_pointer = 4
               Case 3
                  I2c_tx_b(3) = 0
                  I2c_write_pointer = 4
               Case 4
                  I2c_tx_b(3) = 3
                  I2c_tx_b(4) = "8"
                  I2c_tx_b(5) = "N"
                  I2c_tx_b(6) = "1"
                  I2c_write_pointer = 7
               Case 5
                  I2c_tx_b(3) = Usb_active
                  I2c_write_pointer = 4
            End Select
         Else
            Error_no = 4
            Error_cmd_no = Command_no
            'ignore anything else
         End If
         Gosub Print_i2c_tx
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
'announce text
'
Announce0:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;RS232_I2C_interface Master;V05.0;1;120;1;20;1-1"
'
Announce1:
'Befehl &H01 <s>
'string an angeschlossenes device schicken, Myc_mode = 0
'write string to device
Data "1;oa;250"
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
Data "16;m;DK1RI;RS232_I2C_interface Slave;V04.0;1;90;1;8;1-1"
'
Announce4:
'Befehl &H11 <s>
'übersetzes 1 des slave Myc_mode = 1 I2C nach RS232
'translated 1 of slave I2C to RS232
Data "17,oa;250"
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
Data "I;DK1RI;RS232_I2C_interface Master;V05.0;Device 1;1;DK1RI;Rs232_i2c_interface Slave;V05.0;Device 1;1"
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
Data "240;ln,ANNOUNCEMENTS;120;20"
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
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;a,USB,1"
'
Announce17:
'Befehl &HFF <n> :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
Announce18:
Data "R !($1 $2) IF $239=1"
'
Announce19:
Data "R !($16 $17 $18 $19 $20) IF $239=0"
'