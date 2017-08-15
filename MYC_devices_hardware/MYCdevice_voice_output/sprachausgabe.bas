'-----------------------------------------------------------------------
'name : sprachausgabe.bas
'Version V03.0, 20170715
'purpose : Play 10 voice/music amples from ELV MSM2 module
'This Programm workes as I2C slave or using RS232
'Can be used with  sprachausgabe Version V01.0 by DK1RI
'The Programm supports the MYC protocol
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
'dtmf_sender V03.1
'-----------------------------------------------------------------------
'Used Hardware:
' RS232
' I2C
'-----------------------------------------------------------------------
' Inputs, Outputs :see below
' I/O : I2C , RS232
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'$regfile = "m88pdef.dat"
' for ATmega8P
'$regfile = "m88def.dat"
' (for ATmega8)
$regfile = "m328pdef.dat"
'for ATmega328
$crystal = 20000000
$baud = 19200
' use baud rate
$hwstack = 64
' default use 32 for the hardware stack .
$swstack = 20
' default use 10 for the SW stack
$framesize = 50
' default use 40 for the frame space
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
Const No_of_announcelines = 11
'announcements start with 0
Const Cystal = 20000000
Const Blinktime = 5000
Const Cmd_watchdog_time = Blinktime * 10
'Number of main loop before command reset
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
Const Tx = 4 * Tx_factor
Const Tx_timeout = Cmd_watchdog_time * Tx
Const Not_valid_cmd = &H80
'a non valid commandtoken
Const T_factor = 1953
'20MHz / 1024 / 1953 = 10  Hz -> 100ms

'stop for Timer1

Const T_Short = 2
'0,2s
Const T_long = T_short * 13
'2.5 s
Const T_modus = T_short * 63
'12.5s

'
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
Dim I As Integer
'Blinkcounter
Dim J As Integer
Dim K as Byte

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
Dim Twi_control As Byte
'
Dim Error_no As Byte
Dim Error_cmd_no As Byte
Dim Errorflag As Bit
Dim Cmd_watchdog As Dword
'Watchdog for loop
Dim Tx_time As Dword
'Watchdog for I2c sending
Dim Command_mode As Byte
'0: I2C input 1: seriell
'
Dim Modus As Byte
Dim Timer_started As Bit
Dim Voice As Byte
Dim Moduss AS Byte
'
Blw = Peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'**************** Config / Init
' Jumper:
Config portB.2 = Input
PortB.2 = 1
Reset__ Alias PinB.2
Config PortC.0 = Output
Voice1 Alias PortC.0
Config portC.1 = Output
Voice2 Alias PortC.1
Config portb.0 = Output
Voice3 Alias portb.0
Config portb.1 = Output
Voice4 Alias portb.1
Config portD.2 = Output
Voice5 Alias portD.2
Config portD.3 = Output
Voice6 Alias portD.3
Config portD.4 = Output
Voice7 Alias portD.4
Config portD.7 = Output
Voice8 Alias portD.7
Config portD.6 = Output
Voice9 Alias portD.6
Config portD.5 = Output
Voice10 Alias portD.5
'
Config Watchdog = 2048
Config Timer1 = Timer, Prescale = 1024
Stop Timer1
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
'
'wait for speach modul to initialize
Wait 10
'
'set continous mode
Commandpointer = 1
Voice = 9
Modus = T_modus
Timer_started = 0
Gosub Control_sound
'
Slave_loop:
Start Watchdog
'Loop must be less than 2s
'
'check voicecontrol timer
If Modus > 0 Then
   If Timer_started = 0 Then
      Timer1 = 0
      Start Timer1
      Timer_started = 1
      K = 0
   End If
   If Timer1 > T_factor Then
      Incr K
      Stop Timer1
      If K >= Modus Then
         Gosub Control_sound_off
      Else
         Timer1 = 0
         Start Timer1
      End If
   End If
End If

'Blink
J = J + 1
If J = Blinktime Then
   J = 0
   Select Case I
   Case 10
      I = 0
      'reset I2c if not busy
      Twi_control = Twcr And &H80
      'twint set?
      If Twi_control = &H00 Then Gosub Reset_i2c
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
   Errorflag = 1
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
   A = Waitkey()
   If Command_mode = 0 Then
   'restart if i2cmode
      Command_mode = 1
      Gosub  Command_received
   End If
   If Commandpointer < Stringlength Then
   'If Buffer is full, chars are ignored !!
      Command_b(commandpointer) = A
      If Cmd_watchdog = 0 Then Cmd_watchdog = 1
      ' start watchdog
      If Rs232_active = 0 And Usb_active = 0 Then
      'allow &HFE only
         If Command_b(1) = 254 Then
            Gosub Slave_commandparser
         Else
            Gosub  Command_received
         End If
      Else
         Gosub Slave_commandparser
      End If
   End If
End If
'
'I2C
'This part should be executed as fast as poosible to continue I2C:
Twi_control = Twcr And &H80
'twint set?
If Twi_control = &H80 Then
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
Reset_:
'This wait is necessary, because some programmers provide the chip
'with power for a short time after programming.
'This may start the reset_ sub, but stop before ending.
Wait 1
'set at first use
Dev_number = 1
Dev_number_eeram = Dev_number
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Dev_name = Dev_name_eeram
Adress = 40
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
'This should be the last
First_set = 5
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
Errorflag = 0
Error_cmd_no = 0
Send_lines = 0
Gosub Command_received
Gosub Reset_i2c_tx
Gosub Reset_i2c
I = 0
J = 0
Command_mode = 0
Announceline = 255
Gosub Control_sound_off
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
If Errorflag = 1 Then
   Error_cmd_no = Command_no
   Errorflag = 0
End If
Incr Command_no
If Command_no = 255 Then Command_no = 0
Cmd_watchdog = 0
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
Control_sound:
If Modus = T_modus Then Reset Voice1
Select Case Voice
   Case 1
      Reset Voice1
   Case 2
      Reset Voice2
   Case 3
      Reset Voice3
   Case 4
      Reset Voice4
   Case 5
      Reset Voice5
   Case 6
      Reset Voice6
   Case 7
      Reset Voice7
   Case 8
      Reset Voice8
   Case 9
      Reset Voice9
   Case 10
      Reset Voice10
End Select
Return
'
Control_sound_off:
Set Voice1
Set Voice2
Set Voice3
Set Voice4
Set Voice5
Set Voice6
Set Voice7
Set Voice8
Set Voice9
Set Voice10
Modus = 0
Timer_started = 0
Moduss = 0
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
End If
'
Select Case Command_b(1)
   Case 0
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
'Data "0;m;DK1RI;Sprachausgabe;V03.0;1;145;1;11"
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
         Errorflag = 1
      End If
      Gosub Command_received
'
   Case 1
'Befehl &H01 0 to 9
'spielt Sprache/Musik
'play voice/music
'Data "1;os,,sound;0;1;2;3;4;5;6;7;8;9"
      If Commandpointer >= 2 Then
         If Command_b(2) < 10 Then
            If Modus <> T_Modus Then
               Modus = T_short
               Voice = Command_b(Commandpointer) + 1
               'start Music
               Gosub Control_sound
            Else
               Error_no = 4
               Errorflag = 1
            End If
         Else
            Error_no = 4
            Errorflag = 1
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
      Case 2
'Befehl &H02 0 to 9
'spielt Playliste
'play playlist
'Data "2;os,playlist;0;1;2;3;4;5;6;7;8;9"
         If Commandpointer >= 2 Then
            If Command_b(2) < 10 Then
               If Modus <> T_Modus Then
                  Modus = T_long
                  Voice = Command_b(Commandpointer) + 1
                  'start playlist
                  Gosub Control_sound
               Else
                  Error_no = 4
                  Errorflag = 1
               End If
            Else
               Error_no = 4
               Errorflag = 1
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 3
'Befehl &H03 0 to 8
'Modi
'set modes
'Data "3;os,modi;0,2;1,3;2.4;3,5;4,6;5,7;6,8;7,9;8,10"
         If Commandpointer >= 2 Then
            If Command_b(2) < 9 Then
               If Modus <>  T_modus Then
                  Modus = T_modus
                  Moduss = Command_b(2)
                  Voice = Command_b(Commandpointer) + 2
                  Gosub Control_sound
               Else
                  Error_no = 4
                  Errorflag = 1
               End If
            Else
               Error_no = 4
               Errorflag = 1
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
'Befehl &H04
'liest Modus
' read mode
'Data "4;au,as3"
      Case 4
         If I2c_tx_busy = 0 Then
            I2c_tx_busy = 1
            Tx_time = 1
            I2c_tx_b(1) = &H04
            I2c_tx_b(2) = Moduss
            I2c_write_pointer = 3
            If Command_mode = 1 Then Gosub Print_i2c_tx
         Else
            Error_no = 7
            Errorflag = 1
         End If
         Gosub Command_received
      Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;145;11"
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
               Errorflag = 1
            End If
         Else
            Error_no = 4
            Errorflag = 1
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
         Errorflag = 1
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
         Errorflag = 1
      End If
      Gosub Command_received
'
   Case 254
'Befehl &HFE <0..5> <data>
'eigene Individualisierung schreiben
'write individualization
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,20,{0 to 127};a,RS232,1;a,USB,1"
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
                     Errorflag = 1
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
                     Errorflag = 1
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
                     Errorflag = 1
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
                     Errorflag = 1
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If

            Case Else
               Error_no = 0
               Errorflag = 1
         End Select
      Else
        Incr Commandpointer
      End If
'
   Case 255
'Befehl &HFF <0..5>:
'eigene Individualisierung lesen
'read individualization
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,20,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8N1;a,USB,1"
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
                     Tempc = Len(dev_name)
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
               Errorflag = 1
               'ignore anything else
            End If
            If Command_mode = 1 Then Gosub Print_i2c_tx
            Gosub Command_received
         Else
            Error_no = 7
            Errorflag = 1
         End If
      Else
         Incr Commandpointer
      End If
'
   Case Else
      Error_no = 0
      'ignore anything else
      Errorflag = 1
      Gosub Command_received
End Select
Stop Watchdog
Return
'
'==================================================
'
End
'announce text
'
Announce0:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Sprachausgabe;V03.0;1;145;1;11"
'
Announce1:
'Befehl &H01 0 to 9
'spielt Sprache/Musik
'play voice/music
Data "1;os,,sound;0;1;2;3;4;5;6;7;8;9"
'
Announce2:
'Befehl &H02 0 to 9
'spielt Playliste
'play playlist
Data "2;os,playlist;0;1;2;3;4;5;6;7;8;9"
'
Announce3:
'Befehl &H03 0 to 8
'Modi
'set modes
Data "3;ou,modi;0,2;1,3;2.4;3,5;4,6;5,7;6,8;7,9;8,10"
'
Announce4:
'Befehl &H04
'liest Modus
' read mode
Data "4;au,as3"
'
Announce5:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;145;11"
'
Announce6:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce7:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce8:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,20,{0 to 127};a,RS232,1;a,USB,1"
'
Announce9:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,20,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
Announce10:
Data "R !$1 !$2 If $3&1 > 0"