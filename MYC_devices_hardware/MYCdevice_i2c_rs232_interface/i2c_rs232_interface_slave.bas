'-----------------------------------------------------------------------
'name : rs232_i2c_interface_slave.bas
'Version V05.0, 20170715
'purpose : I2C-RS232_interface Slave
'This Programm workes as I2C slave
'Can be used with hardware rs232_i2c_interface Version V02.0 by DK1RI
'The Programm supports the MYC protocol
'Slave max length of RS232 string is 252 Bytes.
'Please modify clock frequncy and processor type, if necessary
'Please modify Const Tx_factor to 1 for usage in a real MYC system
'Please verify, that EEprom is programmes as well!!
'
'micro : ATMega168 or higher
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
'This is the template
'-----------------------------------------------------------------------
'Used Hardware:
' RS232
' I2C
'-----------------------------------------------------------------------
' Inputs: Reset: PinB.2
' Outputs : Test LEDs D.3, D.2
' I/O : I2C , RS232
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
$regfile = "m328pdef.dat"
'$regfile = "m168def.dat"
'
$crystal = 20000000
' used crystal frequency
$baud = 19200
' use baud rate
$hwstack = 64
' default use 32 for the hardware stack
$swstack = 20
' default use 10 for the SW stack
$framesize = 50
' default use 40 for the frame space
'
'**************** libs
'use byte library for smaller code
'$lib "mcsbyte.lbx"
'
'**************** Variables
Const Lf = 10
Const I2c_buff_length = 252
'that is maximum
Const Rs232_length = 250
'must be smaller than I2c_buff_length
Const Command_length = 254
'No command has more bytes
Const A_line_length = 85
'max length of announcelines
Const No_of_announcelines = 9
'0 based
Const Blinktime = 5000
Const Cmd_watchdog_time = Blinktime * 10
'Number of main loop before command reset
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
Const Tx = 4 * Tx_factor
Const Tx_timeout = Cmd_watchdog_time * Tx
Const Not_valid_cmd = &H80
'a non valid commandtoken

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
'
'Temps
Dim L As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Tempw As Word
Dim Temps As String * A_line_length
Dim Temps_b(A_line_length) As Byte At Temps Overlay
'
Dim I As Byte
'Blinkcounter  for tests
Dim J As Word
'
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
'
Dim Rs232_in As String * Rs232_length
'RS232 input
Dim Rs232_in_b(Rs232_length) As Byte At Rs232_in Overlay
Dim A As Byte
'actual RS232 input
Dim Rs232_pointer As Byte
'
'check for previous Watchdog error
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'**************** Config / Init
' Jumper:
Config PinB.2 = Input
PortB.2 = 1
Reset__ Alias PinB.2
'
' Life LED:

Config Portd.2 = Output
'for tests
Config Portd.3 = Output
Led4 Alias Portd.2
'life LED
Led3 Alias PortD.3
'on if cmd activ, off, when cmd finished
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

If First_set <> 5 Then Gosub Reset_
'
Gosub Init
'
Start Watchdog
'
Slave_loop:
'Loop must be less than 2s
'
Gosub Blink_
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
'RS232 got data for I2C ?
'Input on RS232 is stored in a buffer and transferred on read request to I2C buffer
'actual start is position 1 always
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
   If Rs232_pointer < Rs232_length Then
      Incr Rs232_pointer
      Printbin A
      Rs232_in_b(Rs232_pointer) = A
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
Reset Watchdog                                               '
Goto Slave_loop
'
'===========================================
'
Reset_:
Reset Led3
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
Adress = 2
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
'This should be the last
First_set = 5
Set Led3
Return
'
Init:
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram
I2C_active = I2C_active_eeram
Set Led3
'for tests
Set Led4
Command_no = 1
Announceline = 255
Rs232_in = String(Rs232_length, Not_valid_cmd)
Rs232_pointer = 0
Errorflag = 0
Error_cmd_no = 0
Send_lines = 0
Gosub Command_received
Gosub Reset_i2c_tx
Gosub Reset_i2c
Return
'
Blink_:
'for tests
'Led Blinks To Show Life
J = J + 1
If J = Blinktime Then
   J = 0
   Select Case I
   Case 1
      Set Led4
   Case 6
      Reset Led4
   Case 10
      I = 0
      'reset I2c if not busy
      Twi_control = Twcr And &H80
      'twint set?
      If Twi_control = &H00 Then Gosub Reset_i2c
   End Select
   Incr I
End If
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
Slave_commandparser:
'checks to avoid commandbuffer overflow are within commands !!
If I2c_active = 0 Then
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
'basic annoumement wird gelesen
'basic announcement is read to I2C
'Data "0;m;DK1RI;Rs232_i2c_interface Slave;V05.0;1;85;1;8"
         If I2c_tx_busy = 0 Then
            'require empty buffer
            A_line = 0
            Number_of_lines = 1
            Send_lines = 3
            I2c_tx_busy = 1
            Tx_time = 1
            Gosub Sub_restore
         Else
            Error_no = 7
            Errorflag = 1
         End If
         Gosub Command_received
'
   Case 1
'Befehl &H01 <s>
'Sendet Daten von I2C nach RS232
'read data from I2C, write to RS232 (write to device)
'Data "1,oa;252"
      If Commandpointer > 1 Then
         L = Command_b(2)
         If Commandpointer = 2 Then
            If L = 0 Then
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         Else
            If L > 252  Then
               Error_no = 4
               Errorflag =1
               Gosub Command_received
            Else
               L = L + 2
               If Commandpointer = L Then
               'string finished
                  For Tempb = 3 To Commandpointer
                     Tempc = Command_b(tempb)
                     Printbin Tempc
                  Next Tempb
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            End If
         End If
      Else
         Incr Commandpointer
      End If
'
   Case 2
'Befehl &H02
'liest Daten von RS232 nach I2C
'read data from RS232, write to I2C  (read from device)
'Data "2,aa,252"
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &H02
         I2c_tx_b(2) = Rs232_pointer
         I2c_write_pointer = 3
         For Tempb = 1 To Rs232_pointer
            I2c_tx_b(I2c_write_pointer) = Rs232_in_b(Tempb)
            Incr I2c_write_pointer
         Next Tempb
         Rs232_pointer = 0
         'all bytes transfered to I2c_tx
      Else
         'not valid now
         Error_no = 7
         Errorflag = 1
      End If
      Gosub Command_received
'
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;85;8"
      If Commandpointer >= 3 Then
         If Command_b(2) < No_of_announcelines And Command_b(3) < No_of_announcelines Then
            If I2c_tx_busy = 0 Then
               I2c_tx_busy = 1
               Tx_time = 1
               Send_lines = 2
               Number_of_lines = Command_b(3)
               A_line = Command_b(2)
               Gosub Sub_restore
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
      Else
         Error_no = 7
         Errorflag = 1
      End If
      Gosub Command_received
'
   Case 254
'Befehl &HFE <0..3> <data>
'eigene Individualisierung schreiben
'write individualization
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127}"
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
            Case Else
               Error_no = 0
               Errorflag = 1
         End Select
      Else
        Incr Commandpointer
      End If
'
   Case 255
'Befehl &HFF <0..3>:
'eigene Individualisierung lesen
'read individualization
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127}"
      If Commandpointer >= 2 Then
         If I2c_tx_busy = 0 Then
            If Command_b(2) < 4 Then
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
               End Select
            Else
               Error_no = 4
               Errorflag = 1
               'ignore anything else
            End If
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
'
$Data
'announce text
'
Announce0:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read to I2C
Data "0;m;DK1RI;Rs232_i2c_interface Slave;V05.0;1;85;1;9"
'
Announce1:
'Befehl &H01 <s>
'Sendet Daten von I2C nach RS232
'read data from I2C, write to RS232 (write to device)
Data "1,oa;252"
'
Announce2:
'Befehl &H02
'liest Daten von RS232 nach I2C
'read data from RS232, write to I2C  (read from device)
Data "2,aa,252"
'
Announce3:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;85;9"
'
Announce4:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce5:                                                  '
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce6:
'Befehl &HFE <0..3> <data>
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127}"
'
Announce7:
'Befehl &HFF <0 .. 3> :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127}"
'
Announce8:
Data "R 254&2 IF $255&2=0"