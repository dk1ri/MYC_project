'-----------------------------------------------------------------------
'name : infrarot_rx.bas
'Version V02.1, 20151227
'purpose : Programm for receiving infrared RC5 Signals
'This Programm workes as I2C slave, or serial
'Can be used with hardware i2c_rs232_interface Version V01.9 by DK1RI
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
' DTMF_rx V01.0
'-----------------------------------------------------------------------
'Used Hardware:
' RS232
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
'$regfile = "m88pdef.dat"                                    ' for ATmega8P
'$regfile = "m88def.dat"                                     ' (for ATmega8)
$regfile = "m328pdef.dat"                                   'for ATmega328
$crystal = 8000000                                          ' iR Background mode need 8MHz max
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
Const Blinktime = 3000
Const No_of_announcelines = 12                              'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte                                 'first run after reset
Dim L As Byte                                               'Temps and local
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim I As Integer                                           'Blinkcounter  for tests
Dim J As Integer
Dim Temps_b(20) As Byte At Temps Overlay
Dim A As Byte                                               'actual input
Dim Announceline As Byte                                    'notifier for multiple announcelines
Dim A_line As Byte                                          'actual announline
Dim Dev_name As String * 20
Dim Dev_name_eeram As Eram String * 20
Dim Dev_name_b(20) As Byte At Dev_name Overlay
Dim Dev_number As Byte
Dim Dev_number_eeram As Eram Byte
Dim Adress As Byte                                          'I2C adress
Dim Adress_eeram As Eram Byte                              'I2C Buffer
Dim I2c_tx As String * Stringlength
Dim I2c_tx_b(stringlength) As Byte At I2c_tx Overlay
Dim I2c_pointer As Byte
Dim Writepointer As Byte
Dim I2c_length As Byte
Dim Command As String * Stringlength                       'Command Buffer
Dim Command_b(stringlength) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
Dim Twi_status As Byte                                      'HW I2C
Dim Twi_control As Byte
Dim Last_error As String * 30                              'Error Buffer
Dim Last_error_b(30) As Byte At Last_error Overlay
Dim Error_no As Byte
Dim Cmd_watchdog As Word                                    'Watchdog notifier
'
Dim Command_mode As Byte                                    '0: rs232 input, 1: I2C input
Dim no_myc as byte
Dim no_myc_eeram as eram byte
Dim blocked As Byte
Dim Additional_Byte as Bit
Dim Daten as Byte
Dim valid_adress As Byte
Dim I2C_name As String * 1
Dim I2C_name_eeram As Eram String * 1
'
'**************** Config / Init
DDRB.0 = 0
PortB.0 = 1
Config Rc5 = Pinb.0 , Timer = 1 , Mode = background, Wait = 50
Enable Interrupts
'
DDRB.2 = 0                                                  'Input
PortB.2 = 1                                                 'Pullup
Reset__ Alias PinB.2
'
' Life LED:
Config Portd.6 = Output
Config Portd.4 = Output
Config Portd.3 = Output
Led1 Alias Portd.6                                          'life LED
Led2 Alias Portd.4
Led3 Alias Portd.3                                          'on if cmd activ, off, when cmd finished                                        'on if cmd activ, off, when cmd finished
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
   no_myc=no_myc_eeram
   I2C_name= I2C_name_eeram
End If
'
Gosub Init
'
Slave_loop:
Start Watchdog                                             'Loop must be less than 512 ms
'
Gosub Blink_                                                'for tests
'
Gosub Cmd_watch
'
If _rc5_bits.4 = 1 Then
   _rc5_bits.4 = 0
   If Rc5_address = Valid_adress Then
'clear the toggle bit
'the toggle bit toggles on each new received command
'toggle bit is bit 7. Extended RC5 bit is in bit 6
      Daten = Rc5_command And &B01111111
      I2c_tx_b(Writepointer) = Daten
      Incr  Writepointer
      If Writepointer = 253 Then Writepointer = 1
      If Writepointer = I2c_pointer Then INCR  I2c_pointer
      If I2c_pointer = 253 Then I2c_pointer = 1
      If No_myc = 1 Then
         Tempb = Daten / 10
         Printbin Tempb
         Tempc = 10 * Tempb
         Tempb = Daten - Tempc
         Printbin Tempb
      Else
         Printbin &H01
         Printbin Daten
      End If
   End If
End If
'
'RS232 got data for I2C ?
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
   If no_myc = 1 Then
      If A = 20 Then                                        'switch to myc mode again
         no_myc=0
         no_myc_eeram =no_myc
      End If
   Else
      If Command_mode = 1 Then
         Command_mode = 0                                    'restart serial if i2cmode
         Gosub Command_finished
      End If
      If Commandpointer < Stringlength Then                 'If Buffer is full, chars are ignored !!
         Command_b(commandpointer) = A
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1                                 ' start watchdog
            Reset Led3                                      'LED on
         End If
         Gosub Slave_commandparser
      End If
   end if                                                   'As a testdevice, all characters are send to RS232
End If
'
'I2C
Twi_control = Twcr And &H80                                  'twint set?
If Twi_control = &H80 Then                                  'twsr 60 -> start, 80-> daten, A0 -> stop
   Twi_status = Twsr
   Twi_status = Twi_status And &HF8
'slave send:
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
      If blocked = 1 Then
         If I2c_pointer <= I2c_length Then
            Twdr = I2c_tx_b(i2c_pointer)
            Incr I2c_pointer
         Else
            If Announceline < No_of_announcelines Then      'multiple lines to send
               Cmd_watchdog = 0                              'command may take longer
               A_line = Announceline
               Gosub Sub_restore
               Incr Announceline
               Twdr = I2c_tx_b(i2c_pointer)
               Incr I2c_pointer
            Else                                            'all bytes send
               Announceline = 255
               i2c_length = 0
               I2c_pointer = 1
               Writepointer = 1
               blocked = 0
               I2c_tx = String(stringlength , 255)
               TWDR=&H00
               Set Led3
            End If
         End If
      Else
         If Additional_byte = 1 Then
            if I2C_pointer < Writepointer Then
               Tempb = Writepointer - I2C_pointer
            Else
               Tempb = I2C_pointer - Writepointer
            End If
            TWDR = Tempb
            Additional_byte = 0
         Else
            If  I2c_pointer = Writepointer Then
               Twdr = 255                                     'not valid  buffer empty
            Else
               Twdr = I2c_tx_b(i2c_pointer)
               Incr I2c_pointer
               If I2c_pointer > Stringlength Then I2c_pointer = 1
            End If
         End If
      End If
   End If
'I2C receives data and and interpet as commands.
'slave receive:
   If Twi_status = &H80 Or Twi_status = &H88 Then
      If Command_mode = 0 Then                             'restart if rs232mode
         Command_mode = 1                                   'i2c mode
         Command = String(stringlength , 0)
         Commandpointer = 1
      End If
      Tempb = Twdr
      If Commandpointer <= Stringlength Then
         Command_b(commandpointer) = Tempb
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1                                'start watchdog
            Reset Led3                                      'LED on  for tests
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
Dev_number = 1                                              'unsigned , set at first use                                 'obviously not yet set
Dev_number_eeram = Dev_number                               'default values
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 12
Adress_eeram = Adress
no_myc=0
no_myc_eeram = no_myc
I2C_name="1"
I2C_Name_eeram = I2C_name
Return
'
Init:
Led1 = 1
Led2 = 1
Led3 = 1
I = 0
J = 0
Command_no = 1
Announceline = 255                                          'no multiple announcelines
I2c_tx = String(stringlength , 255)                        'will delete buffer and restart ponter
I2c_length = 0
I2c_pointer = 1
Last_error = " No Error"
Error_no = 255                                              'No Error
blocked =0
Additional_byte = 0
Command_mode = 1                                           'I2C Mode
Valid_adress = 1
Gosub Command_received
Gosub Command_finished                                     'master will read 0 without a command
Return
'
Cmd_watch:
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong coomands will be deleted
If Cmd_watchdog > Cmd_watchdog_time Then
   Error_no = 3
   Gosub Last_err
   Gosub Command_received                                  'reset commandinput
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
Blink_:                                                     'for tests
'Led Blinks To Show Life
J = J + 1
If J = Blinktime Then
   J = 0
   Select Case I
      Set Led1
   Case 8
      I = 0
      Reset Led1
   End Select
   Incr I
End If
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
If Error_no <> 3 Then Set Led3
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
   Case 9
      Restore Announce9
   Case 10
      Restore Announce10
   Case 11
      Restore Announce11

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
      For Tempb = I2c_length To 1 Step -1               'shift 1 pos right
         I2c_tx_b(tempb + 1) = I2c_tx_b(tempb)
      Next Tempb
      I2c_tx_b(1) = I2c_length
      Incr I2c_length
      I2c_pointer = 1
      blocked = 1                                     'complete length of string
   End If
End If
Return
'
Reset_i2c_tx:
I2c_length = 0
I2c_pointer = 1
Writepointer = 1
I2c_tx = String(stringlength , 255)                          'will delete buffer , read appear 0 at end ???
Return

Slave_commandparser:
If Commandpointer > 253 Then                                'Error, do nothing
   Gosub Command_received
Else
'
   Select Case Command_b(1)
      Case 0
'Befehl &H00            eigenes basic announcement lesen
'                       basic announcement is read to I2C or output
'Data "0;m;DK1RI;Infrared (RC5) receiver;V02.1;1;160;7;12"
         If Command_mode = 1 Then blocked = 1
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl  &H01           definiert den DTMF-Lesespeicher
'                       keine Funktion im I2C mode, seriell: liefert &HFF
'                       defines the read buffer
'                       no function in I2C mode, serial: &HFF
'Data "1;af,RC5 buffer;b,0 to 63"
         If Command_mode = 0 Then                           'data already sent -> not valid
            Printbin &HFF
         End If
         Gosub Command_received
'
      Case 2
'Befehl  &H02           liest Zahl der gueltigen Werte
'                       read number of valid data bytes
'Data "2;af,valid RC5 buffer length;b,0 to 252"
         If Command_mode = 0 Then
            Printbin 0
            Gosub Reset_i2c_tx
         Else
            Additional_byte = 1
         End If
         Gosub Command_received
'
      Case 3
'Befehl &H03   0-31     RC5 Adresse schreiben
'                       write RC5 adress
'Data "3;oa,rc5adress;b,0 to 31"
         If Commandpointer = 2 Then
            Tempb = Command_b(commandpointer)
            If Tempb < 32 Then
               Valid_adress = Tempb
            Else
               Error_no = 0
               Gosub Last_err
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 4
'Befehl &H04            RC5 Adresse lesen
'                       read RC5 adress
'Data "4;oa,rc5adress,as3"
         I2c_pointer = 1
         I2c_length = 1
         If Command_mode = 0 Then
            Printbin Valid_adress
         Else
            I2c_tx = String(stringlength , 0)
            I2c_tx_b(1) = Valid_adress
         End If
         Gosub Command_received
'

      Case 20
'Befehl  &H14           schaltet MYC / no_MYC mode
'                       switches MYC / no_MYC mode
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
'Befehl  &H15           liest MYC / no_MYC mode
'                       read MYC / no_MYC mode
'Data "21;aa,as20"
         Gosub Reset_i2c_tx
         If Command_mode = 0 Then
            Printbin no_myc
         Else
            I2c_tx_b(1) = no_myc
            Writepointer = 2
         End If
         Gosub Command_received
'
      Case 240
'Befehl &HF0 :   0-13,
'                253,254 255        announcement aller Befehle in I2C Puffer kopieren
'                                   announcement lines are read to I2C  or output
'Data "240;am,ANNOUNCEMENTS;160;12"
         If Commandpointer = 2 Then
            If Command_mode = 1 Then blocked = 1
            Select Case Command_b(2)
               Case 254
                  Announceline = 1
                  If  Command_mode = 0  Then                'RS232 multiple announcelines
                     For A_line = 0 to No_of_announcelines
                        Gosub  Sub_restore
                     Next A_line
                     Announceline = 255
                  Else
                     A_line = 0
                     Gosub Sub_restore
                  End If
               Case 255                                     'so more lines will be transmitted
                  A_line = 0
                  Gosub Sub_restore
               Case  Is < No_of_announcelines
                  A_line = Command_b(2)
                  Gosub Sub_restore
               Case Else
                  Error_no = 0
                  Gosub Last_err
                  blocked = 0
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
         If Command_mode = 1 Then blocked = 1
         I2c_tx = String(stringlength , 0)                  'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = 1                                     'so 1st byte <> 0!!
         Temps = Str(command_no)
         I2c_length = Len(temps)
         For Tempb = 1 To I2c_length                        'leave space for length
            I2c_tx_b(tempb + 1) = Temps_b(tempb)
         Next Tempb
         Incr I2c_length                                    'because of 1 byte with length
         Tempb = Len(last_error)
         For Tempc = 1 To Tempb
             Tempd = Tempc + I2c_length                       'write at the end
             I2c_tx_b(tempd) = Last_error_b(tempc)
         Next Tempc
         I2c_length = Tempd                                    'last tempd is length
         Decr Tempd
         I2c_tx_b(1) = Tempd
         If Command_mode = 0 Then
            Print I2c_tx;
            Gosub Reset_i2c_tx
         Else
            blocked = 1
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
            I2c_tx_b(1) = 4                                     'no info
            Writepointer = 2
         End If
         Gosub Command_received
'
      Case 254
'Befehl &HFE :        *         eigene Individualisierung schreiben
'                               Der Devicename &HFE00 kann maximal 20 Zeichen haben
'                               Anderer Adresstyp &HFE02 kann maximal 3 Zeichen haben.
'                               wird aber ignoriert.
'
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,6"
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
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,6;1,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;1,USB,1"
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
               Case 7
                  I2C_tx="{001}1"
                  I2c_length = 2
               Case Else
                  Error_no = 0                               'ignore anything else
                  Gosub Last_err
                  blocked = 0
            End Select
            If Command_mode = 0 Then
               For Tempb = 1 To I2c_length
                  Print Chr(i2c_tx_b(tempb)) ;
               Next Tempb
               Gosub Reset_i2c_tx
            Else
               blocked = 1
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
Data "0;m;DK1RI;Infrared (RC5) receiver;V02.1;1;160;7;12"
'
Announce1:
'Befehl  &H01           definiert den DTMF-Lesespeicher
'                       keine Funktion im I2C mode, seriell: liefert &HFF
'                        defines the read buffer
'                       no function in I2C mode, serial: &HFF
Data "1;af,RC5 buffer;b,0 to 63"
'
Announce2:
'Befehl  &H02           liest Zahl der gueltigen Werte
'                       read number of valid data bytes
Data "2;af,valid RC5 buffer length;b,0 to 252"
'
Announce3:
'Befehl &H03   0-31     RC5 Adresse schreiben
'                       write RC5 adress
'Data "3;oa,rc5adress;b,0 to 31"
Announce4:
'Befehl &H04            RC5 Adresse lesen
'                       read RC5 adress
'Data "4;oa,rc5adress,as3"
'
Announce5:
'Befehl  &H14           schaltet MYC / no_MYC mode
'                       switches MYC / no_MYC mode
Data "20;oa,no_myc;a"
'
Announce6:
'Befehl  &H15           liest MYC / no_MYC mode
'                       read MYC / no_MYC mode
Data "21;aa,as20"
'
Announce7:
'Befehl &HF0 :   0-13,
'                253,254 255        announcement aller Befehle in I2C Puffer kopieren
'                                   announcement lines are read to I2C  or output
Data "240;am,ANNOUNCEMENTS;160;12"
'
Announce8:                                                  '
'&HFC                                Letzten Fehler in I2C Puffer kopieren oder ausgeben
'                                   read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce9:                                                  '
'Befehl &HFD :                      eigene activ Meldung in I2C Puffer kopieren (&H04) oder ausgeben
'                                   Life signal
Data "253;aa,MYC INFO;b,BUSY"
'
Announce10:
'Befehl &HFE :        *             eiene Individualisierung schreiben
'                                   Der Devicename &HFE00 kann maximal 20 Zeichen haben
'                                   Anderer Adresstyp &HFE02 kann maximal 3 Zeichen haben.
'                                   wird aber ignoriert.
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,6"
'
Announce11:
'Befehl &HFF :        0 - 3         eigene Individualisierung in I2C Puffer kopieren
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,6;1,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;1,USB,1"
'