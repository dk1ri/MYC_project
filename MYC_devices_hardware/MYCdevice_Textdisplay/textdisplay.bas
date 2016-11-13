'-----------------------------------------------------------------------
'name : textdisplay_20.bas
'Version V02.2 20161110
'purpose : Textdisplay
'This Programm workes as I2C slave
'Can be used with hardware textdisplay V01.1 by DK1RI
'The Programm supports the MYC protocol
'uses LCD 4 Bit Mode, 116x2 and 20x2 displays
'This Programm workes as I2C slave or serial protocoll
'Can be used with hardware rs232_i2c_interface Version V03.0 by DK1RI
'The Programm supports the MYC protocol
'Slave max length of string is 252 Bytes.
'Please modify clock frequncy and processor type, if necessary
'
'micro : ATMega88
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
' DTMF sender V03.1
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
'$regfile = "m88pdef.dat"
' for ATmega8P
'$regfile = "m88def.dat"
' (for ATmega8)
$regfile = "m328pdef.dat"
' (for ATmega328)
$crystal = 20000000
' DTMF need 10MHz max
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
Const Stringlength = 50
Const Cmd_watchdog_time = 65000
'Number of main loop before command reset
Const No_of_announcelines = 19
'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte
'first run after reset
Dim L As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim Temps_b(20) As Byte At Temps Overlay
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
'I2C Buffer
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
Dim I2C_active As Byte
Dim I2C_active_eeram As Eram Byte
Dim USB_active As Byte
Dim Usb_active_eeram As Eram Byte
Dim Send_lines As Byte
Dim Number_of_lines As Byte
Dim CMP1 as Byte
Dim Cmp1_eeram As Eram Byte
Dim CMP2 as Byte
Dim Cmp2_eeram As Eram Byte
Dim Command_mode As Byte
'0: I2C input 1: seriell
Dim Row As Byte
Dim Col As Byte
Dim Chars As Byte
Dim Chars2 As Byte
'1/2 Char
Dim Chars_eeram As Eram Byte
'1: 2* 16, 2: 2*20 Display
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
Gosub Cmd_watch
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
      If Usb_active = 0 Then
      'allow &HFE only
         If Command_b(1) = 254 Then
            Gosub Slave_commandparser
         Else
            Gosub  Command_received
         End If
      Else
         Gosub Slave_commandparser
      End If
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
         If I2c_active = 0 Then
         'allow &HFE only
            If Command_b(1) = 254 Then
               Gosub Slave_commandparser
            Else
               Gosub  Command_received
            End If
         Else
            Gosub Slave_commandparser
         End If
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
Dev_number = 1
Dev_number_eeram = Dev_number
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 16
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
USB_active = 1
Usb_active_eeram = Usb_active
Chars = 32
Chars_eeram = Chars
Cmp1 = 20
Cmp1_eeram = Cmp1
Cmp2 = 128
Cmp2_eeram = Cmp2
Return
'
Init:
Command_no = 1
Command_mode = 0
Announceline = 255
Last_error = " No Error"
Error_no = 255
'No Error
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram
I2C_active = I2C_active_eeram
Usb_active = Usb_active_eeram
Chars = Chars_eeram
Chars2 = Chars / 2
Cmp1 = Cmp1_eeram
Pwm1a = Cmp1
Cmp2 = Cmp2_eeram
Pwm1b = 255 - Cmp2
Reset RW
Gosub Config_lcd
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
   'complete length of string
End If
Return
'
Reset_i2c_tx:
I2c_length = 0
I2c_pointer = 1
I2c_tx = String(Stringlength,0)
Return
'
LCD_pos:
If Commandpointer = 2 Then
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
      Gosub Last_err
   End If
   Gosub Command_received
Else
   Incr Commandpointer
End If
Return
'
LCD_write:
If Commandpointer = 2 Then
   If Command_b(2) > Chars Then
      Error_no = 4
      Gosub Command_received
   End If
   If Command_b(2) = 0 Then
      Gosub Command_received
   End If
End If
If Commandpointer > 2 Then
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
Else
   Incr Commandpointer
End If
Return
'
LCD_locate_write:
If Commandpointer >= 3 Then
   If Commandpointer = 3 Then
      If Command_b(2) >= Chars Or Command_b(3) >= Chars Then
         Error_no = 4
         Gosub Last_err
         Gosub Command_received
         Return
      End If
      If Command_b(3) = 0 Then
         Gosub Command_received
         Return
      End If
   End If
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
Else
   Incr Commandpointer
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
COl = 1
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
'Data "0;m;DK1RI;Textdisplay;V02.2;1;160;1;19"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl &H01
'LCD schreiben
'write LCD
'Data "1;oa,write text;32"
         If Chars = 32 Then
            Gosub Lcd_write
         Else
            Error_no = 4
            Gosub Command_received
         End If

'
      Case 2
'Befehl &H02
'an position schreiben
'goto position and write
'Data "2;on,write to position;b;32"
         If Chars = 32 Then
            Gosub LCD_locate_write
         Else
            Error_no = 4
            Gosub Command_received
         End If
'
      Case 3
'Befehl  &H03
'gehe zu Cursorposition
' go to Cursorposition
'Data "3;op,Cursorposition;32;lin;-"
         If Chars = 32 Then
            Gosub LCD_pos
         Else
            Error_no = 4
            Gosub Command_received
         End If
'
      Case 4
'Befehl &H04
'LCD schreiben
'write LCD
'Data "4;oa,write text;40"
         If Chars = 40 Then
            Gosub LCD_write
         Else
            Error_no = 4
            Gosub Command_received
         End If

'
      Case 5
'Befehl &H05
'an position schreiben
'goto position and write
'Data "5;on,write to position;b;40"
         If Chars = 40 Then
            Gosub LCD_locate_write
         Else
            Error_no = 4
            Gosub Command_received
         End If
'
      Case 6
'Befehl  &H06
'gehe zu Cursorposition
' go to Cursorposition
'Data "6;op,Cursorposition;40;lin;-"
         If Chars = 40 Then
            Gosub LCD_pos
         Else
            Error_no = 4
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
         Gosub Reset_i2c_tx
         If Command_mode = 1 Then
            Printbin Cmp1
         Else
            I2c_tx_b(1) = Cmp1
            I2c_length = 1
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
         Gosub Reset_i2c_tx
         If Command_mode = 1 Then
            Printbin Cmp2
         Else
            I2c_tx_b(1) = Cmp2
            I2c_length = 1
         End If
         Gosub Command_received
'
      Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;100;19"
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
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,USB,1;a,DISPLAYSIZE,0,{16x2,20x2}"
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
                       End If
                     End If
                     Chars_eeram = Chars
                     Chars2 = Chars / 2
                     Gosub Config_lcd
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
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,USB,1;a,DISPLAYSIZE,0,{16x2,20x2}"
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
                  I2c_length = 3
               Case 4
                  I2c_tx_b(1) = USB_active
                  I2c_length = 1
               Case 5
                  If Chars = 32 Then
                     Tempb = 0
                  Else
                     Tempb = 1
                  End If
                  I2c_tx_b(1) = Tempb
                  I2c_length = 1
               Case Else
                  Error_no = 4
                  'ignore anything else
                  Gosub Last_err
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
Data "0;m;DK1RI;Textdisplay;V02.2;1;160;1;19"
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
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,8,{0 to 127};a,USB,1;a,DISPLAYSIZE,0,{16x2,20x2}"
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