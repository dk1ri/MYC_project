'-----------------------------------------------------------------------
'name : rotorsteuerung_create.bas
'Version V03.1, 20160104
'purpose : Programm for control a Create RC5 Rotator
'Can be used with hardware rotorsteuerung_create V01.5 by DK1RI
'The Programm supports the MYC protocol
'
'micro :  mega16
'Fuse Bits :
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
'JTAG disabled
$PROG &HFF,&HC6,&HDF,&HF9' generated. Take care that the chip supports all fuse bytes.
'commercial addon needed : no
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no older rights are affected, this programm can be used
'under GPL (Gnu public licence)
'-----------------------------------------------------------------------
'Templates:
'I2c_slave_template V02.0
'-----------------------------------------------------------------------
'Used Hardware:
' I/O: I2C
' Inputs: Limit: PinC.2, Reset: PinD.7
' ADC Inputs: Rotator-position(ADC1),
' Outputs : motor_cw: B.2, motor_ccw: B.1, control_on: B.0
'
'-----------------------------------------------------------------------
' For announcements and rules see Data section at the end
' Interface to MYC commandrouter via I2C
' Device is I2C slave
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'$regfile = "m88def.dat"                                     ' for ATmega8
$regfile = "m328pdef.dat"                                   ' for ATmega 328
$crystal = 20000000                                         ' used crystal frequency
'$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack                            ' generated. Take care that the chip supports all fuse bytes.
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space
' Simulation!!!!
' $sim
'
'**************** libs
'use byte library for smaller code
$lib "mcsbyte.lbx"
$lib "i2c_twi.lbx"
'
'**************** Variables
Const Lf = 10
Const Stringlength = 254                                    'that is maximum
Const Const Command_length = 20
Const Cmd_watchdog_time = 65000                             'Number of main loop before command reset
Const No_of_announcelines = 23                              'announcements start with 0 -> minus 1
'
Dim First_set As Eram Byte                                 'first run after reset
Dim L As Byte                                               'Temps and local
Dim I As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temp_w As Word
Dim Temp_single As Single
Dim Temps As String * 20
Dim Temps_b(20) As Byte At Temps Overlay
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
' for Rotatorcontrol:
Dim Preset_active As Byte
Dim Preset_active_eeram As Word
Dim Preset_pos_antenna As Word                                 'presetposition of  antennadirection, North=0, degree
Dim Preset_pos_antenna_eeram As Word
Dim Preset_pos_voltage As Word
Dim Rotator_offset As Word                                  'direction of limit of rotatorat North=0degree
Dim Rotator_offset_eeram As Eram Word                      'in eeram
Dim Antenna_offset As Word                                  'antennadirection, if rotator is alimit. North=0degree
Dim Antenna_offset_eeram As Eram Word                      'in eeram
Dim Pos_rotator_voltage As Word                             'actual Rotatorposition, voltage
Dim Pos_real_rotator As Word                                'rotator position in degree without offset
Dim Pos_rotator As Word                                     'rotator position in degree with offset
Dim Pos_temp As Word
Dim Pos_temp2 As Word
Dim Pos_antenna As Word                                     'actual antennadirection , North =0
Dim Pos_antenna_s As Single                                 'as single
Dim Ccw_0_voltage As Word                                   'ccw adc value at calibration
Dim Ccw_0_voltage_temp As Word
Dim Ccw_0_voltage_eeram As Eram Word
Dim Cw_360_voltage As Word
Dim Cw_360_voltage_temp As Word                             'cw adc value at calibration  '
Dim Cw_360_voltage_eeram As Eram Word
Dim Voltage_range_0_360 As Word                             'difference of the above
Dim Hw_limit_detected As Byte                               '0: not detected 1: detected 2: move rotator manually
Dim I2C_name As Byte
Dim I2C_name_eeram As Eram Byte
'
Const Ccw_limit_default = 953                               '25 deg (out of400) before end -> 6,25% -> 6,25 % * 1024 = 64
                                                             'ccw has high voltage, cw low voltage
                                                             'those are my values
Const Cw_limit_default = 55
Const Rotator_deviation = 15                                'during preset motor will not start within this range: 15 means 3 dergree
'
'**************** Config / Init
Config Pinc.2 = Input
Portc.2 = 1
Not_limit Alias Pinc.2                                      ' Limit  0 activ
Config Pind.7 = Input
Portd.7 = 1
Resetpin Alias Pind.7
'
Config Portb.0 = Output
Controlon Alias Portb.0
Config Portb.1 = Output
Motor_ccw Alias Portb.1
Config Portb.2 = Output
Motor_cw Alias Portb.2
'
Config Sda = Portc.4                                        'must !!, otherwise error
Config Scl = Portc.5
'
Config Adc = Single , Prescaler = Auto , Reference = Avcc
'
Config Watchdog = 2048                                      '
'
'****************Interrupts
' not used
' Enable INTERRUPTS
' serialin not buffered!!
' serialout not buffered!!!
'
'**************** Main ***************************************************
'
If First_set <> 5 Then Gosub Reset_
'
If Resetpin = 0 Then Gosub Reset_
'
Gosub Init
'
Slave_loop:
Start Watchdog                                             'Loop must be less than 512 ms
'
Gosub Cmd_watch
'
Pos_rotator_voltage = Getadc(1)
Gosub Calculate_pos_rotator

If Controlon = 1 Then
'
'check rotator 0 / 360 degree limit
   If Pos_rotator_voltage < Cw_360_voltage Then             'Cw_360_voltage is "low" voltage
      If Motor_cw = 1 Then
         Gosub Stop_all
      End If
   End If
   If Pos_rotator_voltage > Ccw_0_voltage Then              'Ccw_0_voltage is "high" voltage
      If Motor_ccw = 1 Then
         Gosub Stop_all
      End If
   End If
'
'check Hw-limit                                              'not at limit
   If Not_limit = 1 Then
      Hw_limit_detected = 0
   Else                                                      'Hw_limit_detected 0: no limit. 1: detected, stop motor, 2: move out of limit
      Select Case Hw_limit_detected
         Case 2
            Stop Watchdog                                   'move  rotator started                                                       'move  rotator started
            I = 1
            While I < 10
               Waitms 500
               If Not_limit = 0 Then
                  Incr I
                  If I = 10 Then                            'stop after 5 seconds moving wrong direction
                     Gosub Stop_all
                     Hw_limit_detected = 1
                  End If
               Else                                          'No more limit detected
                  I = 10
                  Hw_limit_detected = 0
               End If
            Wend
            Start Watchdog
         Case 0                                              'limit detected first time: stop immediate
            Hw_limit_detected = 1
            Gosub Stop_all
            If Preset_active = 1 Then                       'should nor happen
               Preset_active = 0
               Preset_active_eeram =0
            End If
         Case 1                                              'stop, if other than move command started rotator
            Gosub Stop_all
      End Select
   End If                                               '
'
'checks during motor preset
   If Preset_active = 1 Then
      If Pos_antenna = Preset_pos_antenna Then
         Gosub Stop_all
      Else
         Pos_temp = Preset_pos_voltage + Rotator_deviation
         Pos_temp2 = Preset_pos_voltage - Rotator_deviation
         If Pos_rotator_voltage > Pos_temp Then
            Gosub Motor_cw_on
         Else
            If Pos_rotator_voltage < Pos_temp2 Then
               Gosub Motor_ccw_on
            End If
         End If
      End If
   End If
End If
'
'I2C
'In a MYC System, this interface behaves like a device on a I2C Bus.
Twi_control = Twcr And &H80                                 'twint set?
If Twi_control = &H80 Then                                  'twsr 60 -> start, 80-> daten, A0 -> stop
   Twi_status = Twsr
   Twi_status = Twi_status And &HF8
'slave send:
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
      If I2c_pointer <= I2c_length Then
         Twdr = I2c_tx_b(i2c_pointer)
         Incr I2c_pointer
      Else                                                   'last Byte, String finished
         If Announceline < No_of_announcelines Then          'multiple lines to send
            Cmd_watchdog = 0                                  'command may take longer
            A_line = Announceline
            Gosub Sub_restore
            Incr Announceline
            Twdr = I2c_tx_b(i2c_pointer)
            Incr I2c_pointer
         Else
            Twdr = &H00
            Announceline = 255
         End If                                              'for tests
      End If
   End If
'I2C receives data and and interpet as commands.
'slave receive:
   If Twi_status = &H80 Or Twi_status = &H88 Then
      Tempb = Twdr
      If Commandpointer <= Stringlength Then
         Command_b(commandpointer) = Tempb
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1                                  'start watchdog
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
Dev_number = 1                                                'unsigned , set at first use                                 'obviously not yet set
Dev_number_eeram = Dev_number                                 'default values
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 4
Adress_eeram = Adress
I2C_name="1"
I2C_Name_eeram = I2C_name
'
Rotator_offset = 180                                          'standard of compass display is South
Rotator_offset_eeram = Rotator_offset
Antenna_offset = 0                                          'standard of compass display is South
Antenna_offset_eeram = Antenna_offset
Ccw_0_voltage = Ccw_limit_default                             'my values
Ccw_0_voltage_eeram = Ccw_0_voltage
Cw_360_voltage = Cw_limit_default
Cw_360_voltage_eeram = Cw_360_voltage
Preset_pos_antenna = 0                                           'north
Preset_pos_antenna_eeram = Preset_pos_antenna
Preset_active = 0                                             'manual
Preset_active_eeram = Preset_active
Return
'
Init:
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram                                       'No Error
Cmd_watchdog = 0
Announceline = 255
Command_no = 1                                              'no multiple announcelines
I2c_tx = String(stringlength , 0)                          'will delete buffer and restart ponter
I2c_length = 0                                              'should not be 0 at any time
I2c_pointer = 1
Last_error = " No Error"
Error_no = 255
L = 0
Commandpointer = 1
'
Ccw_0_voltage = Ccw_0_voltage_eeram
Cw_360_voltage = Cw_360_voltage_eeram
Voltage_range_0_360 = Ccw_0_voltage - Cw_360_voltage        'actual voltage range for 360 degree
Rotator_offset = Rotator_offset_eeram
Antenna_offset=Antenna_offset_eeram
Preset_pos_antenna = Preset_pos_antenna_eeram
Preset_active = Preset_active_eeram
I2C_name= I2C_name_eeram
Hw_limit_detected = 0
Gosub Command_received
Gosub Command_finished
Gosub Stop_all
Gosub Calculate_Preset_pos_voltage
Return
'
Cmd_watch:
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong coomands will be deleted
If Cmd_watchdog > Cmd_watchdog_time Then                   'one loop without command finishes
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
   Case 4
      Last_error = ":parameter error: "
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
'I2cinit                                                    'may be not neccessary
'Config Twi = 100000                                        ' 100KHz
Twsr = 0                                                    ' status und Prescaler auf 0
Twdr = &HFF                                                 ' default
Twar = Adress                                               ' Slaveadress
Twcr = &B01000100
Return
'
Command_received:
Commandpointer = 1
Command = String(stringlength , 0)                         'no multiple announcelines, if not finished
Cmd_watchdog = 0
Incr Command_no
Return
'
I2c_reset:
I2c_tx = String(stringlength , 0)                          'will delete buffer and restart ponter
I2c_pointer = 1
Return
'
Sub_restore:
Error_no = 255                                              'no error
I2c_tx = String(stringlength , 0)                          'will delete buffer , read appear 0 at end ???
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
   Case Else
      Error_no = 0
      Gosub Last_err
End Select
If Error_no = 255 Then
   Read I2c_tx
   I2c_length = Len(i2c_tx)
   For Tempb = I2c_length To 1 Step -1                     'shift 1 pos right
      I2c_tx_b(tempb + 1) = I2c_tx_b(tempb)
   Next Tempb
   I2c_tx_b(1) = I2c_length
   Incr I2c_length                                         'complte length of string
End If
Return
'                                                           'Rotator and Antenna
Calculate_pos_rotator:
If Pos_rotator_voltage >= Ccw_0_voltage Then
   Pos_real_rotator = 0
   Pos_rotator = Rotator_offset
   Pos_antenna = Antenna_offset + Pos_antenna
   If Pos_antenna > 359 Then Pos_antenna = Pos_antenna - 360
Else
   If Pos_rotator_voltage <= Cw_360_voltage Then
      Pos_real_rotator = 360
      Pos_rotator = Rotator_offset
      Pos_antenna = Antenna_offset + Rotator_offset
      If Pos_antenna > 359 Then Pos_antenna = Pos_antenna - 360
   Else
      Temp_single = Ccw_0_voltage - Pos_rotator_voltage     'subtract the 0 value
      Temp_single = Temp_single * 360
      Temp_single = Temp_single / Voltage_range_0_360
      Pos_real_rotator = Temp_single                        'real rotator position
      Pos_rotator = Pos_real_rotator + Rotator_offset
      If Pos_rotator > 359 Then Pos_rotator = Pos_rotator - 360  'rotator position relative to north
      Pos_temp = 360 - Antenna_offset
      Pos_antenna = Pos_rotator + Pos_temp
      If Pos_antenna > 359 Then Pos_antenna = Pos_antenna - 360   'same for antenna
   End If
End If
Return
'
Calculate_Preset_pos_voltage:
   If Preset_pos_antenna > Antenna_offset Then
      Pos_temp = Preset_pos_antenna - Antenna_offset
   Else
      Pos_temp = Preset_pos_antenna + 360
      Pos_temp = Pos_temp - Antenna_offset
   End If
   If Pos_temp > Rotator_offset Then
      Pos_temp = Pos_temp - Rotator_offset
   Else
      Pos_temp = Pos_temp + 360
      Pos_temp = Pos_temp - Rotator_offset
   End If                                                     'real position of ratator for Preset_pos_rotator
      Temp_single = Pos_temp * Voltage_range_0_360
      Temp_single = Temp_single / 360
      Temp_single = Ccw_0_voltage - Temp_single
      Preset_pos_voltage = Temp_single                     'Word now
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
'     '
Slave_commandparser:
   Select Case Command_b(1)
      Case 0
'Befehl &H00               basic annoumement wird gelesen
'                          basic announcement is read
'Data "0;m;DK1RI;RC5 rotator control;V03.1;1;120;15;23"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl &H01 0|1           Motorsteuerung aus /an schalten
'                          control of / on
'Data "1;os,Device off on;0,off;1,on"
      If Commandpointer = 2 Then
         Select Case Command_b(2)
            Case 1
               Set Controlon
            Case 0
               Reset Controlon
               Gosub Stop_all
            Case Else
               Error_no = 4
               Gosub Last_err
         End Select
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 2
'Befehl &H02               liest Antennenposition
'                          read antenna rposition
'Data "2;ap,antenna position,359;lin:degree"
      Gosub I2c_reset
      I2c_tx_b(1) = High(pos_antenna)
      I2c_tx_b(2) = Low(pos_antenna)
      I2c_length = 2
      Gosub Command_received
'
      Case 3
'Befehl &H03 0|1           Manual / Preset switch
'                          Manual / Preset switch
'Data "3;os;0,manual;1,preset"
   If Commandpointer = 2 Then
      If Controlon = 1 Then
         Select Case Command_b(2)
            Case 1
               Preset_active = 1
               Preset_active_eeram = Preset_active
            Case 0
               Gosub Stop_all
               Preset_active = 0
               Preset_active_eeram = Preset_active
            Case Else
               Error_no = 4
               Gosub Last_err
         End Select
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
'Befehl &H04 0 to 359      preset Antennerichtung; kann motor im prset mode starten
'                          preset, real antenna direction may starts motor if preset mode
'Data "4;op,Preset Position;359;lin;degree"
      If Commandpointer = 3 Then
         Temp_w = Command_b(2) * 256                        'word, MSB first
         Temp_w = Temp_w + Command_b(3)                     'preset antenna direction
         If Temp_w < 361 Then
            Preset_pos_antenna = Temp_w
            Preset_pos_antenna_eeram = Preset_pos_antenna
            Gosub Calculate_Preset_pos_voltage
         Else
            Error_no = 4
            Gosub Last_err
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
      Case 5
'Befehl &H05               manuell startet den Motor ccw
'                          manual start motor ccw
'Data "5;ou,Motor ccw;0;1,ccw"
      Preset_active = 0
      If Controlon = 1 Then                                 'rule 1
         Gosub Motor_ccw_on
         If Hw_limit_detected = 1 Then Hw_limit_detected = 2
      Else
         Error_no = 0
         Gosub Last_err
      End If
      Gosub Command_received
'
      Case 6
'Befehl &H06               manuell stoppt den Motor
'                          manual stops motor
'Data "6;ou,Motor stop;0;1,stop"
         Gosub Stop_all
         Preset_active = 0
         Gosub Command_received
'
      Case 7
'Befehl &H07               manuell startet den Motor cw
'                          manual start motor cw
'Data "7;ou,Motor cw;0;1,cw"
      Preset_active = 0
      If Controlon = 1 Then                                'rule 1
         Gosub Motor_cw_on
         If Hw_limit_detected = 1 Then Hw_limit_detected = 2
      Else
         Error_no = 0
         Gosub Last_err
      End If
      Gosub Command_received
'
      Case 8
'Befehl &H08               schreibt Rotoroffset
'                          write Rotatoroffset
'Data "8;op,Rotatoroffset;359;lin;degree"
      If Commandpointer = 3 Then
         Temp_w = Command_b(2) * 256                        'word, MSB first
         Temp_w = Temp_w + Command_b(3)                     'preset antenna direction
         If Temp_w < 361 Then
            Rotator_offset = Temp_w
            Rotator_offset_eeram = Rotator_offset
            Gosub Calculate_Preset_pos_voltage
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
'Befehl &H09               schreibt Antennenoffset
'                          write antennaoffset
'Data "9;op,antennaoffset;359;lin;degree"
      If Commandpointer = 3 Then
         Temp_w = Command_b(2) * 256                        'word, MSB first
         Temp_w = Temp_w + Command_b(3)                     'preset antenna direction
         If Temp_w < 361 Then
            Antenna_offset = Temp_w
            Antenna_offset_eeram = Antenna_offset
            Gosub Calculate_Preset_pos_voltage
         Else
            Error_no = 4
            Gosub Last_err
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
      Case 10
'Befehl &H0A               liest Werte
'                          read values
'Data "10;aa,Values 1;a;controlon;a,Preset;a,Motor_cw;a,Motor_ccw;a,Limit"
         Gosub I2c_reset
         I2c_tx_b(1) = Controlon
         I2c_tx_b(2) = Preset_active
         I2c_tx_b(3) = Motor_cw
         I2c_tx_b(4) = Motor_ccw
         I2c_tx_b(5) = Not_limit
         I2c_length = 5
         Gosub Command_received
'
      Case 11
'Befehl &H0B               liest Werte
'                          read values
'Data "11;aa,values 2;w,rotator_offset;w,antenna offset;w,preset value;w,Ccw_correction;w,Cw_correction"
         Gosub I2c_reset
         I2c_tx_b(1) = High(rotator_offset)
         I2c_tx_b(2) = Low(rotator_offset)
         I2c_tx_b(3) = High(antenna_offset)
         I2c_tx_b(4) = Low(antenna_offset)
         I2c_tx_b(5) = High(Preset_pos_antenna)
         I2c_tx_b(6) = Low(Preset_pos_antenna)
         I2c_tx_b(7) = High(ccw_0_voltage)
         I2c_tx_b(8) = Low(ccw_0_voltage)
         I2c_tx_b(9) = High(cw_360_voltage)
         I2c_tx_b(10) = Low(cw_360_voltage)
         I2c_length = 10
         Gosub Command_received
'
   Case 12
'Befehl &H0C               liest die Spannung an der ccw Grenze, Eichung (noch vor hardware Limit) , normalerweise Antenne nach Nord
'                          read voltage for ccw limit, calibration (before hardware limit, usually antenna north)
'Data "12;ou;0,idle;1,CCW calibration"
      Ccw_0_voltage_temp = Pos_rotator_voltage                      'voltage, should be near 1024 for ccw position
      Gosub Command_received
'
   Case 13
'Befehl &H0D               liest die Spannung an der cw Grenze, Eichung (noch vor hardware Limit) , normalerweise Antenne nach Nord
'                          read voltage for cw limit, calibration (before hardware limit, usually antenna north)
'Data "13;ou;0,idle;1,CW calibration"

      Cw_360_voltage_temp = Pos_rotator_voltage             'voltage, should be near 0 for cw position  !!
      If Cw_360_voltage_temp < 100 And Ccw_0_voltage_temp > 900 Then
         Ccw_0_voltage = Ccw_0_voltage_temp
         Cw_360_voltage = Cw_360_voltage_temp
         Ccw_0_voltage_eeram = Ccw_0_voltage
         Cw_360_voltage_eeram = Cw_360_voltage
         Voltage_range_0_360 = Ccw_0_voltage - Cw_360_voltage  'actual voltage range for 360 degree
      End If
      Gosub Command_received
'
      Case 14
'Befehl &H0E               liest limit
'                          read limit
'Data "14;aa,limit value;a,Limit"
         I2c_tx = String(stringlength , 0)                 'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = Not_limit
         I2c_length = 1
         Gosub Command_received
'
      Case 240
'Befehl &HF0 0-13,
'            253,254 255   announcement aller Befehle lesen
'                          read announcement lines
'Data "240;am,ANNOUNCEMENTS;120;23"
         If Commandpointer = 2 Then
            Select Case Command_b(2)
               Case 253:
                  A_line = 19
                  Announceline = 20
                  Gosub Sub_restore
               Case 254
                  A_line = 0
                  Announceline = 1
                  Gosub Sub_restore
               Case 255                                    'so more lines will be transmitted
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
'Befehl &HFC               Liest letzen Fehler
'                          read last error
'Data "252;aa,LAST ERROR;20,last_error"
         I2c_tx = String(stringlength , 0)                 'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = 1                                    'so 1st byte <> 0!!
         Temps = Str(command_no)
         I2c_length = Len(temps)
         For Tempb = 1 To I2c_length                       'leave space for length
            I2c_tx_b(tempb + 1) = Temps_b(tempb)
         Next Tempb
         Incr I2c_length                                   'because of 1 byte with length
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
'Befehl &HFD               geraet aktiv antwort
'                          Life signal
'Data "253;aa,MYC INFO;b,&H04,BUSY"
         I2c_tx = String(stringlength , 0)                 'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = 4                                    'no info
         I2c_length = 1
         Gosub Command_received
'
      Case 254
'Befehl &HFE <n> <n>       Individualisierung schreiben
'                          write indivdualization
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,2"
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
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,2"
        If Commandpointer = 2 Then
            I2c_tx = String(stringlength , 0)              'delete buffer and restart ponter
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
                  I2C_tx="{001}"
                  I2C_tx_b(2) = I2C_name
                  I2c_length = 2
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
Return
'
'==================================================
'
End
'
'announce text
'
Announce0:                                                  'Slave
'Befehl &H00               basic annoumement wird gelesen
'                          basic announcement is read
Data "0;m;DK1RI;RC5 rotator control;V03.1;1;120;15;23"
'
Announce1:
'Befehl &H01 0|1           Motorsteuerung aus /an schalten
'                          control of / on
Data "1;os,Device off on;0,off;1,on"
'
Announce2:
'Befehl &H02               liest Antennenposition
'                          read antenna rposition
Data "2;ap,antenna position,359;lin:degree"
 '
Announce3:
'Befehl &H03 0|1           Manual / Preset switch
'                          Manual / Preset switch
Data "3;os;0,manual;1,preset"
'
Announce4:
'Befehl &H04 0 to 359      preset Antennerichtung; kann motor im prset mode starten
'                          preset, real antenna direction may starts motor if preset mode
Data "4;op,Preset Position;359;lin;degree"
'
Announce5:
'Befehl &H05               manuell startet den Motor ccw
'                          manual start motor ccw
Data "5;ou,Motor ccw;0;1,ccw"
'
Announce6:
'Befehl &H06               manuell stoppt den Motor
'                          manual stops motor
Data "6;ou,Motor stop;0;1,stop"
'
Announce7:
'Befehl &H07               manuell startet den Motor cw
'                          manual start motor cw
Data "7;ou,Motor cw;0;1,cw"
'
Announce8:
'Befehl &H08               schreibt Rotoroffset
'                          write Rotatoroffset
Data "8;op,Rotatoroffset;359;lin;degree"
'
Announce9:
'Befehl &H09               schreibt Antennenoffset
'                          write antennaoffset
Data "9;op,antennaoffset;359;lin;degree"
'
Announce10:
'Befehl &H0A               liest Werte
'                          read values
Data "10;aa,Values 1;a;controlon;a,Preset;a,Motor_cw;a,Motor_ccw;a,Limit"
'
Announce11:
'Befehl &H0B               liest Werte
'                          read values
Data "11;aa,values 2;w,rotator_offset;w,antenna offset;w,preset value;w,Ccw_correction;w,Cw_correction"
'
Announce12:
'Befehl &H0C               liest die Spannung an der ccw Grenze, Eichung (noch vor hardware Limit) , normalerweise Antenne nach Nord
'                          read voltage for ccw limit, calibration (before hardware limit, usually antenna NORTH)
Data "12;ou;0,idle;1,CCW calibration"
'
Announce13:
'Befehl &H0D               liest die Spannung an der cw Grenze, Eichung (noch vor hardware Limit) , normalerweise Antenne nach Nord
'                          read voltage for cw limit, calibration (before hardware limit, usually antenna north)
Data "13;ou;0,idle;1,CW calibration"
'
Announce14:
'Befehl &H0E               liest limit
'                          read limit
Data "14;aa,limit value;a,Limit"
'
Announce15:
'Befehl &HF0 0-13,
'            253,254 255   announcement aller Befehle lesen
'                          read announcement lines
Data "240;am,ANNOUNCEMENTS;120;23"
'
Announce16:                                                 '
'Befehl &HFC               Liest letzen Fehler
'                          read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce17:                                                 '
'Befehl &HFD               geraet aktiv antwort
'                          Life signal
Data "253;aa,MYC INFO;b,&H04BUSY"
'
Announce18:
'Befehl &HFE <n> <n>       Individualisierung schreiben
'                          write indivdualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,2"
'
Announce19:
'Befehl &HFF <n>           Individualisierung lesen
'                          read indivdualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,2"
'
Announce20:
' - no operate command is done before Control_on is set
Data "R !$2 !$4 !$6 IF $1=0"
'
Announce21:
' - motor at limit will switch off , no need for logic device to send switch off command
Data "R $5 IF $13=1"
'
Announce22:
'No Preset If hardwarelimit
Data "R !$2 IF $13>0"