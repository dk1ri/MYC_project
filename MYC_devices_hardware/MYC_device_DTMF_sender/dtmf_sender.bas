'-----------------------------------------------------------------------
'name : dtmf_sender.bas
'Version V02.1, 20160104
'purpose : Programm for sending MYC protocol as DTMF Signals
'This Programm workes as I2C slave
'Can be used with hardware rs232_i2c_interface Version V01.8 by DK1RI
'The Programm supports the MYC protocol
'Slave max length of RS232 string is 252 Bytes.
'Please modify clock frequncy and processor type, if necessary
'
'micro : ATMega88
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
' I2C_slave_2.0
'-----------------------------------------------------------------------
'Used Hardware:
' RS232
' I2C
' Timer1 by DTMF
'-----------------------------------------------------------------------
' Inputs: Reset: Pin B.0
' Outputs : Test LEDs D.3, D.2
' DTMFout at OCA Timer1 pin
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:
' hangs sometimes at start-> power reset
'-----------------------------------------------------------------------
$regfile = "m88pdef.dat"                                    ' for ATmega8P
'$regfile = "m88def.dat"                                     ' (for ATmega8)
$crystal = 10000000                                         ' DTMF need 10MHz max
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
Const Stringlength = 254                                    'that is maximum
Const Rs232length = 253                                     'must be smaller than Stringlength
Const Cmd_watchdog_time = 65000                             'Number of main loop before command reset
Const Blinktime = 3000
Const No_of_announcelines = 13                              'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte                                  'first run after reset
Dim L As Byte                                               'Temps and local
Dim L1 As Byte
Dim L2 As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim I As Integer                                            'Blinkcounter  for tests
Dim J As Integer
Dim Temps_b(20) As Byte At Temps Overlay
'Dim Rs232_in As String * Stringlength                       'RS232 input
'Dim Rs232_in_b(stringlength) As Byte At Rs232_in Overlay
Dim A As Byte                                               'actual input
'Dim Rs232_pointer As Byte
Dim Announceline As Byte                                    'notifier for multiple announcelines
Dim A_line As Byte                                          'actual announline
Dim Dev_name As String * 20
Dim Dev_name_eeram As Eram String * 20
Dim Dev_name_b(20) As Byte At Dev_name Overlay
Dim Dev_number As Byte
Dim Dev_number_eeram As Eram Byte
Dim Adress As Byte                                          'I2C adress
Dim Adress_eeram As Eram Byte                               'I2C Buffer
Dim I2c_tx As String * Stringlength
Dim I2c_tx_b(stringlength) As Byte At I2c_tx Overlay
Dim I2c_pointer As Byte
Dim I2c_length As Byte
Dim Command As String * Stringlength                        'Command Buffer
Dim Command_b(stringlength) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
Dim Twi_status As Byte                                      'HW I2C
Dim Twi_control As Byte
Dim Last_error As String * 30                               'Error Buffer
Dim Last_error_b(30) As Byte At Last_error Overlay
Dim Error_no As Byte
Dim Cmd_watchdog As Word                                    'Watchdog notifier
'
Dim Dtmf_duration As Byte
Dim Dtmf_duration_eeram As Eram Byte
Dim Dtmf_pause As Byte
Dim Dtmf_pause_eeram As Eram Byte
Dim Command_mode As Byte                                    '0: rs232 input, 1: I2C input
dim no_myc as byte
dim no_myc_eeram as eram byte
Dim Btmp As Byte
Dim I2C_name As Byte
Dim I2C_name_eeram As Eram Byte
'**************** Config / Init
' Jumper:
Config PinB.2 = Input
PortB.2 = 1
Reset__ Alias PinB.2
'Config  PORTB.1 = Output
DTMF Alias PortB.1
'
' Life LED:
Config Portd.2 = Output
Config Portd.3 = Output
Led3 Alias Portd.3                                          'life LED
Led4 Alias Portd.2                                          'on if cmd activ, off, when cmd finished
'
Config Sda = Portc.4                                        'must !!, otherwise error
Config Scl = Portc.5
'
Config Watchdog = 2048
'
'Mega8 has fixed parameter, processor will hang here, if uncommented:
'Config Com1 = 19200 , Databits = 8 Parity = None , Stopbits = 1                                                '
'
'****************Interrupts
Enable Interrupts
'Disable Pcint2
' serialin not buffered!!
' serialout not buffered!!!
'
'**************** Main ***************************************************
'
If First_set <> 5 Then
   Gosub Reset_
Else
   Dev_number = Dev_number_eeram
   Dev_name = Dev_name_eeram
   Adress = Adress_eeram
   Dtmf_duration = Dtmf_duration_eeram
   Dtmf_pause = Dtmf_pause_eeram
   no_myc=no_myc_eeram
   I2C_name= I2C_name_eeram

End If
'
Gosub Init
'
If Reset__ = 0 Then Gosub Reset_
'
Slave_loop:
Start Watchdog                                              'Loop must be less than 512 ms
'
Gosub Blink_                                                'for tests
'
Gosub Cmd_watch
'
'RS232 got data?
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
   If no_myc = 1 Then
      If A = 20 Then                                        'switch to myc mode again
         no_myc=0
         no_myc_eeram =no_myc
      Else
         Select Case A
            Case 48 to 58
               Printbin A
               Tempb = A - 48
               Dtmfout Tempb, dtmf_duration
             Case  42
               Printbin A
               Tempb = 10
               Dtmfout Tempb , dtmf_duration
             Case 35
               Printbin A
               Tempb = 11
               Dtmfout Tempb , dtmf_duration
            Case 65 to 68
               Printbin A
               Tempb = A - 53
               Dtmfout Tempb, dtmf_duration
            Case 97 to 100
               Printbin A
               Tempb = A - 85
               Dtmfout Tempb, dtmf_duration

         End Select
         reset DTMF
     End If
   else
      If Command_mode = 1 Then                                 'restart if i2cmode
         Command_mode = 0
         Gosub  Command_received
      End If
      If Commandpointer < Stringlength Then                    'If Buffer is full, chars are ignored !!
         Command_b(commandpointer) = A
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1                                   ' start watchdog
            Reset Led3                                         'LED on
         End If                                                '
         Gosub Slave_commandparser
      End If
   end if                                                      'As a testdevice, all characters are send to RS232
End If
'
'I2C
Twi_control = Twcr And &H80                                     'twint set?
If Twi_control = &H80 Then                                     'twsr 60 -> start, 80-> daten, A0 -> stop
   Twi_status = Twsr
   Twi_status = Twi_status And &HF8
'slave send:
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
      If I2c_pointer <= I2c_length Then
         Twdr = I2c_tx_b(i2c_pointer)
         Incr I2c_pointer
      Else
         If Announceline <= No_of_announcelines Then            'multiple lines to send
            Cmd_watchdog = 0                                   'command may take longer
            A_line = Announceline
            Gosub Sub_restore
            Incr Announceline
            Twdr = I2c_tx_b(i2c_pointer)
            Incr I2c_pointer
         Else
            Announceline = 255
            TWDR=&H00
            Set Led3
         End If                                                'for tests
      End If
   End If
'I2C receives data and and interpet as commands.
'slave receive:
   If Twi_status = &H80 Or Twi_status = &H88 Then
      If Command_mode = 0 Then                                 'restart if rs232mode
         Command_mode = 1                                      'i2c mode
         Command = String(stringlength , 0)
         Commandpointer = 1
      End If
      Tempb = Twdr
      If Commandpointer <= Stringlength Then
         Command_b(commandpointer) = Tempb
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1                                   'start watchdog
            Reset Led3                                         'LED on  for tests
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
Dev_number = 1                                                 'unsigned , set at first use                                 'obviously not yet set
Dev_number_eeram = Dev_number                                  'default values
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 14
Adress_eeram = Adress
Dtmf_duration = 50
Dtmf_duration_eeram = Dtmf_duration
Dtmf_pause = 50
Dtmf_pause_eeram = Dtmf_pause
no_myc=0
no_myc_eeram = no_myc
I2C_name="1"
I2C_Name_eeram = I2C_name
Return
'
Init:
Portc.3 = 1
Led3 = 1
Led4  = 1
DTMF = 0                                                       'for tests'Set Led4
I = 0
J = 0
Command_no = 1
Announceline = 255                                             'no multiple announcelines
'Rs232_pointer = 1
I2c_tx = String(stringlength , 0)                              'will delete buffer and restart ponter
I2c_length = 0
I2c_pointer = 1
Last_error = " No Error"
Error_no = 255                                                 'No Error
Gosub Command_received
Gosub Command_finished                                         'master will read 0 without a command
Return
'
Cmd_watch:
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong coomands will be deleted
If Cmd_watchdog > Cmd_watchdog_time Then
   Error_no = 3
   Gosub Last_err
   Gosub Command_received                                      'reset commandinput
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
Blink_:                                                          'for tests
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
'i2c reset, only after error, at start and multiple announcements
'I2cinit                                                       'may be not neccessary
'Config Twi = 100000                                           '100KHz
Twsr = 0                                                       'status und Prescaler auf 0
Twdr = &HFF                                                    'default
Twar = Adress                                                  'Slaveadress
Twcr = &B01000100
Return
'
Command_received:
Commandpointer = 1
Command = String(stringlength , 0)
Cmd_watchdog = 0
Incr Command_no
If Error_no <> 3 Then Set Led3
Return
'
Sub_restore:
Error_no = 255                                                 'no error
I2c_tx = String(stringlength , 0)                              'will delete buffer , read appear 0 at end ???
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
   Else
      For Tempb = I2c_length To 1 Step -1                   'shift 1 pos right
         I2c_tx_b(tempb + 1) = I2c_tx_b(tempb)
      Next Tempb
      I2c_tx_b(1) = I2c_length
      Incr I2c_length
      I2c_pointer = 1                                         'complte length of string
   End If
End If
Return
'
Slave_commandparser:
If Commandpointer > 253 Then                                   'Error, do nothing
   Gosub Command_received
Else
'
   Select Case Command_b(1)
      Case 0
'Befehl &H00               basic annoumement wird gelesen
'                          basic announcement is read
'Data "0;m;DK1RI;DTMF_sender;V02.1;1;170;8;13"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl &H01 <s>           sendet string als DTMF
'                          send string as DTMF
'Data "1;oa,send dtmf;252,0 to 9,*,#,A to D]"
        If Commandpointer = 2 Then
            L = Command_b(commandpointer)
            If L = 0 Then
               Gosub Command_finished
               Gosub command_received
            Else
               Incr Commandpointer
            End If
         Else
            L = Command_b(2) + 2                                   'Length
            If Commandpointer = L Then                            'string finished
               Stop Watchdog
               For Tempb = 3 To L
                  Tempd = Command_b(tempb)
                  If Tempd < 16 Then                             'ignore wrong DTMF codes
                     Select Case Tempd
                        Case 0 to 9
                           Tempc = Tempd + 48                     'figures
                           Printbin Tempc
                        case 10
                           Printbin 42
                        Case 11
                           Printbin 35
                        Case 12 to 15
                           Tempc = Tempd + 53                     'A-F
                           Printbin Tempc
                     End Select
                     Enable Pcint2
                     Dtmfout Tempd , Dtmf_duration
'The output state is not defined now, but the following statement do not reset the port:
                     DTMF = 0
'                  Disable Pcint2
                     DTMF = 0
                     If tempb < L Then
                        Waitms dtmf_pause
                     End If
                  End If
               Next Tempb
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         End If
'
      Case 16
'Befehl &H10 0.to 255      schreibt DTMF Länge
'                          write DTMF length
'Data "16;oa,DTMF Duration;b"
         If Commandpointer = 2 Then
            Dtmf_duration = Command_b(2)
            Dtmf_duration_eeram = Dtmf_duration
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 17
'Befehl &H11               liest DTMF Länge
'                          read DTMF length
'Data "17;aa,as16"
         I2c_pointer = 1
         I2c_length = 1
         If Command_mode = 0 Then
            Printbin Dtmf_duration
         Else
            I2c_tx = String(stringlength , 0)
            I2c_tx_b(1) = Dtmf_duration
         End If
         Gosub Command_received
'
      Case 18
'Befehl &H12               schreibt DTMF Pausenlänge
'                          write DTMF pause length
'Data "18;oa,DTMF Pause;b"
         If Commandpointer = 2 Then
            Dtmf_pause = Command_b(2)
            Dtmf_pause_eeram = Dtmf_pause
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 19
'Befehl &H13               liest DTMF Pausenlänge
'                          read DTMF pause length
'Data "19;aa,as18"
         I2c_pointer = 1
         I2c_length = 1
         If Command_mode = 0 Then
            Printbin Dtmf_pause
         Else
            I2c_tx = String(stringlength , 0)
            I2c_tx_b(1) = Dtmf_pause
         End If
         Gosub Command_received
'
      Case 20
'Befehl &H14 0|1           schreibt no_myc
'                          write no_myc
'Data "20;oa,no_myc;a"
         If Commandpointer = 2 Then
            If Command_b(2) < 2 Then
               no_myc = Command_b(2)
               no_myc_eeram = no_myc
            Else
               Error_no =0
               Gosub Last_err
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 21
'Befehl &H15               liest no_myc
'                          read no_myc
'Data "21;aa,as20"
         I2c_pointer = 1
         I2c_length = 1
         If Command_mode = 0 Then
            Printbin no_myc
         Else
            I2c_tx = String(stringlength , 0)
            I2c_tx_b(1) = no_myc
         End If
         Gosub Command_received
'

      Case 240
'Befehl &HF0 0-13,
'            253,254 255   announcement aller Befehle lesen
'                          read announcement lines
'Data "240;am,ANNOUNCEMENTS;170;13"
         If Commandpointer = 2 Then
            Select Case Command_b(2)
               Case 254
                  Announceline = 1
                  If  Command_mode = 0  Then                   'RS232 multiple announcelines
                     For A_line = 0 to No_of_announcelines - 1
                        Gosub  Sub_restore
                     Next A_line
                     Announceline = 255
                  Else
                     A_line = 0
                     Gosub Sub_restore
                  End If
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
'Befehl &HFC               Liest letzten Fehler
'                          read last error
'Data "252;aa,LAST ERROR;20,last_error"
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
            Tempd = Tempc + I2c_length                         'write at the end
            I2c_tx_b(tempd) = Last_error_b(tempc)
         Next Tempc
         I2c_length = Tempd                                    'last tempd is length
         Decr Tempd
         I2c_tx_b(1) = Tempd
         If Command_mode = 0 Then
            Print I2c_tx;
            I2c_length = 0
         End If
         Gosub Command_received
'
       Case 253
'Befehl &HFD               geraet aktiv antwort
'                          Life signal
'Data "253;aa,MYC INFO;b,BUSY"
         I2c_tx = String(stringlength , 0)                     'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = 4                                        'no info
         I2c_length = 1
         If Command_mode = 0 Then
            Printbin 4
            I2c_length = 0
         End If
         Gosub Command_received
'
      Case 254
'Befehl &HFE <n> <n>       Individualisierung schreiben
'                          write indivdualization
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,7"
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
                  Else                                                        'as per announcement: 1 byte string
                     I2C_name = Command_b(4)
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
'Befehl &HFF <n>           Individualisierung lesen
'                          read indivdualization
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,7;1,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;1,USB,1"
         If Commandpointer = 2 Then
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
               Case 7
                  I2C_tx="{001}1"
                  I2c_length = 2
               Case Else
                  Error_no = 4                                'ignore anything else
                  Gosub Last_err
            End Select
            If Command_mode = 0 Then
               For Tempb = 1 To I2c_length
                  Print Chr(i2c_tx_b(tempb)) ;
               Next Tempb
            End If
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
'Befehl &H00               basic annoumement wird gelesen
'                          basic announcement is read
Data "0;m;DK1RI;DTMF_sender;V02.1;1;170;8;13"
'
Announce1:
'Befehl &H01 <s>           sendet string als DTMF
'                          send string as DTMF
Data "1;oa,send dtmf;252,[0 to 9,*,#,A to D]"
'
Announce2:
'Befehl &H10 0.to 255      schreibt DTMF Länge
'                          write DTMF length
Data "16;oa,DTMF Duration;b"
'
Announce3:
'Befehl &H11               liest DTMF Länge
'                          read DTMF length
Data "17;aa,as16"
'
Announce4:
'Befehl &H12               schreibt DTMF Pausenlänge
'                          write DTMF pause length
Data "18;oa,DTMF Pause;b"
'
Announce5:
'Befehl &H13               liest DTMF Pausenlänge
'                          read DTMF pause length
Data "19;aa,DTMF Pause,as18"
'
Announce6:
'Befehl &H14 0|1           schreibt no_myc
'                          write no_myc
Data "20;oa,no_myc;a"
'
Announce7:
'Befehl &H15               liest no_myc
'                          read no_myc
Data "21;aa,as20"
'
Announce8:
'Befehl &HF0 0-13,
'            253,254 255   announcement aller Befehle lesen
'                          read announcement lines
Data "240;am,ANNOUNCEMENTS;170;13"
'
Announce9:                                                  '
'Befehl &HFC               Liest letzten Fehler
'                          read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce10:                                                  '
'Befehl &HFD               geraet aktiv antwort
'                          Life signal
Data "253;aa,MYC INFO;b,&H04,BUSY"
'
Announce11:
'Befehl &HFE <n> <n>       Individualisierung schreiben
'                          write indivdualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,7"
'
Announce12:
'Befehl &HFF <n>           Individualisierung lesen
'                          read indivdualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,7;1,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;1,USB,1"
'