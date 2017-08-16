'-----------------------------------------------------------------------
'name : textdisplay.bas
'Version V03.0 20170816
'purpose : Textdisplay
'This Programm workes as I2C slave
'Can be used with hardware textdisplay V01.1 by DK1RI
'uses LCD 4 Bit Mode, 116x2 and 20x2 displays
'This program workes as I2C slave or serial protocol
'
'The Programm supports the MYC protocol
'Slave max length of  I2C string is 252 Bytes.
'Please modify clock frequency and processor type, if necessary
'
'micro : ATMega88 or higher
'
'Fuse Bits :
'External Crystal, high frequency
'clock output enabled
'divide by 8 disabled
'$PROG &HFF,&HC6,&HDF,&HF9' generated. Take care that the chip supports all fuse bytes.
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other right are affected, this programm can be used
'under GPL (Gnu public licence)
'-----------------------------------------------------------------------
'Templates:
'slave_core_V01.0
'-----------------------------------------------------------------------
'
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
'$regfile = "m88pdef.dat"
'for ATMega8P
'$regfile = "m88def.dat"
'for ATMega8
$regfile = "m328pdef.dat"
$crystal = 20000000
$baud = 19200
'use baud rate
$hwstack = 128
'default use 32 for the hardware stack
$swstack = 30
'default use 10 for the SW stack
$framesize = 60
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
Const I2c_buff_length = 252
'that is maximum
Const Stringlength = 252
Const Command_length = 254
'that is maximum
Const A_line_length = 145
'max length of announcelines
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
'
Const No_of_announcelines = 19
'announcements start with 0 -> minus 1
'
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
'************************
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
Dim Cmd_watchdog As Dword
'Watchdog for loop
Dim Tx_time As Dword
'Watchdog for I2c sending
Dim Command_mode As Byte
'0: I2C input 1: seriell
'
Dim CMP1 as Byte
Dim Cmp1_eeram As Eram Byte
Dim CMP2 as Byte
Dim Cmp2_eeram As Eram Byte
Dim Row As Byte
Dim Col As Byte
Dim Chars As Byte
Dim Chars2 As Byte
'1/2 Char
Dim Chars_eeram As Eram Byte
'1: 2* 16, 2: 2*20 Display
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'**************** Config / Init
' Jumper:
Config PinB.3 = Input
PortB.3 = 1
Reset__ Alias PinB.3
Config  PORTC.2 = Output
RW Alias PortC.2
'
Config Sda = Portc.4
'must !!, otherwise error
Config Scl = Portc.5
'
Config Watchdog = 2048
'
Config Lcdpin = Pin, Db4 = PortD.4, Db5 = PortD.5, Db6 = PortD.6, Db7 =PortD.7, E = PortB.0, Rs = PortC.3
'
'Mega8 has fixed parameter, processor will hang here, if uncommented:
'Config Com1 = 19200 , Databits = 8 Parity = None , Stopbits = 1                                                '
'
Config Timer1 = Pwm , Pwm = 8 , Compare_A_Pwm = Clear_Up , Compare_B_Pwm = Clear_Up , Prescale = 1

'****************Interrupts
Enable Interrupts
'Disable Pcint2
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
   Error_cmd_no = Command_no
   Gosub Command_received
End If
'
If Tx_time > 0 Then
   Incr Tx_time
   If Tx_time > Tx_timeout Then
      Gosub Reset_i2c_tx
      Error_no = 6
      Error_cmd_no = Command_no
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
      If Rs232_active = 0 And Usb_active = 0 Then
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
Adress = 16
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
'
Chars = 32
Chars_eeram = Chars
Cmp1 = 20
Cmp1_eeram = Cmp1
Cmp2 = 128
Cmp2_eeram = Cmp2
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
Error_cmd_no = 0
Send_lines = 0
Gosub Command_received
Gosub Reset_i2c_tx
Gosub Reset_i2c
I = 0
J = 0
Command_mode = 0
Announceline = 255
'
'
Chars = Chars_eeram
Chars2 = Chars / 2
Cmp1 = Cmp1_eeram
Pwm1a = Cmp1
Cmp2 = Cmp2_eeram
Pwm1b = 255 - Cmp2
Reset RW
Gosub Config_lcd
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
LCD_pos:
   If Command_b(2) < Chars Then
   'Command_b(2): 0 ... Chars - 1
      If Command_b(2) >= Chars2 Then
         Row = 2
      Else
         Row = 1
      End If
      Tempc= Row - 1
      Tempc = Tempc * Chars2
      Col = Command_b(2) - Tempc
      Incr Col
      Locate Row , Col
   Else
      Error_no = 4
      Error_cmd_no = Command_no
   End If
   Gosub Command_received
Return
'
LCD_write:
If Commandpointer = 2 Then
   Select Case Command_b(2)
      Case 0
         Gosub Command_received
      Case Is > Chars
         Error_no = 4
         Error_cmd_no = Command_no
         Gosub Command_received
      Case Else
         Incr Commandpointer
   End Select
Else
   Tempc = Command_b(2) + 2
   If Commandpointer >= Tempc Then
      For Tempb = 3 To Commandpointer
         LCD Chr(Command_b(Tempb))
         Incr Col
         If Col > Chars2 Then
            If Row = 2 Then
               Row = 1
               Home Upper
            Else
               Row = 2
               Home Lower
            End If
            Col = 1
         End If
      Next Tempb
      Gosub Command_received
   Else
      Incr Commandpointer
   End If
End If
Return
'
LCD_locate_write:
If Commandpointer = 2 Then
   If Command_b(2) >= Chars Then
      Error_no = 4
      Error_cmd_no = Command_no
      Gosub Command_received
      Return
   Else
      Incr Commandpointer
   End If
Else
   If Command_b(3) = 0 Then
      Gosub Command_received
      Return
   Else
      If Command_b(3) >= Chars Then
         Error_no = 4
         Error_cmd_no = Command_no
         Gosub Command_received
         Return
      Else
         Tempb = Command_b(3) + 3
         If Commandpointer >= Tempb Then
            If Command_b(2) >= Chars2 Then
               Row = 2
            Else
               Row = 1
            End If
            Tempc= Row - 1
            Tempc = Tempc * Chars2
            Col = Command_b(2) - Tempc
            Incr Col
            'Command_b(2) is 0 based, Col 1 based
            Locate Row , Col
            For Tempb = 4 To Commandpointer
               LCD Chr(Command_b(Tempb))
               Incr Col
               If Col > Chars2 Then
                  If Row = 2 Then
                     Row = 1
                     Home Upper
                  Else
                     Row = 2
                     Home Lower
                  End If
                  Col = 1
               End If
            Next Tempb
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      End If
   End If
End If
Return
'
Config_lcd:
If Chars = 32 Then
   Config LCD = 16*2
Else
   Config LCD = 20*2
End If
Initlcd
Home upper
CLS
Cursor on blink
Row = 1
Col = 1
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
'Data "0;m;DK1RI;Textdisplay;V03.0;1;160;1;19"
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
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 1
'Befehl &H01
'LCD schreiben
'write LCD
'Data "1;oa,write text;32"
      If Chars = 32 Then
         If Commandpointer > 1 Then
            Gosub Lcd_write
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
'an position schreiben
'goto position and write
'Data "2;on,write to position;b;32"
      If Chars = 32 Then
         If Commandpointer > 1 Then
            Gosub LCD_locate_write
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
'Befehl  &H03
'gehe zu Cursorposition
' go to Cursorposition
'Data "3;op,Cursorposition;32;lin;-"
      If Chars = 32 Then
         If Commandpointer > 1 Then
            Gosub LCD_pos
         Else
            Incr Commandpointer
         End If
      Else
         Error_no = 0
         Error_cmd_no = Command_no
         Gosub Command_received
      End If
'
   Case 4
'Befehl &H04
'LCD schreiben
'write LCD
'Data "4;oa,write text;40"
      If Chars = 40 Then
         If Commandpointer > 1 Then
            Gosub Lcd_write
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
'an position schreiben
'goto position and write
'Data "5;on,write to position;b;40"
      If Chars = 40 Then
         If Commandpointer > 1 Then
            Gosub LCD_locate_write
         Else
            Incr Commandpointer
         End If
      Else
         Error_no = 0
         Error_cmd_no = Command_no
         Gosub Command_received
      End If
'
   Case 6
'Befehl  &H06
'gehe zu Cursorposition
' go to Cursorposition
'Data "6;op,Cursorposition;40;lin;-"
      If Chars = 40 Then
         If Commandpointer > 1 Then
            Gosub LCD_pos
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
'Anzeige löschen
'clear screen
'Data "7;ou,CLS;0,CLS"
      CLS
      Col = 1
      Row = 1
      Gosub Command_received
'
   Case 8
'Befehl &H08
'Kontrast schreiben
'write Contrast
'Data "8;oa,contrast;b"
      If Commandpointer = 2 Then
         Cmp1 = Command_b(2)
         Cmp1_eeram = Cmp1
         Pwm1a = Cmp1
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 9
'Befehl &H09
'Kontrast lesen
'read Contrast
'Data "9;oa,contrast;b"
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &H09
         I2c_tx_b(2) = Cmp1
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 10
'Befehl &H0A
'Helligkeit schreiben
'write brightness
'Data "10;oa,brightness;b"
      If Commandpointer = 2 Then
         Cmp2 = Command_b(2)
         Cmp2_eeram = Cmp2
         Pwm1b = 255 - Cmp2
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 11
'Befehl &H0B
'Helligkeit lesen
'read brightness
'Data "11;oa,brightness;b"
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &H0B
         I2c_tx_b(2) = Cmp2
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;100;19"
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
         Error_cmd_no = Command_no
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
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
      Case 254
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,USB,1;a,DISPLAYSIZE,0,{16x2,20x2}"
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
            Case 5
               If Commandpointer < 3 Then
                  Incr Commandpointer
               Else
                  If Command_b(3) = 0 Then
                     Chars = 32
                  Else
                     If Command_b(3) = 1 Then
                        Chars = 40
                     Else
                        Error_no = 4
                        Error_cmd_no = Command_no
                    End If
                  End If
                  Chars_eeram = Chars
                  Chars2 = Chars / 2
                  Gosub Config_lcd
                  Gosub Command_received
               End If
            Case Else
               Error_no = 0
               Error_cmd_no = Command_no
         End Select
      Else
        Incr Commandpointer
      End If
'
      Case 255
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,USB,1;a,DISPLAYSIZE,0,{16x2,20x2}"
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
                     I2c_tx_b(3) = Usb_active
                     I2c_write_pointer = 4
                  Case 5
                     If Chars = 32 Then
                        Tempb = 0
                     Else
                        Tempb = 1
                     End If
                     I2c_tx_b(3) = Tempb
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
            Error_no = 7
            Error_cmd_no = Command_no
         End If
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
Data "0;m;DK1RI;Textdisplay;V03.0;1;160;1;19"
'
Announce1:
'Befehl &H01
'LCD schreiben
'write LCD
Data "1;oa,write text;32"
'
Announce2:
'Befehl &H02
'an position schreiben
'goto position and write
Data "2;on,write to position;b;32"
'
Announce3:
'Befehl  &H03
'gehe zu Cursorposition
' go to Cursorposition
Data "3;op,Cursorposition;32;lin;-"
'
Announce4:
'Befehl &H04
'LCD schreiben
'write LCD
Data "4;oa,write text;40"
'
Announce5:
'Befehl &H05
'an position schreiben
'goto position and write
Data "5;on,write to position;b;40"
'
Announce6:
'Befehl  &H06
'gehe zu Cursorposition
' go to Cursorposition
Data "6;op,Cursorposition;40;lin;-"
'
Announce7:
'Befehl &H07
'Anzeige löschen
'clear screen
Data "7;ou,CLS;0,CLS"
'
Announce8:
'Befehl &H08
'Kontrast schreiben
'write Contrast
Data "8;oa,contrast;b"
'
Announce9:
'Befehl &H09
'Kontrast lesen
'read Contrast
Data "9;oa,contrast;b"
'
Announce10:
'Befehl &H0A
'Helligkeit schreiben
'write brightness
Data "10;oa,brightness;b"
'
Announce11:
'Befehl &H0B
'Helligkeit lesen
'read brightness
Data "11;oa,brightness;b"
'
Announce12:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;100;19"
'
Announce13:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce14:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce15:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,USB,1;a,DISPLAYSIZE,0,{16x2,20x2}"
 '
Announce16:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,USB,1,a,DISPLAYSIZE,0,{16x2,20x2}"
'
Announce17:
Data "R !($1 $2 $3) IF $255&5 = 1"
'
Announce18:
Data "R !($4 $5 $6) IF $255&5 = 0"