'-----------------------------------------------------------------------
'name : FS20_8Kanal_rx_bascom.bas
'Version V05.1, 20180927
'purpose : Programm for receiving FS20 Signals
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
'slave_core_V01.6
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
$regfile = "m644def.dat"
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
Const Tx_timeout = Cmd_watchdog_time * Tx_factor
'           timeout, when I2c_Tx_b is cleared and new commands allowed
'
Const T_factor = 1953
'20MHz / 1024 / 1953 = 10  Hz -> 100ms
'stop for Timer1
Const T_Short = 2
'0,2s
Const T_long = T_short * 30
'6 s
Const T_modus = T_short * 63
'12.5s
'
Const No_of_announcelines = 11
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
Dim Switchoff_time As Byte
'contains waittime for switchoff
Dim K as Byte
Dim Timer_started as Bit
Dim Switch As Byte
Dim Switch1 As Byte
Dim Codelength As Byte
' Number of blocks to transfer
Dim Codepointer As Byte
' pointer to aktiv block
Dim Send_code(30) As Byte
Dim Switch_status  As Byte
Dim Switch_status_old As Byte
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
Config PortA.7 = Output
Ta1 Alias PortA.7     'INH Taster Eingang 1
Config PortA.6 = Output
Ta2 Alias portA.6     'ING Taster Eingang 2
Config PortA.5 = Output
Ta3 Alias PortA.4     'INF Taster Eingang 3
Config PortA.4 = Output
Ta4 Alias PortA.4     'INE Taster Eingang 4
Config PortA.3 = Output
Ta5 Alias PortA.3     'IND Taster Eingang 5
Config PortA.2 = Output
Ta6 Alias PortA.2     'INC Taster Eingang 6
Config PortA.1 = Output
Ta7 Alias PortA.1     'INB Taster Eingang 7
Config PortA.0 = Output
Ta8 Alias PortA.0     'INA Taster Eingang 8
Porta = &HFF
'
Config PinC.7 = Input '1 Modul Output_1
PortC.7 = 1
Sch1 Alias Pinc.7
Config PinC.6 = Input '2 Modul Output_2
PortC.6 = 1
Sch2 Alias Pinc.6
Config PinC.5 = Input '3 Modul Output_3
PortC.5 = 1
Sch3 Alias Pinc.5
Config PinC.4 = Input '4 Modul Output_4
PortC.4 = 1
Sch4 Alias PinC.4
Config PinC.3 = Input '5 Modul Output_5
Portc.3 = 1
Sch5 Alias Pinc.3
Config Pinc.2 = Input '6 Modul Output_6
Portc.2 = 1
Sch6 Alias PinC.2
Config Pind.7 = Input '7 Modul Output_7
Portd.7 = 1
Sch7 Alias Pind.7
Config Pind.6 = Input '8 Modul Output 8
Portd.6 = 1
Sch8 Alias Pind.6
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
Gosub Check_input_status
'
'check timer
If Codelength > 0 Then
   If Timer_started = 0 Then
      'After each transferred data: switch_off has set Timer_started = 0
      Tempb = 3 * Codepointer
      Switchoff_time = Send_code(Tempb)
      Decr Tempb
      Switch1 = Send_code(Tempb)
      Decr Tempb
      Switch = Send_code(Tempb)
      Gosub Switch_on
      Incr Codepointer
      Timer1 = 0
      Start Timer1
      Timer_started = 1
      K = 0
   End If
   If Timer1 > T_factor Then
      Incr K
      Stop Timer1
      If K >= Switchoff_time Then
         'Switch_off
         Gosub Switch_off
         If Codepointer >= Codelength Then Codelength = 0
         ' This allow the next transfer command
      Else
         'continue
         Timer1 = 0
         Start Timer1
      End If
   End If
End If
'
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
               Gosub Reset_i2c_tx
               If Number_of_lines > 0 Then Gosub Sub_restore
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
Adress = 26
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
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
Switchoff_time = 0
Timer_started = 0
K = 0
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
'Byte beyond restored data must be 0:
Tempc = Len(I2c_tx)
For Tempb = 1 To I2c_buff_length
   I2c_tx_b(Tempb) = 0
Next Tempb
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
   Case Else
         'will not happen
End Select
Read I2c_tx
Tempc = Len(I2c_tx)
For Tempb = Tempc To 1 Step - 1
   Tempa = Tempb + Send_line_gaps
   I2c_tx_b(Tempa) = I2c_tx_b(Tempb)
Next Tempb
Select Case Send_line_gaps
   Case 1
      'additional announcement lines
      I2c_tx_b(1) = Tempc
      I2c_write_pointer = Tempc + 2
      Send_line_gaps = 1
      Incr A_line
      I2c_write_pointer = Tempc + 2
      If A_line >= No_of_announcelines Then A_line = 0
   Case 2
      'start basic announcement
      I2c_tx_b(1) = &H00
      I2c_tx_b(2) = Tempc
      I2c_write_pointer = Tempc + 3
   Case 4
      'start of announceline(s), send 3 byte first
      I2c_tx_b(1) = &HF0
      I2c_tx_b(2) = A_line
      I2c_tx_b(3) = Number_of_lines
      I2c_tx_b(4) = Tempc
      I2c_write_pointer = Tempc + 5
      Send_line_gaps = 1
      Incr A_line
      If A_line >= No_of_announcelines Then A_line = 0
End Select
Decr Number_of_lines
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
Check_input_status:
'This will not interrupt the F0 command
If Number_of_lines > 0 Then Return
Switch_status_old = Switch_status
Switch_status.0 = Sch1
Switch_status.1 = Sch2
Switch_status.2 = Sch3
Switch_status.3 = Sch4
Switch_status.4 = Sch5
Switch_status.5 = Sch6
Switch_status.6 = Sch7
Switch_status.7 = Sch8
If Switch_status <> Switch_status_old Then
   If Switch_status.0 <> Switch_status_old.0 Then
      Tempb = 0
      Tempc = Switch_status.0
      Gosub status_changed
   End If
   If Switch_status.1 <> Switch_status_old.1 Then
      Tempb = 1
      Tempc = Switch_status.1
      Gosub status_changed
   End If
   If Switch_status.2 <> Switch_status_old.2 Then
      Tempb = 2
      Tempc = Switch_status.2
      Gosub status_changed
   End If
   If Switch_status.3 <> Switch_status_old.3 Then
      Tempb = 3
      Tempc = Switch_status.3
      Gosub status_changed
   End If
   If Switch_status.4 <> Switch_status_old.4 Then
      Tempb = 4
      Tempc = Switch_status.4
      Gosub status_changed
   End If
   If Switch_status.5 <> Switch_status_old.5 Then
      Tempb = 5
      Tempc = Switch_status.5
      Gosub status_changed
   End If
   If Switch_status.6 <> Switch_status_old.6 Then
      Tempb = 6
      Tempc = Switch_status.6
      Gosub status_changed
   End If
   If Switch_status.7 <> Switch_status_old.7 Then
      Tempb = 7
      Tempc = Switch_status.7
      Gosub status_changed
   End If
End If
Return
'
Status_changed:
'show active high as 1
If Tempc = 0 Then
   Tempc = 1
Else
   Tempc = 0
End If
Printbin &H01
Printbin Tempb
Printbin Tempc
I2c_tx_b(I2c_Write_pointer) = &H01
Incr I2c_Write_pointer
If I2c_Write_pointer = I2c_buff_length Then I2c_Write_pointer = 1
I2c_tx_b(I2c_Write_pointer) = Tempb
Incr I2c_Write_pointer
If I2c_Write_pointer = I2c_buff_length Then I2c_Write_pointer = 1
I2c_tx_b(I2c_Write_pointer) = Tempc
Incr I2c_Write_pointer
If I2c_Write_pointer = I2c_buff_length Then I2c_Write_pointer = 1
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
'Data "0;s;DK1RI;FS20_receiver;V05.1;1;145;1;11;1-1"
      I2c_tx_busy = 2
      Tx_time = 1
      A_line = 0
      Number_of_lines = 1
      Send_line_gaps = 2
      Gosub Sub_restore
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 1
'Befehl  &H01
'liest Status der 8 Schalter, und sendet als operate
'read status of 8 switches and send as operate
'Data "1;rr,8 switches;1;0;1;2;3;4;5.6,7"
      Error_no = 0
      Error_cmd_no = Command_no
      'This command is sent only
      Gosub Command_received
'
   Case 2
'Befehl  &H02
'liest Status aller 8 Schalter  MYC write!!
'read status of all 8 switches  MYC write!!
'Data "2;sa,status all switches,for Test and Initialization;b"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H02
      I2c_write_pointer = 3
      Tempb = 0
      If Sch1 = 1 Then Tempb = Tempb Or &B00000001
      If Sch2 = 1 Then Tempb = Tempb Or &B00000010
      If Sch3 = 1 Then Tempb = Tempb Or &B00000100
      If Sch4 = 1 Then Tempb = Tempb Or &B00001000
      If Sch5 = 1 Then Tempb = Tempb Or &B00010000
      If Sch6 = 1 Then Tempb = Tempb Or &B00100000
      If Sch7 = 1 Then Tempb = Tempb Or &B01000000
      If Sch8 = 1 Then Tempb = Tempb Or &B10000000
      I2c_tx_b(2) = Tempb
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 237
'Befehl &HED
'busy, 1: keine Befehle akzeptiert
'busy, 1: no commands accepted
'Data "237;la,busy;a"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &HEA
      I2c_write_pointer = 3
      Tempb = 0
      If Codelength > 0 Then Tempb = 1
      I2c_tx_b(2) = Tempb
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 238
'Befehl  &HEE
'schaltet ein /aus
'switch on / off
'Data "238;ku, switch for Test;1;0;1;2;3;4;5;6;7"
      If Commandpointer >= 2 Then
         If Command_b(2) < 8 Then
            If Codelength = 0 Then
               Send_code(1) = Command_b(2) + 1
               Send_code(2) = 0
               Send_code(3) = T_short
               Codepointer = 1
               Codelength = 1
            Else
               Error_no = 7
               Error_cmd_no = Command_no
            End If
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
      Else
         Incr Commandpointer
      End If
'
   Case 239
'Befehl  &HEF
'schaltet ein /aus  Anlernen
'switch on / off learning
'Data "239;ku, learning mode for Test and Initialization;1;0;1;2;3;4;5;6;7"
      If Switchoff_time = 0 Then
         If Commandpointer >= 2 Then
            If Command_b(2) < 8 And Command_b(3) > 0  Then
               If Codelength = 0 Then
                  Send_code(1) = Command_b(2) + 1
                  Send_code(2) = 0
                  Send_code(3) = T_modus
                  Codepointer = 1
                  Codelength = 1
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
      Else
         Error_no = 0
         Error_cmd_no = Command_no
         Gosub Command_received
      End If
'
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
'Data "240;ln,ANNOUNCEMENTS;145;11"
      If Commandpointer >= 3 Then
         If Command_b(2) < No_of_announcelines And Command_b(3) < No_of_announcelines Then
            If Command_b(3) > 0 Then
               I2c_tx_busy = 2
               Tx_time = 1
               Send_line_gaps = 4
               Number_of_lines = Command_b(3)
               A_line = Command_b(2)
               Gosub Sub_restore
               If Command_mode = 1 Then
                  Gosub Print_i2c_tx
                  While Number_of_lines > 0
                     Gosub Sub_restore
                     Gosub Print_i2c_tx
                  Wend
                  Gosub Reset_i2c_tx
               End If
            End If
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
      print commandpointer
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
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,13,{0 to 127};a,RS232,1;a,USB,1"
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
'Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,13,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
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
'basic announcement is read
Data "0;m;DK1RI;FS20_receiver;V05.1;1;145;1;11;1-1"
'
Announce1:
'Befehl  &H01
'liest Status der 8 Schalter, und sendet als operate
'read status of 8 switches and send as operate
Data "1;rr,8 switches;1;0;1;2;3;4;5.6,7"
'
Announce2:
'Befehl  &H02
'liest Status aller 8 Schalter  MYC write!!
'read status of all 8 switches  MYC write!!
Data "2;sa,status all switches,for Test and Initialization;b"
'
Announce3:
'Befehl &HED
'busy, 1: keine Befehle akzeptiert
'busy, 1: no commands accepted
Data "237;la,busy;a"
'
Announce4:
'Befehl  &HEE
'schaltet ein /aus
'switch on / off
Data "238;ku, switch for Test;1;0;1;2;3;4;5;6;7"
'
Announce5:
'Befehl  &HEF
'schaltet ein /aus  Anlernen
'switch on / off learning
'Data "239;ku, learning mode for Test and Initialization;1;0;1;2;3;4;5;6;7"
'
Announce6:
'Befehl &HF0<n><m>
'announcement aller Befehle lesen
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;11"
'
Announce7:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce8:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce9:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,13,{0 to 127};a,RS232,1;a,USB,1"
'
Announce10:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,13,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'