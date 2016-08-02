'-----------------------------------------------------------------------
'name : 'name : dtmf_trx.bas
'Version V02.1, 20160729
'purpose : Programm for receiving DTMF Signals
'This Programm workes as I2C slave, or serial
'Can be used with hardware dtmf_trx Version V01.0 by DK1R
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
'dtmfsender.V03.2
'-----------------------------------------------------------------------
'Used Hardware:
'RS232
'I2C
'SPI
'-----------------------------------------------------------------------
' Inputs Outputs :see below
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
'iR Background mode need 8MHz max
$baud = 19200'use baud rate
$hwstack = 64'ault use 32 for the hardware stack
$swstack = 20
'default use 10 for the SW stack
$framesize = 50
'default use 40 for the frame space
'
'**************** libs
'use byte library for smaller code
'$lib "mcsbyte.lbx"
'
'**************** Variables
Const Stringlength = 252
Const Dtmf_length = 251
'must be Stringlength - 1 or less
Const Cmd_watchdog_time = 65000
'Number of main loop before command reset
Const Blinktime = 6000
Const No_of_announcelines = 10
'announcements start with 0 -> minus 1
Const ControlA_default  = &B00001101
'lower nibble: RegB, IRQ on, DTMF, Tone on
Const ControlB_default  = 0
'-, dual tone, no test mode, burst mode
'
Dim First_set As Eram Byte
'first run after reset
Dim L As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Tempe As Byte
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
Dim USB_active As Byte
Dim Usb_active_eeram As Eram Byte
Dim Send_lines As Byte
Dim Number_of_lines As Byte
'
Dim Command_mode As Byte
'0:I2C input 1:serial
Dim no_myc as byte
Dim no_myc_eeram as eram byte
'
Dim Received_byte As  Byte
Dim Status_byte As  Byte
Dim Transmit_byte As Byte
Dim Dtmf_buffer As String * Dtmf_length
'input Buffer
Dim Dtmf_buffer_b(Dtmf_length) As Byte At Dtmf_buffer Overlay
Dim Dtmf_buffer_out As String * Dtmf_length
Dim Dtmf_buffer_out_b(Dtmf_length) As Byte At Dtmf_buffer_out Overlay
Dim Dtmf_buffer_out_writepointer As Byte
Dim Dtmf_buffer_out_readpointer As Byte
Dim Dtmf_out_empty As Byte
Dim Dtmf_out_reset As Bit
Dim Write_stop As Bit
Dim K As Word
'output buffer
'**************** Config / Init
Q1in Alias PinC.3
Q2in Alias PinC.2
Q3in Alias PinC.1
Q4in Alias PinC.0
Q1out Alias Portc.3
Q2out Alias Portc.2
Q3out Alias PortC.1
Q4out Alias Portc.0
' Jumper:
Config PinD.7 = Input
PortD.7 = 1
Reset__ Alias PinD.7
'
Config PinD.2 = Input
PortD.2 = 1
IRQ Alias PinD.2
Config PinD.3 = Output
PortD.3 = 1
Phy2 Alias PortD.3
Config PinD.4 = Output
PortD.4 = 1
Rw Alias Portd.4
Config PinD.5 = Output
PortD.5 = 1
RS0 Alias PortD.5
'
' Life LED:
Config Pind.6 = Output
Led1 Alias Portd.6
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
Gosub Config_input
'
'Mt8880 need this at start:
Waitms 300
Gosub Read_status
'Initialisition of MT8880
Tempc = &B00000000
Gosub Write_control
Gosub Write_control
Tempc = &B00001000
Gosub Write_control
Tempc = &B00000000
Gosub Write_control
Gosub Read_status
'
Waitms 100
'
'Config MT8880:
Tempc = ControlA_default
Gosub Write_control
Tempc = ControlB_default
Gosub Write_control
'
Slave_loop:
Start Watchdog
'Loop must be less than 2s
Incr K
If K = &HFFFF Then K = 0
'
Gosub Blink_
'
Gosub Cmd_watch
'
'check DTMF
If Irq = 0 Then
'new DTMF signal received or Buffer empty
'This if part handles complete receive
   Gosub Read_status
   If Status_byte.2 = 1 Then
   'DTMF received
      Gosub Read_receive
      If no_myc = 1 Then
      'non MYC Mode
         Gosub Read_receive
         Printbin Received_byte
      Else
      'MYC Mode
         If Writepointer >= Dtmf_length  Then
         'shift everything 1 Byte left
            Tempb = 1
            For Tempb = 1 to Dtmf_length - 1
               Dtmf_buffer_b(Tempb) = Dtmf_buffer_b(Tempb + 1)
            Next Tempb
            Dtmf_buffer_b(Writepointer) = Received_byte
         Else
            Dtmf_buffer_b(Writepointer) = Received_byte
            Incr  Writepointer
         End If
      End If
   End If
End If
'
If Dtmf_out_empty = 0 And Status_byte.1 = 1 Then Dtmf_out_empty = 1
'Buffer empty flag set just before after a DTMF Char sent
'This allows to clear Status_byte later
'
If Dtmf_buffer_out_writepointer <> Dtmf_buffer_out_readpointer Then
'Dtmf_out_buffer not empty
   If Dtmf_out_empty > 0 Or Status_byte.1 = 1 Then
   '>0 means, that there were no data for a while
      Transmit_byte = Dtmf_buffer_out_b(Dtmf_buffer_out_readpointer)
      Gosub Write_transmit
      Incr Dtmf_buffer_out_readpointer
      If Dtmf_buffer_out_readpointer > Dtmf_length Then Dtmf_buffer_out_readpointer = 1
      Dtmf_out_empty = 0
      'Wait fo next IRQ or,if there are no other bytes, wait to count up to Dtmf_out_empty = 3
   End If
'Else
'do nothing now, usually wait for next IRQ
End If
'
Status_byte = 0
' Everything done with status_byte
'
'serial got data?
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
   If Command_mode = 0 Then
      Command_mode = 1
      'restart serial if i2cmode
      Gosub Command_finished
   End If
   If No_myc = 0 Then
   'everything via the commandparser
      If Commandpointer < Stringlength Then
      'If Buffer is full, chars are ignored !!
         Command_b(commandpointer) = A
         If Cmd_watchdog = 0 Then Cmd_watchdog = 1
       'start watchdog
         Gosub Slave_commandparser
      End If
   Else
   'no MYC Mode
      If A = 32 Then
      'switch to myc mode again
         no_myc=0
         no_myc_eeram = no_myc
         Gosub Reset_Dtmf_buffer_out
      Else
     'Use Dtmf_buffer_out as well
         If Write_stop = 0 Then
            Tempd = Dtmf_buffer_out_writepointer
            Incr Tempd
            If Tempd > Dtmf_length Then Tempd = 1
            If Tempd = Dtmf_buffer_out_readpointer Then
               Write_stop = 1
               'stop if buffer is full
               'writepointer keep one poistion behind read
            Else
               Dtmf_buffer_out_b(Dtmf_buffer_out_writepointer) = A
               Incr Dtmf_buffer_out_writepointer
               If Dtmf_buffer_out_writepointer >  Dtmf_length Then Dtmf_buffer_out_writepointer = 1
            End If
         End If
      End If
   End if
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
Adress = 34
'-> 17
Adress_eeram = Adress
no_myc = 0
no_myc_eeram = no_myc
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
no_myc = no_myc_eeram
I2C_active = I2C_active_eeram
Usb_active = Usb_active_eeram
Set Led1
I = 0
J = 0
Command_no = 1
Command_mode = 0
Announceline = 255
Last_error = " No Error"
Error_no = 255
'No Error
Phy2 = 0
'master will read 0 without a command
Gosub Command_received
Gosub Command_finished
Gosub Reset_i2c_tx
Gosub Reset_dtmf_buffer
Gosub Reset_Dtmf_buffer_out
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
Incr J
If J >= Blinktime Then
   J = 0
   Select Case I
      Case 4
         Set Led1
         If Dtmf_out_empty < 3 Then
            Incr Dtmf_out_empty
            Dtmf_out_reset = 0
         End If
         If Dtmf_out_empty = 3 And Dtmf_out_reset = 0 Then
            Gosub Reset_dtmf_buffer_out
            Dtmf_out_reset = 1
         End If
      Case 8
         I = 0
         Reset Led1
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
   'complete length of string
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
Reset_Dtmf_buffer:
Writepointer= 1
Dtmf_buffer = String(Dtmf_length,0)
Return
'
Reset_Dtmf_buffer_out:
Dtmf_buffer_out_writepointer = 1
Dtmf_buffer_out_readpointer = 1
Dtmf_buffer_out = String(Dtmf_length,0)
DTMf_out_empty = 4
Write_stop = 0
Return
'
Config_input:
Config PinC.0 = Input
Q1out = 1
Config PinC.1 = Input
Q2out = 1
Config PinC.2 = Input
Q3out = 1
Config PinC.3 = Input
Q4out = 1
Return
'
Config_output:
Config PinC.0 = Output
Config PinC.1 = Output
Config PinC.2 = Output
Config PiNC.3 = Output
Return
'
Write_transmit:
Select Case Transmit_byte
   Case 49 to 57
   '1 to 9
      Transmit_byte =  Transmit_byte - 48
   Case 48
   '0
      Transmit_byte = 10
   Case 42
   '*
      Transmit_byte = 11
   Case 35
   '#
      Transmit_byte = 12
   Case 65 to 67
   'A to C
      Transmit_byte = Transmit_byte - 52
      '65 -> 13
   Case 97 to 99
   'a to c
      Transmit_byte = Transmit_byte - 84
      '97 -> 13
   Case 68
   'D
      Transmit_byte = 0
   Case 100
   'd
      Transmit_byte = 0
   Case Else
      Transmit_byte = 255
End Select
If Transmit_byte = 255 Then Return
'
Q1out = Transmit_byte.0
Q2out = Transmit_byte.1
Q3out = Transmit_byte.2
Q4out = Transmit_byte.3
Gosub Config_output
Rs0 = 0
Rw = 0
Phy2 = 1
NOP
NOP
NOP
Phy2 = 0
Return
'
Read_receive:
Gosub Config_input
Rs0 = 0
Rw =  1
Phy2 = 1
NOP
NOP
NOP
Received_byte = 0
Received_byte.0 = Q1in
Received_byte.1 = Q2in
Received_byte.2 = Q3in
Received_byte.3 = Q4in
Phy2 = 0
Select Case Received_byte
   Case 1 to 9
   '1 to 9
      Received_byte = Received_byte + 48
   case 10
   '0
      Received_byte = 48
   Case 11
   '*
      Received_byte = 42
   Case 12
   '#
      Received_byte = 35
   Case 13 to 15
   'A to C
      Received_byte = Received_byte + 52
   Case 0
   'D
      Received_byte = 68
End Select
Return
'
Write_control:
'Uses lower niblle of Tempc
Q1out = Tempc.0
Q2out = Tempc.1
Q3out = Tempc.2
Q4out = Tempc.3
Gosub Config_output
Rs0 = 1
Rw = 0
Phy2 = 1
NOP
NOP
NOP
Phy2 = 0
Return
'
Read_status:
Status_byte = 0
Gosub Config_input
Rs0 = 1
Rw =  1
Phy2 = 1
NOP
Status_byte = 0
Status_byte.0 = Q1in
Status_byte.1 = Q2in
Status_byte.2 = Q3in
Status_byte.3 = Q4in
Phy2 = 0
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
'Data "0;m;DK1RI;DTMF_transceiver;V02.1;1;110;5;10"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl  &H01 <s>
'liest den DTMF-Lesespeicher
'read the read DTMF buffer
'Data "1;aa,DTMF buffer;252,{0 to 9,*,#,A to D}"
         Gosub Reset_i2c_tx
         L = Writepointer
         'Writepointer points to next position
         I2c_tx_b(1) = L - 1
         'length
         For Tempb = 1 to Writepointer
           Tempc = Tempb + 1
            'Dtmf_buffer start with 1
            I2c_tx_b(Tempc) = Dtmf_buffer_b(tempb)
         Next Tempb
         I2c_length = Writepointer
         If Command_mode = 1 Then
            For Tempb = 1 to L
            Tempc = I2c_tx_b(tempb)
               Printbin Tempc
            Next Tempb
         End If
         Gosub Reset_dtmf_buffer
         Gosub Command_received
'
      Case 2
'Befehl  &H02
'gibt DTMF Signal aus
'send DTMF tones
'Data "2;oa,send dtmf;252,{0 to 9,*,#,A to D"
        If Commandpointer = 2 Then
            L = Command_b(commandpointer)
            If L = 0 Then
               Gosub command_received
            Else
               Incr Commandpointer
            End If
         Else
            L = Command_b(2) + 2
            'Length of string
            If Commandpointer = L Then
            'string finished
            'adds to Buffer, do not purge old data
               'If Dtmf_buffer_out_writepointer = Dtmf_buffer_out_readpointer Then
               'This means, that the buffer is empty
               'write to actual readposition and increment writepointer
               'otheterwise write to (same) actual writeposition
               For Tempb = 3 To L
                  If Write_stop = 0 Then
                     Tempd = Dtmf_buffer_out_writepointer
                     Incr Tempd
                     If Tempd > Dtmf_length Then Tempd = 1
                     If Tempd = Dtmf_buffer_out_readpointer Then
                        Write_stop = 1
                        'stop if buffer is full
                        'writepointer keep one poistion behind read
                     Else
                        Dtmf_buffer_out_b(Dtmf_buffer_out_writepointer) = Command_b(tempb)
                        Incr Dtmf_buffer_out_writepointer
                        If Dtmf_buffer_out_writepointer >  Dtmf_length Then Dtmf_buffer_out_writepointer = 1
                     End If
                  End If
               Next Tempb
               Write_stop = 0
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         End If
'
      Case 238
'Befehl  &HEE 0|1
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
'Data "238;oa,no_myc;a"
         If Commandpointer = 2 Then
            If Command_b(2) < 2 Then
               no_myc = Command_b(2)
               no_myc_eeram = no_myc
               Gosub Reset_Dtmf_buffer_out
               Gosub Reset_i2c_tx
            Else
               Error_no =0
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 239
'Befehl  &HEF
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
'Data "239;aa,as238"
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
'Data "240;an,ANNOUNCEMENTS;110;10"
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
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,6,{0 to 127};a,USB,1"
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
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,6,{0 to 127};a,USB,1"
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
Data "0;m;DK1RI;DTMF_transceiver;V02.1;1;110;5;10"
'
Announce1:
'Befehl  &H01 <s>
'liest den DTMF-Lesespeicher
'read the read DTMF buffer
Data "1;aa,DTMF buffer;252,{0 to 9,*,#,A to D}"
'
Announce2:
'Befehl  &H02
'gibt DTMF Signal aus
'send DTMF tones
Data "2;oa,send dtmf;252,{0 to 9,*,#,A to D"
'
Announce3:
'Befehl  &HEE 0|1
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
Data "238;oa,no_myc;a"
'
Announce4:
'Befehl  &HEF
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
Data "239;aa,as238"
':
Announce5:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;110;10"
'
Announce6:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce7:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce8:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,6,{0 to 127};a,USB,1"
'
Announce9:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,6,{0 to 127};a,USB,1"
'