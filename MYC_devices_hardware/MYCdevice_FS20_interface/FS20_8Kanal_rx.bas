'-----------------------------------------------------------------------
'name : FS20_8Kanal_rx.bas
'Version V02.1, 20151227
'purpose : Programm for receiving FS20 Signals
'This Programm workes as I2C slave, or serial
'Can be used with hardware FS20_interface Version V01.2 by DK1RI
'The Programm supports the MYC protocol
'Please modify clock frequncy and processor type, if necessary
'
'When modifying the number of commands or type of interface, please modify:
' Const No_of_announcelines =
' number of announcements in the 0 and 240 command announcements
' add lines in Sub_restore
' IC2 Adress
'
'micro : ATMega88 or more
'Fuse Bits :
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
$prog &HFF , &HC6 , &HDF , &HF9                             ' generated. Take care that the chip supports all fuse bytes.
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other right are affected, this programm can be used
'under GPL (Gnu public licence)
'-----------------------------------------------------------------------
'Templates:
' I2C_slave_2.0
'-----------------------------------------------------------------------
'Used Hardware:
' RS232
' I2C
'-----------------------------------------------------------------------
' Inputs: Reset: Pin B.0
' Inputs: PD2 - PD7, PB0, PB1
' Outputs:PC0 - PC3, PB2 - PB5
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'$regfile = "m88def.dat"                                    ' for ATmega8P
$regfile = "m328pdef.dat"                                   ' (for ATmega8)
$crystal = 20000000                                         ' DTMF need 10MHz max
$baud = 19200                                               ' use baud rate
$hwstack = 64                                               ' default use 32 for the hardware stack                            ' generated. Take care that the chip supports all fuse bytes.
$swstack = 20                                               ' default use 10 for the SW stack
$framesize = 50                                             ' default use 40 for the frame space
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
Const Stringlength = 252                                    'that is maximum
Const Cmd_watchdog_time = 65000                             'Number of main loop before command reset
Const No_of_announcelines = 11                              'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte                                  'first run after reset
Dim L As Byte                                               'Temps and local
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim Temps_b(20) As Byte At Temps Overlay
Dim A As Byte                                                'actual input
Dim Announceline As Byte                                     'notifier for multiple announcelines
Dim A_line As Byte                                           'actual announline
Dim Dev_name As String * 20
Dim Dev_name_eeram As Eram String * 20
Dim Dev_name_b(20) As Byte At Dev_name Overlay
Dim Dev_number As Byte
Dim Dev_number_eeram As Eram Byte
Dim Adress As Byte                                           'I2C adress
Dim Adress_eeram As Eram Byte                               'I2C Buffer
Dim I2c_tx As String * Stringlength
Dim I2c_tx_b(stringlength) As Byte At I2c_tx Overlay
Dim I2c_pointer As Byte
Dim I2c_length As Byte
Dim Command As String * Stringlength                         'Command Buffer
Dim Command_b(stringlength) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
Dim Twi_status As Byte                                       'HW I2C
Dim Twi_control As Byte
Dim Last_error As String * 30                                'Error Buffer
Dim Last_error_b(30) As Byte At Last_error Overlay
Dim Error_no As Byte
Dim Cmd_watchdog As Word                                     'Watchdog notifier
'
Dim Command_mode As Byte                                     '0: rs232 input, 1: I2C input
Dim Additional_byte As Bit
Dim Scan_mode As Byte
Dim Scan_mode_eeram As Eram Byte
Dim Event_write_pointer As Byte
Dim Event_received As Bit
Dim I2C_name As String * 1
Dim I2C_name_eeram As Eram String * 1
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
Config Sda = Portc.4                                         'must !!, otherwise error
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
   Scan_mode = Scan_mode_eeram
   I2C_name= I2C_name_eeram
End If
'
Gosub Init
'
Slave_loop:
Start Watchdog                                              'Loop must be less than 512 ms
'
Gosub Cmd_watch
'
If Scan_mode = 0 Then Gosub Check_inputs
'
'RS232 got data?
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
   If Command_mode = 1 Then
      Command_mode = 0                                        'restart serial if i2cmode
      Gosub Command_finished
      Gosub Command_received
   End If
   If Commandpointer < Stringlength Then                     'If Buffer is full, chars are ignored !!
      Command_b(commandpointer) = A
      If Cmd_watchdog = 0 Then
         Cmd_watchdog = 1                                     'start watchdog
      End If
      Gosub Slave_commandparser
   End If
End If
'
'I2C
Twi_control = Twcr And &H80                                   'twint set?
If Twi_control = &H80 Then                                   'twsr 60 -> start, 80-> daten, A0 -> stop
   Twi_status = Twsr
   Twi_status = Twi_status And &HF8
'slave send:
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
      If Additional_byte = 0 Then
         If Event_received = 0 Then                          'normal mode answering commands
            If I2c_pointer <= I2c_length Then
               Twdr = I2c_tx_b(i2c_pointer)
               Incr I2c_pointer
            Else
               If Announceline < No_of_announcelines Then    'multiple lines to send
                  Cmd_watchdog = 0                            'command may take longer
                  A_line = Announceline
                  Gosub Sub_restore
                  Incr Announceline
                  Twdr = I2c_tx_b(i2c_pointer)
                  Incr I2c_pointer
               Else                                          'all bytes send
                  Announceline = 255
                  Gosub Reset_i2c_tx
                  Twdr = &HFF
               End If
            End If
         Else                                                'reading buffered events
            If I2c_pointer = Event_write_pointer Then
               TWDR = &HFF
            Else
               Twdr = I2c_tx_b(i2c_pointer)
               Incr I2c_pointer
               If I2c_pointer > Stringlength Then I2c_pointer = 1
            End If
         End If
      Else
         If I2c_pointer <= Event_write_pointer Then
            Tempb = Event_write_pointer - I2c_pointer
         Else
            Tempb = Stringlength - I2c_pointer
            Tempb = Tempb + Event_write_pointer
         End If
         Twdr = Tempb                                         'no change of pointers
         Additional_byte = 0
      End If
   End If
'I2C receives data and and interpet as commands.
'slave receive:
   If Twi_status = &H80 Or Twi_status = &H88 Then
      If Command_mode = 0 Then                               'restart if rs232mode
         Command_mode = 1                                     'i2c mode
         Gosub Reset_i2c_tx
         Gosub Command_received
      End If
      Tempb = Twdr
      If Commandpointer <= Stringlength Then
         Command_b(commandpointer) = Tempb
         If Cmd_watchdog = 0 Then Cmd_watchdog = 1           'start watchdog
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
Dev_number = 1                                                'unsigned , set at first use                                 'obviously not yet set
Dev_number_eeram = Dev_number                                 'default values
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 26
Adress_eeram = Adress
Scan_mode = 0
Scan_mode_eeram = Scan_mode
I2C_name="1"
I2C_Name_eeram = I2C_name
Return
'
Init:
Command_no = 1
Announceline = 255                                            'no multiple announcelines
I2c_tx = String(stringlength , 255)                          'will delete buffer and restart ponter
If Scan_mode = 0 Then
   I2c_length = 255
ELse
   I2c_length = 0
End If
I2c_pointer = 1
Last_error = " No Error"
Error_no = 255
Additional_byte = 0                                           'No Error
Command_mode = 1                                              'I2C Mode
Gosub Command_received
Gosub Command_finished                                       'master will read 0 without a command
Return
'
Cmd_watch:
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong coomands will be deleted
If Cmd_watchdog > Cmd_watchdog_time Then
   Error_no = 3
   Gosub Last_err
   Gosub Command_received                                    'reset commandinput
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
'i2c reset, only after error, at start and multiple announcements
'I2cinit                                                      'may be not neccessary
'Config Twi = 100000                                          '100KHz
Twsr = 0                                                      'status und Prescaler auf 0
Twdr = &HFF                                                   'default
Twar = Adress                                                 'Slaveadress
Twcr = &B01000100
Return
'
Command_received:
Commandpointer = 1
Command = String(stringlength , 0)
Cmd_watchdog = 0
Incr Command_no
Event_write_pointer = 1
Event_received = 0
Return
'
Sub_restore:
Error_no = 255                                                'no error
I2c_tx = String(stringlength , 0)                            'will delete buffer , read appear 0 at end ???
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
   If Command_mode = 0 Then
      Printbin I2c_length
      Print I2c_tx;
      Gosub Reset_i2c_tx
   Else
      For Tempb = I2c_length To 1 Step -1                    'shift 1 pos right
         I2c_tx_b(tempb + 1) = I2c_tx_b(tempb)
      Next Tempb
      I2c_tx_b(1) = I2c_length
      Incr I2c_length
      I2c_pointer = 1
   End If
End If
Return
'
Reset_i2c_tx:
I2c_length = 0
I2c_pointer = 1
Event_Write_pointer = 1
I2c_tx = String(stringlength , 0)                            'will delete buffer ,
Event_received = 0
Return
'
'
Check_input_status:
Tempb = 0
Select Case Command_b(2)
   Case 0
      If In1 = 0 Then Tempb = 1
   Case 1
      If In2 = 0 Then Tempb = 1
   Case 2
      If In3 = 0 Then Tempb = 1
   Case 3
      If In4 = 0 Then Tempb = 1
   Case 4
      If In5 = 0 Then Tempb = 1
   Case 5
      If In6 = 0 Then Tempb = 1
   Case 6
      If In7 = 0 Then Tempb = 1
   Case 7
      If In8 = 0 Then Tempb = 1
End Select
Return
'
Check_inputs:
Tempb = 9
If In1 = 0 Then
   Reset Sch1
   Waitms 110
   Set Sch1
   Tempb = 0
End If
If In2 = 0 Then
   Reset Sch2
   Waitms 110
   Set Sch2
   Tempb = 1
End If
If In3 = 0 Then
   Reset Sch3
   Waitms 110
   Set Sch3
   Tempb = 2
End If
If In4 = 0 Then
   Reset Sch4
   Waitms 110
   Set Sch4
   Tempb = 3
End If
If In5 = 0 Then
   Reset Sch5
   Waitms 110
   Set Sch5
   Tempb = 4
End If
If In6 = 0 Then
   Reset Sch6
   Waitms 110
   Set Sch6
   Tempb = 5
End If
If In7 = 0 Then
   Reset Sch7
   Waitms 110
   Set Sch7
   Tempb = 6
End If
If In8 = 0 Then
   Reset Sch8
   Waitms 110
   Set Sch8
   Tempb = 7
End If
If Tempb < 9 Then
   Event_received = 1
   Gosub Update_writepointer
End If
Return
'
Update_writepointer:
If Command_mode = 0 Then
   Printbin 1
   Printbin Tempb
Else
   I2c_tx_b(Event_write_pointer) = 1
   Gosub Incr_write_pointer
   I2c_tx_b(Event_write_pointer) = Tempb
   Gosub Incr_write_pointer
End If
Return
'
Incr_write_pointer:
Incr Event_write_pointer
If Event_write_pointer > Stringlength Then Event_write_pointer = 1
If Event_write_pointer = I2c_pointer Then                    'Buffer full
   Incr I2c_pointer
   If I2c_pointer > Stringlength Then I2c_pointer = 1        'read pointer to next byte
End If
Return
'
Slave_commandparser:
If Commandpointer > 253 Then                                 'Error, do nothing
   Gosub Command_received
Else
'
   Select Case Command_b(1)
      Case 0
'Befehl &H00            eigenes basic announcement lesen
'                       basic announcement is read to I2C or output
'Data "0;m;DK1RI;FS20_receiver;V02.1;1;170;6;11"
         Gosub Reset_i2c_tx
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl  &H01           definiert 8 fach Taster  scan_mode : 0
'                       defines 8 push button switches
'Data "1;au,8 push button shwitches;0;1;2;3;4;5;6;7;8"
         If Commandpointer = 2 Then
            If Command_b(2) > 7 Then
               Error_no = 4
               Gosub Last_err
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      Case 2
'Befehl  &H02           8 schalter, scan_mode : 1
'                       8 switches
'Data "2;ar,8 switches;0;1;2;3;4;5;6;7"
         If Commandpointer = 2 Then
            If Command_b(2) < 8 Then
               If Scan_mode = 1 Then
                  Gosub Check_input_status
                  If Command_mode = 0 Then
                     Printbin Tempb
                  Else
                     Gosub Reset_i2c_tx
                     I2c_length = 1
                     I2c_tx_b(1) = Tempb
                  End If
               Else
                  Error_no = 0
                  Gosub Last_err
               End If
            Else
               Error_no = 4
               Gosub Last_err
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      Case 3
'Befehl  &H03           liest Zahl der gueltigen Werte for command 1
'                       read number of valid data bytes for command 1
'Data "3;af,valid buffer length;b,1 to 252"
         If Command_mode = 0 Then
            Printbin 0
            Gosub Reset_i2c_tx
         Else
            Additional_byte = 1
         End If
         Commandpointer = 1                                   'No Gosub Command_received ; this would reset I2C_buffer
         Command = String(stringlength , 0)
         Cmd_watchdog = 0
         Incr Command_no
'

      Case 4
'Befehl  &H04           schreibt scanmode 0 default: eventmode, 1: Statusmode
'                       write scanmode 0 default: eventmode, 1: Statusmode
'Data "4;oa,scanmode;a"
         If Commandpointer = 2 Then
            If Command_b(2) < 2 Then
               Scan_mode = Command_b(2)
               Scan_mode_eeram = Scan_mode
               If Scan_mode = 0 Then
                  I2c_length = 255
               ELse
                  I2c_length = 0
               End If
            Else
               Error_no = 0
               Gosub Last_err
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 5
'Befehl  &H05           liest scanmode
'                       read scanmode
'Data "5;aa,as4"
         If Command_mode = 0 Then
            Printbin Scan_mode
         Else
            Gosub Reset_i2c_tx
            I2c_length = 1
            I2c_tx_b(1) = Scan_mode
         End If
         Gosub Command_received
'
      Case 240
'Befehl &HF0 :   0-13,
'                253,254 255        announcement aller Befehle in I2C Puffer kopieren
'                                   announcement lines are read to I2C  or output
'Data "240;am,ANNOUNCEMENTS;170;11"
         If Commandpointer = 2 Then
            Gosub Reset_i2c_tx
            Select Case Command_b(2)
               Case 254
                  Announceline = 1
                  If Command_mode = 0 Then                   'RS232 multiple announcelines
                     For A_line = 0 To No_of_announcelines
                        Gosub Sub_restore
                     Next A_line
                     Announceline = 255
                  Else
                     A_line = 0
                     Gosub Sub_restore
                  End If
               Case 255                                      'so more lines will be transmitted
                  A_line = 0
                  Gosub Sub_restore
               Case Is < No_of_announcelines
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
'Befehl &HFC                        Letzten Fehler in I2C Puffer kopieren oder ausgeben
'                                   read last error
'Data "252;aa,LAST ERROR;20,last_error"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = 1                                     'so 1st byte <> 0!!
         Temps = Str(command_no)
         I2c_length = Len(temps)
         For Tempb = 1 To I2c_length                        'leave space for length
             I2c_tx_b(tempb + 1) = Temps_b(tempb)
         Next Tempb
         Incr I2c_length                                    'because of 1 byte with length
         Tempb = Len(last_error)
         For Tempc = 1 To Tempb
             Tempd = Tempc + I2c_length                      'write at the end
             I2c_tx_b(tempd) = Last_error_b(tempc)
         Next Tempc
         I2c_length = Tempd                                 'last tempd is length
         Decr Tempd
         I2c_tx_b(1) = Tempd
         If Command_mode = 0 Then
            Print I2c_tx;
            Gosub Reset_i2c_tx
         End If
         Gosub Command_received
'
       Case 253
'Befehl &HFD :                      eigene activ Meldung in I2C Puffer kopieren (&H04) oder ausgeben
'                                   Life signal
'Data "253;aa,MYC INFO;b,BUSY"
         Gosub Reset_i2c_tx
         If Command_mode = 0 Then
            Printbin 4
         Else
            Gosub Reset_i2c_tx
            I2c_length = 1
            I2c_tx_b(1) = 4
         End If
         Gosub Command_received
'
      Case 254
'Befehl &HFE :        *         eigene Individualisierung schreiben
'                               Der Devicename &HFE00 kann maximal 20 Zeichen haben
'                               Anderer Adresstyp &HFE02 kann maximal 3 Zeichen haben.
'                               wird aber ignoriert.
'                                write indivdualization
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,13"
         If Commandpointer >= 2 Then
            Gosub Reset_i2c_tx
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
                  Else                                                        'as per announcement: 1 byte string
                     I2C_name = Chr(Command_b(4))
                     i2C_name_eeram=I2C_name
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
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,13;1,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
         If Commandpointer = 2 Then
            I2c_tx = String(stringlength , 0)               'delete buffer and restart ponter
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
                  I2C_tx="{001}"
                  I2C_tx_b(2) = I2C_name
                  I2c_length = 2
               Case 3
                  Tempb = Adress / 2
                  I2c_tx_b(1) = Tempb
                  I2c_length = 1
               Case 4
                  I2C_tx="{001}1"
                  I2c_length = 2
               Case 5
                  I2C_tx_b(1)=0
                  I2c_length = 1
               Case 6
                  I2C_tx="{003}1n8"
                  I2c_length = 4
               Case Else
                  Error_no = 4                               'ignore anything else
                  Gosub Last_err
            End Select
            If Command_mode = 0 Then
               For Tempb = 1 To I2c_length
                  Print Chr(i2c_tx_b(tempb)) ;
               Next Tempb
               Gosub Reset_i2c_tx
          End If
            Gosub Command_received
         Else
               Incr Commandpointer
         End If
'
      Case Else
         Error_no = 0                                        'ignore anything else
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
Data "0;m;DK1RI;FS20_receiver;V02.1;1;170;6;11"
'
Announce1:
'Befehl  &H01           definiert 8 fach Taster Scan_mode : 0
'                       defines 8 push button switches
Data "1;au,8 push button shwitches;0;1;2;3;4;5;6;7;8"
'
Announce2:
'Befehl  &H02           8 schalter scan_mode : 1
'                       8 switches
Data "2;ar,8 switches;0;1;2;3;4;5;6;7"
'
Announce3:
'Befehl  &H03           liest Zahl der gueltigen Werte for command 1
'                       read number of valid data bytes for command 1
Data "3;af,valid buffer length;b,1 to 252"
'
Announce4:
'Befehl  &H04           schreibt scanmode 0 default: eventmode, 1: Statusmode
'                       write scanmode 0 default: eventmode, 1: Statusmode
Data "4;oa,scanmode;a"
'
Announce5:
'Befehl  &H05           liest scanmode
'                       read scanmode
Data "5;aa,as4"
'
Announce6:
'Befehl &HF0 :   0-13,
'                253,254 255        announcement aller Befehle lesen
'                                   read announcement lines
Data "240;am,ANNOUNCEMENTS;170;11"
'
Announce7:                                                  '
'Befehl &HFC                       Letzten Fehler in I2C Puffer kopieren oder ausgeben
'                                   read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce8:                                                  '
'Befehl &HFD :                      eigene activ Meldung in I2C Puffer kopieren (&H04) oder ausgeben
'                                   Life signal
Data "253;aa,MYC INFO;b,BUSY"
'
Announce9:
'Befehl &HFE :        *         eigene Individualisierung schreiben
'                               Der Devicename &HFE00 kann maximal 20 Zeichen haben
'                               Anderer Adresstyp &HFE02 kann maximal 3 Zeichen haben.
'                               wird aber ignoriert.
'                                write indivdualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,13"
'
Announce10:
'Befehl &HFF :        0 - 3         eigene Individualisierung lesen
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,13;1,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'