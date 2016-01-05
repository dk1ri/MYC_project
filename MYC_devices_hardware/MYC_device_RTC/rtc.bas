'-----------------------------------------------------------------------
'name : rtc.bas
'Version V01.0, 20160104
'purpose : Programm as realtime clock using the ELV RTC-DCF module
'This Programm workes as I2C slave
'Can be used with hardware MYC_rtc Version V01.0 by DK1RI
'The Programm supports the MYC protocol
'I2C Slave max buffer length is 252 Bytes.
'Please modify clock frequncy and processor type, if necessary
'
'When modifying the number of commands or type of interface, please modify:
' Const No_of_announcelines =
' number of announcements in the 0 and 240 command announcements
' add lines in Sub_restore
' IC2 Adress in reset and announcements
'
'micro : ATMega88 or higher
'Fuse Bits :
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
$PROG &HFF,&HC6,&HDF,&HF9' generated. Take care that the chip supports all fuse bytes.
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other right are affected, this programm can be used
'under GPL (Gnu public licence)
'-----------------------------------------------------------------------
'Templates:
' DTMF_rx V01.0
'-----------------------------------------------------------------------
'Used Hardware:
' I2C
' MISO MOSI
'-----------------------------------------------------------------------
' Inputs: Reset: Pin B.2
'          RC5 In : Pin B.0
' Outputs : Test LEDs D.3, D.4 D.6
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'$regfile = "m88pdef.dat"                                   ' for ATmega8P
'$regfile = "m88def.dat"                                    ' (for ATmega8)
$regfile = "m328pdef.dat"                                  'for ATmega328
$crystal = 20000000
$baud = 19200                                              ' use baud rate
$hwstack = 64                                              ' default use 32 for the hardware stack                            ' generated. Take care that the chip supports all fuse bytes.
$swstack = 20                                              ' default use 10 for the SW stack
$framesize = 50                                            ' default use 40 for the frame space
' Simulation!!!!
' $sim
'
'**************** libs
'use byte library for smaller code
'$lib "mcsbyte.lbx"
$lib "i2c_twi.lbx"
'
'**************** Variables
Const Lf = 10
Const Stringlength = 160
Const Stringlength_RS232 =9
Const Cmd_watchdog_time = 65000                            'Number of main loop before command reset
Const Blinktime = 60000
Const No_of_announcelines = 10                             'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte                                'first run after reset
Dim L As Byte                                              'Temps and local
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim Tempw As Word
Dim Tempdw As Dword
Dim Temp_single As Single
Dim J As Word
Dim Temps_b(20) As Byte At Temps Overlay
Dim A As Byte                                              'actual RS232 input
Dim Announceline As Byte                                   'notifier for multiple announcelines
Dim A_line As Byte                                         'actual announline
Dim Dev_name As String * 20
Dim Dev_name_eeram As Eram String * 20
Dim Dev_name_b(20) As Byte At Dev_name Overlay
Dim Dev_number As Byte
Dim Dev_number_eeram As Eram Byte
Dim Adress As Byte                                         'I2C adress
Dim Adress_eeram As Eram Byte                             'I2C Buffer
Dim I2c_tx As String * Stringlength
Dim I2c_tx_b(stringlength) As Byte At I2c_tx Overlay
Dim I2c_pointer As Byte
Dim I2C_name As Byte
Dim I2C_name_eeram As Eram Byte
Dim I2c_length As Byte
Dim Command As String * Stringlength                       'Command Buffer
Dim Command_b(stringlength) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
Dim Twi_status As Byte                                     'HW I2C
Dim Twi_control As Byte
Dim Last_error As String * 30                              'Error Buffer
Dim Last_error_b(30) As Byte At Last_error Overlay
Dim Error_no As Byte
Dim Cmd_watchdog As Word                                   'Watchdog notifier
'
'Dim Daten as Byte
Dim valid_adress As Byte
Dim Number_of_read_bytes As Byte
Dim Stuffed As Bit
Dim Year As Dword
Dim Day As Dword
Dim Month As Byte
Dim Unixtime As Dword
Dim Unixtime0 As Byte At Unixtime Overlay
Dim Unixtime1 As Byte At Unixtime + 1 Overlay
Dim Unixtime2 As Byte At Unixtime + 2 Overlay
Dim Unixtime3 As Byte At Unixtime + 3 Overlay
Dim Tage_seit_ja(12) As Word
Tage_seit_JA(1) = 31                                        ' day since start of year without actuakl day no leapyear
Tage_seit_JA(2) = 59
Tage_seit_JA(3) = 90
Tage_seit_JA(4) = 120
Tage_seit_JA(5) = 151
Tage_seit_JA(6) = 181
Tage_seit_JA(7) = 212
Tage_seit_JA(8) = 243
Tage_seit_JA(9) = 273
Tage_seit_JA(10) = 304
Tage_seit_JA(11) = 334
Dim Schaltjahre As Dword
Dim Value as Byte
Dim Register As Byte
Dim Writepointer   As Byte
Dim RS232_in_buffer  As String * Stringlength_RS232        'content of read RTC data
Dim RS232_in_buffer_b(Stringlength_RS232) As Byte At RS232_in_buffer Overlay
Dim All_bytes_read As Byte
Dim Read_register As Byte
Dim Read_byte As Byte
'
'**************** Config / Init
'
DDRB.2 = 0                                                  'Input
PortB.2 = 1                                                 'Pullup
Reset__ Alias PinB.2
'
' Life LED:
Config PortC.3 = Output
Led1 Alias PortC.3                                         'life LED
'
Config Sda = Portc.4                                       'must !!, otherwise error
Config Scl = Portc.5
'
Config Watchdog = 2048
'
'Mega8 has fixed parameter, processor will hang here, if uncommented:
'Config Com1 = 19200 , Databits = 8 Parity = None , Stopbits = 1                                                '
'
'****************Interrupts
'Enable Interrupts
'serialin not buffered!!
'serialout not buffered!!!
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
   I2C_name= I2C_name_eeram
End If
'
Gosub Init
'
Waitms 5000
print Chr(2);Chr(0);Chr(45);Chr(5);Chr(3);               'Start DCF and LED  registe 2D
'
Slave_loop:
Start Watchdog                                            'Loop must be less than 512 ms
'
If Read_register =0 Then                                   'do not send when register is requested
   Gosub Ask_time                                          'ask for time every 500ms
End If
'
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong coomands will be deleted
If Cmd_watchdog > Cmd_watchdog_time Then
   Error_no = 3
   Gosub Last_err
   Gosub Command_received                                  'reset commandinput
Else
   If Cmd_watchdog <> 0 Then Incr Cmd_watchdog
End If
'
'RS232 got data?                                             data from RTC modul
A = Ischarwaiting()
If A = 1 Then
      A = Waitkey()
      If WritePointer < All_bytes_read Then
         Select Case A
            Case 2
               If Stuffed = 1 Then                         'Otherwise Startbyte -> ignore
                  Stuffed = 0
                  RS232_in_buffer_b(writepointer) = A       'byte is x10
                  Incr WritePointer
               End If
            Case 3
               If Stuffed = 1 Then                         'Otherwise Stopbyte -> ignore
                  Stuffed = 0
                  RS232_in_buffer_b(writepointer) = A       'byte is x10
                  Incr WritePointer
               End If
            Case 16                                        'stuff byte
               If Stuffed = 1 Then
                  Stuffed = 0
                  RS232_in_buffer_b(writepointer) = A       'byte is x10
                  Incr WritePointer
               Else
                  Stuffed = 1
               End If
            Case Else
               Stuffed = 0
               RS232_in_buffer_b(writepointer) = A
               Incr WritePointer
         End Select
         If WritePointer = All_bytes_read Then
            I2C_tx = String (Stringlength , 0)
            I2c_length = 7
            I2c_pointer = 1
            Select Case Read_register
               Case 0
                  Gosub Calculate_unix_time
               Case 2
                   I2C_tx_b(1) =  RS232_in_buffer_b(Read_byte)
                   i2c_length = 1
               Case 1
                  I2C_tx_b(1) = 7
                  For Tempb = 1 To 7
                     I2C_tx_b(Tempb + 1) =  RS232_in_buffer_b(Tempb)
                  Next Tempb
                  I2c_length = 8
               Case Else
                  I2c_length = 0
            End Select
         End If
      End If
End If
'
'I2C
Twi_control = Twcr And &H80                                'twint set?
If Twi_control = &H80 Then                                 'twsr 60 -> start, 80-> daten, A0 -> stop
   Twi_status = Twsr
   Twi_status = Twi_status And &HF8
'slave send:
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
         If I2c_pointer <= I2c_length Then
            Twdr = I2c_tx_b(i2c_pointer)
            Incr I2c_pointer
         Else
            If Announceline <= No_of_announcelines Then    'multiple lines to send
               Cmd_watchdog = 0                             'command may take longer
               A_line = Announceline
               Gosub Sub_restore
               Incr Announceline
               Twdr = I2c_tx_b(i2c_pointer)
               Incr I2c_pointer
            Else                                           'all bytes send
               Announceline = 255
               i2c_length = 0
               I2c_pointer = 1
               I2c_tx = String(stringlength , 255)
               TWDR=&H00
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
            Cmd_watchdog = 1                                'start watchdog
        End If
         Gosub Slave_commandparser
      End If
   End If
   Twcr = &B11000100
End If
Stop Watchdog                                             '
Goto Slave_loop
'
'===========================================
'
Reset_:
First_set = 5
Dev_number = 1                                              'unsigned , set at first use                                 'obviously not yet set
Dev_number_eeram = Dev_number                               'default values
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 38
Adress_eeram = Adress
I2C_name="1"
I2C_Name_eeram = I2C_name
Return
'
Init:
Led1 = 1
J = 0
Command_no = 1
Announceline = 255                                          'no multiple announcelines
I2c_tx = String(stringlength , 255)                        'will delete buffer and restart ponter
I2c_length = 0
I2c_pointer = 1
Last_error = " No Error"
Error_no = 255                                              'No Error
Valid_adress = 1
Gosub Command_received
Gosub Command_finished
Writepointer = 1                                            'master will read 0 without a command
All_bytes_read=8
Read_register = 0                                           'read 7 bytes for time
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
Command_finished:
'i2c reset, only after error, at start and multiple announcements
'I2cinit                                                    'may be not neccessary
'Config Twi = 100000                                        '100KHz
Twsr = 0                                                    'status und Prescaler auf 0
Twdr = &HFF                                                 'default
Twar = Adress                                               'Slaveadress
Twcr = &B01000100
Return
'
Command_received:
Commandpointer = 1
Command = String(stringlength , 0)
Cmd_watchdog = 0
Incr Command_no
Return
'
Sub_restore:
Error_no = 255                                              'no error
I2c_tx = String(stringlength , 0)                          'will delete buffer , read appear 0 at end ???
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
      Error_no = 0
      Gosub Last_err
End Select
If Error_no = 255 Then
   Read I2c_tx
   Gosub I2c_tx_length
End if
'

i2c_tx_length:
   I2c_length = Len(i2c_tx)
   For Tempb = I2c_length To 1 Step -1                     'shift 1 pos right
      I2c_tx_b(tempb + 1) = I2c_tx_b(tempb)
   Next Tempb
   I2c_tx_b(1) = I2c_length
   Incr I2c_length
   I2c_pointer = 1
Return
'
Ask_time:
'Ask module for time  and switch Led
   Incr J
   If J > Blinktime Then
      J = 0
      RS232_in_buffer  = String(Stringlength_RS232,0)
      Writepointer = 1
      Stuffed = 0
      All_bytes_read = 8
      If Led1 = 0 Then
         Set Led1
      else
         Reset Led1
      End If
      Print Chr(2);Chr(1);Chr(32);Chr(7);Chr(3);
   End If
Return
'
Calculate_unix_time:
   Value = RS232_in_buffer_b(1)
   Tempb = Value AND &B01110000                            'sekonds
   Shift Tempb ,Right , 4
   Tempb = Tempb * 10
   Tempc = Value AND &B00001111
   Tempc = Tempb + Tempc
   Unixtime = Tempc
'
   Value = RS232_in_buffer_b(2)                            'minutes
   Tempb = Value AND &B01110000
   Shift Tempb ,Right , 4
   Tempb = Tempb * 10
   Tempc = Value AND &B00001111
   Tempc = Tempc + Tempb
   Tempdw = Tempc
   Tempdw   = Tempdw * 60
   Unixtime = Unixtime + Tempdw
'
   Value = RS232_in_buffer_b(3)                            'hours
   Tempb = Value AND &B00110000
   Shift Tempb ,Right , 4
   Tempb = Tempb * 10
   Tempc = Value AND &B00001111
   Tempc = Tempc + Tempb
   Tempdw = Tempc
   Tempdw = Tempdw * 3600
   Unixtime = Unixtime + Tempdw                             'seconds of actual day
'                                                           'day of week, not used
'
   Value = RS232_in_buffer_b(5)                             'day
   Tempb = Value AND &B00110000
   Shift Tempb , Right , 4
   Tempb = Tempb * 10
   Tempc = Value AND &B00001111
   Tempc = Tempc + Tempb
   Decr Tempc
   Day = Tempc                                              'withot actual day
'
   Value = RS232_in_buffer_b(6)                             'month
   Tempb = Value AND &B00010000
   Shift Tempb , Right , 4
   Tempb = Tempb * 10
   Tempc = Value AND &B00001111
   Month = Tempc + Tempb
   Decr Month                                               'without actual month
   If Month = 0 Then
      Tempdw = Day
   Else
      Tempdw = Tage_seit_ja(Month)
      Tempdw = Tempdw + Day                                 'all days aince start of year
   End If
   Tempdw = Tempdw * 86400                                 '60*60*24  seonds
   Unixtime = Unixtime + Tempdw                             'all sekonds since start of year
'
   Value = RS232_in_buffer_b(7)                             'year: 2 octetts !!!
   Tempb = Value AND &B11110000
   Shift Tempb , Right , 4
   Tempb = Tempb * 10
   Tempc = Value AND &B00001111
   Tempc = Tempc + Tempb
   Year = Tempc  + 30                                       'complete years sind 1. 1. 1970 (without actual year) (31 -1)
   Tempdw = 365 *  Year                                     'alle Tage
'
   Schaltjahre = Tempc - 13
   Schaltjahre = Schaltjahre / 4                            'sinde 2017: Schaltjahre (leapyear) > 0  2016 woüld be actual year
   Schaltjahre = Schaltjahre + 11                           '11 Schaltjahre von 1970  - 2013
'
   Tempdw = Tempdw + Schaltjahre                            'one day per leapyear
   Tempdw = Tempdw * 86400                                  '60*60*24   second of the past years
   Unixtime = Unixtime + Tempdw
'
   Tempc= Year Mod 4                                        'actual year is leapear? This work ok unitil 28.2.2100 :)
   If Tempc = 0 Then
      If Month > 2 Then
         Unixtime = Unixtime + 86400
      End If
   End If
'
   I2C_tx = String (Stringlength , 0)
   I2C_tx_b(5) = Unixtime3                                  'first 4 byte are 0  little endian -> big endian
   I2C_tx_b(6) = Unixtime2
   I2C_tx_b(7) = Unixtime1
   I2C_tx_b(8) = Unixtime0
   I2c_length = 8
   I2c_pointer = 1
Return
'
Slave_commandparser:
If Commandpointer > 253 Then                                'Error, do nothing
   Gosub Command_received
Else
'
   Select Case Command_b(1)
      Case 0
'Befehl &H00            eigenes basic announcement lesen
'                       basic announcement is read to I2C or output
'Data "0;m;DK1RI;RTC;V01.0;1;160;5;10"
         Read_register =1
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl  &H01           liest Uhrzeit
'                       read time
'Data "1;aa,read time;t"
         Read_register =0
         All_bytes_read = 8
         RS232_in_buffer  = String(Stringlength_RS232,0)
         Writepointer = 1
         Stuffed = 0
         Gosub Command_received
      Case 2
'Befehl  &H02           liest Zeit
'                       read time
'Data "2;af,read time;7"
         Read_register = 1
         All_bytes_read = 8
         RS232_in_buffer  = String(Stringlength_RS232,0)
         Writepointer = 1
         Stuffed = 0
         print Chr(2);Chr(1);Chr(32);Chr(7);Chr(3);         'register 32 +0  7 bytes
         Gosub Command_received
'
      Case 3
'Befehl  &H03           liest register
'                       read register
'Data "3;aa,read register;b,{x00 to x0E}"
         If Commandpointer = 2 Then
           If Command_b(2) < 15 Then
               Read_byte = Command_b(2) + 1
               Read_register = 2
               All_bytes_read = 8
               RS232_in_buffer  = String(Stringlength_RS232,0)
               Writepointer = 1
               Stuffed = 0
               print Chr(2);Chr(1);Chr(32);Chr(7);Chr(3);         'register 32 +0  7 bytes
               Gosub Command_received
            Else
               Error_no = 4
               Gosub Last_err
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 4
'Befehl  &H04           schreibt register
'                       write register
'Data "4;oa,write register;b,{x00 to x0E}"
         If Commandpointer = 3 Then
            If Command_b(2) < 15 Then
               Tempb = Command_b(2) + 32
               Read_register = 3
               All_bytes_read = 2
               RS232_in_buffer  = String(Stringlength,0)
               Writepointer = 1
               Stuffed = 0
               print Chr(2);Chr(0);Chr(Tempb);Chr(command_b(3));Chr(3);     'register 32 +7  (x20 + x07)
            Else
               Error_no = 4
               Gosub Last_err
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 240
'Befehl &HF0 :   0-13,
'                253,254 255        announcement aller Befehle in I2C Puffer kopieren
'                                   announcement lines are read to I2C  or output
'Data "240;am,ANNOUNCEMENTS;160;10"
         If Commandpointer = 2 Then
            Read_register =1
            Select Case Command_b(2)
               Case 254
                  Announceline = 1
                  A_line = 0
                  Gosub Sub_restore
               Case 255                                        'so more lines will be transmitted
                  A_line = 0
                  Gosub Sub_restore
               Case  Is < No_of_announcelines
                  A_line = Command_b(2)
                  Gosub Sub_restore
               Case Else
                  Error_no = 0
                  Gosub Last_err
            End Select
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 252
'Befehle &HF0                       Letzten Fehler in I2C Puffer kopieren oder ausgeben
'                                   read last error
'Data "252;aa,LAST ERROR;20,last_error"
         Read_register =1
         I2c_tx = String(stringlength , 0)                     'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = 1                                        'so 1st byte <> 0!!
         Temps = Str(command_no)
         I2c_length = Len(temps)
         For Tempb = 1 To I2c_length                           'leave space for length
            I2c_tx_b(tempb + 1) = Temps_b(tempb)
         Next Tempb
         Incr I2c_length                                       'because of 1 byte with length
         Tempb = Len(last_error)
         For Tempc = 1 To Tempb
             Tempd = Tempc + I2c_length                        'write at the end
             I2c_tx_b(tempd) = Last_error_b(tempc)
         Next Tempc
         I2c_length = Tempd                                    'last tempd is length
         Decr Tempd
         I2c_tx_b(1) = Tempd
         Gosub Command_received
'
       Case 253
'Befehl &HFD :                      eigene activ Meldung in I2C Puffer kopieren (&H04) oder ausgeben
'                                   Life signal
'Data "253;aa,MYC INFO;b,BUSY"
         Read_register =1
         I2c_length = 1
         I2c_pointer = 1
         I2c_tx = String(stringlength , 255)
         I2c_tx_b(1) = 4                                       'no info
         Gosub Command_received
'
      Case 254
'Befehl &HFE :        *         eigene Individualisierung schreiben
'                               Der Devicename &HFE00 kann maximal 20 Zeichen haben
'
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,19"
         If Commandpointer >= 2 Then
            Select Case Command_b(2)
               Case 0
                  If Commandpointer = 2 Then
                     Incr Commandpointer
                  Else
                     If Commandpointer = 3 Then
                        L = Command_b(3)
                        If L = 0 Then
                           Gosub Command_received
                        Else
                           If L > 20 Then L = 20
                           L = L + 3
                           Incr Commandpointer
                        End If
                     Else
                        If Commandpointer = L Then
                           Dev_name = String(20 , 0)
                           For Tempb = 4 To L
                              Dev_name_b(tempb -3) = Command_b(tempb)
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
                  If Commandpointer < 4 Then
                     Incr Commandpointer
                  Else                                        'as per announcement: 1 byte string
                     I2C_name = Command_b(4)
                     I2C_name_eeram = I2C_name
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
                     Gosub Last_err
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
'Befehl &HFF :        0 - 3         eigene Individualisierung lesen
'Data "255;aa,as254"
         If Commandpointer = 2 Then
            Read_register =1
            I2c_tx = String(stringlength , 0)                  'delete buffer and restart ponter
            I2c_pointer = 1
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
                  I2c_tx = "{001}"
                  I2C_tx_b(2) = I2C_name
                  I2c_length = 2
               Case 3
                  Tempb = Adress / 2
                  I2c_tx_b(1) = Tempb
                  I2c_length = 1
               Case Else
                  Error_no = 0                                 'ignore anything else
                  Gosub Last_err
            End Select
            Gosub Command_received
         Else
               Incr Commandpointer
         End If
'
      Case Else
         Error_no = 0                                          'ignore anything else
         Gosub Last_err
   End Select
End If
Return
'
'==================================================
'
End
'announce text
'
Announce0:
'Befehl &H00            eigenes basic announcement lesen
'                       basic announcement is read to I2C or output
Data "0;m;DK1RI;RTC;V01.0;1;160;5;10"
'
Announce1:
'Befehl  &H01           liest Uhrzeit
'                       read time
Data "1;aa,read time;t"
'
Announce2:
'Befehl  &H02           liest Zeit
'                       read time
Data "2;af,read time;7"
'
Announce3:
'Befehl  &H03           liest register
'                       read register
Data "3;aa,read register;b,{x00 to x0E}"
'
Announce4:
'Befehl  &H04           schreibt register
'                       write register
Data "4;oa,write register;b,{x00 to x0E}"
'
Announce5:
'Befehl &HF0 :   0-13,
'                253,254 255        announcement aller Befehle in I2C Puffer kopieren
'                                   announcement lines are read to I2C  or output
Data "240;am,ANNOUNCEMENTS;160;10"
'
Announce6:                                                  '
'Befehle &HF0                       Letzten Fehler in I2C Puffer kopieren oder ausgeben
'                                   read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce7:                                                  '
'Befehl &HFD :                      eigene activ Meldung in I2C Puffer kopieren (&H04) oder ausgeben
'                                   Life signal
Data "253;aa,MYC INFO;b,BUSY"
'
Announce8:
'Befehl &HFE :        *         eigene Individualisierung schreiben
'                               Der Devicename &HFE00 kann maximal 20 Zeichen haben
'
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,19"
'
Announce9:
'Befehl &HFF :        0 - 3         eigene Individualisierung lesen
Data "255;aa,as254"
'