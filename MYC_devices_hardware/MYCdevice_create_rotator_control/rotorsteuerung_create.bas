'-----------------------------------------------------------------------
'name : rotorsteuerung_create_bascom.bas
'Version V06.1, 201200430
'purpose : Programm for control a Create RC5 Rotator
'Can be used with hardware rotorsteuerung_create V04.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,10 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.10\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
'-----------------------------------------------------
' Inputs / Outputs : see file __config.bas
'
'------------------------------------------------------
'Missing/errors:
'
'----------------------------------------------------
$regfile = "m328pdef.dat"
'for ATMega328
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.10\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 2
Const No_of_announcelines = 24
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.10\_Constants_and_variables.bas"
'
Const Ccw_limit_default = 1008
'25 deg (out of400) before end -> 6,25% -> 6,25 % * 1024 = 64
'ccw has high voltage, cw low voltage
'those are my values
Const Cw_limit_default = 49
Const Antenna_deviation = 5
'during preset motor will not start if antenna is within + - Antenna_deviation
'in degree
Const Number_of_off_limits = 10
Const Antenna_limit_direction_default = 180
'
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
'----------------------------------------------------
$include "common_1.10\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.10\_Config.bas"
'
'----------------------------------------------------
$include "common_1.10\_Main.bas"
'
'----------------------------------------------------
$include "common_1.10\_Loop_start.bas"
'
'----------------------------------------------------
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
$include "common_1.10\_Main_end.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.10\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.10\_Init.bas"
'
'----------------------------------------------------
$include "common_1.10\_Subs.bas"
'
'----------------------------------------------------
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
'
$include "_Commands.bas"
$include "common_1.10\_Commands_required.bas"
'
$include "common_1.10\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'