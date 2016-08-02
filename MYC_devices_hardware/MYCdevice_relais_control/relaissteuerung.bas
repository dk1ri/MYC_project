'-----------------------------------------------------------------------
'name : relaisteuerung.bas
'Version V03.2, 20160730
'purpose : Control of a board with 4 Relais and 11 Inputs
'This Programm workes as I2C slave
'Can be used with hardware relaisteuerunge Version V02.0 by DK1RI
'The Programm supports the MYC protocol
'
'micro : ATMega88 or higher
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
' I2C_slave_1.0
'-----------------------------------------------------------------------
'Used Hardware:
' Inputs: see below
' AD Converter 0 - 3
' Outputs : see below
' I/O : I2C
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'$regfile = "m88def.dat"
'for ATmega8)
$regfile = "m88pdef.dat"
'for ATmega8p)
'$regfile = "m328pdef.dat"
'for ATmega328)
$crystal = 20000000
'used crystal frequency
'$baud = 19200
'use baud rate
$hwstack = 64
'default use 32 for the hardware stack
$swstack = 20
'default use 10 for the SW stack
$framesize = 50
'default use 40 for the frame space
'
'Simulation!!!!
'$sim
'
'**************** libs
'use byte library for smaller code
'$lib "mcsbyte.lbx"
$lib "i2c_twi.lbx"
'
'**************** Variables
Const Stringlength = 252
'that is maximum
Const Cmd_watchdog_time = 65000
'Number of main loop before command reset
Const Blinktime = 3000
Const No_of_announcelines = 32
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
Dim Send_lines As Byte
Dim Number_of_lines As Byte
'
Dim Adc_value As Word
Dim Adc_reference As Byte
Dim Adc_reference_eeram As Eram Byte
'
'**************** Config / Init
Config Pind.5 = Input
Portd.5 = 1
Reset__ Alias Pind.5
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
Reset UCR.3
Reset UCR.4
'disable UART and enable PortD.0 As Output
Config Portd.0 = Output
Relais1 Alias Portd.0
Config Portd.1 = Output
Relais2 Alias Portd.1
Config Portd.2 = Output
Relais3 Alias Portd.2
Config Portd.3 = Output
Relais4 Alias Portd.3
'
Config Sda = Portc.4
'must !!, otherwise error
Config Scl = Portc.5
Config Adc = Single , Prescaler = Auto , Reference = Avcc
'
Config Watchdog = 2048
'
'
'**************** Main ***************************************************
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
'
'I2C receives data and and interpet as commands.
'slave receive:
   If Twi_status = &H80 Or Twi_status = &H88 Then
      Tempb = Twdr
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
'unsigned , set at first use
Dev_number_eeram = Dev_number
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 8
Adress_eeram = Adress
I2c_active = 1
I2c_active_eeram = I2c_active
Adc_reference = 0
Adc_reference_eeram = Adc_reference
Return
'
Init:
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram
I2c_active = I2c_active_eeram
Adc_reference = Adc_reference_eeram
Portc.3 = 1
Command_no = 1
Announceline = 255
'no multiple announcelines
I2c_tx = String(stringlength , 0)
'will delete buffer and restart ponter
I2c_length = 0
I2c_pointer = 1
Last_error = " No Error"
Error_no = 255
'No Error
Gosub Command_received
Gosub Command_finished
Reset Relais1
Reset Relais2
Reset Relais3
Reset Relais4
Ucsr0b.3 = 0
'tx disable, tx override PD.1 by default
Return
'
Cmd_watch:
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong coomands will be deleted
If Cmd_watchdog > Cmd_watchdog_time Then
   Error_no = 3
   Gosub Last_err
   Gosub Command_received
   'reset commandinput
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
Error_no = 255
'no error
Gosub Reset_i2c_tx
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
   'complte length of string
End If
Return
'
Reset_i2c_tx:
I2c_length = 0
I2c_pointer = 1
I2c_tx = String(Stringlength,0)
Return
'
Slave_commandparser:
If Commandpointer > 253 Then
' Error, do nothing
   Gosub Command_received
Else
'
   Select Case Command_b(1)
      Case 0
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
'Data "0;m;DK1RI; 4 Relais Bord;V03.2;1;100;27;32"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl &H01
'liest digital Wert INP1
'read digital INP1
'Data"1,as,INP1;0,0;1,1"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Inp1
         I2c_length = 1
         Gosub Command_finished
'
      Case 2
'Befehl &H02
'liest digital Wert INP2
'read digital INP2
'Data"2,as,INP2;0,0;1,1"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Inp2
         I2c_length = 1
         Gosub Command_finished
'
      Case 3
'Befehl &H03
'liest digital Wert INP3
'read digital INP3
'Data"3,as,INP3;0,0;1,1"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Inp3
         I2c_length = 1
         Gosub Command_finished
'
      Case 4
'Befehl &H04
'liest digital Wert INP4
'read digital INP4
'Data "4,as,INP4;0,0;1,1"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Inp4
         I2c_length = 1
         Gosub Command_finished
'
      Case 5
'Befehl &H05
'liest digital Wert INP5
'read digital INP5
'Data"5,as,INP5;0,0;1,1"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Inp5
         I2c_length = 1
         Gosub Command_finished
'
      Case 6
'Befehl &H06
'liest digital Wert INP6
'read digital INP6
'Data "6,as,INP6;0,0;1,1"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Inp6
         I2c_length = 1
         Gosub Command_finished
'
      Case 7
'Befehl &H07
'liest digital Wert INP7
'read digital INP7
'Data"7,as,INP7;0,0;1,1"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Inp7
         I2c_length = 1
         Gosub Command_finished
'
      Case 8
'Befehl &H08
'liest analog Wert INP8
'read analog INP8
'Data "8,ap,INP8;1024;lin;-"
         Start Adc
         Adc_value = Getadc(0)
         Adc_value = Getadc(0)
         Stop Adc
         Gosub Reset_i2c_tx
         I2c_length = 2
         I2c_tx_b(1) = High(adc_value)
         I2c_tx_b(2) = Low(adc_value)
         I2c_length = 2
         Gosub Command_received
'
      Case 9
'Befehl &H09
'liest digital Wert INP8
'read digital INP8
'Data "9,as,INP8;0,0;1,1"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Inp8
         I2c_length = 1
         Gosub Command_received
'
      Case 10
'Befehl &H0A
'liest analog Wert IN9
'read analog INP9
'Data "10,ap,INP9;1024;lin;-"
         Start Adc
         Adc_value = Getadc(1)
         Adc_value = Getadc(1)
         Stop Adc
         Gosub Reset_i2c_tx
         I2c_length = 2
         I2c_tx_b(1) = High(adc_value)
         I2c_tx_b(2) = Low(adc_value)
         I2c_length = 2
         Gosub Command_received
'
      Case 11
'Befehl &H0B
'liest digital Wert INP9
'read digital INP9
'Data "11,as,INP9;0,0;1,1"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Inp9
         I2c_length = 1
         Gosub Command_received
'
      Case 12
'Befehl &H0C
'liest analog Wert IN10
'read analog INP10
'Data"12,ap,INP10;1024;lin;-"
         Start Adc
         Adc_value = Getadc(2)
         Adc_value = Getadc(2)
         Stop Adc
         Gosub Reset_i2c_tx
         I2c_length = 2
         I2c_tx_b(1) = High(adc_value)
         I2c_tx_b(2) = Low(adc_value)
         I2c_length = 2
         Gosub Command_received
'
      Case 13
'Befehl &H0D
'liest digital Wert INP10
'read digital INP10
'Data "13,as,INP10;0,0;1,1"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Inp10
         I2c_length = 1
         Gosub Command_received
'
      Case 14
'Befehl &H0E
'liest analog Wert IN11
'read analog INP11
'Data"14,ap,INP11;1024;lin;-"
         Start Adc
         Adc_value = Getadc(3)
         Adc_value = Getadc(3)
         Stop Adc
         Gosub Reset_i2c_tx
         I2c_length = 2
         I2c_tx_b(1) = High(adc_value)
         I2c_tx_b(2) = Low(adc_value)
         I2c_length = 2
         Gosub Command_received
'
      Case 15
'Befehl &H0F
'liest digital Wert INP11
'read digital INP11
'Data "15,as,INP11;0,0;1,1"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Inp11
         I2c_length = 1
         Gosub Command_received
'
      Case 16
'Befehl &H10
'liest digital alle
'read digital all
'Data"16,am,all;w,{0 to 4095}"
         Gosub Reset_i2c_tx
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
         I2c_length = 2
         Gosub Command_finished
'
      Case 17
'Befehl &H11
'schaltet Relais1
'switch relais1
'Data "17,os,relais1;0,off;1,on"
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
      Case 18
'Befehl &H12
'liest Status Relais1
'read state relais1
'Data "18,as;as17"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Relais1
         I2c_length = 1
         Gosub Command_received
'
      Case 19
'Befehl &H13
'schaltet Relais2
'switch relais2
'Data "19,os,relais2;0,off;1,on"
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
      Case 20
'Befehl &H14
'liest Status Relais2
'read state relais2
'Data "20,as;as19"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Relais2
         I2c_length = 1
         Gosub Command_received
'
      Case 21
'Befehl &H15
'schaltet Relais3
'switch relais3
'Data "21,os,relais3;0,off;1,on"
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
      Case 22
'Befehl &H16
'liest Status Relais3
'read state relais3
'Data "22,as;as21"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Relais3
         I2c_length = 1
         Gosub Command_received
'
      Case 23
'Befehl &H17
'schaltet Relais4
'switch relais4
'Data "23,os, relais4;0,off;1,on"
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
      Case 24
'Befehl &H18
'liest Status Relais4
'read state relais4
'Data "24,as;as23"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Relais4
         I2c_length = 1
         Gosub Command_received
'
   Case 238
'Befehl &HEE
'schreibt Referenz default: 0:5V 1: 1.1V
'write reference voltage
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
         End Select
         Gosub Command_received
      End If
'
   Case 239
'Befehl &HEF
'liest Referenz default: 0:5V 1: 1.1V
'read reference voltage
'Data "239;aa;as238"
      Gosub Reset_i2c_tx
      I2c_tx_b(1) = Adc_reference
      I2c_length = 1
      Gosub Command_received                                '
'
      Case 240
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
'Data "240;an,ANNOUNCEMENTS;100;32"
         If Commandpointer = 3 Then
            If Command_b(2) < No_of_announcelines And Command_b(3) <= No_of_announcelines Then
                If Command_b(3) > 0 Then
                  Send_lines = 1
                  Number_of_lines = Command_b(3)
                  A_line = Command_b(2)
                  Gosub Sub_restore
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
         Gosub Command_received
'
       Case 253
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
'Data "253;aa,MYC INFO;b,ACTIVE"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = 4
         'no info
         I2c_length = 1
         Gosub Command_received
'
      Case 254
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,4,{0 to 127}"
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
               Case Else
                  Error_no = 0
            End Select
         Else
           Incr Commandpointer
         End If
'
      Case 255
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,4,{0 to 127}"
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
                  I2C_tx_b(1) = I2c_active
                  I2c_length = 1
               Case 3
                  Tempb = Adress / 2
                  I2c_tx_b(1) = Tempb
                  I2c_length = 1
               Case Else
                  Error_no = 4
                  'ignore anything else
            End Select
            Gosub Command_received
         Else
               Incr Commandpointer
         End If
'
      Case Else
         Error_no = 0
         'ignore anything else
      End Select
End If
Return
'
End
'
'announce text
'
Announce0:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI; 4 Relais Bord;V03.2;1;100;27;32"
'
Announce1:
'Befehl &H01
'liest digital Wert INP1
'read digital INP1
Data"1,as,INP1;0,0;1,1"
'
Announce2:
'Befehl &H02
'liest digital Wert INP2
'read digital INP2
Data"2,as,INP2;0,0;1,1"
'
Announce3:
'Befehl &H03
'liest digital Wert INP3
'read digital INP3
Data"3,as,INP3;0,0;1,1"
'
Announce4:
'Befehl &H04
'liest digital Wert INP4
'read digital INP4
Data "4,as,INP4;0,0;1,1"
'
Announce5:
'Befehl &H05
'liest digital Wert INP5
'read digital INP5
Data"5,as,INP5;0,0;1,1"
'
Announce6:
'Befehl &H06
'liest digital Wert INP6
'read digital INP6
Data "6,as,INP6;0,0;1,1"
'
Announce7:
'Befehl &H07
'liest digital Wert INP7
'read digital INP7
Data"7,as,INP7;0,0;1,1"
'
Announce8:
'Befehl &H08
'liest analog Wert INP8
'read analog INP8
Data "8,ap,INP8;1024;lin;-"
'
Announce9:
'Befehl &H09
'liest digital Wert INP8
'read digital INP8
Data "9,as,INP8;0,0;1,1"
'
Announce10:
'Befehl &H0A
'liest analog Wert IN9
'read analog INP9
Data "10,ap,INP9;1024;lin;-"
'
Announce11:
'Befehl &H0B
'liest digital Wert INP9
'read digital INP9
Data "11,as,INP9;0,0;1,1"
'
Announce12:
'Befehl &H0C
'liest analog Wert IN10
'read analog INP10
Data"12,ap,INP10;1024;lin;-"
'
Announce13:
'Befehl &H0D
'liest digital Wert INP10
'read digital INP10
Data "13,as,INP10;0,0;1,1"
'
Announce14:
'Befehl &H0E
'liest analog Wert IN11
'read analog INP11
Data"14,ap,INP11;1024;lin;-"
'
Announce15:
'Befehl &H0F
'liest digital Wert INP11
'read digital INP11
Data "15,as,INP11;0,0;1,1"
'
Announce16:
'Befehl &H10
'liest digital alle
'read digital all
Data"16,am,all;w,{0 to 4095}"

Announce17:
'Befehl &H11
'schaltet Relais1
'switch relais1
Data "17,os,relais1;0,off;1,on"
'
Announce18:
'Befehl &H12
'liest Status Relais1
'read state relais1
Data "18,as;as17"
'
Announce19:
'Befehl &H13
'schaltet Relais2
'switch relais2
Data "19,os,relais2;0,off;1,on"
'
Announce20:
'Befehl &H14
'liest Status Relais2
'read state relais2
Data "20,as;as19"
'
Announce21:
'Befehl &H15
'schaltet Relais3
'switch relais3
Data "21,os,relais3;0,off;1,on"
'
Announce22:
'Befehl &H16
'liest Status Relais3
'read state relais3
Data "22,as;as21"
'
Announce23:
'Befehl &H17
'schaltet Relais4
'switch relais4
Data "23,os, relais4;0,off;1,on"
'
Announce24:
'Befehl &H18
'liest Status Relais4
'read state relais4
Data "24,as;as23"
'
Announce25:
'Befehl &HEE
'schreibt Referenz default: 0:5V 1: 1.1V
'write reference voltage
Data "238;oa;a"
'
Announce26:
'Befehl &HEF
'liest Referenz default: 0:5V 1: 1.1V
'read reference voltage
Data "239;aa;as238"
'
Announce27:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;an,ANNOUNCEMENTS;100;32"
'
Announce28:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce29:
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce30:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,4,{0 to 127}"
'
Announce31:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,4,{0 to 127}"
'