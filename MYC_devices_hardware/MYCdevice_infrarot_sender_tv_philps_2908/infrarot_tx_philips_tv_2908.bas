'name : infrarot_tx _philips_tv_2908.bas
'Version V04.0, 20170902
'purpose : Programm to send RC5 Codes to Philips TV 2908
'This Programm workes as I2C slave or serial interface
'Can be used with hardware rs232_i2c_interface Version V02.0 by DK1RI
'The Programm supports the MYC protocol
'Slave max length of  I2C string is 252 Bytes.
'Please modify clock frequency and processor type, if necessary
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
'clock output enabled
'divide by 8 disabled
'$PROG &HFF,&HC6,&HDF,&HF9' generated. Take care that the chip supports all fuse bytes.
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other right are affected, this programm can be used
'under GPL (Gnu public licence)
'-----------------------------------------------------------------------
'Templates:
'slave_core_V01.2
'-----------------------------------------------------------------------
'Used Hardware:
' RS232
' I2C
'-----------------------------------------------------------------------
' Inputs and outputs: see below
' I/O : I2C , RS232
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'$regfile = "m88pdef.dat"
'for ATMega8P
'$regfile = "m88def.dat"
'for ATMega8
$regfile = "m328pdef.dat"
$crystal = 10000000
$baud = 19200
'use baud rate
$hwstack = 128
'default use 32 for the hardware stack
$swstack = 30
'default use 10 for the SW stack
$framesize = 60
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
Const I2c_buff_length = 252
'that is maximum
Const Stringlength = 252
Const Command_length = 254
'that is maximum
Const A_line_length = 145
'max length of announcelines
Const Cystal = 20000000
Const Not_valid_cmd = &H80
'a non valid commandtoken
Const Blinktime = 5000
Const Cmd_watchdog_time = Blinktime * 10
'Number of main loop before command reset
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
Const Tx = 4 * Tx_factor
Const Tx_timeout = Cmd_watchdog_time * Tx
'
Const No_of_announcelines = 47
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
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * A_line_length
Dim Temps_b(20) As Byte At Temps Overlay
'
Dim I As Word
'Blinkcounter
Dim J As Word

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
Dim I2c_action As Byte
' 0 no action, 1: Commandparser, 2: send ready
Dim I2c_tx As String * I2c_buff_length
Dim I2c_tx_b(I2c_buff_length) As Byte At I2c_tx Overlay
Dim I2c_pointer As Byte
Dim I2c_write_pointer As Byte
Dim I2c_tx_busy As Bit
'There are bytes to transmit
Dim Command As String * Command_length
'Command Buffer
Dim Command_b(Command_length) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
'
Dim Twi_status As Byte
'
Dim Error_no As Byte
Dim Error_cmd_no As Byte
Dim Cmd_watchdog As Dword
'Watchdog for loop
Dim Tx_time As Dword
'Watchdog for I2c sending
Dim Command_mode As Byte
'0: I2C input 1: seriell
'
Dim Togglebit As Byte
Dim Rc5_adress As Byte
Dim no_myc as byte
Dim no_myc_eeram as eram byte
Dim Ir As Byte
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'**************** Config / Init
Config PinB.2 = Input
PortB.2 = 1
Reset__ Alias PinB.2
Config  PORTB.1 = Output
Ir_led Alias PORTB.1
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
'Mega8 has fixed parameter, processor will hang here, if uncommented:
'Config Com1 = 19200 , Databits = 8 Parity = None , Stopbits = 1                                                '
'
'****************Interrupts
Enable Interrupts
'
'**************** Main ***************************************************
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
'Blink
Incr J
If J >= Blinktime Then
   J = 0
   Select Case I
      Case 1
         Set Led4
      Case 6
         Reset Led4
      Case 10
         I = 0
         'twint set?
         If TWCR.7 = 0 Then Gosub Reset_i2c
   End Select
   Incr I
End If
'
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong commands will be deleted
'commandbuffers is reset
If Cmd_watchdog > 0 Then Incr Cmd_watchdog
If Cmd_watchdog > Cmd_watchdog_time Then
   Error_no = 5
   Error_cmd_no = Command_no
   Gosub Command_received
End If
'
If Tx_time > 0 Then
   Incr Tx_time
   If Tx_time > Tx_timeout Then
      Gosub Reset_i2c_tx
      Error_no = 6
      Error_cmd_no = Command_no
   End If
End If
'
'RS232 got data?
A = Ischarwaiting()
If A = 1 Then
   A = Inkey()
   If Command_mode = 0 Then
      'restart if i2cmode
      Command_mode = 1
      Gosub  Command_received
   End If
   If Commandpointer < Stringlength Then
      Command_b(commandpointer) = A
      If Rs232_active = 0 And Usb_active = 0 Then
         'allow &HFE only
         If A = 254 Then
            Gosub Slave_commandparser
         Else
            Gosub  Command_received
         End If
      Else
         Gosub Slave_commandparser
      End If
   'Else
      'If Buffer is full, chars are ignored !!
   End If
End If
'
'I2C
'This part should be executed as fast as possible to continue I2C:
'twint set?
If TWCR.7 = 1 Then
   'twsr 60 -> start, 80-> data, A0 -> stop
   Twi_status = Twsr
   Twi_status = Twi_status And &HF8
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
      'slave send:
      'a slave send command must always be done completely (or until timeout)
      'incoming new send commands are ignored if i2c_tx is not empty
      'for multi line F0 command I2c_tx may be loaded a few times if necessary.
      'multiple announcelines are loaded by line
      'So the will be no i2c_tx_overflow; -> no ring buffer
      If I2c_tx_busy = 1 Then
         'continue sending
         TWDR = I2c_tx_b(I2c_pointer)
         Incr I2c_pointer
         If I2c_pointer >= I2c_write_pointer Then I2c_action = 2
      Else
         TwdR = Not_valid_cmd
      End If
   Else
      'slave receive:
      'I2C receives data and and interpret as commands.
      If Twi_status = &H80 Or Twi_status = &H88 Then
         'Command overflow is avoided during command handling
         Command_b(Commandpointer) = TWDR
         I2c_action = 1
      End If
   End If
   Twcr = &B11000100
End If
'
Select Case I2c_action
   Case 0
      NOP
      'nothing to do, NOP necessary here
   Case 1
      If Command_mode = 1 Then
         'restart if rs232mode
         Command_mode = 0
         'i2c mode
         Gosub  Command_received
      End If
      Gosub Slave_commandparser
      I2c_action = 0
   Case 2
      If Number_of_lines > 0 Then
         Gosub Sub_restore
      Else
         Gosub Reset_i2c_tx
      End If
      I2c_action = 0
End Select
'
Stop Watchdog                                               '
Goto Slave_loop
'
'===========================================
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
Dev_name = Dev_name_eeram
'
Adress = 30
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
'
'+++++++++++++++++++++++++++++++++++++++++++++++++++++
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
Announceline = 255
Error_cmd_no = 0
Send_lines = 0
I2c_action = 0
Gosub Command_received
Gosub Reset_i2c_tx
Gosub Reset_i2c
I = 0
J = 0
Command_mode = 0
Announceline = 255
'
Rc5_adress = 1
Togglebit = 0
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
Send_lines = 0
Tx_time = 0
I2c_tx_busy = 0
Twdr = Not_valid_cmd
Return
'
Command_received:
Commandpointer = 1
Command = String(Command_length , 0)
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
   Case 1
      I2c_write_pointer = 1
   Case 3
      'start basic announcement
      I2c_tx_b(1) = &H00
      I2c_write_pointer = 2
      Send_lines = 1
   Case 2
      'start of announceline(s), send 3 byte first
      I2c_tx_b(1) = &HF0
      I2c_tx_b(2) = A_line
      I2c_tx_b(3) = Number_of_lines
      I2c_write_pointer = 4
      Send_lines = 1
End Select
'
If Number_of_lines > 0 Then
   'another announcelines to send
   'This fills I2c_tx again
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
         'will not happen
   End Select
   Read Temps
   Tempc = Len(Temps)
   I2c_tx_b(I2c_write_pointer) = Tempc
   Incr I2c_write_pointer
   For Tempd = 1 To Tempc
      I2c_tx_b(I2c_write_pointer) = Temps_b(Tempd)
      Incr I2c_write_pointer
   Next Tempd
   Incr A_line
   If A_line >= No_of_announcelines Then A_line = 0
   Decr Number_of_lines
'Else
   'happens, for &HF=xx00
   'send header only
End If
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
Send_rc5:
printbin Tempb
Rc5send Togglebit , Rc5_adress , Tempb
Set Ir_led
'Switch of IR LED
Return
'
Slave_commandparser:
'checks to avoid commandbuffer overflow are within commands !!
If I2c_active = 0 And Command_mode = 0 Then
   'allow &HFE only: enable I2C
   If Command_b(1) <> 254 Then
      Gosub  Command_received
      Return
   End If
End If
'
If Cmd_watchdog = 0 Then
   Cmd_watchdog = 1
   'start watchdog
   Reset Led3
   'LED on  for tests
End If
'
Select Case Command_b(1)
   Case 0
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
'Data "0;m;DK1RI;philips_tv_2908;V04.0;1;160;1;47"
      If I2c_tx_busy = 0 Then
         A_line = 0
         Number_of_lines = 1
         Send_lines = 3
         I2c_tx_busy = 1
         Tx_time = 1
         Gosub Sub_restore
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 1
'Befehl &H01
'an / aus
'on / off
'Data "1;ou,An/Aus;0;1,An/Aus"
      Tempb = &H0C
      Gosub Send_rc5
      Gosub Command_received
'
   Case 2
'Befehl &H02
'o
'o
'Data "2;ou,o;0;1,o"
      Tempb = &H18
      Gosub Send_rc5
      Gosub Command_received
'
   Case 3
'Befehl &H03
'||
'||
'Data "3;ou,||;0;1,||"
      Tempb = &H31
      Gosub Send_rc5
      Gosub Command_received
'
   Case 4
'Befehl &H04
'<<
'<<
'Data "4;ou,<<;0;1,<<"
      Tempb = &H1B
      Gosub Send_rc5
      Gosub Command_received
'
   Case 5
'Befehl &H05
'>
'>
'Data "5;ou,>;0;1,>"
      Tempb = &H19
      Gosub Send_rc5
      Gosub Command_received
'
   Case 6
'Befehl &H06
'>>
'>>
'Data "6;ou,>>;0;1,>>"
     Tempb = &H1C
      Gosub Send_rc5
     Gosub Command_received
'
   Case 7
'Befehl &H07
'source
'source
'Data "7;ou,source;0;1,source"
      Tempb = &H38
      Gosub Send_rc5
      Gosub Command_received
'
   Case 8
'Befehl &H08
'tv
'tv
'Data "8;ou,tv;0;1,tv"
      Tempb = &H3F
      Gosub Send_rc5
      Gosub Command_received
'
   Case 9
'Befehl &H09
'format
'format
'Data "9;ou,format;0;1,format"
      Tempb = &H0B
      Gosub Send_rc5
      Gosub Command_received
'
   Case 10
'Befehl &H0A
'home
'home
'Data "10;ou,home;0;1,home"
      Tempb = &H30
      Gosub Send_rc5
      Gosub Command_received
'
   Case 11
'Befehl &H0B
'list
'list
'Data "11;ou,list;0;1,list"
      Tempb = &H26
      Gosub Send_rc5
      Gosub Command_received
'
   Case 12
'Befehl &H0C
'info
'info
'Data "12;ou,info;0;1,info"
      Tempb = &H12
      Gosub Send_rc5
      Gosub Command_received
'
   Case 13
'Befehl &H0D
'adjust
'adjust
'Data "13;ou,adjust;0;1,adjust"
      Tempb = &H33
      Gosub Send_rc5
      Gosub Command_received
'
   Case 14
'Befehl &H0E
'options
'options
'Data "14;ou,options;0;1,options"
      Tempb = &H0F
      Gosub Send_rc5
      Gosub Command_received
'
   Case 15
'Befehl &H0F
'auf
'up
'Data "15;ou,up;0;1,up"
      Tempb = &H14
      Gosub Send_rc5
      Gosub Command_received
'
   Case 16
'Befehl &H10
'links
'left
'Data "16;ou,left;0;1,left"
      Tempb = &H15
      Gosub Send_rc5
      Gosub Command_received
'
   Case 17
'Befehl &H11
'rechts
'right
'Data "17;ou,right;0;1,right"
      Tempb = &H16
      Gosub Send_rc5
      Gosub Command_received
'
   Case 18
'Befehl &H12
'ab
'down
'Data "18;ou,down;0;1,down"
      Tempb = &H13
      Gosub Send_rc5
      Gosub Command_received
'
   Case 19
'Befehl &H13
'zurueck
'back
'Data "19;ou,back;0;1,back"
      Tempb = &H0A
      Gosub Send_rc5
      Gosub Command_received
'
   Case 20
'Befehl &H14
'ch-
'ch-
'Data "20;ou,ch-;0;1,ch-"
      Tempb = &H21
      Gosub Send_rc5
      Gosub Command_received
'
   Case 21
'Befehl &H15
'ch+
'ch+
'Data "21;ou,ch+;0;1,ch+"
      Tempb = &H20
      Gosub Send_rc5
      Gosub Command_received
'
   Case 22
'Befehl &H16
'laut-
'loud-
'Data "22;ou,loud-;0;1,loud-"
      Tempb = &H11
      Gosub Send_rc5
      Gosub Command_received
'
   Case 23
'Befehl &H17
'Ton aus
'loud off
'Data "23;ou,loud off;0;1,loud off"
      Tempb = &H0D
      Gosub Send_rc5
      Gosub Command_received
'
   Case 24
'Befehl &H18
'laut+
'loud+
'Data "24;ou,loud+;0;1,loud+"
      Tempb = &H10
      Gosub Send_rc5
      Gosub Command_received
'
   Case 25
'Befehl &H19
'rot
'red
'Data "25;ou,red;0;1,red"
      Tempb = &H37
      Gosub Send_rc5
      Gosub Command_received
'
   Case 26
'Befehl &H1A
'gruen
'green
'Data "26;ou,green;0;1,green"
      Tempb = &H36
      Gosub Send_rc5
      Gosub Command_received
'
   Case 27
'Befehl &H1B
'gelb
'yellow
'Data "27;ou,yellow;0;1,yellow"
      Tempb = &H32
      Gosub Send_rc5
      Gosub Command_received
'
   Case 28
'Befehl &H1C
'blau
'blue
'Data "28;ou,blue;0;1,blue"
      Tempb = &H34
      Gosub Send_rc5
      Gosub Command_received
'
   Case 29
'Befehl &H1D
'1
'1
'Data "29;ou,1;0;1,1"
      Tempb = &H01
      Gosub Send_rc5
      Gosub Command_received
'
   Case 30
'Befehl &H1E
'2
'2
'Data "30;ou,2;0;1,2"
      Tempb = &H02
      Gosub Send_rc5
      Gosub Command_received
'
   Case 31
'Befehl &H1F
'3
'3
'Data "31;ou,3;0;1,3"
      Tempb = &H03
      Gosub Send_rc5
      Gosub Command_received
'
   Case 32
'Befehl &H20
'4
'4
'Data "32;ou,4;0;1,4"
      Tempb = &H04
      Gosub Send_rc5
      Gosub Command_received
'
    Case 33
'Befehl &H21
'5
'5
'Data "33;ou,5;0;1,5"
      Tempb = &H05
      Gosub Send_rc5
      Gosub Command_received
'
   Case 34
'Befehl &H22
'6
'6
'Data "34;ou,6;0;1,6"
      Tempb = &H06
      Gosub Send_rc5
      Gosub Command_received
'
   Case 35
'Befehl &H23
'7
'7
'Data "35;ou,7;0;1,7"
      Tempb = &H07
      Gosub Send_rc5
      Gosub Command_received
'
   Case 36
'Befehl &H24
'8
'8
'Data "36;ou,8;0;1,8"
     Tempb = &H08
     Gosub Send_rc5
     Gosub Command_received
'
   Case 37
'Befehl &H25
'9
'9
'Data "37;ou,9;0;1,9"
      Tempb = &H09
      Gosub Send_rc5
      Gosub Command_received
'
   Case 38
'Befehl &H26
'0
'0
'Data "38;ou,0;0;1,0"
      Tempb = &H00
      Gosub Send_rc5
      Gosub Command_received
'
   Case 39
'Befehl &H27
'subtitle
'subtitle
'Data "39;ou,0;subtitle;1,subtitle"
      Tempb = &H1F
      Gosub Send_rc5
      Gosub Command_received
'
   Case 40
'Befehl &H28
'text
'text
'Data "40;ou,0;text;1,text"
      Tempb = &H3C
      Gosub Send_rc5
      Gosub Command_received
'
   Case 41
'Befehl &H29
'ok
'ok
'Data "41;ou,0;ok;1,ok"
      Tempb = &H35
      Gosub Send_rc5
      Gosub Command_received
'
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;160;47"
      If Commandpointer >= 3 Then
         If Command_b(2) < No_of_announcelines And Command_b(3) < No_of_announcelines Then
            If I2c_tx_busy = 0 Then
               I2c_tx_busy = 1
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
               Error_no = 7
               Error_cmd_no = Command_no
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
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &HFC
         I2c_tx_b(2) = &H80
         'Dummy
         Temps = Str(command_no)
         Tempc = Len (Temps)
         I2c_write_pointer = 3
         For Tempb = 1 To Tempc
            I2c_tx_b(I2c_write_pointer) = Temps_b(Tempb)
            Incr I2c_write_pointer
         Next Tempb
         Select Case Error_no
            Case 0
               Temps = ": command not found: "
            Case 1
               Temps = ": I2C error: "
            Case 3
               Temps = ": Watchdog reset: "
            Case 4
               Temps = ": parameter error: "
            Case 5
               Temps = ": command watchdog: "
            Case 6
               Temps = ": Tx timeout: "
            Case 7
               Temps = ": not valid at that time: "
            Case 8
               Temps = ": i2c_buffer overflow: "
            Case 255
               Temps = ": No error: "
         End Select
         Tempc = Len (Temps)
         For Tempb = 1 To Tempc
            I2c_tx_b(I2c_write_pointer) = Temps_b(Tempb)
            Incr I2c_write_pointer
         Next Tempb
         Temps = Str(Error_cmd_no)
         Tempc = Len(Temps)
         For Tempb = 1 To Tempc
            I2c_tx_b(I2c_write_pointer) = Temps_b(Tempb)
            Incr I2c_write_pointer
         Next Tempb
         I2c_tx_b(2) = I2c_write_pointer - 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
         Gosub Command_received
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
'
   Case 253
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
'Data "253;aa,MYC INFO;b,ACTIVE"
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &HFD
         I2c_tx_b(2) = 4
         'no info
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
      Case 254
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,15,{0 to 127};a,RS232,1;a,USB,1"
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
               Error_no = 0
               Error_cmd_no = Command_no
         End Select
      Else
        Incr Commandpointer
      End If
'
      Case 255
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,15,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
      If Commandpointer >= 2 Then
         If I2c_tx_busy = 0 Then
            If Command_b(2) < 8 Then
               Tx_time = 1
               I2c_tx_b(1) = &HFF
               I2c_tx_b(2) = Command_b(2)
               I2c_tx_busy = 1
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
         Error_no = 7
         Error_cmd_no = Command_no
         End If
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
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;philips_tv_2908;V04.0;1;160;1;47"
'
Announce1:
'Befehl &H01
'an / aus
'on / off
Data "1;ou,An/Aus;0;1,An/Aus"
'
Announce2:
'Befehl &H02
'o
'o
'Data "2;ou,o;0;1,o"
'
Announce3:
'Befehl &H03
'||
'||
Data "3;ou,||;0;1,||"
'
Announce4:
'Befehl &H04
'<<
'<<
Data "4;ou,<<;0;1,<<"
'
Announce5:
'Befehl &H05
'>
'>
Data "5;ou,>;0;1,>"
'
Announce6:
'Befehl &H06
'>>
'>>
Data "6;ou,>>;0;1,>>"
'
Announce7:
'Befehl &H07
'source
'source
Data "7;ou,source;0;1,source"
'
Announce8:
'Befehl &H08
'tv
'tv
Data "8;ou,tv;0;1,tv"
'
Announce9:
'Befehl &H09
'format
'format
Data "9;ou,format;0;1,format"
'
Announce10:
'Befehl &H0A
'home
'home
Data "10;ou,home;0;1,home"
'
Announce11:
'Befehl &H0B
'list
'list
Data "11;ou,list;0;1,list"
'
Announce12:
'Befehl &H0C
'info
'info
Data "12;ou,info;0;1,info"
'
Announce13:
'Befehl &H0D
'adjust
'adjust
Data "13;ou,adjust;0;1,adjust"
'
Announce14:
'Befehl &H0E
'options
'options
Data "14;ou,options;0;1,options"
'
Announce15:
'Befehl &H0F
'auf
'up
Data "15;ou,up;0;1,up"
'
Announce16:
'Befehl &H10
'links
'left
Data "16;ou,left;0;1,left"
'
Announce17:
'Befehl &H11
'rechts
'right
Data "17;ou,right;0;1,right"
'
Announce18:
'Befehl &H12
'ab
'down
Data "18;ou,down;0;1,down"
'
Announce19:
'Befehl &H13
'zurueck
'back
Data "19;ou,back;0;1,back"
'
Announce20:
'Befehl &H14
'ch-
'ch-
Data "20;ou,ch-;0;1,ch-"
'
Announce21:
'Befehl &H15
'ch+
'ch+
Data "21;ou,ch+;0;1,ch+"
'
Announce22:
'Befehl &H16
'laut-
'loud-
Data "22;ou,loud-;0;1,loud-"
'
Announce23:
'Befehl &H17
'Ton aus
'loud off
Data "23;ou,loud off;0;1,loud off"
'
Announce24:
'Befehl &H18
'laut+
'loud+
Data "24;ou,loud+;0;1,loud+"
'
Announce25:
'Befehl &H19
'rot
'red
Data "25;ou,red;0;1,red"
'
Announce26:
'Befehl &H1A
'gruen
'green
Data "26;ou,green;0;1,green"
'
Announce27:
'Befehl &H1B
'gelb
'yellow
Data "27;ou,yellow;0;1,yellow"
'
Announce28:
'Befehl &H1C
'blau
'blue
Data "28;ou,blue;0;1,blue"
'
Announce29:
'Befehl &H1D
'1
'1
Data "29;ou,1;0;1,1"
'
Announce30:
'Befehl &H1E
'2
'2
Data "30;ou,2;0;1,2"
'
Announce31:
'Befehl &H1F
'3
'3
Data "31;ou,3;0;1,3"
'
Announce32:
'Befehl &H20
'4
'4
Data "32;ou,4;0;1,4"
'
Announce33:
'Befehl &H21
'5
'5
Data "33;ou,5;0;1,5"
'
Announce34:
'Befehl &H22
'6
'6
Data "34;ou,6;0;1,6"
'
Announce35:
'Befehl &H23
'7
'7
Data "35;ou,7;0;1,7"
'
Announce36:
'Befehl &H24
'8
'8
Data "36;ou,8;0;1,8"
'
Announce37:
'Befehl &H25
'9
'9
Data "37;ou,9;0;1,9"
'
Announce38:
'Befehl &H26
'0
'0
Data "38;ou,0;0;1,0"
'
Announce39:
'Befehl &H27
'subtitle
'subtitle
Data "39;ou,0;subtitle;1,subtitle"
'
Announce40:'
'Befehl &H28
'text
'text
Data "40;ou,0;text;1,text"
'
Announce41:
'Befehl &H29
'ok
'ok
Data "41;ou,0;ok;1,ok"
'
Announce42:                                              '
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;160;47"
'
Announce43:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce44:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce45:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,15,{0 to 127};a,RS232,1;a,USB,1"
'
Announce46:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,15,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'