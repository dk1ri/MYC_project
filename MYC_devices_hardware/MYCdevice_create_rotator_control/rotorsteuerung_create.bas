'-----------------------------------------------------------------------
'name : rotorsteuerung_create_bascom.bas
'Version V05.3, 20181019
'purpose : Programm for control a Create RC5 Rotator
'Can be used with hardware rotorsteuerung_create V03.3 by DK1RI
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
'slave_core_V01.6
'-----------------------------------------------------------------------
'
'Used Hardware:
' I/O: I2C
' ADC Inputs: Rotator-position(ADC1),
' Inputs / Outputs see below
'
'-----------------------------------------------------------------------
' For announcements and rules see Data section at the end
' Interface to MYC commandrouter via I2C or USB
' Device is I2C slave
'-----------------------------------------------------------------------
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'$regfile = "m168pdef.dat"
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
Const No_of_announcelines = 24
'announcements start with 0 -> minus 1
Const Ccw_limit_default = 1008
'25 deg (out of400) before end -> 6,25% -> 6,25 % * 1024 = 64
'ccw has high voltage, cw low voltage
'those are my values
Const Cw_limit_default = 49
Const Antenna_deviation = 5
'during preset motor will not start if antenna is within + - Antenna_deviation
'in degree
Const Number_of_off_limits = 10
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
' for Rotatorcontrol:
Dim Preset_active As Byte
Dim Preset_pos_antenna As Word
'presetposition of  antennadirection, North=0, degree
Dim Preset_pos_antenna_eeram As Word
Dim Preset_out_limits As Byte
Dim Preset_rotor As Word
Dim Dir_rotor As Word
Dim Antenna_limit_direction As Word
'antennadirection, if rotator is alimit. North=0degree
Dim Antenna_limit_direction_eeram As Eram Word
'in eeram
Dim Pos_rotator_voltage As Word
'actual Rotatorposition, voltage
Dim Pos_rotator As Word
'rotator position in degree
Dim Pos_temp As Word
Dim Pos_temp2 As Word
Dim Pos_antenna As Word
'actual antennadirection , North =0
Dim Pos_antenna_s As Single
'as single
Dim Ccw_0_voltage As Word
'ccw adc value at calibration
Dim Ccw_0_voltage_temp As Word
Dim Ccw_0_voltage_eeram As Eram Word
Dim Cw_360_voltage As Word
Dim Cw_360_voltage_temp As Word
'cw adc value at calibration  '
Dim Cw_360_voltage_eeram As Eram Word
Dim Voltage_range_0_360 As Word
'difference of the above
Dim Hw_limit_detected As Byte
'0: not detected 1: detected 2: move rotator manually
Dim Off_limit As Byte
Dim Temp_w As Word
Dim Temp_single As Single
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'**************** Config / Init
Config Pinc.2 = Input
Portc.2 = 1
Not_limit Alias Pinc.2
' Limit  0 activ
Config Pind.7 = Input
Portd.7 = 1
Reset__ Alias Pind.7
'
Config Portb.0 = Output
Controlon Alias Portb.0
Config Portb.1 = Output
Motor_cw Alias Portb.1
Config Portb.2 = Output
Motor_ccw Alias Portb.2
'
Config Adc = Single , Prescaler = Auto , Reference = Internal
'
Config Watchdog = 2048                                      '
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
Pos_rotator_voltage = Getadc(1)
Gosub Correct_
Gosub Calculate_antenna_direction
If Pos_antenna < Antenna_limit_direction Then
   Dir_rotor = 360 - Antenna_limit_direction
   Dir_rotor = Dir_rotor + Pos_antenna
Else
   Dir_rotor = Pos_antenna - Antenna_limit_direction
End If
'
If Controlon = 1 Then
'
   Gosub Ckeck_hw_limit                                           '
'
   If Preset_active = 1 Then
   'checks during motor preset
   'Preset uses degrees of antennadirection !!
      Gosub Check_preset
   End If
End If
'
'RS232 got data?
A = Ischarwaiting()
If A = 1 Then
   A = Inkey()
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
Adress = 4
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
'
'standard of compass display is South
Antenna_limit_direction = 180
'standard of compass display is South
Antenna_limit_direction_eeram = Antenna_limit_direction
Ccw_0_voltage = Ccw_limit_default
Ccw_0_voltage_eeram = Ccw_0_voltage
Cw_360_voltage = Cw_limit_default
Cw_360_voltage_eeram = Cw_360_voltage
Preset_pos_antenna = 0
'north
Preset_pos_antenna_eeram = Preset_pos_antenna
Preset_active = 0
'manual
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
Ccw_0_voltage = Ccw_0_voltage_eeram
Cw_360_voltage = Cw_360_voltage_eeram
Voltage_range_0_360 = Ccw_0_voltage - Cw_360_voltage
'actual voltage range for 360 degree
Antenna_limit_direction = Antenna_limit_direction_eeram
Preset_pos_antenna = Preset_pos_antenna_eeram
If Preset_pos_antenna < Antenna_limit_direction Then
   Preset_rotor = 360 -Antenna_limit_direction
   Preset_rotor = Preset_rotor + Preset_pos_antenna
Else
   Preset_rotor = Preset_pos_antenna - Antenna_limit_direction
End If
If Preset_rotor < Antenna_deviation Then Preset_rotor = Antenna_deviation
Temp_w = 359 - Antenna_deviation
If Preset_rotor > Temp_w Then Preset_rotor = Temp_w
Preset_active = 0
Hw_limit_detected = 0
Off_limit = 0
Preset_out_limits = 1
Gosub Stop_all
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
Select Case Send_line_gaps
   'select the start of text
   Case 1
      Tempd = 1
   Case 3
      Tempd = 2
   Case 2
      Tempd = 4
End Select
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
   Case Else
         'will not happen
End Select
Read I2c_tx
Tempc = Len(I2c_tx)
For Tempb = Tempc To 1 Step - 1
   Tempa = Tempb + Tempd
   I2c_tx_b(Tempa) = I2c_tx_b(Tempb)
Next Tempb
Select Case Send_line_gaps
   Case 1
      I2c_tx_b(1) = Tempc
      I2c_write_pointer = Tempc + 2
      'additional announcement lines
   Case 3
      'start basic announcement
      I2c_tx_b(1) = &H00
      I2c_tx_b(2) = Tempc
      I2c_write_pointer = Tempc + 3
      Send_line_gaps = 1
   Case 2
      'start of announceline(s), send 3 byte first
      I2c_tx_b(1) = &HF0
      I2c_tx_b(2) = A_line
      I2c_tx_b(3) = Number_of_lines
      I2c_tx_b(4) = Tempc
      I2c_write_pointer = Tempc + 5
      Send_line_gaps = 1
End Select
Incr A_line
If A_line >= No_of_announcelines Then A_line = 0
Decr Number_of_lines
'Else
'happens, for &HF=xx00
'send header only
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
'Rotator and Antenna:
'Voltage is highest, if ratator is at ccw limit !!!
'
Correct_:
'This correct the systematic error due to the circuit
'For details see the LTspice simulation and the corresponding Calc sheet
'The full range is splitted into 20 Segments (49 steps each)
'detail see excel sheet
   Temp_single = Pos_rotator_voltage
   Select Case Pos_rotator_voltage
   'use word values
      Case 0 to 13
      Case 14 to 38
          Temp_single = Temp_single * 0.9894
      Case 39 to  64
         Temp_single = Temp_single * 0.99
      Case 65 to  90
         Temp_single = Temp_single * 0.9906
      Case 91 to 115
         Temp_single = Temp_single * 0.9912
      Case 116 to 141
         Temp_single = Temp_single * 0.9918
      Case 142 to  166
         Temp_single = Temp_single * 0.9923
      Case 167 to  192
         Temp_single = Temp_single * 0.9929
      Case 193 to 218
         Temp_single = Temp_single * 0.9934
      Case 219 to 243
         Temp_single = Temp_single * 0.9939
      Case 244 to  282
         Temp_single = Temp_single * 0.9944
      Case 283 to 333
         Temp_single = Temp_single * 0.9953
      Case 334 to 384
         Temp_single = Temp_single * 0.9961
      Case 385 to 435
         Temp_single = Temp_single * 0.9968
      Case 436 to  486
         Temp_single = Temp_single * 0.9975
      Case 487 to  538
         Temp_single = Temp_single * 0.9981
      Case 539 to 589
         Temp_single = Temp_single * 0.9986
      Case 590 to 640
         Temp_single = Temp_single * 0.9991
      Case 641 to 691
         Temp_single = Temp_single * 0.9995
      Case 692 to 742
         Temp_single = Temp_single * 0.9998
      Case 743 to 794
      Case 795 to 845
         Temp_single = Temp_single * 1.0001
      Case 846 to 896
         Temp_single = Temp_single * 1.0002
      Case 897 to 934
         Temp_single = Temp_single * 1.0002
      Case 935 to 960
         Temp_single = Temp_single * 1.0001
      Case 961 to 986
         Temp_single = Temp_single * 1.0024
      Case 987 to 1011
      Case 1012 to 1024
      Case Else
   End Select
   Pos_rotator_voltage = Temp_single
Return
'
Calculate_antenna_direction:
If Pos_rotator_voltage >= Ccw_0_voltage Then
   'Voltage over Ccw Limit, positions byond limits are set to limits
   Pos_rotator = 0
   Pos_antenna = Antenna_limit_direction
Else
   If Pos_rotator_voltage <= Cw_360_voltage Then
   'Voltage under Cw Limit, positions byond limits are set to limits
      Pos_rotator = 359
      Pos_antenna = Antenna_limit_direction
   Else
      Temp_single = Ccw_0_voltage - Pos_rotator_voltage
      'Voltage, subtract from the the max value
      Temp_single = Temp_single * 360
      Temp_single = Temp_single / Voltage_range_0_360
      'real rotator position
      Pos_rotator = Temp_single
      Pos_antenna = Pos_rotator + Antenna_limit_direction
      If Pos_antenna > 359 Then Pos_antenna = Pos_antenna - 360
   End If
End If
Return
'
Motor_ccw_on:
Reset Motor_cw
Set Motor_ccw
Return
'
Motor_cw_on:
Reset Motor_ccw
Set Motor_cw
Return
'
Stop_all:
Reset Motor_cw
Reset Motor_ccw
Return
'
Ckeck_hw_limit:
'check rotator 0 / 360 degree limit
'This check uses the voltages !!
   If Pos_rotator_voltage < Cw_360_voltage Or Pos_rotator_voltage > Ccw_0_voltage Then
   'Cw_360_voltage is "low" voltage; Ccw_0_voltage is "high" voltage
      If Off_limit =  Number_of_off_limits Then
      'This may avoi some spikes
         If Pos_rotator_voltage < Cw_360_voltage And Motor_cw = 1 Then Gosub Stop_all
         If Pos_rotator_voltage > Ccw_0_voltage And Motor_ccw = 1 Then Gosub Stop_all
         If Preset_active = 1 Then
         'This should not happen
            Preset_active = 0
            Gosub Stop_all
         End If
         Off_limit = 0
         If Pos_rotator_voltage < Cw_360_voltage Then
            Error_no = 5
            Error_cmd_no = Command_no
         End If
         If Pos_rotator_voltage > Ccw_0_voltage Then
            Error_no = 6
            Error_cmd_no = Command_no
         End If
      Else
         Incr Off_limit
      End If
   End If
'
'check Hw-limit
   If Not_limit = 1 Then
      Hw_limit_detected = 0
   Else
   'Hw_limit_detected 0: no limit. 1: detected, stop motor, 2: move out of limit
      Select Case Hw_limit_detected
         Case 2
            Stop Watchdog
            'move  rotator started
            I = 1
            While I < 10
               Waitms 500
               If Not_limit = 0 Then
                  Incr I
                  If I = 10 Then
                  'stop after 5 seconds moving wrong direction
                     Gosub Stop_all
                     Hw_limit_detected = 1
                  End If
               Else
               'No more limit detected
                  I = 10
                  Hw_limit_detected = 0
               End If
            Wend
            Start Watchdog
         Case 0
         'limit detected first time: stop immediate
            Hw_limit_detected = 1
            Gosub Stop_all
            If Preset_active = 1 Then
            'should nor happen
               Preset_active = 0
            End If
         Case 1
         'stop, if other than move command started rotator
            Gosub Stop_all
      End Select
   End If
Return
'
Check_preset:
' Preset_out_limits:
'0: should be within limits
'1: start motor
'2: move direct to position cw
'3: move direct to position ccw
      Select Case Preset_out_limits
         Case 0
         'still within limits?
         'Calculate the limits:
            Pos_temp = Preset_rotor + Antenna_deviation
            Pos_temp2 = Preset_rotor - Antenna_deviation
            'both values are always between 0 and 359
            If Dir_rotor < Pos_temp2 or Dir_rotor > Pos_temp Then
            'out of limit
               If  Dir_rotor < Pos_temp2  Then  Gosub Motor_cw_on
               If  Dir_rotor > Pos_temp  Then  Gosub Motor_ccw_on
            Else
               Gosub Stop_all
            End If
         Case 1
         'find move direction, start moving
            If Dir_rotor < Preset_rotor Then
               Gosub Motor_cw_on
               Preset_out_limits = 2
            Else
               Gosub Motor_ccw_on
               Preset_out_limits = 3
            End If
         Case 2
         'move cw
            If Dir_rotor > Preset_rotor Then
               Gosub Stop_all
               Preset_out_limits = 0
            End If
         Case 3
         'moving ccw
            If Dir_rotor < Preset_rotor Then
               Gosub Stop_all
               Preset_out_limits = 0
            End If
      End Select
Return
'  '
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
'Data "0;m;DK1RI;RC5 rotator control;V05.3;1;145;1;24;1-1"
      I2c_tx_busy = 2
      Tx_time = 1
      A_line = 0
      Number_of_lines = 1
      Send_line_gaps = 3
      Gosub Sub_restore
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 1
'Befehl &H01 0|1
'Motorsteuerung aus /an schalten
'control off / on
'Data "1;os,Device off on;1;0,off;1,on"
      If Commandpointer = 2 Then
         If Command_b(2) < 2 Then
            If Command_b(2) = 0 Then
               Reset Controlon
               Gosub Stop_all
            Else
               Set Controlon
            End If
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 2
'Befehl &H02
'liest Antennenposition 0... 359
'read antenna position
'Data "2;ap,antenna position;1;360;lin:degree"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H02
      I2c_tx_b(2) =  High(pos_antenna)
      I2c_tx_b(3) =  Low(pos_antenna)
      I2c_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 3
'Befehl &H03 0|1
'Manual / Preset switch
'Data "3;os;1;0,manual;1,preset"
      If Commandpointer = 2 Then
         If Controlon = 1 Then
            If Command_b(2) < 2 Then
               If Command_b(2) = 0 Then
                  Gosub Stop_all
                  Preset_active = 0
               Else
                  Preset_active = 1
                  Preset_out_limits = 1
               End If
            Else
               Error_no = 4
               Error_cmd_no = Command_no
            End If
         Else
            Error_no = 7
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 4
'Befehl &H04 0 to 359
'preset Antennerichtung; kann motor im preset mode starten
'preset, real antenna direction may starts motor if preset mode
'Data "4;op,Preset Position;1;360;lin;degree"
      If Commandpointer = 3 Then
         Temp_w = Command_b(2) * 256
         'word, MSB first
         Temp_w = Temp_w + Command_b(3)
         'preset antenna direction
         If Temp_w < 360 Then
            Preset_pos_antenna = Temp_w
            Preset_pos_antenna_eeram = Preset_pos_antenna
            If Preset_pos_antenna < Antenna_limit_direction Then
               Preset_rotor = 360 -Antenna_limit_direction
               Preset_rotor = Preset_rotor + Preset_pos_antenna
            Else
               Preset_rotor = Preset_pos_antenna - Antenna_limit_direction
            End If
            If Preset_rotor < Antenna_deviation Then Preset_rotor = Antenna_deviation
            Temp_w = 359 - Antenna_deviation
            If Preset_rotor > Temp_w Then Preset_rotor = Temp_w
            Preset_out_limits = 1
            'if preset_active:start again
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 5
'Befehl &H05
'manuell startet den Motor ccw
'manual start motor ccw
'Data "5;ou,Motor ccw;1;0,idle;1,ccw"
      Preset_active = 0
      If Controlon = 1 Then
      'rule 1
         Gosub Motor_ccw_on
         If Hw_limit_detected = 1 Then Hw_limit_detected = 2
      Else
         Error_no = 0
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 6
'Befehl &H06
'manuell stoppt den Motor
'manual stops motor
'Data "6;ou,Motor stop;1;0;idle;1,stop"
      Gosub Stop_all
      Preset_active = 0
      Gosub Command_received
'
   Case 7
'Befehl &H07
'manuell startet den Motor cw
'manual start motor cw
'Data "7;ou,Motor cw;1;0,idle;1,cw"
      Preset_active = 0
      If Controlon = 1 Then
      'rule 1
         Gosub Motor_cw_on
         If Hw_limit_detected = 1 Then Hw_limit_detected = 2
      Else
         Error_no = 0
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 8
'Befehl &H08 0 to 359
'schreibt Antenna_limit_direction 0 .. 359
'write Antenna_limit_direction
'Data "8;op,Antenna_limit_direction;1;360;lin;degree"
      If Commandpointer = 3 Then
         Temp_w = Command_b(2) * 256
         'word, MSB first
         Temp_w = Temp_w + Command_b(3)
         'preset antenna direction
         '0 to 359
         If Temp_w < 360 Then
            Antenna_limit_direction = Temp_w
            Antenna_limit_direction_eeram = Antenna_limit_direction
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 9
'Befehl &H09
'liest Antenna_limit_direction
'read Antenna_limit_direction
'Data "9;as8"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H09
      I2c_tx_b(2) =  High(Antenna_limit_direction)
      I2c_tx_b(3) =  Low(Antenna_limit_direction)
      I2c_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 10
'Befehl &H0A
'liest Werte
'read values
'Data "10;aa,Values 1;b,controlon;b,Preset;b,Motor_cw;b,Motor_ccw;b,not_Limit;b,preset_limits"
      If Commandpointer = 2 Then
         If Command_b(2) < 6 Then
            I2c_tx_busy = 2
            Tx_time = 1
            Select Case Command_b(2)
                Case 0
                   I2c_tx_b(2) = Controlon
                Case 1
                   I2c_tx_b(2) = Preset_active
                Case 2
                   I2c_tx_b(2) = Motor_cw
                Case 3
                   I2c_tx_b(2) = Motor_ccw
                Case 4
                   I2c_tx_b(2) = Not_limit
                Case 5
                   I2c_tx_b(2) = Preset_out_limits
            End Select
            I2c_tx_b(1) = &H0A
            I2c_write_pointer = 3
            If Command_mode = 1 Then Gosub Print_i2c_tx
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 11
'Befehl &H0B
'liest Werte
'read values
'Data "11;aa,values 2;w,preset value;w,Ccw_correction;w.Cw_correction,w,dir_rotor;w,preset_rotor"
      If Commandpointer = 2 Then
         If Command_b(2) < 5 Then
            I2c_tx_busy = 2
            Tx_time = 1
            Select Case Command_b(2)
               Case 0
                  I2c_tx_b(2) = High(Preset_pos_antenna)
                  I2c_tx_b(3) = Low(Preset_pos_antenna)
               Case 1
                  I2c_tx_b(2) = High(ccw_0_voltage)
                  I2c_tx_b(3) = Low(ccw_0_voltage)
               Case 2
                  I2c_tx_b(2) = High(cw_360_voltage)
                  I2c_tx_b(3) = Low(cw_360_voltage)
               Case 3
                  I2c_tx_b(2) = High(Dir_rotor)
                  I2c_tx_b(3) = Low(Dir_rotor)
               Case 4
                  I2c_tx_b(2) = High(Preset_rotor)
                  I2c_tx_b(3) = Low(Preset_rotor)
            End Select
            I2c_tx_b(1) = &H0B
            I2c_write_pointer = 3
            If Command_mode = 1 Then Gosub Print_i2c_tx
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 12
'Befehl &H0C
'liest die Spannung an der ccw Grenze, Eichung (noch vor hardware Limit)
'read voltage for ccw limit, calibration (before hardware limit)
'Data "12;ku;1;0,idle;1,CCW calibration"
      Ccw_0_voltage_temp = Pos_rotator_voltage
      'voltage, should be near 1024 for ccw position
      'corrected values
      Gosub Command_received
'
   Case 13
'Befehl &H0D
'liest die Spannung an der cw Grenze, Eichung (noch vor hardware Limit)
'read voltage for cw limit, calibration (before hardware limit)
'Data "13;ku;1;0,idle;1,CW calibration"

      Cw_360_voltage_temp = Pos_rotator_voltage
      'voltage, should be near 0 for cw position  !!
      If Cw_360_voltage_temp < 100 And Ccw_0_voltage_temp > 900 Then
         Ccw_0_voltage = Ccw_0_voltage_temp
         Cw_360_voltage = Cw_360_voltage_temp
         Ccw_0_voltage_eeram = Ccw_0_voltage
         Cw_360_voltage_eeram = Cw_360_voltage
         Voltage_range_0_360 = Ccw_0_voltage - Cw_360_voltage
         'actual voltage range for 360 degree
      End If
      Gosub Command_received
'
   Case 14
'Befehl &H0E
'liest limit
'read limit
'Data "14;aa,limit value;a,Limit"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H0E
      I2c_tx_b(2) = Not_limit
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 15
'Befehl &H0F
'Motorsteuerung aus /an status lesen
'read on / off control
'Data "1;as,as1"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H09
      I2c_tx_b(2) = Controlon
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 240
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
'Data "240;ln,ANNOUNCEMENTS;145;24"
      If Commandpointer >= 3 Then
         If Command_b(2) < No_of_announcelines And Command_b(3) < No_of_announcelines Then
            I2c_tx_busy = 2
            Tx_time = 1
            Send_line_gaps = 2
            Number_of_lines = Command_b(3)
            A_line = Command_b(2)
            Gosub Sub_restore
            If Command_mode = 1 Then
               Gosub Print_i2c_tx
               While Number_of_lines > 0
                  Gosub Sub_restore
                  Gosub Print_i2c_tx
               Wend
            End If
         Else
            Error_no = 4
            Error_cmd_no = Command_no
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
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,2,{0 to 127};a,RS232,1;a,USB,1"
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
'Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,2,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
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
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;RC5 rotator control;V05.3;1;145;1;24:1-1"
'
Announce1:
'Befehl &H01 0|1
'Motorsteuerung aus /an schalten
'control off / on
Data "1;os,Device off on;1;0,off;1,on"
'
Announce2:
'Befehl &H02
'liest Antennenposition 0... 359
'read antenna position
Data "2;ap,antenna position;1;360;lin:degree"
'
Announce3:
'Befehl &H03 0|1
'Manual / Preset switch
Data "3;os;1;0,manual;1,preset"
'
Announce4:
'Befehl &H04 0 to 359
'preset Antennerichtung; kann motor im preset mode starten
'preset, real antenna direction may starts motor if preset mode
Data "4;op,Preset Position;1;360;lin;degree"
'
Announce5:
'Befehl &H05
'manuell startet den Motor ccw
'manual start motor ccw
Data "5;ou,Motor ccw;1;0,idle;1,ccw"
'
Announce6:
'Befehl &H06
'manuell stoppt den Motor
'manual stops motor
'Data "6;ou,Motor stop;1;0;idle;1,stop"
'
Announce7:
'Befehl &H07
'manuell startet den Motor cw
'manual start motor cw
Data "7;ou,Motor cw;1;0,idle;1,cw"
'
Announce8:
'Befehl &H08 0 to 359
'schreibt Antenna_limit_direction 0 ... 359
'write Antenna_limit_direction
Data "8;op,Antenna_limit_direction;1;360;lin;degree"
'
Announce9:
'Befehl &H09
'liest Antenna_limit_direction
'read Antenna_limit_direction
Data "9;as8"
'
Announce10:
'Befehl &H0A
'liest Werte
'read values
Data "10;aa,Values 1;b,controlon;b,Preset;b,Motor_cw;b,Motor_ccw;b,not_Limit;b,preset_limits"
'
Announce11:
'Befehl &H0B
'liest Werte
'read values
Data "11;aa,values 2;w,preset value;w,Ccw_correction;w.Cw_correction,w,dir_rotor;w,preset_rotor"
'
Announce12:
'Befehl &H0C
'liest die Spannung an der ccw Grenze, Eichung (noch vor hardware Limit)
'read voltage for ccw limit, calibration (before hardware limit)
Data "12;ou;1;0,idle;1,CCW calibration"
'
Announce13:
'Befehl &H0D
'liest die Spannung an der cw Grenze, Eichung (noch vor hardware Limit)
'read voltage for cw limit, calibration (before hardware limit)
Data "13;ou;1;0,idle;1,CW calibration"
'
Announce14:
'Befehl &H0E
'liest limit
'read limit
Data "14;aa,limit value;a,Limit"
'
Announce15:
'Befehl &H0F
'Motorsteuerung aus /an status lesen
'read on / off control
'Data "1;as,as1"
'
Announce16:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;ln,ANNOUNCEMENTS;145;24"
'
Announce17:                                                  '
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce18:                                                  '
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce19:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,2,{0 to 127};a,RS232,1;a,USB,1"
'
Announce20:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,2,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8N1;a,USB,1"
'
Announce21:
' - no operate command is done before Control_on is set
Data "R !$3 !$5 !$7 IF $15=0"
'
Announce22:
' - motor at limit will switch off , no need for logic device to send switch off command
Data "R $6 IF $14=1"
'
Announce23:
'No Preset If hardwarelimit
Data "R !$3 IF $14=1"