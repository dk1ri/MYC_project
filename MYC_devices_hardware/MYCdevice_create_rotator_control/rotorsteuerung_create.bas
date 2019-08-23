'-----------------------------------------------------------------------
'name : rotorsteuerung_create_bascom.bas
'Version V06.0, 20190807
'purpose : Programm for control a Create RC5 Rotator
'Can be used with hardware rotorsteuerung_create V04.0 by DK1RI
'

'
' ---> Description / name of program
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,7 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.7\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
'-----------------------------------------------------
' Inputs /Outputs : see file __config
' For announcements and rules see Data section at the end
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'
'----------------------------------------------------
$regfile = "m328pdef.dat"
'for ATMega328
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.7\_Processor.bas"
'
'----------------------------------------------------
'
' 8: for 8/32pin, ATMEGAx8; 4 for 40/44pin, ATMEGAx4 packages
' used for reset now: different portnumber of SPI SS pin
Const Processor = "8"
Const Command_is_2_byte = 0
'1...127:
Const I2c_address = 2
Const No_of_announcelines = 24
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
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
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.7\_Config.bas"
'
'----------------------------------------------------
' procedures at start
'
'----------------------------------------------------
$include "common_1.7\_Main.bas"
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
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
'----------------------------------------------------
$include "common_1.7\_Serial.bas"
'----------------------------------------------------
$include "common_1.7\_I2c.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.7\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.7\_Init.bas"
'
'----------------------------------------------------
$include "common_1.7\_Subs.bas"
$include "common_1.7\_Sub_reset_i2c.bas"
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
'
'----------------------------------------------------
   $include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
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
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H02
      Tx_b(2) =  High(pos_antenna)
      Tx_b(3) =  Low(pos_antenna)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
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
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H09
      Tx_b(2) =  High(Antenna_limit_direction)
      Tx_b(3) =  Low(Antenna_limit_direction)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 10
'Befehl &H0A
'liest Werte
'read values
'Data "10;aa,Values 1;b,controlon;b,Preset;b,Motor_cw;b,Motor_ccw;b,not_Limit;b,preset_limits"
      If Commandpointer = 2 Then
         If Command_b(2) < 6 Then
            Tx_busy = 2
            Tx_time = 1
            Select Case Command_b(2)
                Case 0
                   Tx_b(2) = Controlon
                Case 1
                   Tx_b(2) = Preset_active
                Case 2
                   Tx_b(2) = Motor_cw
                Case 3
                   Tx_b(2) = Motor_ccw
                Case 4
                   Tx_b(2) = Not_limit
                Case 5
                   Tx_b(2) = Preset_out_limits
            End Select
            Tx_b(1) = &H0A
            Tx_write_pointer = 3
            If Command_mode = 1 Then Gosub Print_tx
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
            Tx_busy = 2
            Tx_time = 1
            Select Case Command_b(2)
               Case 0
                  Tx_b(2) = High(Preset_pos_antenna)
                  Tx_b(3) = Low(Preset_pos_antenna)
               Case 1
                  Tx_b(2) = High(ccw_0_voltage)
                  Tx_b(3) = Low(ccw_0_voltage)
               Case 2
                  Tx_b(2) = High(cw_360_voltage)
                  Tx_b(3) = Low(cw_360_voltage)
               Case 3
                  Tx_b(2) = High(Dir_rotor)
                  Tx_b(3) = Low(Dir_rotor)
               Case 4
                  Tx_b(2) = High(Preset_rotor)
                  Tx_b(3) = Low(Preset_rotor)
            End Select
            Tx_b(1) = &H0B
            Tx_write_pointer = 3
            If Command_mode = 1 Then Gosub Print_tx
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
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H0E
      Tx_b(2) = Not_limit
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 15
'Befehl &H0F
'Motorsteuerung aus /an status lesen
'read on / off control
'Data "1;as,as1"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H09
      Tx_b(2) = Controlon
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
'-----------------------------------------------------
$include "common_1.7\_Command_240.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_252.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_253.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_254.bas"
'
'-----------------------------------------------------
$include "common_1.7\_Command_255.bas"
'
'-----------------------------------------------------
$include "common_1.7\_End.bas"
'
' ---> Rules announcements
Announce0:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;RC5 rotator control;V06.0;1;145;1;24:1-1"
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
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,2,{0 to 127};a,SERIAL,1"
'
Announce20:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,2,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8N1"
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