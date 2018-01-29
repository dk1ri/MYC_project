'-----------------------------------------------------------------------
'name : dtmf_rbc_bascom.bas
'Version V03.0, 2018026
'purpose : Programm for sending MYC protocol as DTMF Signals for romote Shack of MFJ (TM)

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
'
'-----------------------------------------------------------------------
'Used Hardware:
' RS232
' I2C
' Timer1 by DTMF
'-----------------------------------------------------------------------
' Inputs, Ourput see below
' DTMFout at OCA Timer1 pin C.5
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'$regfile = "m168def.dat"
$regfile = "m328pdef.dat"
$crystal = 10000000
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
Const Tx_timeout = 10
'ca 5s: 10 for 10MHZ 20 for 20 MHz
'Number of loops: 256 * 30 * Tx_timeout
'timeout, when I2c_Tx_b is cleared and new commands allowed
'
Const No_of_announcelines = 61
'announcements start with 0 -> + 1
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
Dim Templ As Dword
Dim Templl As Dword
Dim Templll As Dword
Dim Templlll As Dword
Dim New_commandmode As Byte
Dim Commandmode As byte
' ! there is command_mode as well !!!!!
Dim Dtmf_duration As Byte
Dim Dtmfchar As Byte
Dim New_dtmfchar As Byte
Dim Dtmf_duration_eeram As Eram Byte
Dim DTMF_pause As Byte
Dim Dtmf_pause_eeram As Eram Byte
Dim Vfo_a_b As Byte
Dim Memory_set_recall As Byte
Dim Antenna As Byte
Dim Func As Byte
Dim Ta As Byte
Dim Tb As Long
Dim Tc As Byte
Dim Td As Dword
Dim Te As Byte
Dim Tf As Byte
Dim I2C_name As Byte
Dim I2C_name_eeram As Eram Byte
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'**************** Config / Init
'
Config PinB.2 = Input
PortB.2 = 1
Reset__ Alias PinB.2
Config  PORTB.1 = Output
DTMF_ Alias PortB.1
'
' Life LED:
Config Portd.2 = Output
Config Portd.3 = Output
Led3 Alias Portd.3
'on if cmd activ, off, when cmd finished
Led4 Alias Portd.2
'life LED
'
Config TWI = 400000
Config Watchdog = 2048
'
'****************Interrupts
Enable Interrupts
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
'RS232 got data?
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
Adress = 28
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
'
Dtmf_duration = 50
Dtmf_duration_eeram = Dtmf_duration
Dtmf_pause = 50
Dtmf_pause_eeram = Dtmf_pause
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
Dtmf_duration = Dtmf_duration_eeram
Dtmf_pause = Dtmf_pause_eeram
Reset Dtmf_
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
   Case 47
      Restore Announce47
   Case 48
      Restore Announce48
   Case 49
      Restore Announce49
   Case 50
      Restore Announce50
   Case 51
      Restore Announce51
   Case 52
      Restore Announce52
   Case 53
      Restore Announce53
   Case 54
      Restore Announce54
   Case 55
      Restore Announce55
   Case 56
      Restore Announce56
   Case 57
      Restore Announce57
   Case 58
      Restore Announce58
   Case 59
      Restore Announce59
   Case 60
      Restore Announce60
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
Dtmf:
   Dtmfout Dtmfchar , Dtmf_duration
   Printbin Dtmfchar
   Waitms Dtmf_pause
   Reset DTMF_
Return
'
Send_dtmf:
'Convert Command_b -> Te digits
'Tb: limit
'Tc: Start DTMF character
'Td: highest divisor
'Te: number of digits
'Tf: end Dtmf character
'
Templ = Command_b(2)
If Ta > 2 Then
   'create Templ (Dword) from Ta - 1 bytes
   For Tempb = 3 To Ta
      Templ = Templ * 256
      Templ = Templ + Command_b(tempb)
   Next Tempb
End If
If Templ < Tb Then
   'check limit
   If New_commandmode < 10 Then Gosub Setcommandmode
   If Tc < 255 Then
      Dtmfchar = Tc
      Gosub Dtmf
     End If
   'convert to Te  digits
   Templl = Td
   For Tempb = 1 To Te
      Templlll = Templ / Templl
      DTMFchar = Templlll
      Gosub Dtmf
      Templll = Dtmfchar * Templl
      Templ = Templ - Templll
      Templl = Templl / 10
   Next Tempb
   If Tf < 255 Then
      Dtmfchar = Tf
      Gosub Dtmf
   End If
Else
   Error_no = 4
   Error_cmd_no = Command_no
End If
Gosub Command_received
Return
'
Frequency:
'long word / 4 byte 0 to 9999999 -> 7 digits
New_commandmode = 1
Tb = 10000000
Tc = Vfo_a_b
Td = 1000000
Te = 7
Tf = Vfo_a_b
Gosub Send_dtmf
Return
'
Memory:
'1 byte, 0 to 99 -> 2 digits
New_commandmode = 1
Tb = 100
Tc = Memory_set_recall
Td = 10
Te = 2
Tf = 255
Gosub Send_dtmf
Return
'
Single_dtmf_char:
   Gosub Setcommandmode
   DTMFchar = Tempb
   Gosub Dtmf
   Gosub Command_received
Return
'
Command3_1_5:
Gosub Setcommandmode
Select Case Command_b(2)
   Case 0                                       'off: 0 Func
      Dtmfchar = 0
      Gosub Dtmf
      Dtmfchar = Func
      Gosub Dtmf
   Case 1                                       'on: Func
      Dtmfchar = Func
      Gosub Dtmf
   Case Else
      Error_no = 4
      Error_cmd_no = Command_no
End Select
Gosub Command_received
'
Tx_function:
New_commandmode = 4
Gosub Setcommandmode
Select Case Command_b(2)
   Case 0
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 1
      Gosub Dtmf
   Case 1
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 2
      Gosub Dtmf
   Case 2
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 3
      Gosub Dtmf
   Case 3
      If Func = 9 Then
         Dtmfchar = Func
         Gosub Dtmf
         Dtmfchar = 4
         Gosub Dtmf
      Else
         Error_no = 4
         Error_cmd_no = Command_no
      End If
   Case Else
      Error_no = 4
      Error_cmd_no = Command_no
End Select
Gosub Command_received
Return
'
Command6_:
New_commandmode = 6
Gosub Setcommandmode
Select Case Command_b(2)
   Case 0
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 0
      Gosub Dtmf
   Case 1
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 1
      Gosub Dtmf
   Case Else
      Error_no = 4
      Error_cmd_no = Command_no
End Select
Gosub Command_received
'
Setcommandmode:
   If Commandmode <> New_commandmode Then
      Commandmode = New_commandmode
      Dtmfchar = 11
      Gosub Dtmf
      Dtmfchar = New_commandmode
      Gosub Dtmf
   End If
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
'Data "0;m;DK1RI;MFJ RBC Interface(TM);V03.0;1;145;1;61;1-1"
      I2c_tx_busy = 2
      Tx_time = 1
      A_line = 0
      Number_of_lines = 1
      Send_lines = 3
      Gosub Sub_restore
      print i2c_tx
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
'All Menues
'
   Case 1
'Befehl &H01
'setzt FrequenzVFO A, command * VFOA  *
'set frequency
'Data "1;op,set frequency;1;10000000,{0 to 999999900};lin;Hz"
      If Commandpointer >= 5 Then
         Vfo_a_b = 10
         Gosub Frequency
      Else
         Incr Commandpointer
      End If
'
   Case 2
'Befehl &H02
'setzt Frequenz VFO B, command * VFOB #
'set frequency
'Data "2;op,set frequency;1;10000000,{0 to 999999900};lin;Hz"
      If Commandpointer >= 5 Then
         Vfo_a_b = 11
         Gosub Frequency
      Else
         Incr Commandpointer
      End If
'
   Case 3
'Befehl &H03
'gibt frequenz ausVFO A (als Sprache),  command **
'play frequency VFOA
'Data "3;ou,frequency VFO A;1;0;idle;1 play"
      Dtmfchar = 10
      Gosub Dtmf
      '*
      Gosub Dtmf
      Gosub Command_received
'
   Case 4
'Befehl &H04
'gibt frequenz aus (als Sprache),  command ##
'play frequency VFOB
'Data "4;ou,frequency VFOB;1;0,idle;1 play"
      Dtmfchar = 11
      Gosub Dtmf
      '#
      Gosub Dtmf
      Gosub Command_received
'
'Menu 1 RX
'
   Case 5
'Befehl &H05   0 to 3
'Aendert Frequenz um 1 Step; command #1 1 4 8 0
'change frequency 1 step
'Data"5;os,change frequency;1;0,+100;1,-100;2,+500;3,-500"
      If Commandpointer = 2 Then
         If Command_b(2) < 4 Then
            New_commandmode = 1
            Gosub Setcommandmode
            Select Case Command_b(2)
               Case 0
                  Dtmfchar = 1
                  Gosub Dtmf
               Case 1
                  Dtmfchar = 4
                  Gosub Dtmf
               Case 2
                  Dtmfchar = 8
                  Gosub Dtmf
               Case 3
                  Dtmfchar = 0
                  Gosub Dtmf
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
   Case 6
'Befehl &H06    0 to 4
'startet scan,  command #1 2 3 5 6 0
'start scan
'Data"6;os,scan;0,medium up;1;1,fast up;2,medium down;3,fast down;4,stop"
      If Commandpointer = 2 Then
         If Command_b(2) < 5 Then
            New_commandmode = 1
            Gosub Setcommandmode
            Select Case Command_b(2)
               Case 0
                  Dtmfchar = 2
                  Gosub Dtmf
               Case 1
                  Dtmfchar = 3
                  Gosub Dtmf
               Case 2
                  Dtmfchar = 5
                  Gosub Dtmf
               Case 3
                  Dtmfchar = 6
                  Gosub Dtmf
               Case 4
                  Dtmfchar = 0
                  Gosub Dtmf
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
'Befehl &H07   0 to 99
'setzt memory, command #1 7 x x
'set memory
'Data "7;op,set memory;1;100,{0 to 99};lin;-"
      If Commandpointer >= 5 Then
         Memory_set_recall = 7
         Gosub Memory
      Else
         Incr Commandpointer
      End If
'
   Case 8
'Befehl &H08   0 to 99
'recall memory, command #1 9 x x
'recall memory
'Data "8;op,recall memory frequency;1;100,{0 to 99};lin;-"
      If Commandpointer >= 5 Then
         Memory_set_recall = 9
         Gosub Memory
      Else
         Incr Commandpointer
      End If
'
'=================================================0
'Menu 2  Antenna
'
   Case 9
'Befehl &H09
'Ant 1 ein, command #2 1
'Ant 1 on
'Data"9;ou,Ant1;1;0,idle;1,Ant1"
      New_commandmode = 2
      Tempb = 1
      Gosub Single_dtmf_char
'
   Case 10
'Befehl &H0A
'Ant 2 ein command #2 2
'Ant 2 on
'Data "10;ou,Ant2;1.0;idle;1,Ant2"
      New_commandmode = 2
      Tempb = 2
      Gosub Single_dtmf_char
'
   Case 11
'Befehl &H0B
'Tuner an, command #2 3
'Tuner on
'Data"11;ou,Tuner on;1;0,idle;1,tuner on"
      New_commandmode = 2
      Tempb = 3
      Gosub Single_dtmf_char
'
   Case 12
'Befehl &H0C
'Tuner aus, command #2 6
'Tuner off
'Data"12;ou,Tuner off;1;0,idle;1,tuner off"
      New_commandmode = 2
      Tempb = 6
      Gosub Single_dtmf_char
'
   Case 13
'Befehl &H0D
'Aux1 an, command #2 7
'Aux1 on
'Data"13;ou,Aux1 on;1;0,idle;1,aux1 on"
      New_commandmode = 2
      Tempb = 7
      Gosub Single_dtmf_char
'
   Case 14
'Befehl &H0E
'Aux1 aus, command #2 8
'Aux1 off
'Data"13;ou,Aux1 off;1;0,idle;1,aux1 off"
      New_commandmode = 2
      Tempb = 8
      Gosub Single_dtmf_char
'
   Case 15
'Befehl &H0F
'Tune Antenne command #2 9
'Tune Antenna
'Data"15;ou,Tune Antenna on;1;0,idle;1,tune antenna on"
      New_commandmode = 2
      Tempb = 9
      Gosub Single_dtmf_char
'
   Case 16
'Befehl &H10
'0 to 359 dreht Antenne1, command #2 4 x x x
'Rotate Ant1
'Data "16;op,rotate Antenna 1;1;360,{0 to 359}"
      If Commandpointer >= 3 Then
         New_commandmode = 2
         Antenna = 4
         Tb = 361
         Tc = Antenna
         Td = 100
         Te = 3
         Tf = 255
         Gosub Send_dtmf
      Else
         Incr Commandpointer
      End If
'
   Case 17
'Befehl &H11
'0 to 359 dreht Antenne2, command #2 5 x x x
'Rotate Ant2
'Data "17;op,rotate Antenna 2;1;360,{0 to 359}"
      If Commandpointer >= 3 Then
         New_commandmode = 2
         Antenna = 5
         Tb = 361
         Tc = Antenna
         Td = 100
         Te = 3
         Tf = 255
         Gosub Send_dtmf
      Else
         Incr Commandpointer
      End If
'
   Case 18
'Befehl &H12
'stoppt Rotor, command #2 0
'stops rotation
'Data"18;ou,stop ratation;1;0,idle;1,stop antenna"
      New_commandmode = 2
      Tempb = 0
      Gosub Single_dtmf_char
'
'=================================================0
'Menu 3  Filter
'
   Case 19
'Befehl &H13   0,1
'Abschwächer, command #3 1  or #3 0 1
'Attenuator
'Data"19;ou,Attenuator;1;0.idle;1,attenuator"
      If Commandpointer = 2 Then
         New_commandmode = 3
         Func = 1
         Gosub Command3_1_5
      Else
         Incr Commandpointer
      End If
'
   Case 20
'Befehl &H14   0,1
'Vorverstärker, command #3 2 Or #3 0 2
'Preamp
'Data"20;ou,Preamp;1;0.idle;1,preamp"
      If Commandpointer = 2 Then
         New_commandmode = 3
         Func = 2
         Gosub Command3_1_5
      Else
         Incr Commandpointer
      End If
'
   Case 21
'Befehl &H15   0,1
'Noiseblanker,command #3 3 Or #3 0 3
'Noiseblanker
'Data"21;ou,Noise blanker;1;0.idle;1,noise blanke"
      If Commandpointer = 2 Then
         New_commandmode = 3
         Func = 3
         Gosub Command3_1_5
      Else
         Incr Commandpointer
      End If
'
   Case 22
'Befehl &H16   0,1
'Rauschunterdrückung, command #3 4 Or #3 0 4
'Noise reduction
'Data"22;ou,Noise reduction;1;0.idle;1,noise reduction"
      If Commandpointer = 2 Then
         New_commandmode = 3
         Func = 4
         Gosub Command3_1_5
      Else
         Incr Commandpointer
      End If
'
   Case 23
'Befehl &H17   0,1
'Auto Notch #3 5 Or #3 0 5
'Auto notch
'Data"23;ou,Auto Notch;1;0.idle;1,auto notxh"
      If Commandpointer = 2 Then
         New_commandmode = 3
         Func = 5
         Gosub Command3_1_5
      Else
         Incr Commandpointer
      End If
'
   Case 24
'Befehl &H18   0 to 2
'setzt filter, command #3 7.. 8... 9
'set filter
'Data"24;os,Filter;1;0,narrow;1,medium;2,wide"
      If Commandpointer = 2 Then
         New_commandmode = 3
         Gosub Setcommandmode
         Select Case Command_b(2)
            Case 0
               Dtmfchar = 7
               Gosub Dtmf
            Case 1
               Dtmfchar = 8
               Gosub Dtmf
            Case 2
               Dtmfchar = 9
               Gosub Dtmf
            Case Else
               Error_no = 4
               Error_cmd_no = Command_no
         End Select
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 25
'Befehl &H19
'alle Function aus, command #3 0 0
'all functions off
'Data"25;ou,all filter functions off;1;0,idle;1,all filter off"
      New_commandmode = 3
      Gosub Setcommandmode
      Dtmfchar = 0
      Gosub Dtmf
      Gosub Dtmf
      Gosub Command_received
'
   Case 26
'Befehl &H1A   0 to 4
'setzt Betriebsart, command #3 6 1, 2, 3, 4, 5
'set mode
'Data"26;os,Mode;1;0,LSB;1,USB;2,AM;3,CW;4,FM"
      If Commandpointer = 2 Then
         If Command_b(2) < 5 Then
            New_commandmode = 3
            Gosub Setcommandmode
            Dtmfchar = 6
            Gosub Dtmf
            Select Case Command_b(2)
               Case 0
                  Dtmfchar = 1
                  Gosub Dtmf
               Case 1
                  Dtmfchar = 2
                  Gosub Dtmf
               Case 2
                  Dtmfchar = 3
                  Gosub Dtmf
               Case 3
                  Dtmfchar = 4
                  Gosub Dtmf
               Case 4
                  Dtmfchar = 5
                  Gosub Dtmf
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
'=================================================0
'Menu 4 TX
'
   Case 27
'Befehl &H1B   0,1
'Sprachkompressor, command #4 2 Or #4 0 2
'speech compressor
'Data"27;ou,spech compressor;1;0.idle;1,speech compressor"
      If Commandpointer = 2 Then
         New_commandmode = 4
         Func = 2
         Gosub Command3_1_5
      Else
         Incr Commandpointer
      End If
'
   Case 28
'Befehl &H1C   0,1
'VOX, command #4 3 Or #4 0 3
'VOX
'Data"28;ou,VOX;1;0.idle;1,vox"
      If Commandpointer = 2 Then
         New_commandmode = 4
         Func = 3
         Gosub Command3_1_5
      Else
         Incr Commandpointer
      End If
'
   Case 29
'Befehl &H1D   0,1
'Tone, command #4 4 Or #4 0 4
'Tone
'Data"29;ou,Tone;1;0.idle;1,tone"
      If Commandpointer = 2 Then
         New_commandmode = 4
         Func = 4
         Gosub Command3_1_5
      Else
         Incr Commandpointer
      End If
'
   Case 30
'Befehl &H1E   0,1
'split, command #4 5 Or #4 0 5
'split
'Data"30;ou,split;1;0.idle;1,split"
      If Commandpointer = 2 Then
         New_commandmode = 4
         Func = 5
         Gosub Command3_1_5
      Else
         Incr Commandpointer
      End If
'
   Case 31
'Befehl &H1F   0,1
'Vertärker #4 6 Or #4 0 6
'Amplifier
'Data"31;ou,Amplifier;1;0.idle;1,amplifier"
      If Commandpointer = 2 Then
         New_commandmode = 4
         Func = 6
         Gosub Command3_1_5
      Else
         Incr Commandpointer
      End If

   Case 32
'Befehl &H20
'alle Sendefunctionen aus, command #4 0 0
'all tx functions off
'Data"32;ou,all TX functions off;1;0.idle;1,tx function off"
      New_commandmode = 4
      Gosub Setcommandmode
      Dtmfchar = 0
      Gosub Dtmf
      Gosub Dtmf
      Gosub Command_received
'
   Case 33
'Befehl  &H21  0 to 9999
'setzt tone Frequenz, command #4 7 x x x x
'set tone frequency
'Data "33;op,tone frequency;1;1000,{0 to 999,9};lin;Hz"
      If Commandpointer >= 3 Then
         New_commandmode = 4
         Tb = 10000
         Tc = 7
         Td = 1000
         Te = 4
         Tf = 255
         Gosub Send_dtmf
      Else
         Incr Commandpointer
      End If
'
   Case 34:
'Befehl &H22   0 to 2
'setzt shift,command #4 8 x
'set shift
'Data"34;os,Shift;1;0,simplex;1,+;2,-"
      If Commandpointer >= 2 Then
         Func = 8
         Gosub Tx_function
      Else
         Incr Commandpointer
      End If
'
   Case 35
'Befehl &H23      0 to 3
'Ausgangsleistung, command #4 9 x
'set power
'Data"35;os,power;1;0,25%;1,50%;2,75%;3,100%"
      If Commandpointer >= 2 Then
         Func = 9
         Gosub Tx_function
      Else
         Incr Commandpointer
      End If
'
'=================================================0
'Menu 6 Aux
'
   Case 36
'Befehl &H24   0,1
'AUX2 an au, command #6 2 0 Or #6 2 1
'AUX2 on off
'Data"36;ou,AUX2;1;0.idle;1,aux2"
      If Commandpointer >= 2 Then
         Func = 2
         Gosub Command6_
      Else
         Incr Commandpointer
      End If
'
   Case 37
'Befehl &H25   0,1         #
'AUX3 an au, command #6 3 0 Or #6 3 1
'AUX3 on off
'Data"37;ou,AUX3;1;0.idle;1,aux3"
      If Commandpointer >= 2 Then
         Func = 3
         Gosub Command6_
      Else
         Incr Commandpointer
      End If
'
   Case 38
'Befehl &H26   0,1
'AUX4 an au, command #6 4 0 Or #6 4 1
'AUX4 on off
'Data"38;ou,AUX4;1;0.idle;1,aux4"
      If Commandpointer >= 2 Then
         Func = 4
         Gosub Command6_
      Else
         Incr Commandpointer
      End If
'
   Case 39
'Befehl &H27   0,1
'AUX5 an au, command #6 5 0 Or #6 5 1
'AUX5 on off
'Data"39;ou,AUX5;1;0.idle;1,aux5"
      If Commandpointer >= 2 Then
         Func = 5
         Gosub Command6_
      Else
         Incr Commandpointer
      End If
'
   Case 40
'Befehl &H28   0,1
'AUX6 an au, command #6 6 0 Or #6 6 1
'AUX6 on off
'Data"40;ou,AUX6;1;0.idle;1,aux6"
      If Commandpointer >= 2 Then
         Func = 6
         Gosub Command6_
      Else
         Incr Commandpointer
      End If
'
   Case 41
'Befehl &H29   0,1
'AUX7 an au, command #6 7 0 Or #6 7 1
'AUX7 on off
'Data"41;ou,AUX7;1;0.idle;1,aux7"
      If Commandpointer >= 2 Then
         Func = 7
         Gosub Command6_
      Else
         Incr Commandpointer
      End If
'
   Case 42
'Befehl &H2A   0,1
'AUX8 an au, command #6 8 0 Or #6 8 1
'AUX8 on off
'Data"42;ou,AUX8;1;0.idle;1,aux8"
      If Commandpointer >= 2 Then
         Func = 8
         Gosub Command6_
      Else
         Incr Commandpointer
      End If
'
   Case 43
'Befehl &H2B   0,1
'AUX9 an au, command #6 9 0 Or #6 9 1
'AUX9 on off
'Data"43;ou,AUX9;1;0.idle;1,aux9"
      If Commandpointer >= 2 Then
         Func = 9
         Gosub Command6_
      Else
         Incr Commandpointer
      End If
'
'=================================================0
'menu 5: Settings
'
   Case 44
'Befehl &H2C
'reset, command #5 5
'reset
'Data"44;ou,reset;1;0.idle;1,reset"
      New_commandmode = 5
      Gosub Setcommandmode
      Dtmfchar = 5
      Gosub Dtmf
      Gosub Command_received
'
   Case 45
'Befehl &H2D
'Sprachlautstärke auf, command #5 8
'voice volume up
'Data"45;ou,voice volume up;1;0.idle;1,volume up"
      New_commandmode = 5
      Gosub Setcommandmode
      Dtmfchar = 8
      Gosub Dtmf
      Gosub Command_received
'
   Case 46
'Befehl &H2E
'Sprachlautstärke ab, command #5 0
'voice volume down
'Data"46;ou,voice volume down;1;0.idle;1,volume down"
      New_commandmode = 5
      Gosub Setcommandmode
      Dtmfchar = 0
      Gosub Dtmf
      Gosub Command_received
'
   Case 47
'Befehl &H2F   0 to 9
'Zahl der Ruftone, command#5 7 x
'number of ring
'Data"47;op,number of ring;1;10,{0 to 9}"
      If Commandpointer >= 2 Then
         New_commandmode = 5
         Tb = 10
         Tc = 7
         Td = 1
         Te = 1
         Tf = 255
         Gosub Send_dtmf
      Else
         Incr Commandpointer
      End If
'
   Case 48
'Befehl &H30   0 to 9999
'passwort festlegen, command #5 4 x x x x
'set password
'Data"48;om,set password;L,{0 to 9999}"
      If Commandpointer >= 3 Then
         New_commandmode = 5
         Tb = 10000
         Tc = 4
         Td = 1000
         Te = 4
         Tf = 255
         Gosub Send_dtmf
      Else
         Incr Commandpointer
      End If
'
'=================================================0
'Menu 4 Transmit
'
   Case 49
'Befehl &H31
'Sende ein, command #4 1
'transmit
'Data"49;ou,transmit;1;0.idle;1,transmit"
      New_commandmode = 4
      Gosub  Setcommandmode
      DTMFchar = 1
      Gosub Dtmf
      Gosub Command_received
'
   Case 50
'Befehl &H32
'Spielt Ch1 beim Senden, command #4 1
'play Ch1
'Data"50;ou,play Ch1;1;0.idle;1,play ch 1"
      New_commandmode = 4
      Gosub  Setcommandmode
      DTMFchar = 3
      Gosub Dtmf
      Gosub Command_received
'
'=================================================0
'Start
'
   Case 51
'Befehl &H33
'Start, command *
' start
'Data"51;ou,start;1;0.idle;1,start"
      DTMFchar = 10
      Gosub Dtmf
      Gosub Init
      Gosub Command_received
'
   Case 234
'Befehl &HEA
'DTMF Länge schreiben
'write DTMF length
'Data "234;ka,DTMF Duration;b"
      If Commandpointer = 2 Then
         Dtmf_duration = Command_b(2)
         Dtmf_duration_eeram = Dtmf_duration
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 235
'Befehl &HEB
'Dtmf duration lesen
'read DTMF Länge
'Data "235;la,as234"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &HEB
      I2c_tx_b(2) = Dtmf_duration
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 236
'Befehl &HEC
'Dtmf Pause schreiben
'write DTMF Pause
'Data "236;ka,DTMF Pause;b"
      If Commandpointer = 2 Then
         Dtmf_pause = Command_b(2)
         Dtmf_pause_eeram = Dtmf_pause
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 237
'Befehl &HED
'Dtmf Pause lesen
'read DTMF Pause
'Data "237;la,as236"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &HEB
      I2c_tx_b(2) = Dtmf_pause
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
'Data "240;ln,ANNOUNCEMENTS;145;61"
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
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,14,{0 to 127};a,RS232,1;a,USB,1"
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
'Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,14,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
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
'announce text
'
Announce0:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;MFJ RBC Interface(TM);V03.0;1;145;1;61;1-1"
'
Announce1:
'Befehl &H01
'setzt FrequenzVFO A, command * VFOA  *
'set frequency
Data "1;op,set frequency;1;10000000,{0 to 999999900};lin;Hz"
'
Announce2:
'Befehl &H02
'setzt Frequenz VFO B, command * VFOB #
'set frequency
Data "2;op,set frequency;1;10000000,{0 to 999999900};lin;Hz"
'
Announce3:
'Befehl &H03
'gibt frequenz ausVFO A (als Sprache),  command **
'play frequency VFOA
Data "3;ou,frequency VFO A;1;0;idle;1 play"
'
Announce4:
'Befehl &H04
'gibt frequenz aus (als Sprache),  command ##
'play frequency VFOB
Data "4;ou,frequency VFOB;1;0,idle;1 play"
'
Announce5:
'Befehl &H05   0 to 3
'Aendert Frequenz um 1 Step; command #1 1 4 8 0
'change frequency 1 step
Data"5;os,change frequency;1;0,+100;1,-100;2,+500;3,-500"
'
Announce6:
'Befehl &H06    0 to 4
'startet scan,  command #1 2 3 5 6 0
'start scan
Data"6;os,scan;0,medium up;1;1,fast up;2,medium down;3,fast down;4,stop"
'
Announce7:
'Befehl &H07   0 to 99
'setzt memory, command #1 7 x x
'set memory
Data "7;op,set memory;1;100,{0 to 99};lin;-"
'
Announce8:
'Befehl &H08   0 to 99
'recall memory, command #1 9 x x
'recall memory
Data "8;op,recall memory frequency;1;100,{0 to 99};lin;-"
'
Announce9:
'Befehl &H09
'Ant 1 ein, command #2 1
'Ant 1 on
Data"9;ou,Ant1;1;0,idle;1,Ant1"
'
Announce10:
'Befehl &H0A
'Ant 2 ein command #2 2
'Ant 2 on
Data "10;ou,Ant2;1.0;idle;1,Ant2"
'
Announce11:
'Befehl &H0B
'Tuner an, command #2 3
'Tuner on
Data"11;ou,Tuner on;1;0,idle;1,tuner on"
'
Announce12:
'Befehl &H0C
'Tuner aus, command #2 6
'Tuner off
Data"12;ou,Tuner off;1;0,idle;1,tuner off"
'
Announce13:
'Befehl &H0D
'Aux1 an, command #2 7
'Aux1 on
Data"13;ou,Aux1 on;1;0,idle;1,aux1 on"
'
Announce14:
'Befehl &H0E
'Aux1 aus, command #2 8
'Aux1 off
Data"13;ou,Aux1 off;1;0,idle;1,aux1 off"
'
Announce15:
'Befehl &H0F
'Tune Antenne command #2 9
'Tune Antenna
Data"15;ou,Tune Antenna on;1;0,idle;1,tune antenna on"
'
Announce16:
'Befehl &H10
'0 to 359 dreht Antenne1, command #2 4 x x x
' Rotate Ant1
Data "16;op,rotate Antenna 1;1;360,{0 to 359}"
'
Announce17:
'Befehl &H11
'0 to 359 dreht Antenne2, command #2 5 x x x
'Rotate Ant2
Data "17;op,rotate Antenna 2;1;360,{0 to 359}"
'
Announce18:
'Befehl &H12
'stoppt Rotor, command #2 0
'stops rotation
Data"18;ou,stop ratation;1;0,idle;1,stop antenna"
'
Announce19:
'Befehl &H13   0,1
'Abschwächer, command #3 1  or #3 0 1
'Attenuator
Data"19;ou,Attenuator;1;0.idle;1,attenuator"
'
Announce20:
'Befehl &H14   0,1
'Vorverstärker, command #3 2 Or #3 0 2
'Preamp
Data"20;ou,Preamp;1;0.idle;1,preamp"
'
Announce21:
'Befehl &H15   0,1
'Noiseblanker,command #3 3 Or #3 0 3
'Noiseblanker
Data"21;ou,Noise blanker;1;0.idle;1,noise blanke"
'
Announce22:
'Befehl &H16   0,1
'Rauschunterdrückung, command #3 4 Or #3 0 4
'Noise reduction
Data"22;ou,Noise reduction;1;0.idle;1,noise reduction"
'
Announce23:
'Befehl &H17   0,1
'Auto Notch #3 5 Or #3 0 5
'Auto notch
Data"23;ou,Auto Notch;1;0.idle;1,auto notxh"
'
Announce24:
'Befehl &H18   0 to 2
'setzt filter, command #3 7.. 8... 9
'set filter
Data"24;os,Filter;1;0,narrow;1,medium;2,wide"
'
Announce25:
'Befehl &H19
'alle Function aus, command #3 0 0
'all functions off
Data"25;ou,all filter functions off;1;0,idle;1,all filter off"
'
Announce26:
'Befehl &H1A   0 to 4
'setzt Betriebsart, command #3 6 1, 2, 3, 4, 5
'set mode
Data"26;os,Mode;1;0,LSB;1,USB;2,AM;3,CW;4,FM"
'
Announce27:
'Befehl &H1B   0,1
'Sprachkompressor, command #4 2 Or #4 0 2
'speech compressor
Data"27;ou,spech compressor;1;0.idle;1,speech compressor"
'
Announce28:
'Befehl &H1C   0,1
'VOX, command #4 3 Or #4 0 3
'VOX
Data"28;ou,VOX;1;0.idle;1,vox"
'
Announce29:
'Befehl &H1D   0,1
'Tone, command #4 4 Or #4 0 4
'Tone
Data"29;ou,Tone;1;0.idle;1,tone"
'
Announce30:
'Befehl &H1E   0,1
'split, command #4 5 Or #4 0 5
'split
Data"30;ou,split;1;0.idle;1,split"
'
Announce31:
'Befehl &H1F   0,1
'Vertärker #4 6 Or #4 0 6
'Amplifier
Data"31;ou,Amplifier;1;0.idle;1,amplifier"
'
Announce32:
'Befehl &H20
'alle Sendefunctionen aus, command #4 0 0
'all tx functions off
Data"32;ou,all TX functions off;1;0.idle;1,tx function off"
'
Announce33:
'Befehl  &H21  0 to 9999
'setzt tone Frequenz, command #4 7 x x x x
'set tone frequency
Data "33;op,tone frequency;1;1000,{0 to 999,9};lin;Hz"
'
Announce34:
'Befehl &H22   0 to 2
'setzt shift,command #4 8 x
'set shift
Data"34;os,Shift;1;0,simplex;1,+;2,-"
'
Announce35:
'Befehl &H23      0 to 3
'Ausgangsleistung, command #4 9 x
'set power
Data"35;os,power;1;0,25%;1,50%;2,75%;3,100%"
'
Announce36:
'Befehl &H24   0,1
'AUX2 an au, command #6 2 0 Or #6 2 1
'AUX2 on off
Data"36;ou,AUX2;1;0.idle;1,aux2"
'
Announce37:
'Befehl &H25   0,1         #
'AUX3 an au, command #6 3 0 Or #6 3 1
'AUX3 on off
Data"37;ou,AUX3;1;0.idle;1,aux3"
'
Announce38:
'Befehl &H26   0,1
'AUX4 an au, command #6 4 0 Or #6 4 1
'AUX4 on off
Data"38;ou,AUX4;1;0.idle;1,aux4"
'
Announce39:
'Befehl &H27   0,1
'AUX5 an au, command #6 5 0 Or #6 5 1
'AUX5 on off
Data"39;ou,AUX5;1;0.idle;1,aux5"
'
Announce40:
'Befehl &H28   0,1
'AUX6 an au, command #6 6 0 Or #6 6 1
'AUX6 on off
'
Announce41:
'Befehl &H29   0,1
'AUX7 an au, command #6 7 0 Or #6 7 1
'AUX7 on off
Data"41;ou,AUX7;1;0.idle;1,aux7"
'
Announce42:
'Befehl &H2A   0,1
'AUX8 an au, command #6 8 0 Or #6 8 1
'AUX8 on off
Data"42;ou,AUX8;1;0.idle;1,aux8"
'
Announce43:
'Befehl &H2B   0,1
'AUX9 an au, command #6 9 0 Or #6 9 1
'AUX9 on off
Data"43;ou,AUX9;1;0.idle;1,aux9"
'
Announce44:
'Befehl &H2C
'reset, command #5 5
'reset
Data"44;ou,reset;1;0.idle;1,reset"
'
Announce45:
'Befehl &H2D
'Sprachlautstärke auf, command #5 8
'voice volume up
Data"45;ou,voice volume up;1;0.idle;1,volume up"
'
Announce46:
'Befehl &H2E
'Sprachlautstärke ab, command #5 0
'voice volume down
Data"46;ou,voice volume down;1;0.idle;1,volume down"
'
Announce47:
'Befehl &H2F   0 to 9
'Zahl der Ruftone, command#5 7 x
'number of ring
Data"47;op,number of ring;1;10,{0 to 9}"
'
Announce48:
'Befehl &H30   0 to 9999
'passwort festlegen, command #5 4 x x x x
'set password
Data"48;om,set password;L,{0 to 9999}"
'
Announce49:
'Befehl &H31
'Sende ein, command #4 1
'transmit
Data"49;ou,transmit;1;0.idle;1,transmit"
'
Announce50:
'Befehl &H32
'Spielt Ch1 beim Senden, command #4 1
'play Ch1
Data"50;ou,play Ch1;1;0.idle;1,play ch 1"
'
Announce51:
'Befehl &H33
'Start, command *
' start
Data"51;ou,start;1;0.idle;1,start"
'
Announce52:
'Befehl &HEA
'DTMF Länge schreiben
'write DTMF length
Data "234;ka,DTMF Duration;b"
'
Announce53:
'Befehl &HEB
'Dtmf duration lesen
'read DTMF Länge
Data "235;la,as234"
'
Announce54:
'Befehl &HEC
'Dtmf Pause schreiben
'write DTMF Pause
Data "236;ka,DTMF Pause;b"
'
Announce55:
'Befehl &HED
'Dtmf Pause lesen
'read DTMF Pause
Data "237;la,as236"
'
Announce56:
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;61"
'
Announce57:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce58:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce59:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,14,{0 to 127};a,RS232,1;a,USB,1"
'
Announce60:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,14,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"