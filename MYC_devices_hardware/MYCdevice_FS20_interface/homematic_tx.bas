'-----------------------------------------------------------------------
'name : Fs20_8_kanal_tx_bascom.bas
'Version V01.1, 20180126
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
' SPI
'-----------------------------------------------------------------------
' Inputs: see below
' Outputs : see below
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'
'+++++++++++++++++++++++++++++++++++++++++++++++++++++
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
Const No_of_announcelines = 18
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
Dim Kanal_mode as Byte
'0, 4 Kanal, 1 8 Kanal
Dim Kanal_mode_eeram as Eram Byte
Dim Dim_start As Bit
Dim Timer_start As Bit
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'**************** Config / Init   pin of FS20-S8M Sender
Config PortB.0 = Input
PortB.0 = 1
Reset__ Alias PinB.1
'
'The labels match the naming of the the ELV documentation, but not the eagle circuit !!
Config Pinc.7 = Output
Por1 Alias Portc.7
Set Por1
Config Pinc.6 = Output
Por2 Alias Portc.6
Set Por2
Config Pinc.5 = Output
Por3 Alias Portc.5
Set Por3
Config PINc.4 = Output
Por4 Alias Portc.4
Set Por4
Config Pinc.3 = Output
Por5 Alias Portc.3
Set Por5
Config Pinc.2 = Output
Por6 Alias Portc.2
Set Por6
Config Pind.7 = Output
Por7 Alias Portd.7
Set Por7
Config Pind.6 = Output
Por8 Alias Portd.6
Set Por8
'
Config Pind.2 = Output
Str Alias Portd,2
Config Pind.3 = Output
Stg Alias Portd.3
Config Pind.4 = Output
Sts_ Alias PortD.3
Config Pind.5 = Input
Y Alias PortD.5
Config Pinb.4 = Input
X Alias Portb.4
'
Config Watchdog = 2048
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
'This should be the last
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
Wait 1
Gosub Set_kanal_mode
Dim_start = 0
Timer_start = 0
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
D1:
If Dim_start = 1 Then
   Reset Por1
   Waitms 440
Else
   Set Por1
End If
Return
'
D2:
If Dim_start = 1 Then
   Reset Por2
   Waitms 440
Else
   Set Por2
End If
Return
'
D3:
If Dim_start = 1 Then
   Reset Por3
   Waitms 440
Else
   Set Por3
End If
Return
'
D4:
If Dim_start = 1 Then
   Reset Por4
   Waitms 440
Else
   Set Por4
End If
Return
'
D5:
If Dim_start = 1 Then
   Reset Por5
   Waitms 440
Else
   Set Por5
End If
Return
'
D6:
If Dim_start = 1 Then
   Reset Por6
   Waitms 440
Else
   Set Por6
End If
Return
'
D7:
If Dim_start = 1 Then
   Reset Por7
   Waitms 440
Else
   Set Por7
End If
Return
'
D8:
If Dim_start = 1 Then
   Reset Por8
   Waitms 440
Else
   Set Por8
End If
Return

S1:
Reset Por1
Waitms 110
Set Por1
Return
'
S2:
Reset Por2
Waitms 110
Set Por2
Return
'
S3:
Reset Por3
Waitms 110
Set Por3
Return
'

S4:
Reset Por4
Waitms 110
Set Por4
Return
'
S5:
Reset Por5
Waitms 110
Set Por5
Return
'
S6:
Reset Por6
Waitms 110
Set Por6
Return
'

S7:
Reset Por7
Waitms 110
Set Por7
Return
'
S8:
Reset Por8
Waitms 110
Set Por8
Return
'
M12:
Reset Por1
Reset Por2
Waitms 1100
Set Por1
Set Por2
Return
'
M34:
Reset Por3
Reset Por4
Waitms 1100
Set Por3
Set Por4
Return
'
M56:
Reset Por5
Reset Por6
Waitms 1100
Set Por5
Set Por6
Return
'
M78:
Reset Por7
Reset Por8
Waitms 110
Set Por7
Set Por8
Return
'
T1:
Reset Por1
Reset Por2
Waitms 1100
Set Por2
Waitms 200
Set Por1
Return
'
T2:
Reset Por2
Reset Por1
Waitms 1100
Set Por1
Waitms 200
Set Por2
Set Por1
Return
'
T3:
Reset Por3
Reset Por4
Waitms 1100
Set Por4
Waitms 200
Set Por3
Return
'
T4:
Reset Por4
Reset Por3
Waitms 1100
Set Por3
Waitms 200
Set Por4
Return
'
T5:
Reset Por5
Reset Por6
Waitms 1100
Set Por6
Waitms 200
Set Por5
Return
'
T6:
Reset Por6
Reset Por5
Waitms 1100
Set Por5
Waitms 200
Set Por6
Return
'
T7:
Reset Por7
Reset Por8
Waitms 1100
Set Por8
Waitms 200
Set Por7
Return
'
T8:
Reset Por8
Reset Por7
Waitms 110
Set Por7
Waitms 200
Set Por8
Return
'
Set_kanal_mode:
If Kanal_mode = 0 Then
   '4 Kanal
   Reset Por1
   Reset Por4
   Wait 6
   Set Por4
   Set Por1
Else
   '8 Kanal
   Reset Por2
   Reset Por3
   Wait 6
   Set Por3
   Set Por2

End If
Return
'
'+++++++++++++++++++++++++++++++++++++++++++++++++++++
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
'Data "0;m;DK1RI;FS20 8 chanal sender;V01.1;1;170;1;18"
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
'schaltet kanäle aus
'switch chanals off
'Data "1;or,Aus;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
         If Commandpointer >= 2 Then
            If Kanal_mode = 0 Then
               If Command_b(2) < 4 Then
                  Stop Watchdog
                  If Command_b(2) = 0 Then Gosub S1
                  If Command_b(2) = 1 Then Gosub S3
                  If Command_b(2) = 2 Then Gosub S5
                  If command_b(2) = 3 Then Gosub S7
                  Start Watchdog
               Else
                  Error_no = 4
                  Error_cmd_no = Command_no
               End If
            Else
               Error_no = 0
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 2
'Befehl &H02
'schaltet Kanäle  ein
'switch chanals on
'Data "2;or,Ein;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
         If Commandpointer >= 2 Then
            If Kanal_mode = 0 Then
               If Command_b(2) < 4 Then
                  Stop Watchdog
                  If Command_b(2) = 0 Then Gosub S2
                  If Command_b(2) = 1 Then Gosub S4
                  If Command_b(2) = 2 Then Gosub S6
                  If command_b(2) = 3 Then Gosub S8
                  Start Watchdog
               Else
                  Error_no = 4
                  Error_cmd_no = Command_no
               End If
            Else
               Error_no = 0
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 3
'Befehl &H03
'schaltet Kanäle an / aus
'switch chanals on / off
'Data "3;or,Ein/Aus;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
         If Commandpointer >= 2 Then
            If Kanal_mode = 1 Then
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
                  Error_cmd_no = Command_no
               End If
            Else
               Error_no = 0
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 4
'Befehl &H04
'dimmt kanäle ab
'dim chanals down
'Data "4;or,dimmt ab;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
         If Commandpointer >= 2 Then
            If Kanal_mode = 0 Then
               If Command_b(2) < 4 Then
                  Stop Watchdog
                  Toggle  Dim_start
                  If Command_b(2) = 0 Then Gosub D1
                  If Command_b(2) = 1 Then Gosub D3
                  If Command_b(2) = 2 Then Gosub D5
                  If command_b(2) = 3 Then Gosub D7
                  Start Watchdog
               Else
                  Error_no = 4
                  Error_cmd_no = Command_no
               End If
            Else
               Error_no = 0
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 5
'Befehl &H05
'dimmt kanäle  auf
'dims chanals up
'Data "5;or,dimmt auf;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
         If Commandpointer >= 2 Then
            If Kanal_mode = 0 Then
               If Command_b(2) < 4 Then
                  Stop Watchdog
                  Toggle Dim_start
                  If Command_b(2) = 0 Then Gosub D2
                  If Command_b(2) = 1 Then Gosub D4
                  If Command_b(2) = 2 Then Gosub D6
                  If command_b(2) = 3 Then Gosub D8
                  Start Watchdog
               Else
                  Error_no = 4
                  Error_cmd_no = Command_no
               End If
            Else
               Error_no = 0
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 6
'Befehl &H06
'dimmt kanäle  auf/ab
'dims chanals up/down
'Data "6;or,dimmt auf/ab;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
         If Commandpointer >= 2 Then
            If Kanal_mode = 1 Then
               If Command_b(2) < 8 Then
                  Stop Watchdog
                  Toggle Dim_start
                  If Command_b(2) = 0 Then Gosub D1
                  If Command_b(2) = 1 Then Gosub D2
                  If Command_b(2) = 2 Then Gosub D3
                  If command_b(2) = 3 Then Gosub D4
                  If Command_b(2) = 4 Then Gosub D5
                  If Command_b(2) = 5 Then Gosub D6
                  If Command_b(2) = 6 Then Gosub D7
                  If command_b(2) = 7 Then Gosub D8
                  Start Watchdog
               Else
                  Error_no = 4
                  Error_cmd_no = Command_no
               End If
            Else
               Error_no = 0
            End If
            Gosub Command_received
            Error_cmd_no = Command_no
         Else
            Incr Commandpointer
         End If
'
      Case 7
'Befehl &H07
'Timer für 4 Kanal Mode
'Timer for 4 chanal mode
'Data "7;or,Timer start/stop;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4""
         If Commandpointer >= 2 Then
            If Command_b(2) < 4 Then
               If Kanal_mode = 0 Then
                  Stop Watchdog
                  Toggle  Timer_start
                  If Command_b(2) = 0 Then Gosub M12
                  If Command_b(2) = 1 Then Gosub M34
                  If Command_b(2) = 2 Then Gosub M56
                  If command_b(2) = 3 Then Gosub M78
                  Start Watchdog
               Else
                  Error_no = 0
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
      Case 8
'Befehl &H08
'Timer für 8 Kanal Mode
'Timer for 8 chanal modef
'Data "8;or,Timer start/stop;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8""
         If Commandpointer >= 2 Then
            If Command_b(2) < 8 Then
               If Kanal_mode = 1 Then
                  Stop Watchdog
                  Toggle  Timer_start
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

      Case 9
'Befehl &H09
'schreiben 1: 4 / 2: 8 Kanalmode
'write 1: 4 / 2:8 chanalmode
'Data "9;os;1;0,4 Kanal;1,8 Kanal"
         If Commandpointer >= 2 Then
            If Command_b(2) < 2 Then
              Stop Watchdog
              Select Case Command_b(2)
                 Case 0
                    If Kanal_mode = 1 Then
                       Kanal_mode = 0
                       Kanal_mode_eeram = 0
                    End If
                 Case 1
                    If Kanal_mode = 0 Then
                       Kanal_mode = 1
                       Kanal_mode_eeram = 1
                    End If
               End Select
               Start Watchdog
            Else
               Error_no = 4
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 10
'Befehl &H0A
'lesen 4 / 8 Kanalmodemode
'read 4 / 8 chanal mode
'Data "10,as,as9"
         I2c_tx_busy = 2
         Tx_time =1
         I2c_tx_b(1) = &H0A
         I2c_tx_b(2) = Kanal_mode
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
         Gosub Command_received
'
      Case 240
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
'Data "240;ln,ANNOUNCEMENTS;145;18"
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
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,7;b,ADRESS,1,{0 to 127};a,RS232,1;a,USB,1"
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
'Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,7;b,ADRESS,1,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
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
Data "0;m;DK1RI;FS20 8 chanal sender;V01.1;1;145;1;18"
'
Announce1:
'Befehl &H01
'schaltet kanäle aus
'switch chanals off
Data "1;or,Aus;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
Announce2:
'Befehl &H02
'schaltet Kanäle  ein
'switch chanals on
Data "2;or,Ein;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
Announce3:
'Befehl &H03
'schaltet Kanäle an / aus
'switch chanals on / off
Data "3;or,Ein/Aus;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
'
Announce4:
'Befehl &H04
'dimmt kanäle ab
'dim chanals down
Data "4;or,dimmt ab;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
Announce5:
'Befehl &H05
'dimmt kanäle  auf
'dims chanals up
Data "5;or,dimmt auf;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
Announce6:
'Befehl &H06
'dimmt kanäle  auf/ab
'dims chanals up/down
Data "6;or,dimmt auf/ab;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
'
Announce7:
'Befehl &H07
'Timer für 4 Kanal Mode
'Timer for 4 chanal mode
Data "7;or,Timer start/stop;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4""
'
Announce8:
'Befehl &H08
'Timer für 8 Kanal Mode
'Timer for 8 chanal modef
Data "8;or,Timer start/stop;1;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8""
'
Announce9:
'Befehl &H09
'schreiben 1: 4 / 2: 8 Kanalmode
'write 1: 4 / 2:8 chanalmode
Data "9;os;1;0,4 Kanal;1,8 Kanal"
'
Announce10:
'Befehl &H0A
'lesen 4 / 8 Kanalmodemode
'read 4 / 8 chanal mode
Data "10,as,as9"
'
Announce11:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;18"
'
Announce12:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce13:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce14:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,7,{0 to 127};a,RS232,1;a,USB,1"
'
Announce15:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,7,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
Announce16:
Data "R !$1 !$2 !$4 !$5 !$7 If $10 = 1"
Announce17:
Data "R !$3 !$6 !$8 IF $10 = 0"