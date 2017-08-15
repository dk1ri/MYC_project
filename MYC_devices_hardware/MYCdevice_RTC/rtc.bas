'-----------------------------------------------------------------------
'name : rtc.bas
'Version V02.0, 20170815
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
' morse_tx V03.0
'-----------------------------------------------------------------------
'Used Hardware:
' I2C
' MISO MOSI
' Inputs, Outputs: see below
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
Const Lf = 10
Const I2c_buff_length = 252
'that is maximum
Const Stringlength = 252
Const Command_length = 254
'that is maximum
Const A_line_length = 145
'max length of announcelines
Const No_of_announcelines = 9
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
Const Length_spi = 11
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
Dim USB_active As Byte
Dim Usb_active_eeram As Eram Byte
'
Dim L As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Tempdw as Dword
Dim Temps As String * A_line_length
Dim Temps_b(20) As Byte At Temps Overlay
'
Dim I As Integer
'Blinkcounter
Dim J As Integer

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
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'**************** Config / Init
'
Config PinD.7 = Input
PortD.7 = 1
'Pullup
Reset__ Alias PinD.7
'
Config Spi = Hard, Interrupt = Off, Data Order = Msb, Master = Yes, Polarity = Low, Phase = 1, Clockrate = 64, Noss = 1
'20MHz / 64 = 312KHz ; max is 500KHz
Config PortB.2 = Output
'SS pin for SPI
Set portB.2
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
Gosub Start_dcf
'
Slave_loop:
Start Watchdog
'Loop must be less than 2s
'
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
   A = Inkey()
   If Command_mode = 0 Then
      'restart if i2cmode
      Command_mode = 1
      Gosub  Command_received
   End If
   If Commandpointer < Stringlength Then
      Command_b(commandpointer) = A
      If Usb_active = 0 Then
         'allow &HFE only
         If A = 254 Then
            Gosub Slave_commandparser
         Else
            Gosub  Command_received
         End If
      Else
         Gosub Slave_commandparser
      End If
   'Else
      'If Buffer is full, chars are ignored !!
   End If
End If
'
''I2C
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
Adress = 38
'internal: even figures only
Adress_eeram = Adress
Tempb = adress_eeram
I2C_active = 1
I2C_active_eeram = I2C_active
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
Usb_active = Usb_active_eeram
Command_no = 1
Announceline = 255
Errorflag = 0
Error_cmd_no = 0
Send_lines = 0
I = 0
J = 0
Gosub Command_received
Gosub Reset_i2c_tx
Gosub Reset_i2c
Command_mode = 0
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
   '60*60*24  seconds
   Unixtime = Unixtime + Tempdw
   'all seconds since start of year   (no Leapday)
'
   Value = Spi_buffer(7)
   Tempb = Value AND &B11110000
   Shift Tempb , Right , 4
   Tempc = Value AND &B00001111
   Tempb = Tempb * 10
   Tempc = Tempc + Tempb
   Year = Tempc
   'Year sinse 2000
   Tempdw = Year + 30
   'complete years since 1. 1. 1970 (without actual year) (31 - 1)
'
   Schaltjahre = Tempc / 4
   'since 2001: Schaltjahre (leapyear)
   Schaltjahre = Schaltjahre + 8
   '8 leapyears from 1970  - 2000 inclusive
'
   Tempdw = Tempdw * 365
   Tempdw = Tempdw + Schaltjahre
   'one day per leapyear
'
   Tempdw = Tempdw * 86400
   '60*60*24   second of the past years
'
   Unixtime = Unixtime + Tempdw
'
   Tempc = Year Mod 4
   'actual year is leapear? This work ok unitil 28.2.2100 :)
   Tempb = Tempc Mod 4
   If Tempb = 0 Then
      If Month > 2 Then
         Unixtime = Unixtime + 86400
      End If
   End If
'
   I2c_tx_b(2) = 0
   I2c_tx_b(3) = 0
   I2c_tx_b(4) = 0
   I2c_tx_b(5) = 0
   I2C_tx_b(6) = Unixtime3
   'first 4 byte are 0  little endian -> big endian
   I2C_tx_b(7) = Unixtime2
   I2C_tx_b(8) = Unixtime1
   I2C_tx_b(9) = Unixtime0
Return
'
Start_dcf:
   Wait 2
   'Wait for Modul
   Reset PortB.2
   Tempb = 141
   Spiout Tempb, 1
   'Single write register D
   Tempb = 7
   Waitus 70
   Spiout Tempb, 1
   'DCF on, LED on
   Waitus 70
   Set PortB.2
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
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
'Data "0;m;DK1RI;RTC;V02.0;1;100;1;9"
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

   Case 1
'Befehl  &H01
'liest Uhrzeit
'read time
'Data "1;aa,read time;t"
      If I2c_tx_busy = 0 Then
         Reset PortB.2
         Tempc = 206
         Spiout Tempc, 1
         Waitus 70
         Spiin Spi_buffer(Tempb), 1
         Set PortB.2
         Tempc = Spi_buffer(1)
         If Tempc.0 = 0 Then
         'Interrupt Flag not set
            For Tempb = 1 to 9
               I2c_tx_b(Tempb) = 0
            Next Tempb
            Error_no = 9
            Errorflag = 1
         Else
            Waitus 70
            I2c_tx_busy = 1
            Tx_time = 1
            Reset PortB.2
            For Tempb = 1 To 7
               Tempc = Tempb + 191
               'read register 0 to 6
               Spiout Tempc, 1
               Waitus 70
               Spiin Spi_buffer(Tempb), 1
               Waitus 70
            Next Tempb
            Set PortB.2
            Gosub Calculate_unix_time
         End If
         I2c_tx_b(1) = &H01
         I2c_write_pointer = 10
         I2c_tx_busy = 1
         Tx_time = 1
         If Command_mode = 1 Then  Gosub Print_i2c_tx
      Else
         Error_no = 7
         Errorflag = 1
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
            Spi_buffer = String(Length_spi, 0)
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
            Errorflag = 1
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
      If I2c_tx_busy = 0 Then
         If Commandpointer >= 2 Then
            If Command_b(2) < 15 Then
               Spi_buffer(1) = Command_b(2) + 192
               Reset PortB.2
               Spiout Spi_buffer(1), 1
               Waitus 70
               Spi_buffer = String(Length_spi, 0)
               Spiin Spi_buffer(1), 1
               Waitus 70
               Set PortB.2
               I2c_tx_busy = 1
               Tx_time = 1
               I2c_tx_b(1) = &H03
               I2c_tx_b(2) = Command_b(2)
               I2c_tx_b(3) = Spi_buffer(1)
               I2c_write_pointer = 4
               If Command_mode = 1 Then Gosub Print_i2c_tx
            Else
               Error_no = 4
               Errorflag = 1
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      Else
         Error_no = 7
         Errorflag = 1
         Gosub Command_received
      End If
'
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;100;9"
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
'Data "252;aa,LAST ERROR;20,last_error"
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
            Case 9
               Temps = ": DCF Modul not ready: "
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
'Geraet aktiv Antwort
'Life signal
'Data "253;aa,MYC INFO;b,ACTIVE"
      If I2c_tx_busy = 0 Then
         Reset PortB.2
         Tempc = = 206
         Spiout Tempc, 1
         Waitus 70
         Spiin Spi_buffer(1), 1
         Set PortB.2
         Tempc = Spi_buffer(1)
         Tempc = Tempc.0
         Tx_time = 1
         I2c_tx_b(1) = &HFD
         If Tempc = 1 Then
            I2c_tx_b(2) = 4
         Else
            I2c_tx_b(2) = 1
         End If
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Errorflag = 1
      End If
      Gosub Command_received
'
   Case 254
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,19,{0 to 127};a,USB,1"
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
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,19,{0 to 127};a,USB,1"
      If Commandpointer >= 2 Then
         If I2c_tx_busy = 0 Then
            If Command_b(2) < 5 Then
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
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;RTC;V02.0;1;100;1;9"
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
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,19,{0 to 127};a,USB,1"
'
Announce8:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,19,{0 to 127};a,USB,1"