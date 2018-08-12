'-----------------------------------------------------------------------
'name : 'name : dtmf_trx.bas
'Version V03.1, 20180811
'purpose : Programm for receiving DTMF Signals
'This Programm workes as I2C slave, or serial
'Can be used with hardware dtmf_trx Version V01.2 by DK1RI
'
'The Programm supports the MYC protocol
'Slave max length of I2C string is 250 Bytes.
'Please modify clock frequency and processor type, if necessary
'
'When doing modifying, please check / modify:
' Const No_of_announcelines =
' Const Aline_length (also in F0 command)
' number of announcements in the 0 and 240 command announcements
' add lines in Sub_restore
' IC2 Adress in reset and announcements
' check Const Tx_factor
'
'Fuse Bits :
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
'JTAG Disabled (if applicable)
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other right are affected, this programm can be used
'under GPL (Gnu public licence)
'-----------------------------------------------------------------------
'Templates:
'slave_core_V01.5
'-----------------------------------------------------------------------
'
'Used Hardware:
'RS232
'I2C
'-----------------------------------------------------------------------
' Inputs Outputs :see below
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
$regfile = "m328pdef.dat"
$crystal = 20000000
$baud = 19200
'use baud rate
$hwstack = 32
'default use 32 for the hardware stack
$swstack = 10
'default use 10 for the SW stack
$framesize = 40
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
Const I2c_buff_length = 254
'that is maximum
Const Stringlength = I2c_buff_length - 4
'I2c_buff_length - command - parameter
Const Not_valid_cmd = &H80
'a non valid commandtoken
Const Cmd_watchdog_time = 200
'Number of main loop * 256  before command reset
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
Const Tx_timeout = Cmd_watchdog_time * Tx_factor
'timeout, when I2c_Tx_b is cleared and new commands allowed
'
Const No_of_announcelines = 10
'announcements start with 0 -> minus 1
Const ControlA_default  = &B00001101
'lower nibble: RegB, IRQ on, DTMF, Tone on
Const ControlB_default  = 0
'-, dual tone, no test mode, burst mode
Const Dtmf_length = 251
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
Dim Usb_active_eeram As Eram Byte
'
Dim L As Byte
Dim Tempa As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim Temps_b(20) As Byte At Temps Overlay
'
Dim I As Byte
Dim J As Byte

Dim A As Byte
'actual input
Dim Blw As Byte
'
Dim Announceline As Byte
'notifier for multiple announcelines
Dim A_line As Byte
' Announcline for 00 and F0 command
Dim Number_of_lines As Byte
Dim Send_line_gaps As Byte
' Temporaray Marker
' 0: idle; 1: in work; 2: F0 command; 3 : 00 command
Dim I2c_tx As String * I2c_buff_length
Dim I2c_tx_b(I2c_buff_length) As Byte At I2c_tx Overlay
Dim I2c_pointer As Byte
Dim I2c_write_pointer As Byte
Dim I2c_tx_busy As Byte
' 0: new commands ok
' 2. answer in progress, new command wait, until data transfer finished or timeout
Dim Command As String * I2c_buff_length
'Command Buffer
Dim Command_b(I2c_buff_length) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
'
Dim Twi_status As Byte
'
Dim Error_no As Byte
Dim Error_cmd_no As Byte
Dim Cmd_watchdog As Word
'Watchdog for loop
'Watchdog for I2c sending
Dim Tx_time As Word
Dim Command_mode As Byte
'0: I2C input 1: seriell
'
Dim Received_byte As  Byte
Dim Transmit_byte As Byte
Dim Dtmf_buffer As String * Dtmf_length
'input Buffer
Dim Dtmf_buffer_b(Dtmf_length) As Byte At Dtmf_buffer Overlay
Dim Dtmf_buffer_out As String * Dtmf_length
Dim Dtmf_buffer_out_b(Dtmf_length) As Byte At Dtmf_buffer_out Overlay
Dim Dtmf_buffer_out_writepointer As Byte
Dim Dtmf_buffer_out_readpointer As Byte
Dim Dtmf_out_empty As Byte
Dim no_myc as byte
Dim no_myc_eeram as eram byte
Dim Dtmf_in_writepointer As Byte
Dim Dtmf_in_readpointer As Byte
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'output buffer
'**************** Config / Init
Q0in Alias PinC.3
Q1in Alias PinC.2
Q2in Alias PinC.1
Q3in Alias PinC.0
Q0out Alias Portc.3
Q1out Alias Portc.2
Q2out Alias PortC.1
Q3out Alias Portc.0
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
'
Gosub Init
'
'Initialisition of MT8880
Waitms 300
RS0 = 1
Gosub Read_dtmf
Tempc = &B00000000
Gosub Write_dtmf
Gosub Write_dtmf
Tempc = &B00001000
Gosub Write_dtmf
Tempc = &B00000000
Gosub Write_dtmf
Gosub Read_dtmf
'
Waitms 100
'Config MT8880:
Tempc = ControlA_default
Gosub Write_dtmf
Tempc = ControlB_default
Gosub Write_dtmf
'
Slave_loop:
Start Watchdog
'Loop must be less than 2s
'
'Blink and timeoout
Incr J
If J = 255 Then
   J = 0
   Incr I
   Select Case I
      Case 30
         If Tx_time > 0 Then
            Incr Tx_time
            If Tx_time > Tx_timeout Then
               Gosub Reset_i2c_tx
               Error_no = 6
               Error_cmd_no = Command_no
            End If
         End If
      Case 255
         I = 0
         'twint set?
         If TWCR.7 = 0 Then Gosub Reset_i2c
   End Select
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong commands will be deleted
'commandbuffers is reset
   If Cmd_watchdog > 0 Then Incr Cmd_watchdog
      If Cmd_watchdog > Cmd_watchdog_time Then
      Error_no = 5
      Error_cmd_no = Command_no
      Gosub Command_received
   End If
End If
'
'check DTMF chip
If Irq = 0 Then
'new DTMF signal received (input) or Buffer empty (output)
   Rs0 = 1
   'status
   'is cleared automatically after reading
   Gosub Read_dtmf
   If Tempc.2 = 1 Then
   'DTMF received (input)
      Rs0 = 0
      'read data
      Gosub Read_receive
      If no_myc = 1 Then  Printbin Received_byte
      'non MYC Mode
      'store to ringbuffer Dtmf_buffer always
      Dtmf_buffer_b(Dtmf_in_writepointer) = Received_byte
      Incr  Dtmf_in_writepointer
      If Dtmf_in_writepointer >= Dtmf_length  Then Dtmf_in_writepointer  = 1
      'Old data are overwritten
      If Dtmf_in_writepointer = Dtmf_in_readpointer Then Incr Dtmf_in_readpointer
      If Dtmf_in_readpointer >= Dtmf_length Then Dtmf_in_readpointer = 1
   End If
'
   If Tempc.1 = 1 Then Dtmf_out_empty = 1
   'Buffer empty flag set(output)
   'must be stored, because data are cled after read
'
End If
'
'some Dtmf to send?
If Dtmf_out_empty = 1 Then
   'MT8088 ready to send
   If Dtmf_buffer_out_writepointer <> Dtmf_buffer_out_readpointer Then
      'Dtmf_out_buffer not empty
      Transmit_byte = Dtmf_buffer_out_b(Dtmf_buffer_out_readpointer)
      Gosub Write_transmit
      Incr Dtmf_buffer_out_readpointer
      If Dtmf_buffer_out_readpointer > Dtmf_length Then Dtmf_buffer_out_readpointer = 1
      Dtmf_out_empty = 0
      'Wait for next IRQ
   End If
End If
'
'RS232 got data?
A = Ischarwaiting()
If A = 1 Then
   A = Inkey()
   If no_myc = 1 Then
      If A = 32 Then
      'switch to myc mode again
         no_myc=0
         no_myc_eeram = no_myc
         Dtmf_buffer_out_writepointer = 1
         Dtmf_buffer_out_readpointer = 1
      Else
         Dtmf_buffer_out_b(Dtmf_buffer_out_writepointer) = A
         'This may overwrite old data (may happen, if data input is faster than DTMF out)
         'write to ringbuffer Dtmd_buffer_out
         Incr Dtmf_buffer_out_writepointer
         If Dtmf_buffer_out_writepointer > Dtmf_length Then Dtmf_buffer_out_writepointer = 1
         If Dtmf_buffer_out_writepointer = Dtmf_buffer_out_readpointer Then
            Incr Dtmf_buffer_out_readpointer
            'Dtmf_buffer_out_readpointer to next position
            If Dtmf_buffer_out_readpointer = Dtmf_length Then Dtmf_buffer_out_readpointer = 1
         End If
      End If
   Else
     If Command_mode = 0 Then
        'restart if i2cmode
        Command_mode = 1
        Gosub  Command_received
     End If
     If I2c_tx_busy = 0 Then
        Command_b(Commandpointer) = A
        If RS232_active = 1 Or Usb_active = 1 Then
           Gosub Slave_commandparser
        Else
           'allow &HFE only
           If Command_b(1) <> 254 Then
              Gosub  Command_received
           Else
              Gosub Slave_commandparser
           End If
        End If
     Else
        Error_no = 7
        Error_cmd_no = Command_no
     End If
   End If
End If
'
'I2C
'This part should be executed as fast as possible to continue I2C:
'twint set?
If TWCR.7 = 1 Then
   'twsr 60 -> start, 80-> data, A0 -> stop
      Twi_status = TWSR And &HF8
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
      'slave send:
      'a slave send command must always be completed (or until timeout)
      'incoming commands are ignored as long as i2c_tx is not empty
      'for multi line F0 command I2c_tx may be loaded a few times if necessary.
      'multiple announcelines are loaded by line
      If I2c_write_pointer = 1 Or I2c_active = 0 Then
         'nothing to send
         Twdr = Not_valid_cmd
      Else
         If I2c_pointer < I2c_write_pointer Then
            'continue sending
            TWDR = I2c_tx_b(I2c_pointer)
            Incr I2c_pointer
            If I2c_pointer >= I2c_write_pointer Then
               Gosub Reset_i2c_tx
               If Number_of_lines > 0 Then Gosub Sub_restore
            End If
         End If
      End If
   Else
      If Twi_status = &H80 Or Twi_status = &H88 Then
         'I2C receives data and and interpret as commands.
         If I2c_tx_busy = 0 Then
            If Command_mode = 1 Then
            'restart if rs232mode
               Command_mode = 0
               'i2c mode
               Gosub  Command_received
            End If
            Command_b(Commandpointer) = TWDR
            If I2c_active = 0 And Command_b(1) <> 254 Then
               'allow &HFE only
               Gosub  Command_received
            Else
               Gosub Slave_commandparser
            End If
         Else
            Error_no = 7
            Error_cmd_no = Command_no
         End If
      End If
   End If
   Twcr = &B11000100
End If
'
Stop Watchdog                                               '
Goto Slave_loop
'
'===========================================
'
Reset_:
'This wait is necessary, because some programmers provide the chip
'with power for a short time after programming.
'This may start the reset_ sub, but stop before ending.
Wait 1
Dev_number = 1
Dev_number_eeram = Dev_number
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
'
Adress = 34
'-> 17
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
'
'This should be the last
First_set = 5
'set at first use
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
Error_cmd_no = 0
Send_line_gaps = 0
Gosub Command_received
Gosub Reset_i2c_tx
Gosub Reset_i2c
I = 0
J = 0
Command_mode = 0
Announceline = 255
I2c_tx_busy = 0
'
Phy2 = 0
no_myc = no_myc_eeram
Dtmf_in_readpointer = 1
Dtmf_in_writepointer = 1
Dtmf_buffer_out_readpointer = 1
Dtmf_buffer_out_writepointer = 1
Dtmf_out_empty = 1
'empty at start
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
I2c_tx_busy = 0
Tx_time = 0
Return
'
Command_received:
Commandpointer = 1
Incr Command_no
If Command_no = 255 Then Command_no = 1
If Command_no = Error_cmd_no Then
   Error_cmd_no = 0
   Error_no = 255
End If
Cmd_watchdog = 0
Return
'
Sub_restore:
' read one line
'Byte beyond restored data must be 0:
Tempc = Len(I2c_tx)
For Tempb = 1 To I2c_buff_length
   I2c_tx_b(Tempb) = 0
Next Tempb
'
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
         'will not happen
End Select
Read I2c_tx
Tempc = Len(I2c_tx)
For Tempb = Tempc To 1 Step - 1
   Tempa = Tempb + Send_line_gaps
   I2c_tx_b(Tempa) = I2c_tx_b(Tempb)
Next Tempb
Select Case Send_line_gaps
   Case 1
      'additional announcement lines
      I2c_tx_b(1) = Tempc
      I2c_write_pointer = Tempc + 2
      Send_line_gaps = 1
      Incr A_line
      I2c_write_pointer = Tempc + 2
      If A_line >= No_of_announcelines Then A_line = 0
   Case 2
      'start basic announcement
      I2c_tx_b(1) = &H00
      I2c_tx_b(2) = Tempc
      I2c_write_pointer = Tempc + 3
   Case 4
      'start of announceline(s), send 3 byte first
      I2c_tx_b(1) = &HF0
      I2c_tx_b(2) = A_line
      I2c_tx_b(3) = Number_of_lines
      I2c_tx_b(4) = Tempc
      I2c_write_pointer = Tempc + 5
      Send_line_gaps = 1
      Incr A_line
      If A_line >= No_of_announcelines Then A_line = 0
End Select
Decr Number_of_lines
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
Config_input:
Config PinC.0 = Input
Config PinC.1 = Input
Config PinC.2 = Input
Config PinC.3 = Input
Q0out = 1
Q1out = 1
Q2out = 1
Q3out = 1
Return
'
Write_transmit:
Select Case Transmit_byte
   Case 49 to 57
   '1 to 9
      Tempc =  Transmit_byte - 48
   Case 48
   '0
      Tempc = 10
   Case 42
   '*
      Tempc = 11
   Case 35
   '#
      Tempc = 12
   Case 65 to 67
   'A to C
      Tempc = Transmit_byte - 52
      '65 -> 13
   Case 97 to 99
   'a to c
      Tempc = Transmit_byte - 84
      '97 -> 13
   Case 68
   'D
      Tempc = 0
   Case 100
   'd
      Tempc = 0
   Case Else
      Tempc = 255
End Select
If Tempc = 255 Then Return
'
Rs0 = 0
Gosub Write_dtmf
Return
'
Read_receive:
Rs0 = 0
Gosub Read_dtmf
Received_byte = Tempc
'
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
Write_dtmf:
'Uses lower nibble of Tempc
'Config_output
Config PinC.0 = Output
Config PinC.1 = Output
Config PinC.2 = Output
Config PiNC.3 = Output
'
Q0out = Tempc.0
Q1out = Tempc.1
Q2out = Tempc.2
Q3out = Tempc.3
Rw = 0
Phy2 = 1
NOP
NOP
NOP
Phy2 = 0
Return
'
Read_dtmf:
Gosub Config_input
Rw =  1
Phy2 = 1
NOP
NOP
Tempc = 0
Tempc.0 = Q0in
Tempc.1 = Q1in
Tempc.2 = Q2in
Tempc.3 = Q3in
Phy2 = 0
Return
'
Slave_commandparser:
'checks to avoid commandbuffer overflow are within commands !!
'
'start watchdog if 0
Incr Cmd_watchdog
'
Select Case Command_b(1)
   Case 0
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
'Data "0;m;DK1RI;DTMF_transceiver;V03.1;1;145;1;10;1-1"
      I2c_tx_busy = 2
      Tx_time = 1
      A_line = 0
      Number_of_lines = 1
      Send_line_gaps = 2
      Gosub Sub_restore
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 1
'Befehl  &H01 1 Byte + <s> / -
'liest den DTMF-Lesespeicher
'read the read DTMF buffer
'Data "1;aa,DTMF buffer;251,{0 to 9,*,#,A to D}"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H01
      'read ringbuffer Dtmf_buffer from Dtmf_in_readpointer to Dtmf_in_writepointer - 1
      I2c_write_pointer = 3
      While Dtmf_in_readpointer <> Dtmf_in_writepointer
         I2c_tx_b(I2c_write_pointer) = Dtmf_buffer_b(Dtmf_in_readpointer)
         Incr Dtmf_in_readpointer
         If Dtmf_in_readpointer = Dtmf_length Then Dtmf_in_readpointer = 1
         Incr I2c_write_pointer
      Wend
      I2c_tx_b(2) = I2c_write_pointer - 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 2
'Befehl  &H02 1 Byte / 1 Byte + <s>
'gibt DTMF Signal aus
'send DTMF tones
'Data "2;oa,send dtmf;252,{0 to 9,*,#,A to D"
      If Commandpointer < 2 Then
         L = Command_b(2)
         If L = 0 Or L > Dtmf_length Then
            Gosub command_received
         Else
            Incr Commandpointer
         End If
      Else
         L = Command_b(2) + 2
         If Commandpointer = L Then
            'string finished
            'adds to ringbuffer Dtmf_buffer_out,
            'overwrite old data, if buffer is full
            Tempb = 3
            While Tempb <= L
               Dtmf_buffer_out_b(Dtmf_buffer_out_writepointer) = Command_b(Tempb)
               Incr Dtmf_buffer_out_writepointer
               If Dtmf_buffer_out_writepointer > Dtmf_length Then Dtmf_buffer_out_writepointer = 1
               If Dtmf_buffer_out_writepointer = Dtmf_buffer_out_readpointer Then Incr Dtmf_buffer_out_readpointer
               'Buffer full -> shift Dtmf_buffer_out_readpointer to next position
               If Dtmf_buffer_out_readpointer >  Dtmf_length Then Dtmf_buffer_out_readpointer = 1
               Incr Tempb
            Wend
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      End If
'
   Case 238
'Befehl  &HEE 0|1 2 Byte / -
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
'Data "238;ka,no_myc;a"
      If Commandpointer = 2 Then
         If Command_b(2) < 2 Then
            no_myc = Command_b(2)
            no_myc_eeram = no_myc
            Dtmf_buffer_out_writepointer = 1
            Dtmf_buffer_out_readpointer = 1
            Gosub Reset_i2c_tx
         Else
            Error_no = 0
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
        Incr Commandpointer
      End If
'
   Case 239
'Befehl  &HEF 1 Byte / 2 Byte
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
'Data "239;la,as238"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &HEB
      I2c_tx_b(2) = no_myc
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
'Data "240;ln,ANNOUNCEMENTS;145;10"
      If Commandpointer >= 3 Then
         If Command_b(2) < No_of_announcelines And Command_b(3) < No_of_announcelines Then
            If Command_b(3) > 0 Then
               I2c_tx_busy = 2
               Tx_time = 1
               Send_line_gaps = 4
               Number_of_lines = Command_b(3)
               A_line = Command_b(2)
               Gosub Sub_restore
               If Command_mode = 1 Then
                  Gosub Print_i2c_tx
                  While Number_of_lines > 0
                     Gosub Sub_restore
                     Gosub Print_i2c_tx
                  Wend
                  Gosub Reset_i2c_tx
               End If
            End If
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
      print commandpointer
         Incr Commandpointer
      End If
'
   Case 252
'Befehl &HFC
'Liest letzten Fehler
'read last error
'Data 252;aa,LAST ERROR;20,last_error"
      I2c_tx_busy = 2
      Tx_time = 1
      Select Case Error_no
         Case 0
            I2c_tx = ": command not found: "
         Case 1
            I2c_tx = ": I2C error: "
         Case 3
            I2c_tx = ": Watchdog reset: "
         Case 4
            I2c_tx = ": parameter error: "
         Case 5
            I2c_tx = ": command watchdog: "
         Case 6
            I2c_tx = ": Tx timeout: "
         Case 7
            I2c_tx = ": not valid at that time: "
         Case 8
            I2c_tx = ": i2c_buffer overflow: "
         Case 255
            I2c_tx = ": No error: "
         Case Else
            I2c_tx = ": other error: "
      End Select
      Tempc = Len (I2c_tx)
      For Tempb = Tempc To 1 Step - 1
         I2c_tx_b(Tempb + 5) = I2c_tx_b(Tempb)
      Next Tempb
      I2c_tx_b(1) = &HFC
      I2c_tx_b(2) = &H20
      I2c_tx_b(3) = &H20
      I2c_tx_b(4) = &H20
      I2c_tx_b(5) = &H20
      Temps = Str(Command_no)
      Tempd = Len (Temps)
      For Tempb = 1 To Tempd
         I2c_tx_b(Tempb + 2) = Temps_b(Tempb)
      Next Tempb
      I2c_write_pointer = Tempc + 6
      Temps = Str(Error_cmd_no)
      Tempd = Len (Temps)
      For Tempb = 1 To Tempd
         I2c_tx_b(I2c_write_pointer) = Temps_b(Tempb)
         Incr I2c_write_pointer
      Next Tempb
      Tempc = Tempc + 3
      I2c_tx_b(2) = Tempc + Tempd
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 253
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
'Data "253;aa,MYC INFO;b,ACTIVE"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &HFD
      I2c_tx_b(2) = 4
      'no info
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 254
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,17,{0 to 127};a,RS232,1;a,USB,1"
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
                     L = Command_b(3) + 3
                     If Commandpointer >= L Then
                        Dev_name = String(20 , 0)
                        If L > 23 Then L = 23
                        For Tempb = 4 To L
                           Dev_name_b(Tempb - 3) = Command_b(Tempb)
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
                     Rs232_active = Tempb
                     Rs232_active_eeram = Rs232_active
                  Else
                     Error_no = 4
                     Error_cmd_no = Command_no
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            Case 5
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

            Case Else
               Error_no = 4
               Error_cmd_no = Command_no
         End Select
      Else
        Incr Commandpointer
      End If
'
   Case 255
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
'Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,6,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
      If Commandpointer >= 2 Then
         I2c_tx_busy = 2
         Tx_time = 1
         If Command_b(2) < 8 Then
            I2c_tx_b(1) = &HFF
            I2c_tx_b(2) = Command_b(2)
            Select Case Command_b(2)
               Case 0
                  'Will send &HFF0000 for empty string
                  Tempc = Len(Dev_name)
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
                  I2c_tx_b(3) = Rs232_active
                  I2c_write_pointer = 4
               Case 5
                  I2c_tx_b(3) = 0
                  I2c_write_pointer = 4
               Case 6
                  I2c_tx_b(3) = 3
                  I2c_tx_b(4) = "8"
                  I2c_tx_b(5) = "N"
                  I2c_tx_b(6) = "1"
                  I2c_write_pointer = 7
               Case 7
                  I2c_tx_b(3) = Usb_active
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
'Befehl &H00 1 Byte / -
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;DTMF_transceiver;V03.1;1;110;1;10;1-1"
'
Announce1:
'Befehl  &H01 1 Byte + <s> / -
'liest den DTMF-Lesespeicher
'read the read DTMF buffer
Data "1;aa,DTMF buffer;251,{0 to 9,*,#,A to D}"
'
Announce2:
'Befehl  &H02 1 Byte / 1 Byte + <s>
'gibt DTMF Signal aus
'send DTMF tones
Data "2;oa,send dtmf;252,{0 to 9,*,#,A to D"
'
Announce3:
'Befehl  &HEE 0|1 2 Byte / -
'schaltet MYC / no_MYC mode
'switches MYC / no_MYC mode
Data "238;ka,no_myc;a"
'
Announce4:
'Befehl  &HEF 1 Byte / 2 Byte
'liest MYC / no_MYC mode
'read MYC / no_MYC mode
Data "239;la,as238"
':
Announce5:
'Befehl &HF0<n><m>3 Byte / 3 Byte + n * <s>
'liest announcements
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;110;10"
'
Announce6:
'Befehl &HFC 1 Byte / 1 Byte +<s>
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce7:
'Befehl &HFD 1 Byte / 2 Byte
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce8:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,17,{0 to 127};a,RS232,1;a,USB,1"
'
Announce9:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,17,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'