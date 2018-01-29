'-----------------------------------------------------------------------
'name : Fs20_8_kanal_tx.bas
'Version V05.0, 20180126
'purpose : Programm for sending FS20 Signals
'Can be used with hardware FS20_interface V02.0 by DK1RI
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
' serial
' I2C
'-----------------------------------------------------------------------
' Inputs: see below
' Outputs : see below
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
$regfile = "m644pdef.dat"
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
Const T_factor = 1953
'20MHz / 1024 / 1953 = 10  Hz -> 100ms
'stop for Timer1
Const T_Short = 2
'0,2s
Const T_long = T_short * 4
'0.8 s
Const T_timer = T_short * 10
'2 s for timer
Const T_modus = T_short * 30
'6 s
'
Const No_of_announcelines = 20
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
Dim Switch_status As Byte
Dim Switch_status_old As Byte
Dim Mod_counter As Byte
'counter for modus
Dim Modus As Byte
'contains waittime for switchoff
Dim K as Byte
Dim Timer_started as Bit
Dim Switch As Byte
Dim Switch1 As Byte
Dim Konfig_modus As Byte
'1: Housecode, 2: FS20 adress, 3: 4/8 chanal mode, 4: adress 8 chanal
Dim Code As String * 10
Dim Code_b(10) As Byte At Code Overlay
Dim Codepointer As Byte
Dim Kanal_mode as Byte
Dim Kanal_mode_eeram as Eram Byte
'0, 4 Kanal, 1 8 Kanal
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'**************** Config / Init
'The labels match the naming of the the ELV documentation, but not the eagle circuit !!
Config Portb.0 = Input
Portb.0 = 1
Reset__ Alias Pinb.0
'
Config PortC.7 = Output '1 Modul Output_1
PortC.7 = 1
Ta1 Alias Portc.7
Config PortC.6 = Output '2 Modul Output_2
PortC.6 = 1
Ta2 Alias Portc.6
Config PortC.5 = Output '3 Modul Output_3
PortC.5 = 1
Ta3 Alias Portc.5
Config PortC.4 = Output '4 Modul Output_4
PortC.4 = 1
Ta4 Alias PortC.4
Config PortC.3 = Output '5 Modul Output_5
Portc.3 = 1
Ta5 Alias Portc.3
Config Portc.2 = Output '6 Modul Output_6
Portc.2 = 1
Ta6 Alias PortC.2
Config portd.7 = Output '7 Modul Output_7
Portd.7 = 1
Ta7 Alias Portd.7
Config Portd.6 = Output '8 Modul Output 8
Portd.6 = 1
Ta8 Alias Portd.6
'
'
Config Watchdog = 2048
'
Config Timer1 = Timer, Prescale = 1024
Stop Timer1
'
'****************Interrupts
'Enable Interrupts
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
'check timer
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
         'Switch_off
         Gosub Switch_off
      Else
         'continue
         Timer1 = 0
         Start Timer1
      End If
   End If
End If

If Konfig_modus > 0 And Modus = 0 Then
Select Case Konfig_modus
   Case 1
      Gosub Set_hauscode
   Case 2
      Gosub Set_adress
   Case 4
      Gosub Set_adress_8
End Select

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
Adress = 24
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
'
Kanal_mode = 0
Kanal_mode_eeram = Kanal_mode
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
Gosub Switch_off
Kanal_mode = Kanal_mode_eeram
'set the old Kanal_mode
Tempb = Kanal_mode
Gosub Set4_8_kanal_mode
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
Switch_on:
   Select Case Switch
      Case 1
         Reset Ta1
      Case 2
         Reset Ta2
      Case 3
         Reset Ta3
      Case 4
         Reset Ta4
      Case 5
         Reset Ta5
      Case 6
         Reset Ta6
      Case 7
         Reset Ta7
      Case 8
         Reset Ta8
   End Select
   Select Case Switch1
      Case 1
         Reset Ta1
      Case 2
         Reset Ta2
      Case 3
         Reset Ta3
      Case 4
         Reset Ta4
      Case 5
         Reset Ta5
      Case 6
         Reset Ta6
      Case 7
         Reset Ta7
      Case 8
         Reset Ta8
   End Select
Return
'
Switch_off:
print "off"
   Set Ta1
   Set Ta2
   Set Ta3
   Set Ta4
   Set Ta5
   Set Ta6
   Set Ta7
   Set Ta8
   Switch = 0
   Switch1 = 0
   K = 0
   Timer_started = 0
   Modus = 0
Return
'
Set_hauscode:
   If Codepointer = 1 Then
      Switch = 1
      Switch1 = 3
      Modus = T_long
      Gosub Switch_on
      Codepointer = 2
   Else
      If Codepointer < 10 Then
         Switch = Code_b(Codepointer) - 3
         Modus = T_short
         Gosub Switch_on
         Incr Codepointer
      Else
         Codepointer = 0
         Konfig_modus = 0
      End If
   End If
Return
'
Set_adress:
   If Codepointer = 1 Then
      Switch = Code_b(1)
      '1 2 3 4
      Decr Switch
      Switch = Switch * 2
      ' 0 2 4 6
      Incr Switch
      ' 1 3 5 7
      Modus = T_long
      Switch1 = Switch + 1
      Codepointer = 2
      Gosub Switch_on
   Else
      If Codepointer < 6 Then
         Switch = Code_b(Codepointer) - 30
         Modus = T_short
         Gosub Switch_on
         Incr Codepointer
      Else
         Codepointer = 0
         Konfig_modus = 0
      End If
   End If
Return
'
Set_adress_8:
   If Codepointer = 1 Then
      Switch = Code_b(1)
      Switch1 = 0
      '1 2 3 4 5 6 7 8
      Gosub Switch_on
      Waitms 500
      If Switch = 1 Or Switch = 3 Or Switch = 5 Or Switch = 7 Then
         Switch1 = Switch + 1
      Else
         Switch1 = Switch -1
      End If
      Gosub Switch_on
      Modus = T_long
      Codepointer = 2
   Else
      If Codepointer < 6 Then
         Switch = Code_b(Codepointer) - 30
         Modus = T_short
         Gosub Switch_on
         Incr Codepointer
      Else
         Codepointer = 0
         Konfig_modus = 0
      End If
   End If
Return
'
Set4_8_kanal_mode:
If Tempb = 0 Then
   Kanal_mode = 0
   Kanal_mode_eeram = 0
   Switch = 1
   Switch1 = 4
End If
If Tempb = 1 Then
   Kanal_mode = 1
   Kanal_mode_eeram = 1
   Switch = 2
   Switch1 = 3
End If
Gosub Switch_on
Modus = T_modus
Konfig_modus = 3
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
'Data "0;m;DK1RI;FS20 8 chanal sender;V04.1;1;145;1;21;1-1"
      I2c_tx_busy = 2
      Tx_time = 1
      A_line = 0
      Number_of_lines = 1
      Send_lines = 3
      Gosub Sub_restore
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 1
'Befehl &H01
'schaltet kanäle, 4 Kanal
'switch chanals,4 chanal mode
'Data "1;or,Aus / An;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
      If Kanal_mode = 0 Then
         If Commandpointer >= 3 Then
            If Command_b(2) < 4 Then
               Switch = Command_b(2) * 2
               Incr Switch
               If Command_b(3) = 1 Then
                  Gosub Switch_on
                  Modus = T_short
               Else
                  If Command_b(3) = 0 Then
                     Incr Switch
                     Gosub Switch_on
                     Modus = T_short
                  Else
                     Error_no = 4
                     Error_cmd_no = Command_no
                  End If
               End If
            Else
               Error_no = 4
               Error_cmd_no = Command_no
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
   Case 2
'Befehl &H02
'dimmt kanäle ab , 4 Kanal
'dim chanals down,4 chanal mode
'Data "2;ou,dimmt ab;1;0,idle;1,Kanal1;2,Kanal2;3,Kanal3;4,Kanal4"
      If Modus = 0 Then
         If Commandpointer >= 2 Then
            If Command_b(2) < 5 Then
               Switch = Command_b(2) * 2
               Incr Switch
               Gosub Switch_on
               Modus = T_long
            Else
               Error_no = 4
               Error_cmd_no = Command_no
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
   Case 3
'Befehl &H03
'dimmt kanäle  auf, 4 Kanal
'dims chanals up, 4 chanal mode
'Data "3;ou,dimmt auf;1;0,idle;1,Kanal1;2,Kanal2;3,Kanal3;4,Kanal4"
      If Modus = 0 Then
         If Commandpointer >= 2 Then
            If Command_b(2) < 5 Then
               Switch = Command_b(2)
               Switch = switch * 2
               Incr Switch
               Incr Switch
               Gosub Switch_on
               Modus = T_long
            Else
               Error_no = 4
               Error_cmd_no = Command_no
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
   Case 4
'Befehl &H04
'Timer für 4 Kanal Mode
'Timer for 4 chanal mode
'Data "4;ou,Timer start/stop;1;0,idle;1,Kanal1;2,Kanal2;3,Kanal3;4,Kanal4"
      If Modus = 0 Then
         If Commandpointer >= 2 Then
            If Command_b(2) <= 4 And Command_b(2) > 0 Then
               Switch = Command_b(2) - 1
               Switch = Switch * 2
               Incr Switch
               '1 3 5 7
               Switch1 = Switch + 1
               '2 4 6 8
               Gosub Switch_on
               Modus = T_timer
            Else
               Error_no = 4
               Error_cmd_no = Command_no
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
   Case 5
'Befehl &H05
'schaltet Kanäle an / aus, 8 Kanäle
'switch chanals on / off, 8 chanal mode
'Data "5;ou,Ein/Aus;1;0,idle;1,Kanal1;2,Kanal2;3,Kanal3;4,Kanal4;5,Kanal5;6,kanal6;7,Kanal7;8,Kanal8"
      If Kanal_mode = 0 Then
         If Commandpointer >= 2 Then
            If Command_b(2) <= 8 And Command_b(2) > 0 Then
               Switch = Command_b(2)
               Gosub Switch_on
               Modus = T_short
            Else
               Error_no = 4
               Error_cmd_no = Command_no
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
      print Cmd_watchdog
'
   Case 6
'Befehl &H06
'dimmt kanäle  auf/ab, 8 Kanäle
'dims chanals up/down, 8 chanal mode
'Data "6;ou,dimmt auf/ab;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
      If Modus = 0 Then
         If Commandpointer >= 2 Then
            If Command_b(2) < 8 And Command_b(3) < 2  Then
               Switch = Command_b(2)
               Gosub Switch_on
               Modus = T_long
            Else
               Error_no = 4
               Error_cmd_no = Command_no
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
   Case 7
'Befehl &H07
'Timer für 8 Kanal Mode
'Timer for 8 chanal mode
'Data "7;ou,Timer start/stop;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
      If Modus = 0 Then
         If Commandpointer >= 2 Then
            If Command_b(2) < 8 And Command_b(3) < 2  Then
               Switch = Command_b(2)
               Gosub Switch_on
               Modus = T_long
            Else
               Error_no = 4
               Error_cmd_no = Command_no
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
   Case 8
'Befehl &H08
'schreiben 0: 4 / 1 : 8 Kanalmode
'write 0: 4 / 1: 8 chanal mode
'Data "8;ks;1;0,4 Kanal;1,8 Kanal"
      If Modus = 0 Then
         If Commandpointer >= 2 Then
            If Command_b(2) < 2 Then
               Tempb = Command_b(2)
               Gosub Set4_8_kanal_mode
            Else
               Error_no = 4
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      Else
         Error_no = 7
         Error_cmd_no = Command_no
         Gosub Command_received
      End If
'
   Case 9
'Befehl &H09
'lesen 4 / 8 Kanalmodemode
'read 4 / 8 chanal mode
'Data "9,as,as9"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H0A
      I2c_tx_b(2) = Kanal_mode
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 10
'Befehl &H0A
'Hauscode eingeben (8 Ascii Ziffern von 1 - 4)
'housecode (8 ASCII Digits from 1 to 4
'Data "10;ka,housecode;8,{1 TO 4}"
      If Konfig_modus = 0 And Modus = 0 Then
         If Commandpointer >= 9 Then
            Tempc = 0
            For Tempb = 2 to 9
               If Command_b(Tempb) < 31 Or Command_b(Tempb) > 34 Then Tempc = 1
               Code_b(Tempb) = Command_b(Tempb)
            Next Tempb
            If Tempc = 0 Then
               Konfig_modus = 1
               Codepointer = 1
            Else
               Error_no = 4
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      Else
         Error_no = 7
         Error_cmd_no = Command_no
         Gosub Command_received
      End If
'
   Case 11
'Befehl &H0B
'Adresse eingeben 5 Ziffern von 1 bis 4; tastenpaar + 4 Ziffern Adresse
'adress, 5 digits from 1 to 4; Buttonnumber + 4 digits Adress
'Data "11;ka,adress, 4 chanal;5,{1 to 4}"
      If Konfig_modus = 0 And Modus = 0 Then
         If Kanal_mode = 0 Then
            If Commandpointer >= 5 Then
               Tempc = 0
               For Tempb = 2 to 5
                  If Command_b(Tempb) < 31 Or Command_b(Tempb) > 34 Then Tempc = 1
                  Code_b(Tempb) = Command_b(Tempb)
               Next Tempb
               If Tempc = 0 Then
                  Konfig_modus = 2
                  Codepointer = 1
               Else
                  Error_no = 4
                  Error_cmd_no = Command_no
               End If
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         Else
            Error_no = 7
            Error_cmd_no = Command_no
            Gosub Command_received
         End If
      Else
         Error_no = 7
         Error_cmd_no = Command_no
         Gosub Command_received
      End If
'
   Case 12
'Befehl &H0C
'Adresse eingeben 5 Ziffern Tasten 1-8 + 4 Ziffern fuer Adresse 1 - 4
'adress, 5 digits Button 1 to 8 + 4 Digits for adress 1 to 4
'Data "12;ka,adress, 8 chanal;5,{1 to 8}"
      If Konfig_modus = 0 And Modus = 0 Then
         If Kanal_mode = 1 Then
            If Commandpointer >= 5 Then
               Tempc = 0
               For Tempb = 2 to 5
                  If Command_b(Tempb) < 31 Or Command_b(Tempb) > 38 Then Tempc = 1
                  If Tempb > 2 And Command_b(Tempb) > 34 Then Tempc = 1
                  Code_b(Tempb) = Command_b(Tempb)
               Next Tempb
               If Tempc = 0 Then
                  Konfig_modus = 4
                  Codepointer = 1
               Else
                  Error_no = 4
                  Error_cmd_no = Command_no
               End If
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         Else
            Error_no = 7
            Error_cmd_no = Command_no
            Gosub Command_received
         End If
      Else
         Error_no = 7
         Error_cmd_no = Command_no
         Gosub Command_received
      End If
'
   Case 13
'Befehl &H0D
'busy, 1: keine Befehle akzeptiert
'busy, 1: no commands accepted
'Data "13;la,busy;a"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H05
      I2c_write_pointer = 3
      Tempb = 0
      If Modus > 0 Then Tempb = 1
      I2c_tx_b(2) = Tempb
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
'Data "240;ln,ANNOUNCEMENTS;145;21"
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
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,12;b,ADRESS,1,{0 to 127};a,RS232,1;a,USB,1"
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
'Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,12,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
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
Data "0;m;DK1RI;FS20 8 chanal sender;V04.1;1;145;1;21;1-1"
'
Announce1:
'Befehl &H01
'schaltet kanäle, 4 Kanal
'switch chanals,4 chanal mode
Data "1;or,Aus / An;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
Announce2:
'Befehl &H02
'dimmt kanäle ab , 4 Kanal
'dim chanals down,4 chanal mode
Data "2;ou,dimmt ab;1;0,idle;1,Kanal1;2,Kanal2;3,Kanal3;4,Kanal4"
'
Announce3:
'Befehl &H03
'dimmt kanäle  auf, 4 Kanal
'dims chanals up, 4 chanal mode
Data "3;ou,dimmt auf;1;0,idle;1,Kanal1;2,Kanal2;3,Kanal3;4,Kanal4"
'
Announce4:
'Befehl &H04
'Timer für 4 Kanal Mode
'Timer for 4 chanal mode
Data "4;ou,Timer start/stop;1;0,idle;1,Kanal1;2,Kanal2;3,Kanal3;4,Kanal4"
'
Announce5:
'Befehl &H05
'schaltet Kanäle an / aus, 8 Kanäle
'switch chanals on / off, 8 chanal mode
Data "5;ou,Ein/Aus;1;0,idle;1,Kanal1;2,Kanal2;3,Kanal3;4,Kanal4;5,Kanal5;6,kanal6;7,Kanal7;8,Kanal8"
'
Announce6:
'Befehl &H06
'dimmt kanäle  auf/ab, 8 Kanäle
'dims chanals up/down, 8 chanal mode
'Data "6;ou,dimmt auf/ab;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
'
Announce7:
'Befehl &H07
'Timer für 8 Kanal Mode
'Timer for 8 chanal mode
Data "7;ou,Timer start/stop;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
'
Announce8:
'Befehl &H08
'schreiben 0: 4 / 1 : 8 Kanalmode
'write 0: 4 / 1: 8 chanalmode
Data "8;ks1;;0,4 Kanal;1,8 Kanal"
'
Announce9:
'Befehl &H09
'lesen 4 / 8 Kanalmodemode
'read 4 / 8 chanal mode
Data "9,as,as9"
'
Announce10:
'Befehl &H0A
'Hauscode eingeben (8 Ascii Ziffern von 1 - 4)
'housecode (8 ASCII Digits from 1 to 4
Data "10;ka,housecode;8,{1 TO 4}"
'
Announce11:
'Befehl &H0B
'Adresse eingeben 5 Ziffern von 1 bis 4; tastenpaar + 4 Ziffern Adresse
'adress, 5 digits from 1 to 4; Buttonnumber + 4 digits Adress
Data "11;ka,adress, 4 chanal;5,{1 to 4}"
'
Announce12:
'Befehl &H0C
'Adresse eingeben 5 Ziffern Tasten 1-8 + 4 Ziffern fuer Adresse 1 - 4
'adress, 5 digits Button 1 to 8 + 4 Digits for adress 1 to 4
Data "12;ka,adress, 8 chanal;5,{1 to 8}"
'
Announce13:
'Befehl &H0D
'busy, 1: keine Befehle akzeptiert
'busy, 1: no commands accepted
Data "13;la,busy;a"
'
Announce14:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;21"
'
Announce15:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce16:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce17:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,12,{0 to 127};a,RS232,1;a,USB,1"
'
Announce18:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,12,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
Announce19:
Data "R !$1 !$2 !$3 !$4 !$5 IF $10 = 1"
Announce20:
Data "R !$6 !$7 !$8 IF $10 = 0"
'