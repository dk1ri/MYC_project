'-----------------------------------------------------------------------
'name : FS20_8Kanal_rx.bas
'Version V03.1, 20160523
'purpose : Programm for receiving FS20 Signals
'This Programm workes as I2C slave, or serial
'Can be used with hardware FS20_interface Version V02.0 by DK1RI
'The Programm supports the MYC protocol
'Please modify clock frequncy and processor type, if necessary
'
'
'micro : ATMega88 ore higher
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
' SPI
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
$lib "i2c_twi.lbx"
'
'**************** Variables
Const Stringlength = 254
'that is maximum
Const Cmd_watchdog_time = 65000
'Number of main loop before command reset
Const No_of_announcelines = 11
'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte
'first run after reset
Dim L As Byte
'Temps and local
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim Temps_b(20) As Byte At Temps Overlay
Dim A As Byte
'actual input
'Dim Rs232_pointer As Byte
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
Dim RS232_active As Byte
Dim RS232_active_eeram As Eram Byte
Dim USB_active As Byte
Dim Usb_active_eeram As Eram Byte
Dim Send_lines As Byte
Dim Number_of_lines As Byte
'
Dim Command_mode As Byte
'0: I2C input 1: seriell
Dim no_myc as byte
Dim Scan_mode As Byte
'0: Eventmode 1: Statusmode
Dim Scan_mode_eeram As Eram Byte
Dim Additional_byte As Byte
Dim Switch_status As Byte
Dim Stop_info As BYte
'Eventmode: stop info for output of other answers
'
'**************** Config / Init
Config Portb.0 = Input
Portb.0 = 1
Reset__ Alias Pinb.1
'
Config Portd.2 = Input
Portd.2 = 1
In1 Alias Pind.2
Config Portd.3 = Input
Portd.3 = 1
In2 Alias Pind.3
Config Portd.4 = Input
Portd.4 = 1
In3 Alias Pind.4
Config Portd.5 = Input
Portd.5 = 1
In4 Alias Pind.5
Config Portd.6 = Input
Portd.6 = 1
In5 Alias Pind.6
Config Portd.7 = Input
Portd.7 = 1
In6 Alias Pind.7
Config Portb.0 = Input
Portb.0 = 1
In7 Alias Pinb.0
Config Portb.1 = Input
Portb.1 = 1
In8 Alias Pinb.1
'
Config Portc.3 = Output
Portc.3 = 1
Sch1 Alias Portc.3
Config Portc.2 = Output
Portc.2 = 1
Sch2 Alias Portc.2
Config Portc.1 = Output
Portc.1 = 1
Sch3 Alias Portc.1
Config Portc.0 = Output
Portc.0 = 1
Sch4 Alias Portc.0
Config Portb.5 = Output
Portb.5 = 1
Sch5 Alias Portb.5
Config Portb.4 = Output
Portb.4 = 1
Sch6 Alias Portb.4
Config Portb.3 = Output
Portb.3 = 1
Sch7 Alias Portb.3
Config Portb.2 = Output
Portb.2 = 1
Sch8 Alias Portb.2
'
'Use HW TWI
Config Twi = 400000
'
Config Watchdog = 2048
'
'
'Mega8 has fixed parameter, processor will hang here, if uncommented:
'Config Com1 = 19200 , Databits = 8 Parity = None , Stopbits = 1                                                '
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
   Gosub Reset_
'
Gosub Init
'
Slave_loop:
Start Watchdog
'Loop must be less than 512 ms
'
Gosub Cmd_watch
'
If Scan_mode = 0 And Stop_info = 0 Then Gosub Check_input_status
'Eventmode
'
'RS232 got data?
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
   If Command_mode = 0 Then
      Command_mode = 1
      Stop_info = 0
      'restart serial if i2cmode
      Gosub Command_finished
      Gosub Command_received
   End If
   If Commandpointer < Stringlength Then
   'If Buffer is full, chars are ignored !!
      Command_b(commandpointer) = A
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
            Stop_info = 0
         End If
      End If
   End If
'I2C receives data and and interpet as commands.
'slave receive:
   If Twi_status = &H80 Or Twi_status = &H88 Then
      If Command_mode = 1 Then
      'restart if rs232mode
         Command_mode = 0
         Stop_info = 0
         'i2c mode
         Gosub  Command_received
      End If
      Tempb = Twdr
      If Commandpointer <= Stringlength Then
         Command_b(commandpointer) = Tempb
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1
            'start watchdog
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
Adress = 26
Adress_eeram = Adress
Scan_mode = 0
Scan_mode_eeram = Scan_mode
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
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
RS232_active = RS232_active_eeram
Usb_active = Usb_active_eeram
Scan_mode = Scan_mode_eeram
Gosub Check_inputs
If Scan_mode = 0 Then
   I2c_length = 255
Else
   I2c_length = 0
End If
Switch_status = 0
Stop_info = 0
Gosub Check_inputs
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
   Case 8
      Restore Announce8
   Case 9
      Restore Announce9
   Case 10
      Restore Announce10
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
   Else
      Stop_info = 1
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
Check_inputs:
Tempb = 255
   If In1 <> Switch_status.0 Then
      Switch_status.0 = In1
      Tempb = 0
      Tempc = In1
   End If
   If In2 <> Switch_status.1 Then
      Switch_status.1 = In2
      Tempb = 1
      Tempc = In2
   End If
   If In3 <> Switch_status.2 Then
      Switch_status.2 = In3
      Tempb = 2
      Tempc = In3
   End If
   If In4 <> Switch_status.3 Then
      Switch_status.3 = In4
      Tempb = 3
      Tempc = In4
   End If
   If In5 <> Switch_status.4 Then
      Switch_status.4 = In5
      Tempb = 4
      Tempc = In5
   End If
   If In6 <> Switch_status.5 Then
      Switch_status.5 = In6
      Tempb = 5
      Tempc = In6
   End If
   If In7 <> Switch_status.6 Then
      Switch_status.6 = In7
      Tempb = 6
      Tempc = In7
   End If
   If In8 <> Switch_status.7 Then
      Switch_status.7 = In8
      Tempb = 7
      Tempc = In8
   End If
Return
'
Check_input_status:
Gosub Check_inputs
If Tempb < 255 Then
   If Command_mode = 1 Then
      Printbin 1
      Printbin Tempb
      Printbin Tempc
   Else
      Gosub Reset_i2c_tx
      I2c_length = 3
      I2c_tx_b(1) = 1
      I2c_tx_b(2) = Tempb
      I2c_tx_b(3) = Tempc
   End If
End If
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
'basic announcement is read
'Data "0;m;DK1RI;FS20_receiver;V03.1;1;170;5;11"
         Gosub Reset_i2c_tx
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl  &H01
'liest Status der 8 Schalter  scan_mode : 0
'read status of 8 switches
'Data "1;au,8 shwitches;0;1;2;3;4;5.6,7"
         If Scan_mode = 1 Then
            If Commandpointer >= 2 Then
               If Command_b(2) > 7 Then
                  Error_no = 4
                  Gosub Last_err
               Else
                  Select Case Command_b(2)
                     Case 0
                        Tempb = In1
                     Case 1
                        Tempb = In2
                     Case 2
                        Tempb = In3
                     Case 3
                        Tempb = In4
                     Case 4
                        Tempb = In5
                     Case 5
                        Tempb = In6
                     Case 6
                        Tempb = In7
                     Case 7
                        Tempb = In8
                  End Select
                  If Command_mode = 1 Then
                     Printbin Tempb
                  Else
                     Gosub Reset_i2c_tx
                     I2c_length = 1
                     I2c_tx_b(1) = Tempb
                     Stop_info = 1
                  End If
               End If
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         Else
            Error_no = 0
            Gosub Last_err
            Gosub Command_received
         End If
'
      Case 2
'Befehl  &H02
'liest Status aller 8 Schalter  scan_mode : 0
'read status of all 8 switches
'Data "2;aa,status all shwitches;b"
         If Scan_mode = 1 Then
            Tempb = 0
            If In1 = 1 Then Tempb = Tempb Or &B00000001
            If In2 = 1 Then Tempb = Tempb Or &B00000010
            If In3 = 1 Then Tempb = Tempb Or &B00000100
            If In4 = 1 Then Tempb = Tempb Or &B00001000
            If In5 = 1 Then Tempb = Tempb Or &B00010000
            If In6 = 1 Then Tempb = Tempb Or &B00100000
            If In7 = 1 Then Tempb = Tempb Or &B01000000
            If In8 = 1 Then Tempb = Tempb Or &B10000000
            If Command_mode = 1 Then
               Printbin Tempb
            Else
               Gosub Reset_i2c_tx
               I2c_length = 1
               I2c_tx_b(1) = Tempb
               Stop_info = 1
            End If
         Else
            Error_no = 0
            Gosub Last_err
            Gosub Command_received
         End If
'
      Case 3
'Befehl  &H03
'schreibt scanmode 0 default: eventmode, 1: Statusmode
'write scanmode 0 default: eventmode, 1: Statusmode
'Data "3;oa,scanmode;a"
         If Commandpointer = 2 Then
            If Command_b(2) < 2  Then
               Scan_mode = Command_b(2)
               Scan_mode_eeram = Scan_mode
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
'Befehl  &H04
'liest scanmode
'read scanmode
'Data "4;aa,as3"
         If Command_mode = 1 Then
            Printbin Scan_mode
         Else
            Gosub Reset_i2c_tx
            I2c_length = 1
            I2c_tx_b(1) = Scan_mode
            Stop_info = 1
         End If
         Gosub Command_received
'
      Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;100;11"
         If Commandpointer = 3 Then
            If Command_b(2) < No_of_announcelines And Command_b(3) <= No_of_announcelines Then
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
            Else
               Error_no = 4
               Gosub Last_err
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
         Else
            Stop_info = 1
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
            Stop_info = 1
         End If
         Gosub Command_received
'
      Case 254
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,13,{0 to 127};a,RS232,1;a,USB,1"
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
                        Gosub Last_err
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
                        Gosub Last_err
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
                     RS232_active = Command_b(4)
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
                  Gosub Last_err
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
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,13,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
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
                  Gosub Last_err
            End Select
            If Command_mode = 1 Then
               For Tempb = 1 To I2c_length
                  Tempc = I2c_tx_b(tempb)
                  Printbin Tempc
               Next Tempb
            Else
               Stop_info = 1
            End If
            Gosub Command_received
         Else
               Incr Commandpointer
         End If
      Case Else
         Error_no = 0
         'ignore anything else
         Gosub Last_err
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
'basic announcement is read
Data "0;m;DK1RI;FS20_receiver;V03.1;1;170;5;11"
'
Announce1:
'Befehl  &H01
'liest Status der 8 Schalter  scan_mode : 0
'read status of 8 switches
Data "1;au,8 shwitches;0;1;2;3;4;5.6,7"
'
Announce2:
'Befehl  &H02
'liest Status aller 8 Schalter  scan_mode : 0
'read status of all 8 switches
Data "2;aa,status all shwitches;b"
 '
Announce3:
'Befehl  &H03
'schreibt scanmode 0 default: eventmode, 1: Statusmode
'write scanmode 0 default: eventmode, 1: Statusmode
Data "3;oa,scanmode;a"
'
Announce4:
'Befehl  &H04
'liest scanmode
'read scanmode
Data "4;aa,as3"
'
Announce5:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;am,ANNOUNCEMENTS;100;11"
'
Announce6:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce7:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce8:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,13,{0 to 127};a,RS232,1;a,USB,1"
'
Announce9:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,13,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
Announce10:
Data "R !($1 $2) IF $4 = 0"