'-----------------------------------------------------------------------
'name : relaisteuerung_basom.bas
'Version V04.1, 20181018
'purpose : Control of a board with 4 Relais and 11 Inputs
'This Programm workes as I2C slave
'Can be used with hardware relaisteuerunge Version V02.0 by DK1RI
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
'slave_core_V01.6
'-----------------------------------------------------------------------
'Used Hardware:
' Inputs: see below
' AD Converter 0 - 3
' Outputs : see below
' I/O : I2C
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
$regfile = "m88pdef.dat"
'$regfile = "m88def.dat"
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
Const Tx_factor = 20
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
Const Tx_timeout = Cmd_watchdog_time * Tx_factor
'           timeout, when I2c_Tx_b is cleared and new commands allowed
'
Const No_of_announcelines = 32
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
Dim Send_line_gaps As Byte
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
Dim Tx_time As Word
Dim Command_mode As Byte
'0: I2C input 1: seriell
'
Dim Adc_value As Word
Dim Adc_reference As Byte
Dim Adc_reference_eeram As Eram Byte
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'**************** Config / Init
Config Pind.5 = Input
Portd.5 = 1
Reset__ Alias Pind.5
'
Config Pind.7 = Input
Portd.7 = 1
Inp1 Alias Pind.7
Config Pind.6 = Input
Portd.6 = 1
Inp2 Alias Pind.6
'
Config Pinb.1 = Input
Portb.1 = 1
Inp3 Alias Pinb.1
Config Pinb.2 = Input
Portb.2 = 1
Inp4 Alias Pinb.2
Config Pinb.3 = Input
Portb.3 = 1
Inp5 Alias Pinb.3
Config Pinb.4 = Input
Portb.4 = 1
Inp6 Alias Pinb.4
Config Pinb.5 = Input
Portb.5 = 1
Inp7 Alias Pinb.5
'
Config Pinc.0 = Input
Portc.0 = 1
Inp8 Alias Pinc.0
Config Pinc.1 = Input
Portc.1 = 1
Inp9 Alias Pinc.1
Config Pinc.2 = Input
Portc.2 = 1
Inp10 Alias Pinc.2
Config Pinc.3 = Input
Portc.3 = 1
Inp11 Alias Pinc.3
'
UCSR0B.3 = 0
'disable UART and enable PortD.0 As Output
Config Portd.0 = Output
Relais1 Alias Portd.0
Config Portd.1 = Output
Relais2 Alias Portd.1
Config Portd.2 = Output
Relais3 Alias Portd.2
Config Portd.3 = Output
Relais4 Alias Portd.3
'
Config Sda = Portc.4
'must !!, otherwise error
Config Scl = Portc.5
Config Adc = Single , Prescaler = Auto , Reference = Avcc
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
                  If Number_of_lines > 0 Then Gosub Sub_restore
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
Adress = 8
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
'
Adc_reference = 0
Adc_reference_eeram = Adc_reference
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
Send_line_gaps = 0
Gosub Command_received
Gosub Reset_i2c_tx
Gosub Reset_i2c
I = 0
J = 0
Command_mode = 0
Announceline = 255
I2c_tx_busy = 0
'
Adc_reference = Adc_reference_eeram
Reset Relais1
Reset Relais2
Reset Relais3
Reset Relais4
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
Select Case Send_line_gaps
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
   Case 230
      Restore Announce30
   Case 31
      Restore Announce31
   Case Else
         'will not happen
End Select
Read I2c_tx
Tempc = Len(I2c_tx)
For Tempb = Tempc To 1 Step - 1
   Tempa = Tempb + Tempd
   I2c_tx_b(Tempa) = I2c_tx_b(Tempb)
Next Tempb
Select Case Send_line_gaps
   Case 1
      I2c_tx_b(1) = Tempc
      I2c_write_pointer = Tempc + 2
      'additional announcement lines
   Case 3
      'start basic announcement
      I2c_tx_b(1) = &H00
      I2c_tx_b(2) = Tempc
      I2c_write_pointer = Tempc + 3
      Send_line_gaps = 1
   Case 2
      'start of announceline(s), send 3 byte first
      I2c_tx_b(1) = &HF0
      I2c_tx_b(2) = A_line
      I2c_tx_b(3) = Number_of_lines
      I2c_tx_b(4) = Tempc
      I2c_write_pointer = Tempc + 5
      Send_line_gaps = 1
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
Send_input_2:
Start Adc
Adc_value = Getadc(1)
Adc_value = Getadc(1)
Stop Adc
I2c_tx_b(2) = High(adc_value)
I2c_tx_b(3) = Low(adc_value)
For Tempb = 1 To 3
   Tempc = I2c_tx_b(Tempb)
   Printbin Tempc
Next Tempb
I2c_tx_busy = 2
Tx_time = 1
I2c_pointer = 1
I2c_write_pointer = 1
Gosub Command_received
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
'Data "0;m;DK1RI; 4 Relais Bord;V04.1;1;100;1;32;1-1"
      I2c_tx_busy = 2
      Tx_time = 1
      A_line = 0
      Number_of_lines = 1
      Send_line_gaps = 3
      Gosub Sub_restore
      Gosub Command_received
'
   Case 1
'Befehl &H01
'liest digital Wert INP1
'read digital INP1
'Data"1;as,INP1;1;0,0;1,1"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H01
      I2c_tx_b(2) = Inp1
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 2
'Befehl &H02
'liest digital Wert INP2
'read digital INP2
'Data"2;as,INP2;1;0,0;1,1"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H02
      I2c_tx_b(2) = Inp2
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 3
'Befehl &H03
'liest digital Wert INP3
'read digital INP3
'Data"3;as,INP3;1;0,0;1,1"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H03
      I2c_tx_b(2) = Inp3
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 4
'Befehl &H04
'liest digital Wert INP4
'read digital INP4
'Data "4;as,INP4;1;0,0;1,1"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H04
      I2c_tx_b(2) = Inp4
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 5
'Befehl &H05
'liest digital Wert INP5
'read digital INP5
'Data"5;as,INP5;1;0,0;1,1"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H05
      I2c_tx_b(2) = Inp5
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 6
'Befehl &H06
'liest digital Wert INP6
'read digital INP6
'Data "6;as,INP6;1;0,0;1,1"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H06
      I2c_tx_b(2) = Inp6
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 7
'Befehl &H07
'liest digital Wert INP7
'read digital INP7
'Data"7;as,INP7;1;0,0;1,1"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H07
      I2c_tx_b(2) = Inp7
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 8
'Befehl &H08
'liest analog Wert INP8
'read analog INP8
'Data "8;ap,INP8;1;1024;lin;-"
      I2c_tx_b(1) = &H08
      Gosub Send_input_2
'
   Case 9
'Befehl &H09
'liest digital Wert INP8
'read digital INP8
'Data "9;as,INP8;1;0,0;1,1"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H08
      I2c_tx_b(2) = Inp8
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 10
'Befehl &H0A
'liest analog Wert INP9
'read analog INP9
'Data "10;ap,INP9;1;1024;lin;-"
      I2c_tx_b(1) = &H0A
      Gosub Send_input_2
'
   Case 11
'Befehl &H0B
'liest digital Wert INP9
'read digital INP9
'Data "11;as,INP9;1;0,0;1,1"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H0B
      I2c_tx_b(2) = Inp9
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 12
'Befehl &H0C
'liest analog Wert IN10
'read analog INP10
'Data"12;ap,INP10;1;1024;lin;-"
      I2c_tx_b(1) = &H0C
      Gosub Send_input_2
'
      Case 13
'Befehl &H0D
'liest digital Wert INP10
'read digital INP10
'Data "13;as,INP10;1;0,0;1,1"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H0D
      I2c_tx_b(2) = Inp10
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 14
'Befehl &H0E
'liest analog Wert IN11
'read analog INP11
'Data"14;ap,INP11;1;1024;lin;-"
      I2c_tx_b(1) = &H0E
      Gosub Send_input_2
'
   Case 15
'Befehl &H0F
'liest digital Wert INP11
'read digital INP11
'Data "15;as,INP11;1;0,0;1,1"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H0F
      I2c_tx_b(2) = Inp11
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 16
'Befehl &H10
'liest digital alle
'read digital all
'Data"16;am,all;w,{0 to 4095}"
      Tempb = 0
      If Inp1 = 1 Then Tempb = 1
      If Inp2 = 1 Then Tempb = Tempb + 2
      If Inp3 = 1 Then Tempb = Tempb + 4
      If Inp4 = 1 Then Tempb = Tempb + 8
      If Inp5 = 1 Then Tempb = Tempb + 16
      If Inp6 = 1 Then Tempb = Tempb + 32
      If Inp7 = 1 Then Tempb = Tempb + 64
      If Inp8 = 1 Then Tempb = Tempb + 128
      I2c_tx_b(1) = &H10
      I2c_tx_b(3) = Tempb
      Tempb = 0
      If Inp9 = 1 Then Tempb = 1
      If Inp10 = 1 Then Tempb = Tempb + 2
      If Inp11 = 1 Then Tempb = Tempb + 4
      I2c_tx_b(2) = Tempb
'
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_write_pointer = 4
      Gosub Command_received
'
   Case 17
'Befehl &H11
'schaltet Relais1
'switch relais1
'Data "17;os,relais1;1;0,off;1,on"
      If Commandpointer = 1 Then
         Incr Commandpointer
      Else
         If Command_b(2) = 1 Then
            Set Relais1
         Else
            Reset Relais1
         End If
         Gosub Command_received
      End If
'
   Case 18
'Befehl &H12
'liest Status Relais1
'read state relais1
'Data "18;as;as17"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H12
      I2c_tx_b(2) = Relais1
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 19
'Befehl &H13
'schaltet Relais2
'switch relais2
'Data "19;os,relais2;1;0,off;1,on"
      If Commandpointer = 1 Then
         Incr Commandpointer
      Else
         If Command_b(2) = 1 Then
            Set Relais2
         Else
            Reset Relais2
         End If
         Gosub Command_received
      End If
'
   Case 20
'Befehl &H14
'liest Status Relais2
'read state relais2
'Data "20;as;as19"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H14
      I2c_tx_b(2) = Relais2
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 21
'Befehl &H15
'schaltet Relais3
'switch relais3
'Data "21;os,relais3;1;0,off;1,on"
      If Commandpointer = 1 Then
         Incr Commandpointer
      Else
         If Command_b(2) = 1 Then
            Set Relais3
         Else
            Reset Relais3
         End If
         Gosub Command_received
      End If
'
   Case 22
'Befehl &H16
'liest Status Relais3
'read state relais3
'Data "22;as;as21"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H16
      I2c_tx_b(2) = Relais3
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 23
'Befehl &H17
'schaltet Relais4
'switch relais4
'Data "23;os,relais4;1;0,off;1,on"
      If Commandpointer = 1 Then
         Incr Commandpointer
      Else
         If Command_b(2) = 1 Then
               Set Relais4
            Else
               Reset Relais4
            End If
            Gosub Command_received
         End If
'
   Case 24
'Befehl &H18
'liest Status Relais4
'read state relais4
'Data "24;as;as23"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H18
      I2c_tx_b(2) = Relais4
      I2c_write_pointer = 3
      Gosub Command_received
'
   Case 238
'Befehl &HEE
'schreibt Referenz default: 0:5V 1: 1.1V
'write reference voltage
'Data "238;oa;a"
      If Commandpointer = 1 Then
         Incr Commandpointer
      Else
         Select Case Command_b(2)
            Case 0
               Adc_reference = 0
               Adc_reference_eeram = Adc_reference
               Config Adc = Single , Prescaler = Auto , Reference = Avcc
            Case 1
               Adc_reference = 1
               Adc_reference_eeram = Adc_reference
               Config Adc = Single , Prescaler = Auto , Reference = Internal
            Case Else
               Error_no = 4
               Error_cmd_no = Command_no
         End Select
         Gosub Command_received
      End If
'
   Case 239
'Befehl &HEF
'liest Referenz default: 0:5V 1: 1.1V
'read reference voltage
'Data "239;aa;as238"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &HEF
      I2c_tx_b(2) = Adc_reference
      I2c_write_pointer = 3
      Gosub Command_received                          '
'
      Case 240
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
'Data "240;ln,ANNOUNCEMENTS;145;32"
      If Commandpointer >= 3 Then
         If Command_b(2) < No_of_announcelines And Command_b(3) < No_of_announcelines Then
            I2c_tx_busy = 2
            Tx_time = 1
            Send_line_gaps = 2
            Number_of_lines = Command_b(3)
            A_line = Command_b(2)
            Gosub Sub_restore
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
         Case Else
            I2c_tx = ": other error: "
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
      Gosub Command_received
'
   Case 254
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,4,{0 to 127}"
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
'Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,4,{0 to 127}"
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
Data "0;m;DK1RI; 4 Relais Bord;V04.1;1;100;1;32;1-1"
'
Announce1:
'Befehl &H01
'liest digital Wert INP1
'read digital INP1
Data"1;as,INP1;1;0,0;1,1"
'
Announce2:
'Befehl &H02
'liest digital Wert INP2
'read digital INP2
Data"2;as,INP2;1;0,0;1,1"
'
Announce3:
'Befehl &H03
'liest digital Wert INP3
'read digital INP3
Data"3;as,INP3;1;0,0;1,1"
'
Announce4:
'Befehl &H04
'liest digital Wert INP4
'read digital INP4
Data "4;as,INP4;1;0,0;1,1"
'
Announce5:
'Befehl &H05
'liest digital Wert INP5
'read digital INP5
Data"5;as,INP5;1;0,0;1,1"
'
Announce6:
'Befehl &H06
'liest digital Wert INP6
'read digital INP6
Data "6;as,INP6;1;0,0;1,1"
'
Announce7:
'Befehl &H07
'liest digital Wert INP7
'read digital INP7
Data"7;as,INP7;1;0,0;1,1"
'
Announce8:
'Befehl &H08
'liest analog Wert INP8
'read analog INP8
Data "8;ap,INP8;1;1024;lin;-"
'
Announce9:
'Befehl &H09
'liest digital Wert INP8
'read digital INP8
Data "9;as,INP8;1;0,0;1,1"
'
Announce10:
'Befehl &H0A
'liest analog Wert IN9
'read analog INP9
Data "10;ap,INP9;1;1024;lin;-"
'
Announce11:
'Befehl &H0B
'liest digital Wert INP9
'read digital INP9
Data "11;as,INP9;1;0,0;1,1"
'
Announce12:
'Befehl &H0C
'liest analog Wert IN10
'read analog INP10
Data"12;ap,INP10;1;1024;lin;-"
'
Announce13:
'Befehl &H0D
'liest digital Wert INP10
'read digital INP10
Data "13;as,INP10;1;0,0;1,1"
'
Announce14:
'Befehl &H0E
'liest analog Wert IN11
'read analog INP11
Data"14;ap,INP11;1;1024;lin;-"
'
Announce15:
'Befehl &H0F
'liest digital Wert INP11
'read digital INP11
Data "15;as,INP11;1;0,0;1,1"
'
Announce16:
'Befehl &H10
'liest digital alle
'read digital all
Data"16;am,all;w,{0 to 4095}"

Announce17:
'Befehl &H11
'schaltet Relais1
'switch relais1
Data "17;os,relais1;1;0,off;1,on"
'
Announce18:
'Befehl &H12
'liest Status Relais1
'read state relais1
Data "18;as;as17"
'
Announce19:
'Befehl &H13
'schaltet Relais2
'switch relais2
Data "19;os,relais2;1;0,off;1,on"
'
Announce20:
'Befehl &H14
'liest Status Relais2
'read state relais2
Data "20;as;as19"
'
Announce21:
'Befehl &H15
'schaltet Relais3
'switch relais3
Data "21;os,relais3;1;0,off;1,on"
'
Announce22:
'Befehl &H16
'liest Status Relais3
'read state relais3
Data "22;as;as21"
'
Announce23:
'Befehl &H17
'schaltet Relais4
'switch relais4
Data "23;os, relais4;1;0,off;1,on"
'
Announce24:
'Befehl &H18
'liest Status Relais4
'read state relais4
Data "24;as;as23"
'
Announce25:
'Befehl &HEE
'schreibt Referenz default: 0:5V 1: 1.1V
'write reference voltage
Data "238;oa;a"
'
Announce26:
'Befehl &HEF
'liest Referenz default: 0:5V 1: 1.1V
'read reference voltage
Data "239;aa;as238"
'
Announce27:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;ln,ANNOUNCEMENTS;100;32"
'
Announce28:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce29:
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce30:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,4,{0 to 127}"
'
Announce31:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,4,{0 to 127}"'