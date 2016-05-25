'-----------------------------------------------------------------------
'name : Fs20_8_kanal_tx.bas
'Version V03.1, 20160525
'purpose : Programm for sending FS20 Signals
'This Programm workes as I2C slave and with RS232
'Can be used with hardware FS20_interface Version V01.2 by DK1RI
'The Programm supports the MYC protocol
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
' dtmf_sender V03.1
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
'After Wait of more than 2 sec I2C will work anymore.
'Therefore config commands of the moduls are not used.
'No solution found
'-----------------------------------------------------------------------
$regfile = "m88pdef.dat"
' for ATmega8P
'$regfile = "m88def.dat"
' (for ATmega8)
'$regfile = "m328pdef.dat"
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
Const No_of_announcelines = 18
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
Dim Kanal_mode as Byte
'0, 4 Kanal, 1 8 Kanal
Dim Kanal_mode_eeram as Eram Byte
Dim Dim_start As Bit
Dim Timer_start As Bit
'
'**************** Config / Init   pin of FS20-S8M Sender
Config PortB.0 = Input
PortB.0 = 1
Reset__ Alias PinB.1
'
Config Pind.2 = Output
Por1 Alias Portd.2
Set Por1
Config Pind.3 = Output
Por2 Alias Portd.3
Set Por2
Config Pind.4 = Output
Por3 Alias Portd.4
Set Por3
Config PIND.5 = Output
Por4 Alias Portd.5
Set Por4
Config Pind.6 = Output
Por5 Alias Portd.6
Set Por5
Config Pind.7 = Output
Por6 Alias Portd.7
Set Por6
Config PinB.0 = Output
Por7 Alias Portb.0
Set Por7
Config Pinb.1 = Output
Por8 Alias Portb.1
Set Por8
'
'Use HW TWI
Config Twi = 400000

Config Watchdog = 2048
'
'****************Interrupts
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
'Loop must be less than 512 ms
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
      Command_b(commandpointer) = A
      If Cmd_watchdog = 0 Then Cmd_watchdog = 1
      ' start watchdog
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
Adress = 24
Adress_eeram = Adress
Kanal_mode = 0
Kanal_mode_eeram = Kanal_mode
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
Kanal_mode = Kanal_mode_eeram
Wait 1
Gosub Set_kanal_mode
Dim_start = 0
Timer_start = 0
I2C_active = I2C_active_eeram
RS232_active = RS232_active_eeram
Usb_active = Usb_active_eeram
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
Twdr = &H00
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
D1:
If Dim_start = 1 Then
   Reset Por1
   Waitms 440
Else
   Set Por1
End If
Return
'
D2:
If Dim_start = 1 Then
   Reset Por2
   Waitms 440
Else
   Set Por2
End If
Return
'
D3:
If Dim_start = 1 Then
   Reset Por3
   Waitms 440
Else
   Set Por3
End If
Return
'
D4:
If Dim_start = 1 Then
   Reset Por4
   Waitms 440
Else
   Set Por4
End If
Return
'
D5:
If Dim_start = 1 Then
   Reset Por5
   Waitms 440
Else
   Set Por5
End If
Return
'
D6:
If Dim_start = 1 Then
   Reset Por6
   Waitms 440
Else
   Set Por6
End If
Return
'
D7:
If Dim_start = 1 Then
   Reset Por7
   Waitms 440
Else
   Set Por7
End If
Return
'
D8:
If Dim_start = 1 Then
   Reset Por8
   Waitms 440
Else
   Set Por8
End If
Return

S1:
Reset Por1
Waitms 110
Set Por1
Return
'
S2:
Reset Por2
Waitms 110
Set Por2
Return
'
S3:
Reset Por3
Waitms 110
Set Por3
Return
'

S4:
Reset Por4
Waitms 110
Set Por4
Return
'
S5:
Reset Por5
Waitms 110
Set Por5
Return
'
S6:
Reset Por6
Waitms 110
Set Por6
Return
'

S7:
Reset Por7
Waitms 110
Set Por7
Return
'
S8:
Reset Por8
Waitms 110
Set Por8
Return
'
M12:
Reset Por1
Reset Por2
Waitms 1100
Set Por1
Set Por2
Return
'
M34:
Reset Por3
Reset Por4
Waitms 1100
Set Por3
Set Por4
Return
'
M56:
Reset Por5
Reset Por6
Waitms 1100
Set Por5
Set Por6
Return
'
M78:
Reset Por7
Reset Por8
Waitms 110
Set Por7
Set Por8
Return
'
T1:
Reset Por1
Reset Por2
Waitms 1100
Set Por2
Waitms 200
Set Por1
Return
'
T2:
Reset Por2
Reset Por1
Waitms 1100
Set Por1
Waitms 200
Set Por2
Set Por1
Return
'
T3:
Reset Por3
Reset Por4
Waitms 1100
Set Por4
Waitms 200
Set Por3
Return
'
T4:
Reset Por4
Reset Por3
Waitms 1100
Set Por3
Waitms 200
Set Por4
Return
'
T5:
Reset Por5
Reset Por6
Waitms 1100
Set Por6
Waitms 200
Set Por5
Return
'
T6:
Reset Por6
Reset Por5
Waitms 1100
Set Por5
Waitms 200
Set Por6
Return
'
T7:
Reset Por7
Reset Por8
Waitms 1100
Set Por8
Waitms 200
Set Por7
Return
'
T8:
Reset Por8
Reset Por7
Waitms 110
Set Por7
Waitms 200
Set Por8
Return
'
Set_kanal_mode:
If Kanal_mode = 0 Then
   '4 Kanal
   Reset Por1
   Reset Por4
   Wait 6
   Set Por4
   Set Por1
Else
   '8 Kanal
   Reset Por2
   Reset Por3
   Wait 6
   Set Por3
   Set Por2

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
'basic announcement is read to I2C or output
'Data "0;m;DK1RI;FS20 8 chanal sender;V03.1;1;170;12;18"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
     Case 1
'Befehl &H01
'schaltet kanäle aus
'switch chanals off
'Data "1;or,Aus;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
         If Commandpointer >= 2 Then
            If Kanal_mode = 0 Then
               If Command_b(2) < 4 Then
                  Gosub Command_finished
                  Stop Watchdog
                  If Command_b(2) = 0 Then Gosub S1
                  If Command_b(2) = 1 Then Gosub S3
                  If Command_b(2) = 2 Then Gosub S5
                  If command_b(2) = 3 Then Gosub S7
                  Start Watchdog
               Else
                  Error_no = 4
                  Gosub Last_err
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
      Case 2
'Befehl &H02
'schaltet Kanäle  ein
'switch chanals on
'Data "2;or,Ein;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
         If Commandpointer >= 2 Then
            If Kanal_mode = 0 Then
               If Command_b(2) < 4 Then
                  Gosub Command_finished
                  Stop Watchdog
                  If Command_b(2) = 0 Then Gosub S2
                  If Command_b(2) = 1 Then Gosub S4
                  If Command_b(2) = 2 Then Gosub S6
                  If command_b(2) = 3 Then Gosub S8
                  Start Watchdog
               Else
                  Error_no = 4
                  Gosub Last_err
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
      Case 3
'Befehl &H03
'schaltet Kanäle an / aus
'switch chanals on / off
'Data "3;or,Ein/Aus;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
         If Commandpointer >= 2 Then
            If Kanal_mode = 1 Then
               If Command_b(2) < 8 Then
                  Gosub Command_finished
                  Stop Watchdog
                  If Command_b(2) = 0 Then Gosub S1
                  If Command_b(2) = 1 Then Gosub S2
                  If Command_b(2) = 2 Then Gosub S3
                  If command_b(2) = 3 Then Gosub S4
                  If Command_b(2) = 4 Then Gosub S5
                  If Command_b(2) = 5 Then Gosub S6
                  If Command_b(2) = 6 Then Gosub S7
                  If command_b(2) = 7 Then Gosub S8
                  Start Watchdog
               Else
                  Error_no = 4
                  Gosub Last_err
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
      Case 4
'Befehl &H04
'dimmt kanäle ab
'dim chanals down
'Data "4;or,dimmt ab;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
         If Commandpointer >= 2 Then
            If Kanal_mode = 0 Then
               If Command_b(2) < 4 Then
                  Gosub Command_finished
                  Stop Watchdog
                  Toggle  Dim_start
                  If Command_b(2) = 0 Then Gosub D1
                  If Command_b(2) = 1 Then Gosub D3
                  If Command_b(2) = 2 Then Gosub D5
                  If command_b(2) = 3 Then Gosub D7
                  Start Watchdog
               Else
                  Error_no = 4
                  Gosub Last_err
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
'Befehl &H05
'dimmt kanäle  auf
'dims chanals up
'Data "5;or,dimmt auf;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
         If Commandpointer >= 2 Then
            If Kanal_mode = 0 Then
               If Command_b(2) < 4 Then
                  Gosub Command_finished
                  Stop Watchdog
                  Toggle Dim_start
                  If Command_b(2) = 0 Then Gosub D2
                  If Command_b(2) = 1 Then Gosub D4
                  If Command_b(2) = 2 Then Gosub D6
                  If command_b(2) = 3 Then Gosub D8
                  Start Watchdog
               Else
                  Error_no = 4
                  Gosub Last_err
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
      Case 6
'Befehl &H06
'dimmt kanäle  auf/ab
'dims chanals up/down
'Data "6;or,dimmt auf/ab;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
         If Commandpointer >= 2 Then
            If Kanal_mode = 1 Then
               If Command_b(2) < 8 Then
                  Gosub Command_finished
                  Stop Watchdog
                  Toggle Dim_start
                  If Command_b(2) = 0 Then Gosub D1
                  If Command_b(2) = 1 Then Gosub D2
                  If Command_b(2) = 2 Then Gosub D3
                  If command_b(2) = 3 Then Gosub D4
                  If Command_b(2) = 4 Then Gosub D5
                  If Command_b(2) = 5 Then Gosub D6
                  If Command_b(2) = 6 Then Gosub D7
                  If command_b(2) = 7 Then Gosub D8
                  Start Watchdog
               Else
                  Error_no = 4
                  Gosub Last_err
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
      Case 7
'Befehl &H07
'Timer für 4 Kanal Mode
'Timer for 4 chanal mode
'Data "7;or,Timer start/stop;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4""
         If Commandpointer >= 2 Then
            If Command_b(2) < 4 Then
               If Kanal_mode = 0 Then
                  Gosub Command_finished
                  Stop Watchdog
                  Toggle  Timer_start
                  If Command_b(2) = 0 Then Gosub M12
                  If Command_b(2) = 1 Then Gosub M34
                  If Command_b(2) = 2 Then Gosub M56
                  If command_b(2) = 3 Then Gosub M78
                  Start Watchdog
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
'
      Case 8
'Befehl &H08
'Timer für 8 Kanal Mode
'Timer for 8 chanal modef
'Data "8;or,Timer start/stop;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8""
         If Commandpointer >= 2 Then
            If Command_b(2) < 8 Then
               If Kanal_mode = 1 Then
                  Gosub Command_finished
                  Stop Watchdog
                  Toggle  Timer_start
                  If Command_b(2) = 0 Then Gosub T1
                  If Command_b(2) = 1 Then Gosub T2
                  If Command_b(2) = 2 Then Gosub T3
                  If command_b(2) = 3 Then Gosub T4
                  If Command_b(2) = 4 Then Gosub T5
                  If Command_b(2) = 5 Then Gosub T6
                  If Command_b(2) = 6 Then Gosub T7
                  If command_b(2) = 7 Then Gosub T8
                  Start Watchdog
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
'

      Case 9
'Befehl &H09
'schreiben 1: 4 / 2: 8 Kanalmode
'write 1: 4 / 2:8 chanalmode
'Data "9;os;0,4 Kanal;1,8 Kanal"
         If Commandpointer >= 2 Then
            Gosub Command_finished
            Stop Watchdog
            Select Case Command_b(2)
               Case 0
                  If Kanal_mode = 1 Then
                     Kanal_mode = 0
                     Kanal_mode_eeram = 0
                  End If
               Case 1
                  If Kanal_mode = 0 Then
                     Kanal_mode = 1
                     Kanal_mode_eeram = 1
                  End If
               Case Else
                  Error_no = 4
                  Gosub Last_err
            End Select
            Start Watchdog
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 10
'Befehl &H0A
'lesen 4 / 8 Kanalmodemode
'read 4 / 8 chanal mode
'Data "10,as,as9"
         Gosub Reset_i2c_tx
         I2c_tx_b(1) = Kanal_mode
         I2c_length = 1
         If Command_mode = 1 Then
            Printbin  Kanal_mode
         End If
         Gosub Command_received
'
      Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;100;18"
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
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,7,{0 to 127};a,RS232,1;a,USB,1"
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
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,7,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
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
'basic announcement is read to I2C or output
Data "0;m;DK1RI;FS20 8 chanal sender;V03.1;1;170;12;18"
'
Announce1:
'Befehl &H01
'schaltet kanäle aus
'switch chanals off
Data "1;or,Aus;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
Announce2:
'Befehl &H02
'schaltet Kanäle  ein
'switch chanals on
Data "2;or,Ein;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
Announce3:
'Befehl &H03
'schaltet Kanäle an / aus
'switch chanals on / off
Data "3;or,Ein/Aus;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
'
Announce4:
'Befehl &H04
'dimmt kanäle ab
'dim chanals down
Data "4;or,dimmt ab;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
Announce5:
'Befehl &H05
'dimmt kanäle  auf
'dims chanals up
Data "5;or,dimmt auf;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4"
'
Announce6:
'Befehl &H06
'dimmt kanäle  auf/ab
'dims chanals up/down
Data "6;or,dimmt auf/ab;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8"
'
Announce7:
'Befehl &H07
'Timer für 4 Kanal Mode
'Timer for 4 chanal mode
Data "7;or,Timer start/stop;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4""
'
Announce8:
'Befehl &H08
'Timer für 8 Kanal Mode
'Timer for 8 chanal modef
Data "8;or,Timer start/stop;0,Kanal1;1,Kanal2;2,Kanal3;3,Kanal4;4,Kanal5;5,kanal6;6,Kanal7;7,Kanal8""
'
Announce9:
'Befehl &H09
'schreiben 1: 4 / 2: 8 Kanalmode
'write 1: 4 / 2:8 chanalmode
Data "9;os;0,4 Kanal;1,8 Kanal"
'
Announce10:
'Befehl &H0A
'lesen 4 / 8 Kanalmodemode
'read 4 / 8 chanal mode
Data "10,as,as9"
'
Announce11:
'Befehl &HF0
'announcement aller Befehle lesen
'read announcement lines
Data "240;am,ANNOUNCEMENTS;100;18"
'
Announce12:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce13:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce14:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,7,{0 to 127};a,RS232,1;a,USB,1"
'
Announce15:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,7,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
Announce16:
Data "R !$1 !$2 !$4 !$5 !$7 If $9 = 1"
Announce17:
Data "R !$3 !$6 !$8 IF $9 = 0"