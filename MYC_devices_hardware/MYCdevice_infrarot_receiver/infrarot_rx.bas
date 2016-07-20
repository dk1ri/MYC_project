'-----------------------------------------------------------------------
'name : infrarot_rx.bas
'Version V03.1, 20160719
'purpose : Programm for receiving infrared RC5 Signals
'This Programm workes as I2C slave, or serial
'Can be used with hardware i2c_rs232_interface Version V02.0 by DK1RI
'The Programm supports the MYC protocol
'Please modify clock frequncy and processor type, if necessary
'
'When modifying the number of commands or type of interface, please modify:
' Const No_of_announcelines =
' number of announcements in the 0 and 240 command announcements
' add lines in Sub_restore
' IC2 Adress in reset and announcements
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
' DTMF_tx V03.1
'-----------------------------------------------------------------------
'Used Hardware:
' RS232
' I2C
'-----------------------------------------------------------------------
' Inputs Outputs :see below
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'$regfile = "m88pdef.dat"
'for ATmega8P
'$regfile = "m88def.dat"
$regfile = "m328pdef.dat"
'for ATMega328
$crystal = 8000000
'iR Background mode need 8MHz max
$baud = 19200'use baud rate
$hwstack = 64'ault use 32 for the hardware stack
$swstack = 20
'default use 10 for the SW stack
$framesize = 50
'default use 40 for the frame space
' Simulation!!!!
' $sim
'
'**************** libs
'use byte library for smaller code
'$lib "mcsbyte.lbx"
'
'**************** Variables
Const Stringlength = 252
Const Cmd_watchdog_time = 65000
'Number of main loop before command reset
Const Blinktime = 3000
Const No_of_announcelines = 11
'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte
'first run after reset
Dim L As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim I As Integer
'Blinkcounter  for tests
Dim J As Integer
Dim Temps_b(20) As Byte At Temps Overlay
Dim A As Byte
'actual input
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
Dim Rc5buffer As String * Stringlength
Dim Rc5buffer_b(stringlength) As Byte At Rc5buffer Overlay
Dim Rc5_overflow As Byte
Dim I2c_pointer As Byte
Dim Writepointer As Byte
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
Dim RS232_active As Byte
Dim RS232_active_eeram As Eram Byte
Dim USB_active As Byte
Dim Usb_active_eeram As Eram Byte
Dim Send_lines As Byte
Dim Number_of_lines As Byte
'
Dim Command_mode As Byte
'0:I2C input 1:serial
Dim no_myc as byte
Dim no_myc_eeram as eram byte
Dim Daten as Byte
Dim Valid_adress As Byte
Dim Valid_adress_eeram As Eram Byte
'
'**************** Config / Init
DDRB.0 = 0
PortB.0 = 1
Config Rc5 = Pinb.0 , Timer = 1 , Mode = background, Wait = 50
Enable Interrupts
'
DDRB.2 = 0
'Input
PortB.2 = 1
'Pullup
Reset__ Alias PinB.2
'
' Life LED:
Config Portd.2 = Output
Config Portd.3 = Output
Led3 Alias Portd.3
'on if cmd activ, off, when cmd finished
Led4 Alias Portd.2
'life LED
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
If First_set <> 5 Then Gosub Reset_
'
Gosub Init
'
Slave_loop:
Start Watchdog
'Loop must be less than 2s
'
Gosub Blink_
'
Gosub Cmd_watch
'
If _rc5_bits.4 = 1 Then
   _rc5_bits.4 = 0
   'clear the toggle bit
   'the toggle bit toggles on each new received command
   'toggle bit is bit 7. Extended RC5 bit is in bit 6
   Daten = Rc5_command And &B01111111
   Rc5_address = Rc5_address And &B01111111
   If No_myc = 1 Then
   'Rc5_adress
      Tempb = Rc5_address / 10
      Printbin Tempb
      Tempc = 10 * Tempb
      Tempb = Rc5_address - Tempc
      Printbin Tempb
      'RC5 command
      Tempb = Daten / 10
      Printbin Tempb
      Tempc = 10 * Tempb
      Tempb = Daten - Tempc
      Printbin Tempb
   End If
   If Rc5_address = Valid_adress Then
      Rc5buffer_b(Writepointer) = Daten
      Incr  Writepointer
      If Writepointer > Stringlength Then
         Writepointer = 1
         Rc5_overflow = 1
      End If
   End If
End If
'
'RS232 got data?
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
   If no_myc = 1 Then
      If A = 20 Then
      'switch to myc mode again
         no_myc=0
         no_myc_eeram =no_myc
      End If
   Else
      If Command_mode = 0 Then
         Command_mode = 1
         'restart serial if i2cmode
         Gosub Command_finished
      End If
      If Commandpointer < Stringlength Then
      'If Buffer is full, chars are ignored !!
         Command_b(commandpointer) = A
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1
            'start watchdog
            Reset Led3
         End If
         Gosub Slave_commandparser
      End If
   end if
   'As a testdevice, all characters are send to RS232
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
      If Command_mode = 1 Then
      'restart if rs232mode
         Command_mode = 0
         'i2c mode
         Gosub  Command_received
      End If
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
Dev_number = 1
Dev_number_eeram = Dev_number
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 12
Adress_eeram = Adress
no_myc = 0
no_myc_eeram = no_myc
Valid_adress = 1
Valid_adress_eeram = Valid_adress
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
Return
'
Init:
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram
no_myc = no_myc_eeram
Valid_adress = Valid_adress_eeram
I2C_active = I2C_active_eeram
RS232_active = RS232_active_eeram
Usb_active = Usb_active_eeram
Led3 = 1
Led4  = 1
I = 0
J = 0
Command_no = 1
Command_mode = 0
Announceline = 255
Last_error = " No Error"
Error_no = 255
'No Error
Gosub Command_received
Gosub Command_finished
Gosub Reset_i2c_tx
Gosub Reset_rc5buffer
Command_mode = 0
'I2C Mode
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
Gosub Command_finished
If Error_no <> 3 Then Set Led3
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
Reset_rc5buffer:
Writepointer= 1
Rc5_overflow = 0
Rc5buffer = String(Stringlength,255)
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
'Data "0;m;DK1RI;Infrared (RC5) receiver;V03.1;1;160;7;11"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl  &H01
'kopiert RC5 Daten in den Ausgang
'copies RC5 data to output
'Data "1;aa,RC5 buffer;252,{&H00 to &H3F}"
         Gosub Reset_i2c_tx
         If Rc5_overflow = 0 Then
            L = Writepointer - 1
            I2c_tx_b(1) = L
            'length
            For Tempb = 2 to Writepointer
               Tempc = Tempb - 1
               'Rc5buffer start with 1
               I2c_tx_b(Tempb) = Rc5buffer_b(tempc)
            Next Tempb
            I2c_length = Writepointer
         Else
            L = Stringlength
            Tempc = Writepointer
            For Tempb = 1 to Stringlength
               I2c_tx_b(Tempb) = Rc5buffer_b(Tempc)
               Incr Tempc
               If Tempc > Stringlength Then Tempc = 1
            Next Tempb
            I2c_length = L + 1
         End if
         If Command_mode = 1 Then
            For Tempb = 1 to L + 1
            Tempc = I2c_tx_b(tempb)
               Printbin Tempc
            Next Tempb
         End If
         Gosub Reset_rc5buffer
         Gosub Command_received
'
      Case 2
'Befehl &H02   0-31
'RC5 Adresse schreiben
'write RC5 adress
'Data "2;oa,rc5adress;b,{0 to 31}"
         If Commandpointer = 2 Then
            Tempb = Command_b(commandpointer)
            If Tempb < 32 Then
               Valid_adress = Tempb
               Valid_adress_eeram = Tempb
            Else
               Error_no = 0
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 3
'Befehl &H03
'RC5 Adresse lesen
' read RC5 adress
'Data "3;aa,as3"
         Gosub Reset_i2c_tx
         I2c_length = 1
         If Command_mode = 1 Then
            Printbin Valid_adress
         Else
            I2c_tx = String(stringlength , 0)
            I2c_tx_b(1) = Valid_adress
         End If
         Gosub Command_received
'

      Case 20
'Befehl  &H14
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
'Data "20;oa,no_myc;a"
         If Commandpointer = 2 Then
            If Command_b(2) < 2 Then
               no_myc = Command_b(2)
               no_myc_eeram = no_myc
            Else
               Error_no =0
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 21
'Befehl  &H15
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
'Data "21;aa,as20"
         Gosub Reset_i2c_tx
         If Command_mode = 1 Then
            Printbin no_myc
         Else
            I2c_tx_b(1) = no_myc
            Writepointer = 2
         End If
         Gosub Command_received
'
      Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;160;11"
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
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,6,{0 to 127};a,RS232,1;a,USB,1"
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
               Case 4
                  If Commandpointer < 3 Then
                     Incr Commandpointer
                  Else
                     If Command_b(3) > 1 Then Command_b(3) = 1
                     RS232_active = Command_b(3)
                     RS232_active_eeram = RS232_active
                     Gosub Command_received
                  End If
               Case 5
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
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,6,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
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
                  I2c_tx_b(1) = RS232_active
                  I2c_length = 1
               Case 5
                  I2c_tx_b(1) = 0
                  I2c_length = 1
               Case 6
                  I2c_tx = "8n1"
                  I2c_length = 3
               Case 7
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
Data "0;m;DK1RI;Infrared (RC5) receiver;V03.1;1;160;7;11"
'
Announce1:
'Befehl  &H01
'definiert den DTMF-Lesespeicher
'keine Funktion im I2C mode, seriell: liefert &HFF
'defines the read buffer
'no function in I2C mode, serial: &HFF
Data "1;af,RC5 buffer;b,{&H00 to &H3F"
'
Announce2:
'Befehl &H02   0-31
'RC5 Adresse schreiben
'write RC5 adress
Data "2;oa,rc5adress;b,{0 to 31}"
'
Announce3:
'Befehl &H03
'RC5 Adresse lesen
' read RC5 adress
Data "3;aa,as3"
'
Announce4:
'Befehl  &H14
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
Data "20;oa,no_myc;a"
'
Announce5:
'Befehl  &H15
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
Data "21;aa,as20"
'
Announce6:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;160;11"
'
Announce7:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce8:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce9:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,6,{0 to 127};a,RS232,1;a,USB,1"
'
Announce10:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,6,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'