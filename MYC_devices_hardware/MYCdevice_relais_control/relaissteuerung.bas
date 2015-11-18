'-----------------------------------------------------------------------
'name : relaisteuerung.bas
'Version V03.0, 20151117
'purpose : Control of a board with 4 Relais and 12 Inputs
'This Programm workes as I2C slave
'Can be used with hardware relaisteuerunge Version V01.3 by DK1RI
'The Programm supports the MYC protocol
'
'20150506 Basic announcement modified
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
' I2C_slave_1.0
'-----------------------------------------------------------------------
'Used Hardware:
' Inputs: Reset: PinC.3, D6, D7, B0 - B5, C0 - C3
' AD Converter 0 - 3
' Outputs : D.0 - D.3
' I/O : I2C
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:
' hangs sometimes at start-> power reset
'-----------------------------------------------------------------------
$regfile = "m88def.dat"                                     ' for ATmega8)
$crystal = 20000000                                         ' used crystal frequency
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
Const No_of_announcelines = 44                              'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte                                  'first run after reset
Dim L As Byte                                               'Temps and local
Dim L1 As Byte
Dim L2 As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim Temps_b(20) As Byte At Temps Overlay
Dim Rs232_in As String * Stringlength                       'RS232 input
Dim Rs232_in_b(stringlength) As Byte At Rs232_in Overlay
Dim A As Byte                                               'actual input
Dim Rs232_pointer As Byte
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
Dim In_mode8 As Byte
Dim In_mode8_eeram As Eram Byte
Dim In_mode9 As Byte
Dim In_mode9_eeram As Eram Byte
Dim In_mode10 As Byte
Dim In_mode10_eeram As Eram Byte
Dim In_mode11 As Byte
Dim In_mode11_eeram As Eram Byte
Dim Adc_value As Word
Dim Adc_reference As Byte
Dim Adc_reference_eeram As Eram Byte
'
'**************** Config / Init
Config Pind.5 = Input
Portd.5 = 1
Reset__ Alias Pind.5
'
Config Pinb.0 = Input                                       'compatibility with HW V01.2   clocko must be disabled
Portb.0 = 0
'
Config Pind.7 = Input
Portd.7 = 1
Inp1 Alias Pind.7
Config Pind.6 = Input
Portd.6 = 1
Inp2 Alias Pind.6
'
Config Pinb.1 = Input
Portb.1 = 1
Inp3 Alias Pinb.1
Config Pinb.2 = Input
Portb.2 = 1
Inp4 Alias Pinb.2
Config Pinb.3 = Input
Portb.3 = 1
Inp5 Alias Pinb.3
Config Pinb.4 = Input
Portb.4 = 1
Inp6 Alias Pinb.4
Config Pinb.5 = Input
Portb.5 = 1
Inp7 Alias Pinb.5
'
Config Pinc.0 = Input
Portc.0 = 1
Inp8 Alias Pinc.0
Config Pinc.1 = Input
Portc.1 = 1
Inp9 Alias Pinc.1
Config Pinc.2 = Input
Portc.2 = 1
Inp10 Alias Pinc.2
Config Pinc.3 = Input
Portc.3 = 1
Inp11 Alias Pinc.3
'
Config Portd.0 = Output
Relais1 Alias Portd.0
Config Portd.1 = Output
Relais2 Alias Portd.1
Config Portd.2 = Output
Relais3 Alias Portd.2
Config Portd.3 = Output
Relais4 Alias Portd.3
'
Config Sda = Portc.4                                        'must !!, otherwise error
Config Scl = Portc.5
Config Adc = Single , Prescaler = Auto , Reference = Avcc
'
Config Watchdog = 2048
'
'Mega8 has fixed parameter, processor will hang here, if uncommented:
'Config Com1 = 19200 , Databits = 8 Parity = None , Stopbits = 1                                                '
'
'****************Interrupts
'Enable INTERRUPTS
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
   Adc_reference = Adc_reference_eeram
   In_mode8 = In_mode8_eeram
   In_mode9 = In_mode9_eeram
   In_mode10 = In_mode10_eeram
   In_mode11 = In_mode11_eeram
End If
'
Gosub Init
'
If Reset__ = 0 Then Gosub Reset_
'
'
Slave_loop:
Start Watchdog                                              'Loop must be less than 512 ms
'
Gosub Cmd_watch
'
'I2C
'In a MYC System, the interface behaves like a device on a I2C Bus.
Twi_control = Twcr And &H80                                 'twint set?
If Twi_control = &H80 Then                                  'twsr 60 -> start, 80-> daten, A0 -> stop
   Twi_status = Twsr
   Twi_status = Twi_status And &HF8
'slave send:
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
      If I2c_pointer <= I2c_length Then
         Twdr = I2c_tx_b(i2c_pointer)
         Incr I2c_pointer
      Else                                                  'last Byte, String finished
         If Announceline < No_of_announcelines Then        'multiple lines to send
            Cmd_watchdog = 0                                'command may take longer
            A_line = Announceline
            Gosub Sub_restore
            Incr Announceline
            Twdr = I2c_tx_b(i2c_pointer)
            Incr I2c_pointer
         Else
            Twdr = &H00
            Announceline = 255
         End If
      End If
   End If
'I2C receives data and and interpet as commands.
'slave receive:
   If Twi_status = &H80 Or Twi_status = &H88 Then
      Tempb = Twdr
      If Commandpointer <= Stringlength Then
         Command_b(commandpointer) = Tempb
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1                                ' start watchdog
'            Reset Led3                                      'LED on  for tests
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
Adress = 8
Adress_eeram = Adress
Adc_reference = 0
Adc_reference_eeram = Adc_reference
In_mode8 = 0
In_mode8_eeram = In_mode8
In_mode9 = 0
In_mode9_eeram = In_mode9
In_mode10 = 0
In_mode10_eeram = In_mode10
In_mode11 = 0
In_mode11_eeram = In_mode11
Return
'
Init:
Portc.3 = 1
Command_no = 1
Announceline = 255                                          'no multiple announcelines
Rs232_pointer = 1
I2c_tx = String(stringlength , 0)                           'will delete buffer and restart ponter
I2c_length = 0                                              'should not be 0 at any time
I2c_pointer = 1
Last_error = " No Error"
Error_no = 255                                              'No Error
Gosub Command_received
Gosub Command_finished
Reset Relais1
Reset Relais2
Reset Relais3
Reset Relais4
Ucsr0b.3 = 0                                                'tx disable, tx override PD.1 by default
Return
'
Cmd_watch:
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong coomands will be deleted
If Cmd_watchdog > Cmd_watchdog_time Then
   Error_no = 3
   Gosub Last_err
   Gosub Command_received                                   'reset commandinput
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
'I2cinit                                                     'may be not neccessary
'Config Twi = 100000                                         ' 100KHz
Twsr = 0                                                    ' status und Prescaler auf 0
Twdr = &HFF                                                 ' default
Twar = Adress                                               ' Slaveadress
Twcr = &B01000100
Return
'
Command_received:
Commandpointer = 1
Command = String(stringlength , 0)                          'no multiple announcelines, if not finished
Cmd_watchdog = 0
Incr Command_no
'If Error_no <> 3 Then Set Led3                              'For Tests
Return
'
Sub_restore:
Error_no = 255                                              'no error
I2c_tx = String(stringlength , 0)                           'will delete buffer , read appear 0 at end ???
I2c_pointer = 1
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
   Case 19
      Restore Announce19
   Case 20
      Restore Announce20
   Case 21
      Restore Announce21
   Case 22
      Restore Announce22
   Case 23
      Restore Announce23
   Case 24
      Restore Announce24
   Case 25
      Restore Announce25
   Case 26
      Restore Announce26
   Case 27
      Restore Announce27
   Case 28
      Restore Announce28
   Case 29
      Restore Announce29
   Case 230
      Restore Announce30
   Case 31
      Restore Announce31
   Case 32
      Restore Announce32
   Case 33
      Restore Announce33
   Case 34
      Restore Announce34
   Case 35
      Restore Announce35
   Case 36
      Restore Announce36
   Case 37
      Restore Announce37
   Case 38
      Restore Announce38
   Case 39
      Restore Announce39
   Case 40
      Restore Announce40
   Case 41
      Restore Announce41
   Case 42
      Restore Announce42
   Case 43
      Restore Announce43
   Case Else
      Error_no = 0
      Gosub Last_err
End Select
If Error_no = 255 Then
   Read I2c_tx
   I2c_length = Len(i2c_tx)
   For Tempb = I2c_length To 1 Step -1                      'shift 1 pos right
      I2c_tx_b(tempb + 1) = I2c_tx_b(tempb)
   Next Tempb
   I2c_tx_b(1) = I2c_length
   Incr I2c_length                                          'complte length of string
End If
Return
'
Slave_commandparser:
If Commandpointer > 253 Then                                ' Error, do nothing
   Gosub Command_received
Else
'
   Select Case Command_b(1)
      Case 0
'Befehl &H00               basic annoumement wird gelesen
'                          basic announcement is read
'Data "0;m;DK1RI; 4 Relais Bord;V03.0;1;100;3;441"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl &H01               liest digital Wert INP1
'                          read digital INP1
'Data"1,as,INP1;0,0;1,1"
         I2c_pointer = 1
         I2c_tx_b(1) = Inp1
         I2c_length = 1
         Gosub Command_finished
'
      Case 2
'Befehl &H02               liest digital Wert INP2
'                          read digital INP2
'Data"2,as,INP2;0,0;1,1"
         I2c_pointer = 1
         I2c_tx_b(1) = Inp2
         I2c_length = 1
         Gosub Command_finished
'
      Case 3
'Befehl &H03               liest digital Wert INP3
'                          read digital INP3
'Data"3,as,INP3;0,0;1,1"
         I2c_pointer = 1
         I2c_tx_b(1) = Inp3
         I2c_length = 1
         Gosub Command_finished
'
      Case 4
'Befehl &H04               liest digital Wert INP4
'                          read digital INP4
'Data"4,as,INP4;0,0;1,1"
         I2c_pointer = 1
         I2c_tx_b(1) = Inp4
         I2c_length = 1
         Gosub Command_finished
'
      Case 5
'Befehl &H05               liest digital Wert INP5
'                          read digital INP5
'Data"5,as,INP5;0,0;1,1"
         I2c_pointer = 1
         I2c_tx_b(1) = Inp5
         I2c_length = 1
         Gosub Command_finished
'
      Case 6
'Befehl &H06               liest digital Wert INP6
'                          read digital INP6
'Data"6,as,INP6;0,0;1,1"
         I2c_pointer = 1
         I2c_tx_b(1) = Inp6
         I2c_length = 1
         Gosub Command_finished
'
      Case 7
'Befehl &H07               liest digital Wert INP7
'                          read digital INP7
'Data"7,as,INP7;0,0;1,1"
         I2c_pointer = 1
         I2c_tx_b(1) = Inp7
         I2c_length = 1
         Gosub Command_finished
'
      Case 8
'Befehl &H08               schaltet Eingang8 analog oder digita
'                          switch inp8 analog /digital
'Data "8,os,INP8;1,analog;0,digital"
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            Select Case Command_b(2)
            Case 0
               In_mode8 = 0
            Case 1
               In_mode8 = 1
            Case Else
               Error_no = 0
               Gosub Last_err
            End Select
            Gosub Command_received
         End If
'
      Case 9
'Befehl &H09               liest analog Wert INP8
'                          read analog INP8
'Data"9,ap,INP8;w,0 to 1023;-;lin"
         If In_mode8 = 1 Then
            Start Adc
            Adc_value = Getadc(0)
            Adc_value = Getadc(0)
            Stop Adc
            I2c_pointer = 1
            I2c_length = 2
            I2c_tx_b(1) = High(adc_value)
            I2c_tx_b(2) = Low(adc_value)
            I2c_length = 2
         Else
            Error_no = 0
            Gosub Last_err
         End If
         Gosub Command_received
'
      Case 10
'Befehl &H0A               liest digital Wert INP8
'                          read digital INP8
'Data "10,as,INP8;0,0;1,1"
         If In_mode8 = 0 Then
            I2c_pointer = 1
            I2c_tx_b(1) = Inp8
            I2c_length = 1
         Else
            Error_no = 0
            Gosub Last_err
         End If
         Gosub Command_received
'
      Case 11
'Befehl &H0B               schaltet Eingang9 analog oder digita
'                          switch inp9 analog /digital
'Data "11,os,INP9;1,analog;0,digital"
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            Select Case Command_b(2)
            Case 0
               In_mode9 = 0
            Case 1
               In_mode9 = 1
            Case Else
               Error_no = 0
               Gosub Last_err
            End Select
            Gosub Command_received
         End If
'
      Case 12
'Befehl &H0C               liest analog Wert IN9
'                          read analog INP8
'Data"12,ap,INP9;w,0 to 1023;-;lin"
         If In_mode9 = 1 Then
            Start Adc
            Adc_value = Getadc(1)
            Adc_value = Getadc(1)
            Stop Adc
            I2c_pointer = 1
            I2c_length = 2
            I2c_tx_b(1) = High(adc_value)
            I2c_tx_b(2) = Low(adc_value)
            I2c_length = 2
         Else
            Error_no = 0
            Gosub Last_err
         End If
         Gosub Command_received
'
      Case 13
'Befehl &H0D               liest digital Wert INP9
'                          read digital INP9
'Data "13,as,INP9;0,0;1,1"
         If In_mode9 = 0 Then
            I2c_pointer = 1
            I2c_tx_b(1) = Inp9
            I2c_length = 1
         Else
            Error_no = 0
            Gosub Last_err
         End If
         Gosub Command_received

      Case 14
'Befehl &H0E               schaltet Eingang10 analog oder digita
'                          switch inp10 analog /digital
'Data "14,os,INP10;1,analog;0,digital"
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            Select Case Command_b(2)
            Case 0
               In_mode10 = 0
            Case 1
               In_mode10 = 1
            Case Else
               Error_no = 0
               Gosub Last_err
            End Select
            Gosub Command_received
         End If
'
      Case 15
'Befehl &H0F               liest analog Wert IN10
'                          read analog INP10
'Data"15,ap,INP10;w,0 to 1023;-;lin"
         If In_mode10 = 1 Then
            Start Adc
            Adc_value = Getadc(2)
            Adc_value = Getadc(2)
            Stop Adc
            I2c_pointer = 1
            I2c_length = 2
            I2c_tx_b(1) = High(adc_value)
            I2c_tx_b(2) = Low(adc_value)
            I2c_length = 2
         Else
            Error_no = 0
            Gosub Last_err
         End If
         Gosub Command_received
'
      Case 16
'Befehl &H10               liest digital Wert INP10
'                          read digital INP10
'Data "16,as,INP10;0,0;1,1"
         If In_mode10 = 0 Then
            I2c_pointer = 1
            I2c_tx_b(1) = Inp10
            I2c_length = 1
         Else
            Error_no = 0
            Gosub Last_err
         End If
         Gosub Command_received

      Case 17
'Befehl &H11               schaltet Eingang11 analog oder digita
'                          switch inp11 analog /digital
'Data "17,os,INP11;1,analog;0,digital"
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            Select Case Command_b(2)
            Case 0
               In_mode11 = 0
            Case 1
               In_mode11 = 1
            Case Else
               Error_no = 0
               Gosub Last_err
            End Select
            Gosub Command_received
         End If
'
      Case 18
'Befehl &H12               liest analog Wert IN11
'                          read analog INP11
'Data"18,ap,INP11;w,0 to 1023;-;lin"
         If In_mode11 = 1 Then
            Start Adc
            Adc_value = Getadc(3)
            Adc_value = Getadc(3)
            Stop Adc
            I2c_pointer = 1
            I2c_length = 2
            I2c_tx_b(1) = High(adc_value)
            I2c_tx_b(2) = Low(adc_value)
            I2c_length = 2
         Else
            Error_no = 0
            Gosub Last_err
         End If
         Gosub Command_received
'
      Case 19
'Befehl &H13               liest digital Wert INP13
'                          read digital INP13
'Data"19,as,INP11;0,0;1,1"
         If In_mode11 = 0 Then
            I2c_pointer = 1
            I2c_tx_b(1) = Inp11
            I2c_length = 1
         Else
            Error_no = 0
            Gosub Last_err
         End If
         Gosub Command_received
'
      Case 20
'Befehl &H13               liest digital alle
'                          read digital all
'Data"20,am,all;w,0 to 4095"
         Tempb = 0
         If Inp1 = 1 Then Tempb = 1
         If Inp2 = 1 Then Tempb = Tempb + 2
         If Inp3 = 1 Then Tempb = Tempb + 4
         If Inp4 = 1 Then Tempb = Tempb + 8
         If Inp5 = 1 Then Tempb = Tempb + 16
         If Inp6 = 1 Then Tempb = Tempb + 32
         If Inp7 = 1 Then Tempb = Tempb + 64
         If Inp8 = 1 Then Tempb = Tempb + 128
         I2c_tx_b(2) = Tempb
         Tempb = 0
         If Inp9 = 1 Then Tempb = 1
         If Inp10 = 1 Then Tempb = Tempb + 2
         If Inp11 = 1 Then Tempb = Tempb + 4
         I2c_tx_b(1) = Tempb
         I2c_pointer = 1
         I2c_length = 2
         Gosub Command_finished
'
      Case 21
'Befehl &H14               schaltet Relais1
'                          switch relais1
'Data "21,os,relais1;0,off;1,on"
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            If Command_b(2) = 1 Then
               Set Relais1
            Else
               Reset Relais1
            End If
            Gosub Command_received
         End If
'
      Case 22
'Befehl &H15               liest Status Relais1
'                          read state relais1
'Data "22,as;as21"
         I2c_tx = String(stringlength , 0)                  'delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = Relais1
         I2c_length = 1
         Gosub Command_received
'
      Case 23
'Befehl &H16               schaltet Relais2
'                          switch relais2
'Data "23,os,relais2;0,off;1,on"
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            If Command_b(2) = 1 Then
               Set Relais2
            Else
               Reset Relais2
            End If
            Gosub Command_received
         End If
'
      Case 24
'Befehl &H17               liest Status Relais2
'                          read state relais2
'Data "24,as;as23"
         I2c_tx = String(stringlength , 0)                  'delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = Relais2
         I2c_length = 1
         Gosub Command_received
'
      Case 25
'Befehl &H18               schaltet Relais3
'                          switch relais3
'Data "25,os,relais3;0,off;1,on"
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            If Command_b(2) = 1 Then
               Set Relais3
            Else
               Reset Relais3
            End If
            Gosub Command_received
         End If
'
      Case 26
'Befehl &H19               liest Status Relais3
'                          read state relais3
'Data "26,as;as25"
         I2c_tx = String(stringlength , 0)                  'delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = Relais3
         I2c_length = 1
         Gosub Command_received
'
      Case 27
'Befehl &H1A               schaltet Relais4
'                          switch relais4
'Data "27,os, relais4;0,off;1,on"
         If Commandpointer = 1 Then
            Incr Commandpointer
         Else
            If Command_b(2) = 1 Then
               Set Relais4
            Else
               Reset Relais4
            End If
            Gosub Command_received
         End If
'
      Case 28
'Befehl &H1B               liest Status Relais4
'                          read state relais4
'Data "28,as;as27"
         I2c_tx = String(stringlength , 0)                  'delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = Relais4
         I2c_length = 1
         Gosub Command_received
'
   Case 238
'Befehl &HEE               schreibt Referenz default: 0:5V 1: 1.1V
'                          write reference voltage
'Data "238;oa;a"
      If Commandpointer = 1 Then
         Incr Commandpointer
      Else
         Select Case Command_b(2)
            Case 0
               Adc_reference = 0
               Adc_reference_eeram = Adc_reference
               Config Adc = Single , Prescaler = Auto , Reference = Avcc
            Case 1
               Adc_reference = 1
               Adc_reference_eeram = Adc_reference
               Config Adc = Single , Prescaler = Auto , Reference = Internal
            Case Else
               Error_no = 0
               Gosub Last_err
         End Select
         Gosub Command_received
      End If
'
   Case 239
'Befehl &HEF               liest Referenz default: 0:5V 1: 1.1V
'                          read reference voltage
'Data "239;aa;as238"
      I2c_tx = String(stringlength , 0)                     'delete buffer and restart ponter
      I2c_pointer = 1
      I2c_tx_b(1) = Adc_reference
      I2c_length = 1
      Gosub Command_received                                '
'
      Case 240
'Befehl &HF0 :   0-13,
'                253,254 255        announcement aller Befehle lesen
'                                   read announcement lines
'Data "240;am,ANNOUNCEMENTS;100;44"
         If Commandpointer = 2 Then
            Select Case Command_b(2)
               Case 253
                  A_line = 37
                  Announceline = 37
                  Gosub Sub_restore
               Case 254
                  A_line = 0
                  Announceline = 1
                  Gosub Sub_restore
               Case 255
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
'Befehl &HFC                  Liest letzen Fehler
'                             read last error
'Data "252;aa,LAST ERROR;20,last_error"
         I2c_tx = String(stringlength , 0)                  'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = 1                                    'so 1st byte <> 0!!
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
         Gosub Command_received
'
       Case 253
'Befehl &HFD                  geraet aktiv antwort
'                             Life signal
'Data "253;aa,MYC INFO;b,&H04,BUSY"
         I2c_tx = String(stringlength , 0)                  'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = 4                                    'no info
         I2c_length = 1
         Gosub Command_received
'
      Case 254
'Befehl &HFE :        *         eigene Individualisierung schreiben
'                               Der Devicename &HFE00 kann maximal 20 Zeichen haben
'                               Anderer Adresstyp &HFE02 kann maximal 3 Zeichen haben.
'                               wird aber ignoriert.
'                                write indivdualization
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;3,INTERFACETYPE,I2C;b,ADRESS,4"
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
                  If Commandpointer = 2 Then
                     Incr Commandpointer
                  Else
                     If Commandpointer = 3 Then
                        L = Command_b(3)
                        If L = 0 Then
                           Gosub Command_received
                        Else
                           If L > 3 Then L = 3
                           L = L + 3
                           Incr Commandpointer
                        End If
                     Else
                        If Commandpointer = L Then
                        Gosub Command_received
                        Else
                           Incr Commandpointer
                        End If
                     End If
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
'Data "255;aa;as254"
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
                  I2c_length = 2
               Case 2
                  I2c_tx = "{003}I2C"
                  I2c_length = 4
               Case 3
                  Tempb = Adress / 2
                  I2c_tx_b(1) = Tempb
                  I2c_length = 1
               Case Else
                  Error_no = 0                              'ignore anything else
                  Gosub Last_err
            End Select
            Gosub Command_received
         Else
               Incr Commandpointer
         End If
'
      Case Else
         Error_no = 0                                       'ignore anything else
         Gosub Last_err
      End Select
End If
Return
'
End
'
'announce text
'
Announce0:
'Befehl &H00               basic annoumement wird gelesen
'                          basic announcement is read
Data "0;m;DK1RI; 4 Relais Bord;V03.0;1;100;31;44"
'
Announce1:
'Befehl &H01               liest digital Wert INP1
'                          read digital INP1
Data "1,as,INP1;0,0;1,1"
'
Announce2:
'Befehl &H02               liest digital Wert INP2
'                          read digital INP2
Data "2,as,INP2;0,0;1,1"
'
Announce3:
'Befehl &H03               liest digital Wert INP3
'                          read digital INP3
Data "3,as,INP3;0,0;1,1"
'
Announce4:
'Befehl &H04               liest digital Wert INP4
'                          read digital INP4
Data "4,as,INP4;0,0;1,1"
'
Announce5:
'Befehl &H05               liest digital Wert INP5
'                          read digital INP5
Data "5,as,INP5;0,0;1,1"
'
Announce6:
'Befehl &H06               liest digital Wert INP6
'                          read digital INP6
Data "6,as,INP6;0,0;1,1"
'
Announce7:
'Befehl &H07               liest digital Wert INP7
'                          read digital INP7
Data "7,as,INP7;0,0;1,1"
'
Announce8:
'Befehl &H08               schaltet Eingang8 analog oder digita
'                          switch inp8 analog /digital
Data "8,os,INP8;1,analog;0,digital"
'
Announce9:
'Befehl &H09               liest analog Wert INP8
'                          read analog INP8
Data "9,ap,INP8;digit;0;1023"
'
Announce10:
'Befehl &H0A               liest digital Wert INP8
'                          read digital INP8
Data "10,as,INP8;0,0;1,1"
'
Announce11:
'Befehl &H0B               schaltet Eingang9 analog oder digita
'                          switch inp9 analog /digital
Data "11,os,INP9;1,analog;0,digital"
'
Announce12:
'Befehl &H0C               liest analog Wert IN9
'                          read analog INP8
Data "12,ap,INP9;w,0 to 1023;-;lin"
'
Announce13:
'Befehl &H0D               liest digital Wert INP9
'                          read digital INP9
Data "13,as,INP9;0,0;1,1"
'
Announce14:
'Befehl &H0E               schaltet Eingang10 analog oder digita
'                          switch inp10 analog /digital
Data "14,os,INP10;1,analog;0,digital"
'
Announce15:
'Befehl &H0F               liest analog Wert IN10
'                          read analog INP10
Data "15,ap,INP10;;w,0 to 1023;-;lin"
'
Announce16:
'Befehl &H10               liest digital Wert INP10
'                          read digital INP10
Data "16,as,INP10;0,0;1,1"

Announce17:
'Befehl &H11               schaltet Eingang11 analog oder digita
'                          switch inp11 analog /digital
Data "17,os,INP11;1,analog;0,digital"
'
Announce18:
'Befehl &H12               liest analog Wert IN11
'                          read analog INP11
Data "18,ap,INP11;;w,0 to 1023;-;lin""
'
Announce19:
'Befehl &H13               liest digital Wert INP13
'                          read digital INP13
Data "19,as,INP11;0,0;1,1"
'
Announce20:
'Befehl &H13               liest digital alle
'                          read digital all
Data"20,am,all;w,0 to 4095"
'
Announce21:
'Befehl &H14               schaltet Relais1
'                          switch relais1
Data "21,os,relais1;0,off;1,on"
'
Announce22:
'Befehl &H15               liest Status Relais1
'                          read state relais1
Data "22,as;as21"
'
Announce23:
'Befehl &H16               schaltet Relais2
'                          switch relais2
Data "23,os,relais2;0,off;1,on"
'
Announce24:
'Befehl &H17               liest Status Relais2
'                          read state relais2
Data "24,as;as23"
'
Announce25:
'Befehl &H18               schaltet Relais3
'                          switch relais3
Data "25,os,relais3;0,off;1,on"
'
Announce26:
'Befehl &H19               liest Status Relais3
'                          read state relais3
Data "26,as;as25"
'
Announce27:
'Befehl &H1A               schaltet Relais4
'                          switch relais4
Data "27,os, relais4;0,off;1,on"
'
Announce28:
'Befehl &H1B               liest Status Relais4
'                          read state relais4
Data "28,as;as27"
'
Announce29:
'Befehl &HEE               schreibt Referenz default: 0:5V 1: 1.1V
'                          write reference voltage
Data "238;oa;a"
'
Announce30:
'Befehl &HEF               liest Referenz default: 0:5V 1: 1.1V
'                          read reference voltage
Data "239;aa;as238"                                         '
'
Announce31:
'Befehl &HF0 :   0-13,
'                253,254 255        announcement aller Befehle lesen
'                                   read announcement lines
'Data "240;am,ANNOUNCEMENTS;100;44"
'
Announce32:
'Befehl &HFC                  Liest letzen Fehler
'                             read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce33:
'Befehl &HFD                  geraet aktiv antwort
'                             Life signal
Data "253;aa,MYC INFO;b,&H04,BUSY"
'
Announce34:
'Befehl &HFE :        *         eigene Individualisierung schreiben
'                               Der Devicename &HFE00 kann maximal 20 Zeichen haben
'                               Anderer Adresstyp &HFE02 kann maximal 3 Zeichen haben.
'                               wird aber ignoriert.
'                                write indivdualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;3,INTERFACETYPE,I2C;b,ADRESS,4"
'
Announce35:
'Befehl &HFF :        0 - 3         eigene Individualisierung lesen
Data "255;aa;as254"
'
Announce36:
Data "R !$9  IF $8=0"
'
Announce37:
Data "R !$10 IF $8=1"
'
Announce38:
Data "R !12 IF $11=0"
'
Announce39:
Data "R !$13 IF $11=1"
'
Announce40:
Data "R !$15 IF $14=0"
'
Announce41:
Data "R !$16 IF $14=1"
'
Announce42:
Data "R !$18 IF $17=0"
'
Announce43:
Data "R !$19 IF $17=1"