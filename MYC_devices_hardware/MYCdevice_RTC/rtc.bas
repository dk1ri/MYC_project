'-----------------------------------------------------------------------
'name : rtc.bas
'Version V01.2, 20160802
'purpose : Programm as realtime clock using the ELV RTC-DCF module
'The interface communicates with the module via SPI
'This Programm can be controlled via I2C or serial
'Can be used with hardware MYC_rtc Version V01.2 by DK1RI
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
' DTMF_sender V03.1
'-----------------------------------------------------------------------
'Used Hardware:
' I2C
' MISO MOSI
' Inputs: Reset Outputs: see below
'
'-----------------------------------------------------------------------
' For announcements and rules see Data section at the end
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
Const Stringlength = 160
Const Length_spi = 9
Const Cmd_watchdog_time = 65000
'Number of main loop before command reset
Const No_of_announcelines = 9
'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte
'first run after reset
Dim L As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim Tempdw As Dword
Dim J As Word
Dim Temps_b(20) As Byte At Temps Overlay
'
Dim A As Byte
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
Dim Send_lines As Byte
Dim Number_of_lines As Byte
'
Dim Command_mode As Byte
'0: I2C input, 1: serial input
Dim I2C_active As Byte
Dim I2C_active_eeram As Eram Byte
Dim USB_active As Byte
Dim Usb_active_eeram As Eram Byte
'
Dim Year As Dword
Dim Day As Dword
Dim Month As Byte
Dim Unixtime As Dword
Dim Unixtime0 As Byte At Unixtime Overlay
Dim Unixtime1 As Byte At Unixtime + 1 Overlay
Dim Unixtime2 As Byte At Unixtime + 2 Overlay
Dim Unixtime3 As Byte At Unixtime + 3 Overlay
Dim Tage_seit_ja(12) As Word
Tage_seit_JA(1) = 31
'days since start of year at end of month without leap days
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
Dim Spi_buffer(Length_spi) As Byte
Dim Spi_buffer1 As Byte At Spi_buffer Overlay
Dim Spi_bytes as Byte
Dim Dcf_set as Byte
'
'**************** Config / Init
'
Config PinD.7 = Input
PortD.7 = 1
'Pullup
Reset__ Alias PinD.7
'
Config Sda = Portc.4
'must !!, otherwise error
Config Scl = Portc.5
'
Config Spi = Hard, Interrupt = Off, Data Order = Msb, Master = Yes, Polarity = Low, Phase = 1, Clockrate = 64, Noss = 1
'20MHz / 64 = 312KHz ; max is 500KHz
Config PortB.2 = Output
'SS pin for SPI
'
Config Watchdog = 2048
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
If First_set <> 5 Then Gosub Reset_
'
Gosub Init
Spiinit
'
Do
'
If Dcf_set = 0 Then
'It takes a while, before the modul accept commands
   If J = 60000 Then
   'check register D
      Tempb = 192 + 13
      tempc = 0
      Reset PortB.2
      Spiout Tempb,1
      Waitus 70
      Spiin Tempc, 1
      Set PortB.2
      If Tempc <> 5 Then
      'register D not set -> set it
         Waitus 70
         Tempb = 128 + 13
         Reset PortB.2
         Spiout Tempb,1
         Waitus 70
         Tempb = 5
         Spiout Tempb,1
         Set PortB.2
      Else
         'register D now set at start
         Dcf_set = 1
      End if
      J = 0
   Else
      Incr J
   End If
End If
'
Start Watchdog
'Loop must be less than 2s
'
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong coomands will be deleted
If Cmd_watchdog > Cmd_watchdog_time Then
   Error_no = 3
   Gosub Last_err
   Gosub Command_received
   'reset commandinput
Else
   If Cmd_watchdog <> 0 Then Incr Cmd_watchdog
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
      Command_b(Commandpointer) = A
      If Cmd_watchdog = 0 Then
         Cmd_watchdog = 1
         'start watchdog
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
         Gosub Slave_commandparser
      End If
   End If
   Twcr = &B11000100
End If
Stop Watchdog                                               '
Loop
'
'===========================================
'
Reset_:
First_set = 5
Dev_number = 1
'unsigned , set at first use
Dev_number_eeram = Dev_number
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 38
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
USB_active = 1
Usb_active_eeram = Usb_active
Return
'
Init:
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram
I2C_active = I2C_active_eeram
Usb_active = Usb_active_eeram
J = 0
Dcf_set = 0
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
   Case Else
      Error_no = 4
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
End If
Return
'
Reset_i2c_tx:
I2c_length = 0
I2c_pointer = 1
I2c_tx = String(Stringlength,0)
Return
'
Reset_spi:
For Tempb = 0 To Length_spi
   Spi_buffer(Tempb) = 0
Next Tempb
Return
'
Calculate_unix_time:
   Value = Spi_buffer(1)
   Tempb = Value AND &B01110000
   'seconds
   Shift Tempb ,Right , 4
   Tempb = Tempb * 10
   Tempc = Value AND &B00001111
   Tempc = Tempb + Tempc
   Unixtime = Tempc
'
   Value = Spi_buffer(2)
   'minutes
   Tempb = Value AND &B01110000
   Shift Tempb ,Right , 4
   Tempb = Tempb * 10
   Tempc = Value AND &B00001111
   Tempc = Tempc + Tempb
   Tempdw = Tempc
   Tempdw   = Tempdw * 60
   Unixtime = Unixtime + Tempdw
'
   Value = Spi_buffer(3)
   'hours
   Tempb = Value AND &B00110000
   Shift Tempb ,Right , 4
   Tempb = Tempb * 10
   Tempc = Value AND &B00001111
   Tempc = Tempc + Tempb
   Tempdw = Tempc
   Tempdw = Tempdw * 3600
   Unixtime = Unixtime + Tempdw
   'seconds of actual day
'
 'day of week, not used
'
   Value = Spi_buffer(5)
   'day
   Tempb = Value AND &B00110000
   Shift Tempb , Right , 4
   Tempb = Tempb * 10
   Tempc = Value AND &B00001111
   Tempc = Tempc + Tempb
   Decr Tempc
   Day = Tempc
   'without actual day
'
   Value = Spi_buffer(6)
   'month
   Tempb = Value AND &B00010000
   Shift Tempb , Right , 4
   Tempb = Tempb * 10
   Tempc = Value AND &B00001111
   Month = Tempc + Tempb
   Decr Month
   'without actual month
   If Month = 0 Then
      Tempdw = Day
   Else
      Tempdw = Tage_seit_ja(Month)
      Tempdw = Tempdw + Day
      'all days since start of year without actual day
   End If
   Tempdw = Tempdw * 86400
   '60*60*24  seonds
   Unixtime = Unixtime + Tempdw
   'all seconds since start of year
'
   Value = Spi_buffer(7)
   'year: 2 octetts !!!
   Tempb = Value AND &B11110000
   Shift Tempb , Right , 4
   Tempb = Tempb * 10
   Tempc = Value AND &B00001111
   Tempc = Tempc + Tempb
   Year = Tempc  + 30
   'complete years since 1. 1. 1970 (without actual year) (31 -1)
   Tempdw = 365 *  Year
   'alle Tage
'
   Schaltjahre = Tempc / 4
   'since 2001: Schaltjahre (leapyear)
   Schaltjahre = Schaltjahre + 8
   '8 leapyears from 1970  - 2000 inclusive
'
   Tempdw = Tempdw + Schaltjahre
   'one day per leapyear
   Tempdw = Tempdw * 86400
   '60*60*24   second of the past years
   Unixtime = Unixtime + Tempdw
'
   Tempc= Year Mod 4
   'actual year is leapear? This work ok unitil 28.2.2100 :)
   Tempb = Tempc Mod 4
   If Tempb = 0 Then
      If Month > 2 Then
         Unixtime = Unixtime + 86400
      End If
   End If
'
   I2C_tx_b(5) = Unixtime3
   'first 4 byte are 0  little endian -> big endian
   I2C_tx_b(6) = Unixtime2
   I2C_tx_b(7) = Unixtime1
   I2C_tx_b(8) = Unixtime0
   I2c_length = 8
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
'Data "0;m;DK1RI;RTC;V01.1;2;100;4;9"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl  &H01
'liest Uhrzeit
'read time
'Data "1;aa,read time;t"
         Gosub Reset_i2c_tx
         Gosub Reset_spi
         Reset PortB.2
         For Tempb = 1 To 7
            Tempc = Tempb + 192
            Decr Tempc
            'read register 0 to 6
            Spiout Tempc, 1
            Waitus 70
            Spiin Spi_buffer(Tempb), 1
            Waitus 70
         Next Tempb
         Set PortB.2
         Gosub Calculate_unix_time
         If Command_mode = 1 Then
            For Tempb = 1 to 8
               Tempc = I2C_tx_b(Tempb)
               Printbin Tempc
            Next Tempb
         End If
         Gosub Command_received
'
      Case 2
'Befehl  &H02 <0..14><m>
'schreibt register
'write register
'Data "2;om,write register;b;15"
         If Commandpointer >= 3 Then
            If Command_b(2) < 15 Then
               Gosub Reset_spi
               Spi_buffer(1) = Command_b(2) + 128
               Spi_buffer(2) =  Command_b(3)
               Reset PortB.2
               Spiout Spi_buffer(1), 1
               Waitus 70
               Spiout Spi_buffer(2), 1
               Waitus 70
               Set PortB.2
            Else
               Error_no = 4
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 3
'Befehl  &H03 <0..14>
'liest register
'read register
'Data "3;am,read register;b,15"
         If Commandpointer >= 2 Then
            If Command_b(2) < 15 Then
               Gosub Reset_spi
               Spi_buffer(1) = Command_b(2) + 192
               Reset PortB.2
               Spiout Spi_buffer(1), 1
               Waitus 70
               Gosub Reset_spi
               Spiin Spi_buffer(1), 1
               Waitus 70
               Set PortB.2
               Gosub Reset_i2c_tx
               I2c_tx_b(1) = Spi_buffer(1)
               I2c_length = 1
               If Command_mode = 1 Then Printbin Spi_buffer1
            Else
               Error_no = 4
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;100;9"
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
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127};a,USB,1"
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
                        Error_no = 4
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
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127};a,USB,1"
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
'announce text
'
Announce0:
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;RTC;V01.2;1;100;4;9"
'
Announce1:
'Befehl  &H01
'liest Uhrzeit
'read time
Data "1;aa,read time;t"
'
Announce2:
'Befehl  &H02 <0..14><m>
'schreibt register
'write register
Data "2;om,write register;b;15"
'
Announce3:
'Befehl  &H03 <0..14>
'liest register
'read register
Data "3;am,read register;b,15"
'
Announce4:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;100;9"
'
Announce5:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce6:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce7:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127};a,USB,1"
'
Announce8:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127};a,USB,1"