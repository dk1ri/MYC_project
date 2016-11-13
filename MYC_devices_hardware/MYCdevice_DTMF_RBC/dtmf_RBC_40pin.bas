'-----------------------------------------------------------------------
'name : dtmf_rbc_40pin.bas
'Version V02.1, 20160729
'for 40pin processor
'difference to 28pin version: pins only
'purpose : Programm for sending MYC protocol as DTMF Signals for romote Shack of MFJ (TM)
'This Programm workes as I2C slave
'Can be used with hardware rs232_i2c_interface Version V02.3 by DK1RI with atmega32 (or 16)
'The Programm supports the MYC protocol
'Slave max length of RS232 string is 252 Bytes.
'Please modify clock frequncy and processor type, if necessary
'
'micro : ATMega644 (or min 16)
'Fuse Bits :
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
'PROG &HFF,&HC6,&HD9,&HFF' generated. Take care that the chip supports all fuse bytes.
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other right are affected, this programm can be used
'under GPL (Gnu public licence)
'The command list of MFJ (TM) was used
'-----------------------------------------------------------------------
'Templates:
' dtmf_sender V3.1
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
'following line depends on the processor used!!!!
$regfile = "m644def.dat"
'for ATmega644
$crystal = 10000000
'DTMF need 8 - 10MHz
$baud = 19200
'use baud rate
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
'use byte library for smaller code
'$lib "mcsbyte.lbx"
'
'**************** Variables
Const Lf = 10
Const Stringlength = 252
Const Cmd_watchdog_time = 65000
'Number of main loop before command reset
Const Blinktime = 3000
Const No_of_announcelines = 66
'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte
'first run after reset
Dim L As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Tempe As Byte
Dim Templ As Long
Dim Tempw As Word
Dim Tempww As Word
Dim Templl As Long
Dim Templll As Long
Dim Templlll As Long
Dim Temps As String * 20
Dim I As Integer
'Blinkcounter  for tests
Dim J As Integer
Dim Temps_b(20) As Byte At Temps Overlay
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
'I2C Buffer
Dim I2c_tx As String * Stringlength
Dim I2c_tx_b(stringlength) As Byte At I2c_tx Overlay
Dim I2c_pointer As Byte
Dim I2c_length As Byte
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
Dim I2C_active As Byte
Dim I2C_active_eeram As Eram Byte
Dim RS232_active As Byte
Dim RS232_active_eeram As Eram Byte
Dim USB_active As Byte
Dim Usb_active_eeram As Eram Byte
Dim Send_lines As Byte
Dim Number_of_lines As Byte
'
Dim Dtmf_duration As Byte
Dim Dtmfchar As Byte
Dim New_dtmfchar As Byte
Dim Dtmf_duration_eeram As Eram Byte
Dim DTMF_pause As Byte
Dim Dtmf_pause_eeram As Eram Byte
Dim Command_mode As Byte
'0: rs232 input, 1: I2C input
Dim Commandmode As Byte
Dim Vfo_a_b As Byte
Dim New_commandmode As Byte
Dim Memory_set_recall As Byte
Dim Antenna As Byte
Dim Func As Byte
Dim Ta As Byte
Dim Tb As Long
Dim Tc As Byte
Dim Td As Long
Dim Te As Byte
Dim Tf As Byte
Dim I2C_name As Byte
Dim I2C_name_eeram As Eram Byte
'**************** Config / Init
'
Config PinB.0 = Input
PortB.0 = 1
Reset__ Alias PinB.0
Config  PORTD.5 = Output
DTMF_ Alias Portd.5
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
Gosub Blink_
'
Gosub Cmd_watch
'
'RS232 got data?
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
   If Command_mode = 0 Then
   'restart if i2cmode
      Command_mode = 1
      Gosub  Command_received
   End If
   If Commandpointer < Stringlength Then
   'If Buffer is full, chars are ignored !!
      Command_b(commandpointer) = A
      If Cmd_watchdog = 0 Then
         Cmd_watchdog = 1
         'start watchdog
         Reset Led3
         'LED on
      End If
      Gosub Slave_commandparser
   End If
End If
'
'I2C
Twi_control = Twcr And &H80
'twint set?
If Twi_control = &H80 Then
'twsr 60 -> start, 80-> daten, A0 -> stop
   Twi_status = Twsr
   Twi_status = Twi_status And &HF8
'slave send:
   If Command_mode = 0 Then
   'slave send only in I2C mode
      If Twi_status = &HA8 Or Twi_status = &HB8 Then
         If I2c_pointer <= I2c_length Then
            Twdr = I2c_tx_b(i2c_pointer)
            Incr I2c_pointer
         Else
         'last Byte, String finished
            If Send_lines = 1 Then
            'lines to send
               If Number_of_lines > 1 Then
                  Tempb = No_of_announcelines - 1
                  'A_line is incremented before READ, -> No_of_announcelines -1 is last valid line
                  If A_line < Tempb Then
                     Cmd_watchdog = 0
                     Decr Number_of_lines
                     Incr A_line
                     Gosub Sub_restore
                     Twdr = I2c_tx_b(i2c_pointer)
                     Incr I2c_pointer
                  Else
                     Cmd_watchdog = 0
                     Decr Number_of_lines
                     A_line = 0
                     Gosub Sub_restore
                     Twdr = I2c_tx_b(i2c_pointer)
                     Incr I2c_pointer
                  End If
               Else
                  Twdr =&H00
                  Send_lines = 0
                  I2c_length = 0
               End If
            Else
               Twdr =&H00
               Send_lines = 0
               I2c_length = 0
            End If
         End If
      End If
   End If
'
'I2C receives data and and interpet as commands.
'slave receive:
   If Twi_status = &H80 Or Twi_status = &H88 Then
      Tempb = Twdr
      If Command_mode = 1 Then
      'restart if rs232mode
         Command_mode = 0
         'i2c mode
         Gosub  Command_received
      End If
      If Commandpointer <= Stringlength Then
         Command_b(commandpointer) = Tempb
         If Cmd_watchdog = 0 Then Cmd_watchdog = 1
         'start watchdog
         Reset Led3
         'LED on  for tests
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
Dev_number = 1
Dev_number_eeram = Dev_number
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 28
Adress_eeram = Adress
Dtmf_duration = 50
Dtmf_duration_eeram = Dtmf_duration
Dtmf_pause = 50
Dtmf_pause_eeram = Dtmf_pause
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
Return
'
Init:
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram
Dtmf_duration = Dtmf_duration_eeram
Dtmf_pause = Dtmf_pause_eeram
I2C_active = I2C_active_eeram
RS232_active = RS232_active_eeram
Usb_active = Usb_active_eeram
Led3 = 1
Led4  = 1
DTMF_ = 0
I = 0
J = 0
Command_no = 1
Command_mode = 0
Announceline = 255
Last_error = " No Error"
Error_no = 255
'No Error
Gosub Command_received
Gosub Command_finished
Gosub Reset_i2c_tx
Return
'
Cmd_watch:
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong commands will be deleted
'all buffers are reset
If Cmd_watchdog > Cmd_watchdog_time Then
   Error_no = 3
   Gosub Last_err
   Gosub Command_received
   'reset commandinput
   Gosub Reset_i2c_tx
   'after that time also read must be finished
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
Blink_:
'for tests
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
If Command_no = 255 Then Command_no = 0
Return
'
Sub_restore:
Gosub Reset_i2c_tx
Error_no = 255
'no error
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
   Case 61
      Restore Announce61
   Case 62
      Restore Announce62
   Case 63
      Restore Announce63
   Case 64
      Restore Announce64
   Case 65
      Restore Announce65
   Case Else
      Error_no = 0
      Gosub Last_err
End Select
If Error_no = 255 Then
   Read I2c_tx
   I2c_length = Len(i2c_tx)
   For Tempb = I2c_length To 1 Step -1
   'shift 1 pos right
      I2c_tx_b(tempb + 1) = I2c_tx_b(tempb)
   Next Tempb
   I2c_tx_b(1) = I2c_length
   Incr I2c_length
   If Command_mode = 1 Then
      For Tempb = 1 To I2c_length
         Tempc = I2c_tx_b(Tempb)
         Printbin Tempc
      Next Tempb
   End If
   'complete length of string
End If
Return
'
Reset_i2c_tx:
I2c_length = 0
I2c_pointer = 1
I2c_tx = String(Stringlength,0)
Return
'
Dtmf:
   Dtmfout Dtmfchar , Dtmf_duration
   Waitms Dtmf_pause
   Printbin Dtmfchar
Return
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
Send_dtmf:
'long word /4 byte -> 7 digits
If Commandpointer = Ta Then
   Templ = Command_b(2)
   If Ta >2 Then
      For Tempb = 3 To Ta                                       'create long word from 4 bytes
         Templ = Templ * 256
         Templ = Templ + Command_b(tempb)
      Next Tempb
   End If
   If Templ < Tb Then
      If New_commandmode < 10 Then Gosub Setcommandmode
      If Tc < 255 Then
         Dtmfchar = Tc
         Gosub Dtmf
        End If                                              '255 will do nothing
      Templl = Td
      For Tempb = 1 To Te
         Templlll = Templ / Templl
         DTMFchar = Templlll
         Gosub Dtmf
         templll = Dtmfchar * Templl
         Templ = Templ - Templll
         Templl = Templl / 10
      Next Tempb
      If Tf < 255 Then
         Dtmfchar = Tf
         Gosub Dtmf
      End If
   Else
      Error_no = 4
      Gosub Last_err
   End If
   Gosub Command_received
Else
   Incr Commandpointer
End If
Return
'
Frequency:
'long word /4 byte 0 to 9999999 -> 7 digits
New_commandmode = 1
Ta= 5
Tb = 10000000
Tc = 10
Td = 1000000
Te = 7
Tf = Vfo_a_b
Gosub Send_dtmf
Return
'
Memory:
'1 byte, 0 to 99 -> 2 digits
New_commandmode = 1
Ta = 2
Tb = 100
Tc = Memory_set_recall
Td = 10
Te = 2
Tf = 255
Gosub Send_dtmf
Return
'
Tone:
'Tone 1 word, 0 - 9999 (0 - 9999 Hz ???) to 4 digits
New_commandmode = 4
Ta = 3
Tb = 10000
Tc = 7
Td = 1000
Te = 4
Tf = 255
Gosub Send_dtmf
Return
'
Password:
'Password 1 word, 0 - 9999 to 4 Digits
Ta = 3
Tb = 10000
Td = 1000
Te = 4
Tf = 255
Gosub Send_dtmf
Return
'
Rotate_antenna:
'Rotate_antenna 1 word, 0 to 365 -> 3 digits
New_commandmode = 2
Ta = 3
Tb = 361
Tc = Antenna
Td = 100
Te = 3
Tf = 255
Gosub Send_dtmf
Return
'
Ring:
'1 byte, 0 to 9 -> 1 digits
New_commandmode = 5
Ta = 2
Tb = 10
Tc = 7
Td = 1
Te = 1
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
If Commandpointer = 2 Then
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
         Gosub Last_err
   End Select
   Gosub Command_received
Else
   Incr Commandpointer
End If
Return
'
Tx_function:
     If Commandpointer = 2 Then
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
                  Gosub Last_err
               End If
            Case Else
               Error_no = 4
               Gosub Last_err
         End Select
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
Return
'
Command6_:
If Commandpointer = 2 Then
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
         Gosub Last_err
   End Select
   Gosub Command_received
Else
   Incr Commandpointer
End If
Return
'
Slave_commandparser:
If Commandpointer > 253 Then
'Error, do nothing
   Gosub Command_received
Else
'
   Select Case Command_b(1)
      Case 0
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
'Data "0;m;DK1RI;MFJ RBC Interface(TM);V02.0;1;160;1;66"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
'All Menues
'
   Case 1
'Befehl &H01
'setzt FrequenzVFO A, command * VFOA  *
'set frequency
'Data "1;om,set frequeny;L,(0 to 999999.9}"
      Vfo_a_b = 10
      New_commandmode = 1
      Gosub Frequency
'
   Case 2
'Befehl &H02
'setzt Frequenz VFO B, command * VFOB #
'set frequency
'Data "2;om,set frequency;L,{0 to 999999.9}"
      Vfo_a_b = 11
      New_commandmode = 1
      Gosub Frequency
'
   Case 3
'Befehl &H03
'gibt frequenz ausVFO A (als Sprache),  command **
'play frequency VFOA
'Data "3;ou,play frequency VFO A;0"
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
'Data "4;ou,play frequency VFOB;0"
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
'Data"5;ou,change frequency;0,+100;1,-100;2,+500;3,-500"
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
'Data"6;ou,scan;0,medium up;1,fast up;2,medium down;3,fast down;4,stop"
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
'Data "7;om,set memory;b,{0 to 99}"
      New_commandmode = 1
      Memory_set_recall = 7
      Gosub Memory
'
   Case 8
'Befehl &H08   0 to 99
'recall memory, command #1 9 x x
'recall memory
'Data "8;om,recall memory frequency;b,{0 to 99}"
'
      New_commandmode = 1
      Memory_set_recall = 9
      Gosub Memory
'
'=================================================0
'Menu 2  Antenna
'
   Case 9
'Befehl &H09
'Ant 1 ein, command #2 1
'Ant 1 on
'Data"9;ou,Ant1;0"
      New_commandmode = 2
      Tempb = 1
      Gosub Single_dtmf_char
'
   Case 10
'Befehl &H0A
'Ant 2 ein command #2 2
'Ant 2 on
'Data "10;ou,Ant2;0"
      New_commandmode = 2
      Tempb = 2
      Gosub Single_dtmf_char
'
   Case 11
'Befehl &H0B
'Tuner an, command #2 3
'Tuner on
'Data"11;ou,Tuner in;0"
      New_commandmode = 2
      Tempb = 3
      Gosub Single_dtmf_char
'
   Case 12
'Befehl &H0C
'Tuner aus, command #2 6
'Tuner off
'Data"12;ou,Tuner off;0"
      New_commandmode = 2
      Tempb = 6
      Gosub Single_dtmf_char
'
   Case 13
'Befehl &H0D
'Aux1 an, command #2 7
'Aux1 on
'Data"13;ou,Aux1 on;0"
      New_commandmode = 2
      Tempb = 7
      Gosub Single_dtmf_char
'
   Case 14
'Befehl &H0E
'Aux1 aus, command #2 8
'Aux1 off
'Data"13;ou,Aux1 off;0"
      New_commandmode = 2
      Tempb = 8
      Gosub Single_dtmf_char
'
   Case 15
'Befehl &H0F
'Tune Antenne command #2 9
'Tune Antennea
'Data"15;ou,Tune Antenna on;0"
      New_commandmode = 2
      Tempb = 9
      Gosub Single_dtmf_char
'
   Case 16
'Befehl &H10
'0 to 359 dreht Antenne1, command #2 4 x x x
' Rotatate Ant1
'Data "16;om,rotate Antenna 1;b,{0 to 359}"
      New_commandmode = 2
      Antenna = 4
      Gosub Rotate_antenna
'
   Case 17
'Befehl &H11
'0 to 359 dreht Antenne2, command #2 5 x x x
'Rotatate Ant2
'Data "17;om,rotate Antenna 2;b,{0 to 359}"
      New_commandmode = 2
      Antenna = 5
      Gosub Rotate_antenna
'
   Case 18
'Befehl &H12
'stoppt Rotor, command #2 0
'stops rotation
'Data"18;ou,stop ratation;0"
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
'Data"19;oa,Attenuator;a"
         New_commandmode = 3
         Func = 1
         Gosub Command3_1_5
'
   Case 20
'Befehl &H14   0,1
'Vorverstärker, command #3 2 Or #3 0 2
'Preamp
'Data"20;oa,Preamp;a"
         New_commandmode = 3
         Func = 2
         Gosub Command3_1_5
'
   Case 21
'Befehl &H15   0,1
'Noiseblanker,command #3 3 Or #3 0 3
'Noiseblanker
'Data"21;oa,Noise blanker;a"
         New_commandmode = 3
         Func = 3
         Gosub Command3_1_5
'
   Case 22
'Befehl &H16   0,1
'Rauschunterdrückung, command #3 4 Or #3 0 4
'Noise reduction
'Data"22;oa,Noise reduction;a"
         New_commandmode = 3
         Func = 4
         Gosub Command3_1_5
'
   Case 23
'Befehl &H17   0,1
'Auto Notch #3 5 Or #3 0 5
'Auto notch
'Data"23;oa,Auto Notch;a"
         New_commandmode = 3
         Func = 5
         Gosub Command3_1_5
'
   Case 24
'Befehl &H18   0 to 2
'setzt filter, command #3 7.. 8... 9
'set filter
'Data"24;os,Filter;0,narrow;1,medium;2,wide"
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
'Data"25;ou,all filter functions off;0"
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
'Data"26;os,Mode;0,LSB;1,USB;2,AM;3,CW;4,FM"
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
'Data"27;oa,spech compressor;a"
      New_commandmode = 4
      Func = 2
      Gosub Command3_1_5
'
   Case 28
'Befehl &H1C   0,1
'VOX, command #4 3 Or #4 0 3
'VOX
'Data"28;oa,VOX;a"
      New_commandmode = 4
      Func = 3
      Gosub Command3_1_5
'
   Case 29
'Befehl &H1D   0,1
'Tone, command #4 4 Or #4 0 4
'Tone
'Data"29;oa,Tone;a"
      New_commandmode = 4
      Func = 4
      Gosub Command3_1_5
'
   Case 30
'Befehl &H1E   0,1
'split, command #4 5 Or #4 0 5
'split
'Data"30;oa,split;a"
      New_commandmode = 4
      Func = 5
      Gosub Command3_1_5
'
   Case 31
'Befehl &H1F   0,1
'Vertärker #4 6 Or #4 0 6
'Amplifier
'Data"31;oa,Amplifier;a"
      New_commandmode = 4
      Func = 6
      Gosub Command3_1_5

   Case 32
'Befehl &H20
'alle Sendefunctionen aus, command #4 0 0
'all tx functions off
'Data"32;ou,all TX functions off;0"
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
'Data "33;op,tone frequency;1000,{0 to 999,9};lin;Hz"
      New_commandmode = 4
      Gosub Tone
'
   Case 34:
'Befehl &H22   0 to 2
'setzt shift,command #4 8 x
'set shift
'Data"34;os,Shift;0,simplex;1,+;2,-"
      Func = 8
      Gosub Tx_function
'
   Case 35
'Befehl &H23      0 to 3
'Ausgangsleistung, command #4 9 x
'set power
'Data"35;os,power;0,25%;1,50%;2,75%;3,100%"
      Func = 9
      Gosub Tx_function
'
'=================================================0
'Menu 6 Aux
'
   Case 36
'Befehl &H24   0,1
'AUX2 an au, command #6 2 0 Or #6 2 1
'AUX2 on off
'Data"36;oa,AUX2;a"
      Func = 2
      Gosub Command6_
'
   Case 37
'Befehl &H25   0,1         #
'AUX3 an au, command #6 3 0 Or #6 3 1
'AUX3 on off
'Data"37;oa,AUX3;a"
      Func = 3
      Gosub Command6_
'
   Case 38
'Befehl &H26   0,1
'AUX4 an au, command #6 4 0 Or #6 4 1
'AUX4 on off
'Data"38;oa,AUX4;a"
      Func = 4
      Gosub Command6_
'
   Case 39
'Befehl &H27   0,1
'AUX5 an au, command #6 5 0 Or #6 5 1
'AUX5 on off
'Data"39;oa,AUX5;a"
      Func = 5
      Gosub Command6_
'
   Case 40
'Befehl &H28   0,1
'AUX6 an au, command #6 6 0 Or #6 6 1
'AUX6 on off
'Data"40;oa,AUX6;a"
      Func = 6
      Gosub Command6_
'
   Case 41
'Befehl &H29   0,1
'AUX7 an au, command #6 7 0 Or #6 7 1
'AUX7 on off
'Data"41;oa,AUX7;a"
      Func = 7
      Gosub Command6_
'
   Case 42
'Befehl &H2A   0,1
'AUX8 an au, command #6 8 0 Or #6 8 1
'AUX8 on off
'Data"42;oa,AUX8;a"
      Func = 8
      Gosub Command6_
'
   Case 43
'Befehl &H2B   0,1
'AUX9 an au, command #6 9 0 Or #6 9 1
'AUX9 on off
'Data"43;oa,AUX9;a"
      Func = 9
      Gosub Command6_
'
'=================================================0
'menu 5: Settings
'
   Case 44
'Befehl &H2C
'reset, command #5 5
'reset
'Data"44;ou,reset;0"
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
'Data"45;ou,voice volume up;0"
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
'Data"46;ou,voice volume down;0"
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
'Data"47;om,number of ring;b,{0 to 9}"
      New_commandmode = 5
      Gosub Ring
'
   Case 48
'Befehl &H30   0 to 9999
'passwort festlegen, command #5 4 x x x x
'set password
'Data"48;om,set password;L,{0 to 9999}"
      New_commandmode = 5
      Tc = 4
      Gosub Password

   Case 49
'Befehl &H31   0 to 255
'DTMF Länge
'DTMF length
'Data "49;oa,DTMF Duration;b"
      If Commandpointer = 2 Then
         Dtmf_duration = Command_b(2)
         Dtmf_duration_eeram = Dtmf_duration
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 50
'Befehl &H32   0 to 255
'DTMF Länge lesen
'read DTMF length
'Data "50;aa,as49"
      I2c_pointer = 1
      I2c_length = 1
      If Command_mode = 0 Then
         Printbin Dtmf_duration
      Else
         I2c_tx = String(stringlength , 0)
         I2c_tx_b(1) = Dtmf_duration
      End If
      Gosub Command_received
'
   Case 51
'Befehl &H33   0 to 255
'schreiben DTMF Pausezeit
'write DTMF wait
'Data "51;oa,DTMF wait;b"
      If Commandpointer = 2 Then
         Dtmf_pause = Command_b(2)
         Dtmf_pause_eeram = Dtmf_pause
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 52
'Befehl &H34   0 to 255
'DTMF Pausezeit lesen
'read DTMF wait
'Data "52;aa,as51"

      I2c_pointer = 1
      I2c_length = 1
      If Command_mode = 0 Then
         Printbin Dtmf_pause
      Else
         I2c_tx = String(stringlength , 0)
         I2c_tx_b(1) = Dtmf_pause
      End If
      Gosub Command_received
'
'=================================================0
'Menu 4 Transmit
'
   Case 53
'Befehl &H35
'Sende ein, command #4 1
'transmit
'Data"53;ou,transmit;0"
      New_commandmode = 4
      Gosub  Setcommandmode
      DTMFchar = 1
      Gosub Dtmf
      Gosub Command_received
'
   Case 54
'Befehl &H36
'Spielt Ch1 beim Senden, command #4 1
'play Ch1
'Data"54;ou,play Ch1;0"
      New_commandmode = 4
      Gosub  Setcommandmode
      DTMFchar = 3
      Gosub Dtmf
      Gosub Command_received
'
'=================================================0
'Start
'
   Case 55
'Befehl &H37
'Start, command *
' start
'Data"55;ou,start;0"
      DTMFchar = 10
      Gosub Dtmf
      Gosub Init
      Gosub Command_received
'
   Case 56
'Befehl &H38   0 to 9999
'passwort eingeben, command x x x x
'password
'Data"56;om,password;L,{0 to 9999}"
      New_commandmode = 255
      Tc = 255
      Gosub Password
'
      Case 234
'Befehl &HEA
'DTMF Länge schreiben
'write DTMF length
'Data "234;oa,DTMF Duration;b"
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
'Data "235;aa,as234"
         If Command_mode = 1 Then
            Printbin Dtmf_duration
         Else
            Gosub Reset_i2c_tx
            I2c_length = 1
            I2c_tx_b(1) = Dtmf_duration
         End If
         Gosub Command_received
'
      Case 236
'Befehl &HEC
'Dtmf Pause schreiben
'write DTMF Pause
'Data "236;oa,DTMF Pause;b"
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
'Data "237;aa,as236"
         I2c_length = 1
         If Command_mode = 1 Then
            Printbin Dtmf_pause
         Else
            Gosub Reset_i2c_tx
            I2c_length = 1
            I2c_tx_b(1) = Dtmf_pause
         End If
         Gosub Command_received
'
'=================================================0
   Case 240
      Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;100;66"
         If Commandpointer = 3 Then
            If Command_b(2) < No_of_announcelines And Command_b(3) <= No_of_announcelines Then
                If Command_b(3) > 0 Then
                  Send_lines = 1
                  Number_of_lines = Command_b(3)
                  A_line = Command_b(2)
                  Gosub Sub_restore
                  If Command_mode = 1 Then
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
         Gosub Reset_i2c_tx
         Temps = Str(command_no)
         I2c_length = Len(temps)
         For Tempb = 1 To I2c_length
            I2c_tx_b(tempb + 1) = Temps_b(tempb)
            '+1: leave space for length
         Next Tempb
         Incr I2c_length
         'because of 1 byte with length
         Tempb = Len(last_error)
         For Tempc = 1 To Tempb
            Tempd = Tempc + I2c_length
            'write at the end
            I2c_tx_b(tempd) = Last_error_b(tempc)
         Next Tempc
         I2c_length = Tempd
         'last tempd is length
         Decr Tempd
         I2c_tx_b(1) = Tempd
         If Command_mode = 1 Then
            For Tempb = 1 To I2c_length
               Tempc = I2c_tx_b(tempb)
               Printbin Tempc
            Next Tempb
         End If
         Gosub Command_received
'
       Case 253
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
'Data "253;aa,MYC INFO;b,ACTIVE"
         Gosub Reset_i2c_tx
         If Command_mode = 1 Then
            Printbin 4
         Else
            I2c_tx_b(1) = 4
            'no info
            I2c_length = 1
         End If
         Gosub Command_received
'
      Case 254
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,14,{0 to 127};a,RS232,1;a,USB,1"
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
                  'as per announcement: bit
                     If Command_b(3) < 2 Then
                        I2C_active = Command_b(3)
                        I2C_active_eeram = I2C_active
                     Else
                        Error_no = 4
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
                     Else
                        Gosub Last_err
                     End If
                     Gosub Command_received
                  Else
                     Incr Commandpointer
                  End If
               Case 4
                  If Commandpointer < 3 Then
                     Incr Commandpointer
                  Else
                     If Command_b(3) > 1 Then Command_b(3) = 1
                     RS232_active = Command_b(3)
                     RS232_active_eeram = RS232_active
                     Gosub Command_received
                  End If
               Case 5
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
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,14,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
         If Commandpointer = 2 Then
            Gosub Reset_i2c_tx
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
                  I2C_tx_b(1) = I2C_active
                  I2c_length = 1
               Case 3
                  Tempb = Adress / 2
                  I2c_tx_b(1) = Tempb
                  I2c_length = 1
               Case 4
                  I2c_tx_b(1) = RS232_active
                  I2c_length = 1
               Case 5
                  I2c_tx_b(1) = 0
                  I2c_length = 1
               Case 6
                  I2c_tx = "8n1"
                  I2c_length = 3
               Case 7
                  I2c_tx_b(1) = USB_active
                  I2c_length = 1
               Case Else
                  Error_no = 4
                  'ignore anything else
            End Select
            If Command_mode = 1 Then
               For Tempb = 1 To I2c_length
                  Tempc = I2c_tx_b(tempb)
                  Printbin Tempc
               Next Tempb
            End If
            Gosub Command_received
         Else
               Incr Commandpointer
         End If
      Case Else
         Error_no = 0
         'ignore anything else
         Gosub Command_received
      End Select
End If
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
Data "0;m;DK1RI;MFJ RBC Interface(TM);V02.2;1;160;1;66"
'
Announce1:
'Befehl &H01
'setzt FrequenzVFO A, command * VFOA  *
'set frequency
Data "1;om,set frequeny;L,{0 to 999999.9}"
'
Announce2:
'Befehl &H02
'setzt Frequenz VFO B, command * VFOB #
'set frequency
Data "2;om,set frequency;L,{0 to 999999.9}"
'
Announce3:
'Befehl &H03
'gibt frequenz aus VFO A (als Sprache),  command **
'play frequency VFOA
Data "3;ou,play frequency VFO A;0"
'
Announce4:
'Befehl &H04
'gibt frequenz aus (als Sprache),  command ##
'play frequency VFOB
Data "4;ou,play frequency VFOB;0"
'
Announce5:
'Befehl &H05   0 to 3
'Aendert Frequenz um 1 Step; command #1 1 4 8 0
'change frequency 1 step
Data"5;ou,change frequency;0,+100;1,-100;2,+500;3,-500"
'
Announce6:
'Befehl &H06    0 to 4
'startet scan,  command #1 2 3 5 6 0
'start scan
Data"6;ou,scan;0,medium up;1,fast up;2,medium down;3,fast down;4,stop"
'
Announce7:
'Befehl &H07   0 to 99
'setzt memory, command #1 7 x x
'set memory
Data "7;om,set memory;b,{0 to 99}"
'
Announce8:
'Befehl &H08   0 to 99
'recall memory, command #1 9 x x
'recall memory
Data "8;om,recall memory frequency;b,{0 to 99}"
'
Announce9:
'Befehl &H09
'Ant 1 ein, command #2 1
'Ant 1 on
Data"9;ou,Ant1;0"
'
Announce10:
'Befehl &H0A
'Ant 2 ein command #2 2
'Ant 2 on
Data "10;ou,Ant2;0"
'
Announce11:
'Befehl &H0B
'Tuner an, command #2 3
'Tuner on
Data"11;ou,Tuner in;0"
'
Announce12:
'Befehl &H0C
'Tuner aus, command #2 6
'Tuner off
Data"12;ou,Tuner off;0"
'
Announce13:
'Befehl &H0D
'Aux1 an, command #2 7
'Aux1 on
Data"13;ou,Aux1 on;0"
'
Announce14:
'Befehl &H0E
'Aux1 aus, command #2 8
'Aux1 off
Data"13;ou,Aux1 off;0"
'
Announce15:
'Befehl &H0F
'Tune Antenne command #2 9
'Tune Antennea
Data"15;ou,Tune Antenna on;0"
'
Announce16:
'Befehl &H10
'0 to 359 dreht Antenne1, command #2 4 x x x
' Rotatate Ant1
Data "16;om,rotate Antenna 1;b,{0 to 359}"
'
Announce17:
'Befehl &H11
'0 to 359 dreht Antenne2, command #2 5 x x x
'Rotatate Ant2
Data "17;om,rotate Antenna 2;b,{0 to 359}"
'
Announce18:
'Befehl &H12
'stoppt Rotor, command #2 0
'stops rotation
Data"18;ou,stop ratation;0"
'
Announce19:
'Befehl &H13   0,1
'Abschwächer, command #3 1  or #3 0 1
'Attenuator
Data"19;oa,Attenuator;a"
'
Announce20:
'Befehl &H14   0,1
'Vorverstärker, command #3 2 Or #3 0 2
'Preamp
Data"20;oa,Preamp;a"
'
Announce21:
'Befehl &H15   0,1
'Noiseblanker,command #3 3 Or #3 0 3
'Noiseblanker
Data"21;oa,Noise blanker;a"
'
Announce22:
'Befehl &H16   0,1
'Rauschunterdrückung, command #3 4 Or #3 0 4
'Noise reduction
Data"22;oa,Noise reduction;a"
'
Announce23:
'Befehl &H17   0,1
'Auto Notch #3 5 Or #3 0 5
'Auto notch
Data"23;oa,Auto Notch;a"
'
Announce24:
'Befehl &H18   0 to 2
'setzt filter, command #3 7.. 8... 9
'set filter
Data"24;os,Filter;0,narrow;1,medium;2,wide"
'
Announce25:
'Befehl &H19
'alle Function aus, command #3 0 0
'all functions off
Data"25;ou,all filter functions off;0"
'
Announce26:
'Befehl &H1A   0 to 4
'setzt Betriebsart, command #3 6 1, 2, 3, 4, 5
'set mode
Data"26;os,Mode;0,LSB;1,USB;2,AM;3,CW;4,FM"
'
Announce27:
'Befehl &H1B   0,1
'Sprachkompressor, command #4 2 Or #4 0 2
'speech compressor
Data"27;oa,spech compressor;a"
'
Announce28:
'Befehl &H1C   0,1
'VOX, command #4 3 Or #4 0 3
'VOX
Data"28;oa,VOX;a"
'
Announce29:
'Befehl &H1D   0,1
'Tone, command #4 4 Or #4 0 4
'Tone
Data"29;oa,Tone;a"
'
Announce30:
'Befehl &H1E   0,1
'split, command #4 5 Or #4 0 5
'split
Data"30;oa,split;a"
'
Announce31:
'Befehl &H1F   0,1
'Vertärker #4 6 Or #4 0 6
'Amplifier
Data"31;oa,Amplifier;a"
'
Announce32:
'Befehl &H20
'alle Sendefunctionen aus, command #4 0 0
'all tx functions off
Data"32;ou,all TX functions off;0"
'
Announce33:
'Befehl  &H21  0 to 9999
'setzt tone Frequenz, command #4 7 x x x x
'set tone frequency
Data "33;op,tone frequency;1000,{0 to 999,9};lin;Hz"
'
Announce34:
'Befehl &H22   0 to 2
'setzt shift,command #4 8 x
'set shift
Data"34;os,Shift;0,simplex;1,+;2,-"
'
Announce35:
'Befehl &H23      0 to 3
'Ausgangsleistung, command #4 9 x
'set power
Data"35;os,power;0,25%;1,50%;2,75%;3,100%"
'
Announce36:
'Befehl &H24   0,1
'AUX2 an au, command #6 2 0 Or #6 2 1
'AUX2 on off
Data"36;oa,AUX2;a"
'
Announce37:
'Befehl &H25   0,1         #
'AUX3 an au, command #6 3 0 Or #6 3 1
'AUX3 on off
Data"37;oa,AUX3;a"
'
Announce38:
'Befehl &H26   0,1
'AUX4 an au, command #6 4 0 Or #6 4 1
'AUX4 on off
Data"38;oa,AUX4;a"
'
Announce39:
'Befehl &H27   0,1
'AUX5 an au, command #6 5 0 Or #6 5 1
'AUX5 on off
Data"39;oa,AUX5;a"
'
Announce40:
'Befehl &H28   0,1
'AUX6 an au, command #6 6 0 Or #6 6 1
'AUX6 on off
Data"40;oa,AUX6;a"
'
Announce41:
'Befehl &H29   0,1
'AUX7 an au, command #6 7 0 Or #6 7 1
'AUX7 on off
Data"41;oa,AUX7;a"
'
Announce42:
'Befehl &H2A   0,1
'AUX8 an au, command #6 8 0 Or #6 8 1
'AUX8 on off
Data"42;oa,AUX8;a"
'
Announce43:
'Befehl &H2B   0,1
'AUX9 an au, command #6 9 0 Or #6 9 1
'AUX9 on off
Data"43;oa,AUX9;a"
'
Announce44:
'Befehl &H2C
'reset, command #5 5
'reset
Data"44;ou,reset;0"
'
Announce45:
'Befehl &H2D
'Sprachlautstärke auf, command #5 8
'voice volume up
Data"45;ou,voice volume up;0"
'
Announce46:
'Befehl &H2E
'Sprachlautstärke ab, command #5 0
'voice volume down
Data"46;ou,voice volume down;0"
'
Announce47:
'Befehl &H2F   0 to 9
'Zahl der Ruftone, command#5 7 x
'number of ring
Data"47;om,number of ring;b,{0 to 9}"
'
Announce48:
'Befehl &H30   0 to 9999
'passwort festlegen, command #5 4 x x x x
'set password
Data"48;om,set password;L,{0 to 9999}"
'
Announce49:
'Befehl &H31   0 to 255
'DTMF Länge
'DTMF length
Data "49;oa,DTMF Duration;b"
'
Announce50:
'Befehl &H32   0 to 255
'DTMF Länge lesen
'read DTMF length
Data "50;aa,as49"

Announce51:
'schreiben DTMF Pausezeit
'write DTMF wait
Data "51;oa,DTMF wait;b"
'
Announce52:
'Befehl &H34   0 to 255
'DTMF Pausezeit lesen
'read DTMF wait
Data "52;aa,as51"
'
Announce53:
'Befehl &H35
'Sende ein, command #4 1
'transmit
Data"53;ou,transmit;0"
'
Announce54:
'Befehl &H36
'Spielt Ch1 beim Senden, command #4 1
'play Ch1
Data"54;ou,play Ch1;0"
'
Announce55:
'Befehl &H37
'Start, command *
' start
Data"55;ou,start;0"
'
Announce56:
'Befehl &H38   0 to 9999
'passwort eingeben, command x x x x
'password
Data"56;om,password;L,{0 to 9999}"
'
Announce57:
'Befehl &HEA
'DTMF Länge schreiben
'write DTMF length
Data "234;oa,DTMF Duration;b"
'
Announce58:
'Befehl &HEB
'Dtmf duration lesen
'read DTMF Länge
Data "235;aa,as234"
'
Announce59:
'Befehl &HEC
'Dtmf Pause schreiben
'write DTMF Pause
Data "236;oa,DTMF Pause;b"
'
Announce60:
'Befehl &HED
'Dtmf Pause lesen
'read DTMF Pause
Data "237;aa,as236"
'
Announce61:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;160;66"
'
Announce62:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce63:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce64:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,14,{0 to 127};a,RS232,1;a,USB,1"
'
Announce65:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,14,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"