'-----------------------------------------------------------------------
'name : rs232_i2c_interface_slave.bas
'Version V04.1, 20160702
'purpose : I2C-RS232_interface Slave
'This Programm workes as I2C slave
'Can be used with hardware rs232_i2c_interface Version V03.0 by DK1RI
'The Programm supports the MYC protocol
'Slave max length of RS232 string is 252 Bytes.
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
'$regfile = "m88pdef.dat"
' for ATmega8P
$regfile = "m88def.dat"
' for ATmega8
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
'that is maximum
Const Rs232length = 252
'must be smaller than Stringlength
Const Cmd_watchdog_time = 65000
'Number of main loop before command reset
Const No_of_announcelines = 8
'announcements start with 0 -> minus 1
Const Blinktime = 3000
'
Dim First_set As Eram Byte
'first run after reset
Dim L As Byte
'Temps and local
Dim L1 As Byte
Dim L2 As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim Temps_b(20) As Byte At Temps Overlay
Dim I As Integer
'Blinkcounter  for tests
Dim J As Integer
'
Dim Rs232_in As String * Stringlength
'RS232 input
Dim Rs232_in_b(stringlength) As Byte At Rs232_in Overlay
Dim A As Byte
'actual RS232 input
Dim Rs232_pointer As Byte
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
Dim I2c_tx As String * Stringlength
Dim I2c_tx_b(Stringlength) As Byte At I2c_tx Overlay
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
Dim Send_lines As Byte
Dim Number_of_lines As Byte
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
'
If First_set <> 5 Then
   Gosub Reset_
Else
   Dev_number = Dev_number_eeram
   Dev_name = Dev_name_eeram
   Adress = Adress_eeram
   I2C_active = I2C_active_eeram
End If
'
Gosub Init
'
Slave_loop:
Start Watchdog
'Loop must be less than 2s
'
Gosub Blink_
'for tests
'
Gosub Cmd_watch
'
'RS232 got data for I2C ?
'Input on RS232 is stored in a buffer and transferred on read request to I2C buffer.
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
   If Rs232_pointer < Rs232length Then
   'If Buffer is full, chars are ignored !!
      Rs232_in_b(Rs232_pointer) = A
      Incr Rs232_pointer
      Printbin A
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
'I2C receives data and and interpet as commands.
'slave receive:
   If Twi_status = &H80 Or Twi_status = &H88 Then
      Tempb = Twdr
      If Commandpointer <= Stringlength Then
         Command_b(commandpointer) = Tempb
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1
            'start watchdog
            Reset Led3
            'LED on  for tests
         End If                                             '
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
'unsigned , set at first use
Dev_number = 1
Dev_number_eeram = Dev_number
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 2
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
Return
'
Init:
Set Led3
'for tests
Set Led4
Command_no = 1
Announceline = 255
'no multiple announcelines
Rs232_in = String(stringlength,0)
Rs232_pointer = 1
Gosub Reset_i2c_tx
Last_error = " No Error"
Error_no = 255
'No Error
Gosub Command_received
Gosub Command_finished
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
   Rs232_in = String(stringlength,0)
   Rs232_pointer = 1
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
If Error_no <> 3 Then Set Led3
'For Tests
If Error_no < 255 Then Gosub Last_err
Incr Command_no
Gosub Command_finished
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
   'complte length of string
End If
Return
'
Reset_i2c_tx:
I2c_length = 0
I2c_pointer = 1
I2c_tx = String(Stringlength,0)
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
'basic annoumement wird gelesen
'basic announcement is read to I2C
'Data "0;m;DK1RI;Rs232_i2c_interface Slave;V04.1.0;170;3;8"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl &H01 <s>
'Sendet Daten von I2C nach RS232
'read data from I2C, write to RS232 (write to device)
'Data "1,oa;253"
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            L = Command_b(2)
            If Commandpointer = 2 Then
               If L = 0 Then
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            Else
               If L > 252  Then Commandpointer = 252
               L = L + 2
               If Commandpointer = L Then
               'string finished
                  For Tempb = 3 To Commandpointer
                     Print Chr(command_b(tempb)) ;
                  Next Tempb
                  Print
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            End If
         End If
'
      Case 2
'Befehl &H02
'liest Daten von RS232 nach I2C
'read data from RS232, write to I2C  (read from device)
'Data "2,aa,253"
         If Rs232_pointer > 1 Then
            Gosub Reset_i2c_tx
            I2c_length = Rs232_pointer
            'one more due to length
            I2c_tx_b(1) = I2c_length - 1
            For Tempb = 1 To I2c_length - 1
               I2c_tx_b(tempb + 1) = Rs232_in_b(tempb)
            Next Tempb
         End If
         Rs232_in = String(Stringlength,0)
         Rs232_pointer = 1
         Gosub Command_received
'
      Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;170;8"
         If Commandpointer = 3 Then
            If Command_b(2) < No_of_announcelines And Command_b(3) <= No_of_announcelines Then
                If Command_b(3) > 0 Then
                  Send_lines = 1
                  Number_of_lines = Command_b(3)
                  A_line = Command_b(2)
                  Gosub Sub_restore
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
         Gosub Command_received
'
       Case 253
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
'Data "253;aa,MYC INFO;b,ACTIVE"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = 4
         'no info
         I2c_length = 1
         Gosub Command_received
'
      Case 254
'Befehl &HFE <0..3> <data>
'eigene Individualisierung schreiben
'write individualization
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127}"
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
                     If Tempb < 129 Then
                        Tempb = Tempb * 2
                        Adress = Tempb
                        Adress_eeram = Adress
                     Else
                        Error_no = 4
                     End If
                     Gosub Command_received
                  Else
                     Incr Commandpointer
                  End If
               Case Else
                  Error_no = 0
                  Gosub Last_err
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
               Case Else
                  Error_no = 4
                  'ignore anything else
            End Select
            Gosub Command_received
         Else
               Incr Commandpointer
         End If
'
      Case Else
         Error_no = 0
         'ignore anything else
         Gosub Last_err
         Gosub Command_received
      End Select
End If
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
'basic announcement is read to I2C
Data "0;m;DK1RI;Rs232_i2c_interface Slave;V04.1.0;170;3;8"
'
Announce1:
'Befehl &H01 <s>
'Sendet Daten von I2C nach RS232
'read data from I2C, write to RS232 (write to device)
Data "1,oa;253"
'
Announce2:
'Befehl &H02
'liest Daten von RS232 nach I2C
'read data from RS232, write to I2C  (read from device)
Data "2,aa,253"
'
Announce3:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;170;8"
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
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127}"
'
Announce7:
'Befehl &HFF <0 .. 3> :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127}"
'