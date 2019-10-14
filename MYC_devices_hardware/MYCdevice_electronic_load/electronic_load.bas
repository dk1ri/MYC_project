'-----------------------------------------------------------------------
'name : electronic_load.bas
'Version V04.0, 20191014
'purpose : This is a electronic load for 7 fets IRFP150
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware electronic_load V04.1 by DK1RI
'
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory common_1,7 with includefiles must be copied to the directory of this file!
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
' SPI
'-----------------------------------------------------
' Inputs /Outputs : see file __config
' For announcements and rules see Data section at the end
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'
'Something about the programm design:
'This programm workes with 1 to 7 FETs IRFP150:
'Vmax = 90V (100V)
'Imax = 25.6A   (30A at 100 degC)
'Ptot = 200W
'Ron = 50mOhm
'so the minimum voltage to be applied and will work under all conditions is
' (10mOhm resistor for measuring)
' (50 + 10 mOhm) * 30A = 1,8V
' If current (per FET) is lower, lower voltage can be used.
'
'Most internal calculation are in V, A and W and Ohm and use single variables.

'The resolution used by commands is 1mV, 1mA, 1mW and 1mOhm
'
'The board uses the ADS1115 chip (16Bit) but 15bit are used only (no negative values of the ADC)
'
'The el load will not switch on for voltages below 400mV.
'
'The full scale range of the AD Converter is .256V. This limits the current to 25.6A with 10mOhm resistor.
'The current resolution is 25.6A / 32767 = 0.78mA
'
'The voltage resolution is nominal 3mV ( 90V / 32700)
'
'The maximum of the required resistor is given by the max voltage and the minimum current:
' 90V / 0.7mA ~ 120kOhm
'The required resistor has a range from 1 to 120.000.00 mOhm
'
'The usable maximum power depends on cooling and may be modified.
'default power is V = 350W
'default power per FET is 150W (<Ptot)
'Absolute maximimum (default) is 1050W with 7 IRFP150.
'This is the maximum required power range.
'Actual power must never exceed either of these values.
'
'To improve accuracy all available FETs are used always.
'
'For regulation the current is measured.
'requiredI, requiredR and requiredP requiredU are valid values all the time and vary with change of voltage/current
'
'There are two phases: startup and regulation.
'During startup the FET voltage is increased by a specific value for all FETs in turn.
' After the first overshot the Gate voltage is increased /decreased for  the FET with the current most away from the
'required value as required.
'The check of current / power for overload is done on a per FET base after each measurement.
'
'Each ADC handles two chanals. The input of the ADC must be configured for each chanal, and after a wait time
'the data can be read.
' After starting measurement:
'- configure ACD (MUX) for chanal 0, start timer1
'- after Timer1 = 32 (860SPS, start), 350 (128SPS, regulation):
'- read data, configure ACD (MUX) for chanal 1, start timer1 again
'- after Timer1 = 32 (860SPS, start), 350 (128SPS, regulation):
'- read data,
'- analyze data
'- configure ACD (MUX) for chanal 0, start timer1 again
' ...
'
'----------------------------------------------------
$regfile = "m328pdef.dat"

'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.7\_Processor.bas"
'
$initmicro
'----------------------------------------------------
'
Const Processor = "4"
Const Command_is_2_byte = 0
'1...127:
Const I2c_address = 42
Const No_of_announcelines = 49
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'If other FETs are used or less then 7 FETs are installed, the constants must be modified.
'Modification of announcements may be necessary as well.
'
'el load specific Constants:
Const Max_power_default = 150.0
'50W per fet, this must be a save value
Const Max_cooling = 300.0
'limit by cooling
Const Max_voltage = 90.0
'90V
Const Max_current = 26
'
Const Ad_resolution = 32767
' 15Bit ads1115
' 32767 will result in 25,6A
' I = Measured * Correction_i
Const Calc_i_ = Max_current / Ad_resolution
' 32797 should result in 90V
' U = Measured * Correction_u
Const Correction_i_default = 1.0
Const Calc_u_ = Max_voltage / Ad_resolution
Const Correction_u_default = 1.0
'
Const On_off_time_default = 40000
'about 1 s
Const On_off_time_default_ = On_off_time_default / 100
'is used by the command
'
Const Minimum_voltage_ = 0.4
'400mV necessary to switch on the load
Const Minimum_voltage_v = 0.001
'for volgae mode
'
Const Da_resolution = 4095
'for MCP4921 12 Bit
Const Dac_start = &H0DFF
' This speed up approach to first overshot, should result in a few mA
'
Const Dac_adder = &H30
'DAC config, to be added to the high byte
'bit 15: 0 DAC activ
'bit 14: 0 unbuffered (Vref = 5V)
'bit 13: 1 Gain 1
'bit 12: 1 output enabled
Const Fet_voltage_sub = 10
'change of AD output per step at startup
Const Active_fets_default = &B01111111
'Fet1 is LSB, all Fets available
Const Hyst_default = 0.001
' 1%
Const Hyst_on_default = 0
'
' connected to SDA
Const Adc_adress_F1_U = &B10010100
' connected to SCL
Const Adc_adress_F3_F2 = &B10010110
' connected to GND
Const Adc_adress_F5_F4 = &B10010000
' connected to VS
Const Adc_adress_F7_F6 = &B10010010
'
Const Adc_config_01 = &B00001110
Const Adc_config_23 = &B00111110
'
' -,  , 860SPS, 0,256V, continous conversion mode
Const Adc_config_860 = &B11100011
Const Adc_config_475 = &B11000011
Const Adc_config_250 = &B10100011
Const Adc_config_128 = &B10000011
'
Const Adc_data_register = &H00
Const Adc_control_register = &H01
' in continous conversion mode we must wait two conversion cycles to get the result
'860 SPS:
Const Timer1_860 = 44     ' > 2,3ms
Const Timer1_475 = 350    ' > 4,2ms not used
Const Timer1_250 = 255    ' > 8ms not used
'128 SPS
Const Timer1_128 = 350    ' > 15,6ms
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
'
' Electronic load specific variables
Dim Active_fets As Byte
Active_fet_1 Alias Active_fets.0
Active_fet_2 Alias Active_fets.1
Active_fet_3 Alias Active_fets.2
Active_fet_4 Alias Active_fets.3
Active_fet_5 Alias Active_fets.4
Active_fet_6 Alias Active_fets.5
Active_fet_7 Alias Active_fets.6
Dim Active_fets_eeram As Eram Byte
Dim Number_of_active_fets As Byte
'
Dim Calc_u As Single
Dim Correction_u As Single
Dim Correction_u_eeram As Eram Single
Dim Calibrate_u As Single
'
Dim Calc_i(7) As Single
Dim Correction_i(7) As Single
Dim Correction_i_eeram(7) As Eram Single
Dim Calibrate_i AS Single
'
Dim Voltage As Single
Dim Voltage_w As Word
Dim Required_v As Single
Dim Required_v_m As Single
Dim Required_v_p As Single
Dim Minimum_voltage As single
'
Dim Current(7) As Single
Dim Current_w(7) As Word
Dim Required_i As Single
Dim Required_i_m As Single
Dim Required_i_p As Single
Dim All_current As Single
Dim Mean_current As Single
Dim Max_total_current As Single
'
Dim Power_(7) As Single
Dim All_power As Single
Dim Required_p As Single
Dim Required_p_p As Single
Dim Required_p_m As Single
Dim Max_power As Single
Dim Max_power_eeram As Eram Single
Dim Power_of_all_fets As Single
'
Dim Resistance As Single
Dim Required_r As Single
Dim Required_r_p As Single
Dim Required_r_m As Single
'
Dim On_off_mode As Byte
'0: off, 1: regulated 2: unregulated
Dim Off_on As Byte
Dim On_off_on_start As Byte
Dim On_off_counter As Dword
Dim On_off_time As Dword
Dim On_off_time_eeram As Eram Dword
'   :
Dim Fet_number As Byte
' used for control only
Dim Measure_fet As Byte
' used for measure only
Dim Min_fet As Byte
Dim Max_fet As Byte
Dim Current_min As Word
Dim Current_max As Word
'
Dim El_mode as Byte
'default: 0: off, 1: V, 2:I, 3: P, 4: R, 5: Testmode for command 227, 6: calibrate V, 8: calibrate I
' 6: Voltage calibration, 7: current calibration
Dim El_load_sequence As Byte
Dim Timer1_value As Word
'
Dim Error_req As Byte
Dim Hyst_on As Byte
Dim Hyst_on_eeram As  Eram Byte
Dim Hyst As Single
Dim Hyst_eeram As Eram Single
Dim Spi_buffer(3) As Byte
Dim Measure_v As Byte
'
Dim Dac_out_voltage(7) As Word
'
Dim Adc_adress As Byte
Dim Adc_i2c_content(4) As Byte
Dim Adc_chanal As Byte
' 0: 12 or 1: 34
Dim Adc_speed As Byte
'0: 860 SPS... 3: 128 SPS
'
Dim Temp_w As Word
Dim Temp_w_b1 As Byte At Temp_w Overlay
Dim Temp_w_b2 As Byte At Temp_w + 1 Overlay
Dim Temp_single As Single
Dim Temp_single1 As Single
Dim Temp_single2 As Single
Dim Temp_single3 As SIngle
Dim Temp_dw As Dword
Dim Temp_dw_b1 As Byte At Temp_dw Overlay
Dim Temp_dw_b2 As Byte At Temp_dw + 1 Overlay
Dim Temp_dw_b3 As Byte At Temp_dw + 2 Overlay
Dim Temp_dw_b4 As Byte At Temp_dw + 3 Overlay
'
'----------------------------------------------------
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
Config PinB.2 = Input
Reset__ Alias PinB.2
$include "common_1.7\_Config.bas"
'
Gosub reset_load
'----------------------------------------------------
$include "common_1.7\_Main.bas"
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
'
'----------------------------------------------------
'Splitting to different subs is necessary to avoid possible loss of command data
Select Case El_load_sequence
   Case 11
      Adc_chanal = 0
      Gosub Send_i2c_config
      Tcnt1 = 0
      Start Timer1
      El_load_sequence = 12
   Case 10
      Gosub Modify_if_necessary
      El_load_sequence = 11
   Case 9
      Gosub Calculate
      El_load_sequence = 10
   Case 8
      If Active_fets.5 = 1 Then
         Measure_fet = 6
         Adc_adress = Adc_adress_F7_F6
         Gosub Receive_adc_data
      End If
      El_load_sequence = 9
   Case 7
      If Active_fets.3 = 1 Then
         Measure_fet = 4
         Adc_adress = Adc_adress_F5_F4
         Gosub Receive_adc_data
      End If
      El_load_sequence = 8
   Case 6
      If Active_fets.1 = 1 Then
         Measure_fet = 2
         Adc_adress = Adc_adress_F3_F2
         Gosub Receive_adc_data
      End If
      El_load_sequence = 7
   Case 5
      If Tcnt1 >= Timer1_value Then
         Stop Timer1
         Adc_adress = Adc_adress_F1_U
         ' voltage
         Measure_v = 1
         Gosub Receive_adc_data
         If Temp_w > &H7FFF Then Temp_w = 0
         Voltage_w = Temp_w
         El_load_sequence = 6
      End If
   Case 4
      Adc_chanal = 1
      Gosub Send_i2c_config
      Tcnt1 = 0
      Start Timer1
      El_load_sequence = 5
   Case 3
      If Active_fets.6 = 1 Then
         Measure_fet = 7
         Adc_adress = Adc_adress_F7_F6
         Gosub Receive_adc_data
      End If
      El_load_sequence = 4
   Case 2
      If Active_fets.4 = 1 Then
         Measure_fet = 5
         Adc_adress = Adc_adress_F5_F4
         Gosub Receive_adc_data
      End If
      El_load_sequence = 3
   Case 1
      If Active_fets.2 = 1 Then
         Measure_fet = 3
         Adc_adress = Adc_adress_F3_F2
         Gosub Receive_adc_data
      End If
      El_load_sequence = 2
   Case 0
      If Tcnt1 >= Timer1_value Then
         Stop Timer1
         Current_min = &H7FFF
         Current_max = 0
         If Active_fets.0 = 1 Then
            Measure_fet = 1
            Adc_adress = Adc_adress_F1_U
            Gosub Receive_adc_data
            End If
         El_load_sequence = 1
      End If
   Case 12
      El_load_sequence = 0
End Select
If On_off_mode > 0 Then Gosub Operate_On_off_mode
'
'----------------------------------------------------
$include "common_1.7\_Serial.bas"
'
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
'
_init_micro:
Config Gon = Output
Reset Gon
'disable Gate Voltage for fets
Return
'
Next_fet_to_use:
Incr Fet_number
If Fet_number >= 8 Then Fet_number = 1
B_temp1 = Fet_number - 1
B_temp2 = 0
B_temp3 = 1
While B_temp2 = 0 And B_temp3 < 8
   If B_temp1 >= 7 Then B_temp1 = 0
   If Active_fets.B_temp1 = 1 Then
      B_temp2 = 1
   Else
      Incr B_temp1
   End If
   Incr B_temp3
Wend
Fet_number = B_temp1 + 1
If Fet_number >= 8 Then Fet_number = 1
Return
'
Is_fet_active:
' check, if command_b(2) (0 to 6) is a active Fet
' Active_fet = 0 to 127
   Error_req = 1
   If Active_fets > 0 Then
      ' This is Fet1:
      B_temp1 = 1
      Shift B_temp1, Left, Command_b(2)
      B_temp1  = B_temp1 And Active_fets
      If B_temp1 > 0 Then Error_req = 0
   End If
Return
'
Count_number_of_active_fets:
Number_of_active_fets = 0
For B_temp1 = 0 To 6
   If Active_fets.B_temp1 = 1 Then Incr Number_of_active_fets
Next B_temp1
Max_total_current = Max_current * Number_of_active_fets
Power_of_all_fets = Max_power * Number_of_active_fets
Return
'
Dac_startup:
For B_temp1 = 0 To 6
   If Active_fets.B_temp1 = 1 Then
      Dac_out_voltage (B_temp1) = Dac_start
   End If
Next B_temp1
Reset Led
Return
'
Reset_load:
Set Ldac
Spi_buffer(1) = High(Da_resolution)
Spi_buffer(1) = Spi_buffer(1) + Dac_adder
Spi_buffer(2) = Low(Da_resolution)
'highest value is off
Reset Fet1
Reset Fet2
Reset Fet3
Reset Fet4
Reset Fet5
Reset Fet6
Reset Fet7
Spiout Spi_buffer , 2
'send to all in parallel
Set Fet1
Set Fet2
Set Fet3
Set Fet4
Set Fet5
Set Fet6
Set Fet7
Reset Ldac
Reset Ldac
Set Ldac
El_mode = 0
Error_req = 0
On_off_mode = 0
For Fet_number = 1 to 7
   ' for all fets
   Power_(Fet_number) = 0
   Current(Fet_number) = 0
   Dac_out_voltage(Fet_number) = Da_resolution
Next Fet_number
All_current = 0
All_power = 0
Resistance = 120000
Required_v = 0.4
Required_i = 0
Required_p = 0
Required_r = 120000
Minimum_voltage = Minimum_voltage_
' At start Fetnumber is set to 1 if active_fets.0  = 1
Fet_number = 7
Set Led
'
' set Adc_chanal = 0:
El_load_sequence = 4
Adc_speed = 0
Return
'
Modify_if_necessary:
If On_off_mode = 2 Then Return
If On_off_mode = 1 And Off_on = 0 Then Return
If On_off_on_start > 0 Then
   Incr On_off_on_start
   If On_off_on_start < 3 Then
      Return
   Else
      On_off_on_start = 0
   End If
End If
'
Select Case El_mode
   Case 0
      Return
   Case 1
      If Hyst_on = 0 Then
         If Voltage > Required_v Then
            ' lower resistance
            Gosub Lower_dac_out_voltage
         Else
            ' increase resistance  or nothing
            If Voltage < Required_v Then Gosub Increase_dac_out_voltage
         End If
      Else
         If Voltage > Required_v_m Then
            ' lower resistance
            Gosub Lower_dac_out_voltage
         Else
            ' increase resistance  or nothing
            If Voltage < Required_v_p Then Gosub Increase_dac_out_voltage
         End If
      End If
   Case 2
      If Hyst_on = 0 Then
         If All_current < Required_i Then
            Gosub Lower_dac_out_voltage
         Else
            If All_current > Required_i Then Gosub Increase_dac_out_voltage
         End If
      Else
         If All_current < Required_i_m Then
            Gosub Lower_dac_out_voltage
         Else
            If All_current > Required_i_p Then Gosub Increase_dac_out_voltage
         End If
      End If
   Case 3
      If Hyst_on = 0 Then
         If All_power < Required_p Then
            Gosub Lower_dac_out_voltage
         Else
            ' increase resistance  or nothing
            If All_power > Required_p Then Gosub Increase_dac_out_voltage
         End If
      Else
         If All_power < Required_p_m Then
            Gosub Lower_dac_out_voltage
         Else
            If All_power > Required_p_p Then Gosub Increase_dac_out_voltage
         End If
      End If
   Case 4
      If Hyst_on = 0 Then
         If Resistance > Required_r Then
            Gosub Lower_dac_out_voltage
         Else
            ' increase resistance  or nothing
            If Resistance > Required_r Then Gosub Increase_dac_out_voltage
         End If
      Else
         If Resistance < Required_r_m Then
            Gosub Lower_dac_out_voltage
         Else
            If All_power > Required_r_p Then Gosub Increase_dac_out_voltage
         End If
      End If
   Case Else
      Return
End Select
Return
'
Lower_dac_out_voltage:
' complete I too low -> lower resistance -> raise fetvoltage
' lower Dac_out_voltage due to inverting LM324
'
   If Adc_speed = 3 Then
      ' final approach
      ' use Fet with min current
      Fet_number = Min_fet
      If Dac_out_voltage(Fet_number) > 0 Then Decr Dac_out_voltage(Fet_number)
   Else
      Gosub Next_fet_to_use
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) - Fet_voltage_sub
   End If
   Gosub Send_to_fet
   Reset Led
Return
'
Increase_dac_out_voltage:
   ' increase resistance,
   ' Increase ADC accuracy after 1st overshot
   Adc_speed = 3
   Fet_number = Max_fet
   If Dac_out_voltage(Fet_number) < Da_resolution Then
      Incr Dac_out_voltage(Fet_number)
      Gosub Send_to_fet
   End If
   Set Led
Return
'
Send_to_FET:
Spi_buffer(1) = High(Dac_out_voltage(Fet_number))
Spi_buffer(1) = Spi_buffer(1) + Dac_adder
'add config bits
Spi_buffer(2) = Low(Dac_out_voltage(Fet_number))
Select Case Fet_number
   Case 1
      Reset Fet1
   Case 2
      Reset Fet2
   Case 3
      Reset Fet3
   Case 4
      Reset Fet4
   Case 5
      Reset Fet5
   Case 6
      Reset Fet6
   Case 7
      Reset Fet7
End Select
Spiout Spi_buffer(1) , 2
Select Case Fet_number
   Case 1
      Set Fet1
   Case 2
      Set Fet2
   Case 3
      Set Fet3
   Case 4
      Set Fet4
   Case 5
      Set Fet5
   Case 6
      Set Fet6
   Case 7
      Set Fet7
End Select
Reset Ldac
'transfer to Output
Reset Ldac
'min time is 100ns
Set Ldac
Return
'
Operate_On_off_mode:
   Incr On_off_counter
   If On_off_counter > On_off_time Then
      'time to switch
      If Off_on = 0 Then
         'off -> switch on
         If Active_fet_1 = 1 Then
            Fet_number = 1
            Gosub Send_to_fet
         End If
         If Active_fet_2 = 1 Then
            Fet_number = 2
            Gosub Send_to_fet
         End If
         If Active_fet_3 = 1 Then
            Fet_number = 3
            Gosub Send_to_fet
         End If
         If Active_fet_4 = 1 Then
            Fet_number = 4
            Gosub Send_to_fet
         End If
         If Active_fet_5 = 1 Then
            Fet_number = 5
            Gosub Send_to_fet
         End If
         If Active_fet_6 = 1 Then
            Fet_number = 6
            Gosub Send_to_fet
         End If
         If Active_fet_7 = 1 Then
            Fet_number = 7
            Gosub Send_to_fet
         End If
         Reset Led
         Off_on = 1
         On_off_on_start = 1
      Else

         ' on -> switch off
         Set Ldac
         Spi_buffer(1) = High(Da_resolution)
         Spi_buffer(1) = Spi_buffer(1) + Dac_adder
         Spi_buffer(2) = Low(Da_resolution)
         'highest value is off
         Reset Fet1
         Reset Fet2
         Reset Fet3
         Reset Fet4
         Reset Fet5
         Reset Fet6
         Reset Fet7
         Spiout Spi_buffer , 2
         'send to all in parallel
         Set Fet1
         Set Fet2
         Set Fet3
         Set Fet4
         Set Fet5
         Set Fet6
         Set Fet7
         Reset Ldac
         Reset Ldac
         Set Ldac
         Set Led
         Off_on = 0
      End If
      On_off_counter = 0
   End If
Return
'
Calculate:
Voltage = Voltage_w * Calc_u
Error_req = 0
Select Case El_mode
   Case 0
      Return
   Case 1
      If Voltage < Minimum_voltage_v Then
         Error_req = 1
      Else
         Gosub Calculate_all
      End If
   Case 2 To 4
      If Voltage < Minimum_voltage Then
         Error_req = 1
      Else
         Gosub Calculate_all
      End If
   Case 5
      Gosub Calculate_all
   Case 6
      Temp_single3 = Voltage_w
      Temp_single = Calibrate_u / Temp_single3
      Temp_single = Temp_single / Calc_u_
      If Temp_single > 0.8 And Temp_single < 1.2 Then
         Correction_u = Temp_single
         Calc_u = Calc_u_ * Correction_u
      Else
         Out_of_limit
      End If
      Gosub Reset_load
      Return
   Case 7
      If Current_w(Fet_number) > 0 Then
         Temp_single3 = Current_w(Fet_number)
         Temp_single = Calibrate_i / Temp_single3
         Temp_single = Temp_single / Calc_i_
         If Temp_single > 0.8 And Temp_single < 1.2 Then
            Correction_i(Fet_number) = Temp_single
            Calc_i(Fet_number)  = Calc_i_ * Correction_i(Fet_number)
         Else
            Out_of_limit
         End If
      Else
         Not_valid_at_this_time
      End If
End Select
If Error_req = 1 Then
   Voltage_too_low
   Gosub Reset_load
   Return
End If
Return
'
Calculate_all:
All_current = 0
All_power = 0
For B_temp1 = 1 To 7
  All_current = All_current + Current(B_temp1)
  All_power = All_power + Power_(B_temp1)
Next B_temp1
Resistance = 120000
If All_current > 0 Then
  Resistance = Voltage / All_current
  If Resistance > 120000 Or Voltage < 0.4 Then Resistance = 120000
End If
Return
'
Send_i2c_config:
Adc_i2c_content(1) = Adc_control_register
If Adc_chanal = 0 Then
   Adc_i2c_content(2) = Adc_config_01
Else
   Adc_i2c_content(2) = Adc_config_23
End If
Select Case Adc_speed:
   Case 0
      ' 860 SPS
      Adc_i2c_content(3) = Adc_config_860
      Timer1_value = Timer1_860
'   Case 1
'      ' 475 SPS
'      Adc_i2c_content(3) = Adc_config_475
'      Timer1_value = Timer1_475
'  Case 2
'      ' 250 SPS
'      Adc_i2c_content(3) = Adc_config_250
'      Timer1_value = Timer1_250
   Case 3
      ' 128 SPS
      Adc_i2c_content(3) = Adc_config_128
      Timer1_value = Timer1_128
End Select
'
I2csend Adc_adress_F1_U, Adc_i2c_content(1),3
If Active_fets.1 = 1 Or Active_fets.2 = 1 Then I2csend Adc_adress_F3_F2, Adc_i2c_content(1),3
If Active_fets.3 = 1 Or Active_fets.4 = 1 Then I2csend Adc_adress_F5_F4, Adc_i2c_content(1),3
If Active_fets.5 = 1 Or Active_fets.6 = 1 Then I2csend Adc_adress_F7_F6, Adc_i2c_content(1),3
Return
'
Receive_adc_data:
Adc_i2c_content(1) = Adc_data_register
I2creceive Adc_adress, Adc_i2c_content(1), 1, 2
Temp_w = Adc_i2c_content(1) * 256
Temp_w = Temp_w + Adc_i2c_content(2)
If Measure_v = 0 Then
   If Temp_w < Current_min Then
      Current_min = Temp_w
      Min_fet = Measure_fet
   End If
   If Temp_w > Current_max Then
      Current_max = Temp_w
      Max_fet = Measure_fet
   End If
   If Temp_w > &H7FFF Then Temp_w = 0
   Current_w(Measure_fet) = Temp_w
   Current(Measure_fet) = Temp_w * Calc_i(Measure_fet)
   Power_(Measure_fet) = Voltage * Current(Measure_fet)
   If Current(Fet_number) > Max_current Then
      Actual_Current_too_high
      Gosub  Reset_load
   Else
      If Power_(Fet_number) > Max_power Then
         Actual_power_too_high
         Gosub  Reset_load
      End If
   End If
End If
Measure_v = 0
Return
'
'----------------------------------------------------
   $include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
'
   Case 1
'Befehl &H01 (resolution 1mV);  1 byte / 4 byte
'lese aktuelle Spannung
'read actual voltage
'Data "1;ap,read actual voltage;1;90001,{0.000 to 90.000};lin;V"
      Tx_busy = 2
      Tx_time = 1
      Temp_dw = Voltage * 1000
      Tx_b(1) = &H01
      Tx_b(2) = Temp_dw_b3
      Tx_b(3) = Temp_dw_b2
      Tx_b(4) = Temp_dw_b1
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 2
'Befehl &H02; 1 byte / 4 byte
'liest gesamten Strom (1Bit -> 1mA)
'read all current
'Data "2;ap,read actual current;1;175001,{0.000 to 175.000};lin;A"
      Tx_busy = 2
      Tx_time = 1
      Temp_single = All_current * 1000
      Temp_dw = Temp_single
      Tx_b(1) = &H02
      Tx_b(2) = Temp_dw_b3
      Tx_b(3) = Temp_dw_b2
      Tx_b(4) = Temp_dw_b1
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 3
'Befehl &H03  0 - 6 (resolution 1mA); 2 byte / 4 byte
'liest aktuellen Strom eines FETs
'read actual current of a FET
'Data "3;ap,read actual current;7;25001,{0.000 to 25.000};lin;A"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            Tx_busy = 2
            Tx_time = 1
            B_temp1 = Command_b(2) + 1
            Temp_single = Current(B_temp1) * 1000
            Temp_w = Temp_single
            Tx_b(1) = &H03
            Tx_b(2) = Command_b(2)
            Tx_b(3) = High(Temp_w)
            Tx_b(4) = Low(Temp_w)
            Tx_write_pointer = 5
            If Command_mode = 1 Then Gosub Print_tx
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 4
'Befehl &H04  (resolution 1mW); 1 byte / 4 byte
'liest gesamte Leistung
'read all power
'Data "4;ap,read actual power;1;350001,{0.000 to 350.000};lin;W"
      Tx_busy = 2
      Tx_time = 1
      Temp_single = All_power * 1000
      Temp_dw = Temp_single
      Tx_b(1) = &H04
      Tx_b(2) = Temp_dw_b3
      Tx_b(3) = Temp_dw_b2
      Tx_b(4) = Temp_dw_b1
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 5
'Befehl &H05  0 - 6 (resolution 1mW); 2 byte / 4 Byte
'liest aktuelle Leistung eines FETs
'read actual power of a FET
'Data "5;ap,read actual power;7;5001,{0.000 to 50.000};lin;W"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            Tx_busy = 2
            Tx_time = 1
            B_temp1 = Command_b(2) + 1
            Temp_single = Power_(B_temp1) * 1000
            Temp_w = Temp_single
            Tx_b(1) = &H05
            Tx_b(2) = Command_b(2)
            Tx_b(3) = High(Temp_w)
            Tx_b(4) = Low(Temp_w)
            Tx_write_pointer = 5
            If Command_mode = 1 Then Gosub Print_tx
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 6
'Befehl &H06 (resolution mOhm); 1 byte / 5 byte
'liest aktuellen Widerstand
'read actual resistor
'Data "6;ap,read actual resistor;1;120000000,{1 To 12000000};lin;mOhm"
      Tx_busy = 2
      Tx_time = 1
      Temp_single = Resistance * 1000
      Temp_dw = Temp_single
      Tx_b(1) = &H06
      Tx_b(2) = Temp_dw_b4
      Tx_b(3) = Temp_dw_b3
      Tx_b(4) = Temp_dw_b2
      Tx_b(5) = Temp_dw_b1
      Tx_write_pointer = 6
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 7
'Befehl &H07 (resolution 1mV);  4 byte
'gewuenschte Spannung schreiben
'write required voltage
'Data "7;op,reqired voltage;1;89601,{0.400 to 80.000};lin;V"
      If Commandpointer >= 4 Then
         Temp_dw_b1 = command_b(4)
         'low byte first
         Temp_dw_b2 = command_b(3)
         Temp_dw_b3 = command_b(2)
         Temp_dw_b4 = 0
         If Temp_dw < 79600 Then
            If Active_fets > 0 Then
               Gosub Reset_load
               Required_v = Temp_dw / 1000
               Required_v = Required_v + 0.4
               If Voltage > Required_v Then
                  El_mode = 1
                  Temp_single = Required_v * Hyst
                  Required_v_p  = Required_v + Temp_single
                  Required_v_m  = Required_v - Temp_single
                  If Required_v_m < 0 Then Required_v_m = 0
                  Gosub Dac_startup
                  Minimum_voltage = Minimum_voltage_v
               Else
                  Voltage_too_high
               End If
            Else
               No_active_fet
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 8
'Befehl &H08 (resolution 1mV);  1 byte / 4 byte
'gewuenschte Spannung lesen
'read required voltage
'Data "1;ap,as7"
      Tx_busy = 2
      Tx_time = 1
      Temp_single = Required_v - 0.4
      Temp_single = Temp_single * 1000
      Temp_dw = Temp_single
      Tx_b(1) = &H08
      Tx_b(2) = Temp_dw_b3
      Tx_b(3) = Temp_dw_b2
      Tx_b(4) = Temp_dw_b1
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 9
'Befehl &H09 0 - 21000 (1mA resolution); 4 byte / -
'gewuenschten Strom
'required current
'Data "9;op,required current;1;154001,{0.00 To 182.000};lin;A"
      If Commandpointer >= 4 Then
         Temp_dw = 0
         Temp_dw_b1 = command_b(4)
         'low byte first
         Temp_dw_b2 = command_b(3)
         Temp_dw_b3 = command_b(2)
         Temp_dw_b4 = 0
         If Temp_dw <= 182000 Then
            If Temp_dw > 0 Then
               If Voltage > Minimum_voltage Then
                  If Active_fets > 0 Then
                     Gosub Reset_load
                     If Temp_dw > 0 Then
                        Required_i = Temp_dw / 1000
                        If Required_i < Max_total_current Then
                           El_mode = 2
                           Temp_single = Required_i * Hyst
                           Required_i_p  = Required_i + Temp_single
                           Required_i_m  = Required_i - Temp_single
                           If Required_i_m < 0 Then Required_i_m = 0
                           Gosub Dac_startup
                        Else
                           Required_current_too_high
                           Required_i = 0
                        End If
                     End If
                  Else
                     No_active_fet
                  End If
               Else
                  Voltage_too_low
               End If
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 10
'Befehl &H0A  (1mA resolution); 1 byte / 4 byte
'gewuenschten Strom lesen
'read required current
'Data "10;ap,as9"
      Tx_busy = 2
      Tx_time = 1
      Temp_dw  = Required_i * 1000
      Tx_b(1) = &H0A
      Tx_b(2) = Temp_dw_b3
      Tx_b(3) = Temp_dw_b2
      Tx_b(4) = Temp_dw_b1
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 11
'Befehl &H0B 0 - 140000 (1mW resolution); 4 byte / -
'gewuenschte Leistung
'required power
'Data "11;op,required power;1;300001,{0.00 To 300.000};lin;W"
      If Commandpointer >= 4 Then
         Temp_dw = 0
         Temp_dw_b1 = command_b(4)
         'low byte first
         Temp_dw_b2 = command_b(3)
         Temp_dw_b3 = command_b(2)
         If Temp_dw <= 300000 Then
            If Temp_dw > 0 Then
               If Voltage > Minimum_voltage Then
                  If Active_fets > 0 Then
                     Gosub Reset_load
                     If Temp_dw > 0 Then
                        Required_p = Temp_dw / 1000
                        If Required_p < Power_of_all_fets And Required_p < Max_cooling Then
                           El_mode = 3
                           Temp_single = Required_p * Hyst
                           Required_p_p  = Required_p + Temp_single
                           If Required_p_p > Power_of_all_fets  Then Required_p_p = Power_of_all_fets
                           Required_p_m  = Required_i - Temp_single
                           If Required_p_m < 0 Then Required_p_m = 0
                           Gosub Dac_startup
                        Else
                           Required_power_too_high
                           Required_p = 0
                        End If
                     End If
                  Else
                     No_active_fet
                  End If
               Else
                  Voltage_too_low
               End If
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 12
'Befehl &H0C (1mW resolution); 1 byte / 4 byte
'gewuenschte Leistung lesen
'read required power
'Data "12;ap,as11"
      Tx_busy = 2
      Tx_time = 1
      Temp_dw = Required_p * 1000
      Tx_b(1) = &H0C
      Tx_b(2) = Temp_dw_b3
      Tx_b(3) = Temp_dw_b2
      Tx_b(4) = Temp_dw_b1
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'

   Case 13
'Befehl &H0D 10mOhm - 120kOhm (resolution 1mOhm); 5 byte / -
'gewuenschten Widerstand schreiben
'write required resistor
'Data "13;op,required resistor:1;119999990,{0.01 To 120000.000};lin;Ohm"
      If Commandpointer >= 5 Then
         Temp_dw_b1 = command_b(5)
         'low byte first
         Temp_dw_b2 = command_b(4)
         Temp_dw_b3 = command_b(3)
         Temp_dw_b4 = Command_b(2)
         If Temp_dw < 119999990 Then
            If Voltage > Minimum_voltage Then
                  If Active_fets > 0 Then
                     Temp_dw = Temp_dw + 10
                     Gosub Reset_load
                     Required_r = Temp_dw / 1000
                     El_mode = 4
                     Temp_single = Required_r * Hyst
                     Required_r_p  = Required_r + Temp_single
                     If Required_r_p > 120000  Then Required_r_p = 120000
                     Required_r_m  = Required_r - Temp_single
                     If Required_r_m < 0.001 Then Required_r_m = 0.001
                     Gosub Dac_startup
                  Else
                     No_active_fet
                  End If
               Else
                  Voltage_too_low
               End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 14
'Befehl &H0E (resolution 10mOhm); 1 byte / 5 byte
'gewuenschter Widerstand lesen
'read required resistor
'Data "14;ap,as13"
      Tx_busy = 2
      Tx_time = 1
      Temp_dw = Required_r * 1000
      Temp_dw = Temp_dw - 10
      Tx_b(1) = &H0E
      Tx_b(2) = Temp_dw_b4
      Tx_b(3) = Temp_dw_b3
      Tx_b(4) = Temp_dw_b2
      Tx_b(5) = Temp_dw_b1
      Tx_write_pointer = 6
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 15
'Befehl &H0F 0|1|2; 2 byte / -
'Wechsellast schreiben
'write on /off mode
'Data "15;or,on off mode;1;0,off;1,regulated;2,fixed"
      If Commandpointer >= 2 Then
         If Command_b(2) < 3  Then
            If El_mode > 0 And El_mode < 5 Then
               On_off_mode = Command_b(2)
               On_off_counter = 0
               Off_on = 0
            Else
               Not_valid_at_this_time
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 16
'Befehl &H10; 1 byte / 2 byte
'Wechsellast lesen
'read on /off mode
'Data "16;ar,as15"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H10
      Tx_b(2) = On_off_mode
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 17
'Befehl &H11; 4 byte / -
'Zeit für Wechsellast schreiben
'write time for on - off mode
'Data "17;op,time for on off mode;1;1000,{0.01 To 10.00};lin;s"
      If Commandpointer >= 3 Then
         Temp_w = Command_b(2) * 256
         Temp_w = Temp_w + Command_b (3)
         If Temp_w < 1000 Then
            On_off_time = Temp_w + 1
            On_off_time = On_off_time * On_off_time_default_
            On_off_time_eeram = On_off_time
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 18
'Befehl &H12; 1 byte / 4 byte
'Zeit für Wechsellast lesen
'read time for on - off mode
'Data "18;ap,as17"
      Tx_busy = 2
      Tx_time = 1
      Temp_dw = On_off_time / On_off_time_default_
      Temp_w = Temp_dw -1
      Tx_b(1) = &H12
      Tx_b(2) = High(Temp_w)
      Tx_b(3) = Low(Temp_w)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 19
'Befehl &H13; 1 byte / 1 byte + string
'Betriebsart lesen
'read mode
'Data "19;aa,read mode;b,{idle,V,I,P,R};20"
      If Commandpointer >= 2 Then
         Tx_busy = 2
         Tx_time = 1
         Tx_b(1) = &H13
         Tx_b(2) = Command_b(2)
         If Command_b(2) = 0 Then
            Tx_b(3) =  El_mode
            Tx_write_pointer = 4
         Else
            Select Case El_mode
               Case 0
                  B_temp1 = 7
                  Temps = "0: idle"
               Case 1
                  B_temp1 = 15
                  Temps = "1: voltage mode"
               Case 2
                  B_temp1 = 15
                  Temps = "2: current mode"
               Case 3
                  B_temp1 = 13
                  Temps = "3: power mode"
               Case 4
                  B_temp1 = 16
                  Temps = "4: resistor mode"
               Case 5
                  B_temp1 = 12
                  Temps = "5: test mode"
               Case 6
                  B_temp1 = 22
                  Temps = "6: voltage calibra"
               Case 7
                  B_temp1 = 22
                  Temps = "7: current calibra"
            End Select
            Tx_b(3) = B_temp1
            B_temp2 = 4
            For B_temp3 = 1 To B_temp1
               Tx_b(B_temp2) = Temps_b(B_Temp3)
               Incr B_Temp2
            Next B_Temp3
            Tx_write_pointer = B_temp1 + 4
         End If
         If Command_mode = 1 Then Gosub Print_tx
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 20
'Befehl &H14; 1 byte / -
'schaltet Last ab
'switch off
'Data "20;ou,switch off;1;0,idle;1,off"
      Gosub Reset_load
      Gosub Command_received
'
   Case 21
'Befehl &H15; 2 byte / -
'Hysterese an schreiben
'write hysteresys on
'Data "21;or;hysteresys;1;0,off;1,on"
      If Commandpointer >= 2 Then
         If Command_b(2) < 2 Then
            Hyst_on = Command_b(2)
            Hyst_on_eeram = Hyst_on
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 22
'Befehl &H16; 1 byte / 2 byte
'Hysterese an lesen
'read hysteresys on
'Data "22;ar,as21"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H16
      Tx_b(2) = Hyst_on
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 23
'Befehl &H17; 2 byte / -
'Hysterese schreiben
'write hysteresys
'Data "23;op;hysteresys;1;100,{0,1 To 10};lin;%"
      If Commandpointer >= 2 Then
         If Command_b(2) < 100 Then
            Hyst = Command_b(2) + 1
            Hyst = Hyst / 1000
            Hyst_eeram = Hyst
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 24
'Befehl &H18; 1 byte / 2 byte
'Hysterese lesen
'read hysteresys
'Data "24;ap,as23"
      Tx_busy = 2
      Tx_time = 1
      Temp_single = Hyst * 1000
      Temp_single = Temp_single - 1
      Tx_b(1) = &H18
      Tx_b(2) = Temp_single
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
  Case 25
'Befehl &H19 (0 to 127); 2  byte / -
'Aktive FETs binaer schreiben
'write active FETS binary
'Data "25;ka,active FETs, binary;b,127,{0 To 127}"
      If Commandpointer >= 2 Then
         If Command_b(2) < 128 Then
            Active_fets = Command_b(2)
            Active_fets_eeram = Active_fets
            Gosub Count_number_of_active_fets
            Gosub Reset_load
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 26
'Befehl &H1A; 1 byte / 2 Byte
'Aktive Fets binaer lesen
'read active FETS binary
'Data "26;aa,as25"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H1A
      Tx_b(2) = Active_fets
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 27
'Befehl &H1B; 1 byte / 2 Byte
'Zahl der aktiven Fets lesen
'read number of active FETs
'Data "27;ar,read number of active FETs;1;b,{1 to 7}
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H1B
      Tx_b(2) = Number_of_active_fets
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 28
'Befehl &H1C; 1 byte / 4 byte
'Maximale Leistung pro Fet lesen
'read maximum power per FET
'Data "28;lp,maximum power per FET;1;150001,150000,{0 to 150,000};lin;Watt"
      Tx_busy = 2
      Tx_time = 1
      Temp_dw = Max_power * 1000
      Tx_b(1) = &H1C
      Tx_b(2) = Temp_dw_b3
      Tx_b(3) = Temp_dw_b2
      Tx_b(4) = Temp_dw_b1
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 227
'Befehl &HE3; 3 byte / -
'Maximale Leistung pro Fet
'maximum power per FET
'Data "227;kp;maximum power per FET;1;150001,15000.{0 to 150,000};lin;Watt"
      If Commandpointer >= 4 Then
         Temp_dw = 0
         Temp_dw_b1 = command_b(4)
         'low byte first
         Temp_dw_b2 = command_b(3)
         Temp_dw_b3 = command_b(2)
         Temp_single = Temp_dw / 1000
         ' W
         If Temp_single <= 150000 Then
            Max_power = Temp_single
            Max_power_eeram = Max_power
            Gosub Reset_load
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 228
'Befehl &HE4 0 to 6 , 0 to 4095; 4 byte / -
'Fet control register einstellen
'set fet control register
'Data "228;km,set fet control register;6;w,{0 To 4095}"
      If Commandpointer >= 4 Then
         If Command_b(2) < 7 Then
            W_temp1 = Command_b(3) * 256
            W_temp1 = W_temp1 + Command_b(4)
            If W_temp1 <= Da_resolution Then
               Gosub Is_fet_active
               If Error_req = 0 Then
                  Gosub Reset_load
                  Fet_number = Command_b(2) + 1
                  Dac_out_voltage(Fet_number) = W_temp1
                  Gosub Send_to_fet
                  El_mode = 5
               Else
                  Fet_not_active
               End If
            Else
               Parameter_error
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 229
'Befehl &HE5; 2 byte / 4 byte
'Fet control register lesen
'read fet control register
'Data "229; lm,as228"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            Gosub Is_fet_active
            If Error_req = 0 Then
               Tx_busy = 2
               Tx_time = 1
               Tx_b(1) = &HE5
               Tx_b(2) = Command_b(2)
               B_temp1 = Command_b(2) + 1
               Tx_b(3) = High(Dac_out_voltage(B_temp1))
               Tx_b(4) = Low(Dac_out_voltage(B_temp1))
               Tx_write_pointer = 5
               If Command_mode = 1 Then Gosub Print_tx
            Else
               Fet_not_active
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 230
'Befehl &HE6 0 to 90000; 4 byte / -
'Spannung für Spannungseichung schreiben
'write voltage for voltage calibration
'Data "230;ap,calibration voltage;1;70001,{20000 To 90000};lin:mV"
      If Commandpointer >= 4 Then
         Temp_dw_b1 = command_b(4)
         'low byte first
         Temp_dw_b2 = command_b(3)
         Temp_dw_b3 = command_b(2)
         Temp_dw_b4 = 0
          'mV
         If Temp_dw < 70000 Then
            Temp_dw = Temp_dw + 20000
            Temp_single = Temp_dw
            Calibrate_u = Temp_single / 1000
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 231
'Befehl &HE7; 1 byte / 4 byte
'Spannung für Spannungseichung lesen
'read voltage for calibration
'Data "231;la,as230"
      Temp_single = Calibrate_u
      Temp_single = Temp_single * 1000
      Temp_single = Temp_single - 20000
      Temp_dw = Temp_single
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &HE7
      Tx_b(2) = Temp_dw_b3
      Tx_b(3) = Temp_dw_b2
      Tx_b(4) = Temp_dw_b1
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 232
'Befehl &HE8; 1 byte / -
'Spannung eichen
'calibrate Voltage
'Data "232;ku,calibrate voltage;1;0,,idle;1 calibrate voltage"
      If Voltage > Minimum_voltage Then
         Gosub Reset_load
         El_mode = 6
         Gosub Next_fet_to_use
      Else
         Voltage_too_low
      End If
      Gosub Command_received
'
   Case 233
'Befehl &HE9:1 byte / 2 byte
'Spannungseichung lesen
'read voltage calibration
'Data "234;lp,read voltage calibration;1;4000,{0.8000 To 1.2000};lin;-" :
      Tx_busy = 2
      Tx_time = 1
      Temp_single = Correction_u + 0.2
      Temp_single =  Correction_u * 10000
      Temp_single = Temp_single - 8000
      If Temp_single < 0 Then Temp_single = 0
      Temp_w = Temp_single
      Tx_b(1) = &HE9
      Tx_b(2) = High(Temp_w)
      Tx_b(3) = Low(Temp_w)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 234
'Befehl &HEA 0 to 30000; 3 byte / -
'Strom für Stromeichung schreiben
'write current for current calibration
'Data "234;op,current for calibration;1;20001,{2000 To 22000};lin:mA"
      If Commandpointer >= 3 Then
         Temp_w = Command_b(2) * 256
         Temp_w = Temp_w + Command_b(3)
         If Temp_w < 20000 Then
            Temp_w = Temp_w + 2000
            Temp_single = Temp_w
            Calibrate_i = Temp_single / 1000
            ' Ampere
         Else
            Calibrate_current_too_low
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 235
'Befehl &HEB; 1 byte / 3 byte
'Strom für Stromeichung lesen
'read current for calibration
'Data "235;ap,as234"
      Temp_single =  Calibrate_i * 1000
      Temp_w = Temp_single
      Temp_w = Temp_w - 2000
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &HEB
      Tx_b(2) = High(Temp_w)
      Tx_b(3) = Low(Temp_w)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 236
'Befehl &HEC 0 - 6 ; 2 byte / -
'Fet kurzschliessen
'shorten FET
'Data "236;ku,shorten Fet;0,FET1;1,FET2;2,FET3;3FET4;4,FET5;5,FET6;6,FET7"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            Gosub Reset_load
            Gosub Is_fet_active
            If Error_req = 0 Then
               Fet_number = Command_b(2) + 1
               Dac_out_voltage(Fet_number) = 0
               Gosub Send_to_fet
               El_mode = 5
               Gosub Next_fet_to_use
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 237
'Befehl &HED 0 - 6 ; 2 byte / -
'Strom eichen
'calibrate Current
'Data "236;ku,calibrate current;0,FET1;1,FET2;2,FET3;3FET4;4,FET5;5,FET6;6,FET7"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            Gosub Is_fet_active
            If Error_req = 0 Then
               Fet_number = Command_b(2) + 1
               El_mode = 7
            Else
               Fet_not_active
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 238
'Befehl &HEE; 2 byte / 4 byte
'Stromeichung lesen
'read current calibration
'Data "237;lp,read current calibration;7;4000,{0.8000 To 1.2000};lin;-" :
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            Tx_busy = 2
            Tx_time = 1
            B_temp1 = Command_b(2) + 1
            Temp_single = Correction_i(B_temp1)
            Temp_single = Temp_single * 10000
            Temp_single =Temp_single - 8000
            If Temp_single < 0 Then Temp_single = 0
            Temp_w = Temp_single
            Tx_b(1) = &HEE
            Tx_b(2) = Command_b(2)
            Tx_b(3) = High(Temp_w)
            Tx_b(4) = Low(Temp_w)
            Tx_write_pointer = 5
            If Command_mode = 1 Then Gosub Print_tx
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
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
'
Announce0:
'Befehl &H00; 1 byte / 1 byte + string
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;electronic load for 7 IRFP150;V04.0;1;145;1;49;1-1"
'
Announce1:
'Befehl &H01 (resolution 1mV);  1 byte / 4 byte
'lese aktuelle Spannung
'read actual voltage
Data "1;ap,read actual voltage;1;90001,{0.000 to 90.000};lin;V"
 '
Announce2:
'Befehl &H02; 1 byte / 4 byte
'liest gesamten Strom (1Bit -> 1mA)
'read all current
Data "2;ap,read actual current;1;175001,{0.000 to 175.000};lin;A"
'
Announce3:
'Befehl &H03  0 - 6 (resolution 1mA); 2 byte / 4 byte
'liest aktuellen Strom eines FETs
'read actual current of a FET
Data "3;ap,read actual current;7;25001,{0.000 to 25.000};lin;A"
'
Announce4:
'Befehl &H04  (resolution 1mW); 1 byte / 4 byte
'liest gesamte Leistung
'read all power
Data "4;ap,read actual power;1;350001,{0.000 to 350.000};lin;W"
'
Announce5:
'Befehl &H05  0 - 6 (resolution 1mW); 2 byte / 4 Byte
'liest aktuelle Leistung eines FETs
'read actual power of a FET
Data "5;ap,read actual power;7;5001,{0.000 to 50.000};lin;W"
'
Announce6:
'Befehl &H06 (resolution mOhm); 1 byte / 5 byte
'liest aktuellen Widerstand
'read actual resistor
Data "6;ap,read actual resistor;1;120000000,{1 To 12000000};lin;mOhm"
'
Announce7:
'Befehl &H07 (resolution 1mV);  4 byte
'gewuenschte Spannung schreiben
'write required voltage
Data "7;op,reqired voltage;1;89601,{0.400 to 90.000};lin;V"
'
Announce8:
'Befehl &H08 (resolution 1mV);  1 byte / 4 byte
'gewuenschte Spannung lesen
'read required voltage
Data "1;ap,as7"
'
Announce9:
'Befehl &H09 0 - 21000 (1mA resolution); 4 byte / -
'gewuenschten Strom
'required current
Data "9;op,required current;1;154001,{0.00 To 182.000};lin;A"
'
Announce10:
'Befehl &H0A  (1mA resolution); 1 byte / 4 byte
'gewuenschten Strom lesen
'read required current
Data "10;ap,as9"
'
Announce11:
'Befehl &H0B 0 - 140000 (1mW resolution); 4 byte / -
'gewuenschte Leistung
'required power
Data "11;op,required power;1;300001,{0.00 To 300.000};lin;W"
'
Announce12:
'Befehl &H0C (1mW resolution); 1 byte / 4 byte
'gewuenschte Leistung lesen
'read required power
Data "12;ap,as11"
'
Announce13:
'Befehl &H0D 10mOhm - 120kOhm (resolution 1mOhm); 5 byte / -
'gewuenschten Widerstand schreiben
'write required resistor
Data "13;op,required resistor:1;119999990,{0.01 To 120000.000};lin;Ohm"
'
Announce14:
'Befehl &H0E (resolution 10mOhm); 1 byte / 5 byte
'gewuenschter Widerstand lesen
'read required resistor
Data "14;ap,as13"
'
Announce15:
'Befehl &H0F 0|1|2; 2 byte / -
'Wechsellast schreiben
'write on /off mode
Data "15;or,on off mode;1;0,off;1,regulated;2,fixed"
'
Announce16:
'Befehl &H10; 1 byte / 2 byte
'Wechsellast lesen
'read on /off mode
Data "16;ar,as15"
'
Announce17:
'Befehl &H11; 4 byte / -
'Zeit für Wechsellast schreiben
'write time for on - off mode
Data "17;op,time for on off mode;1;1000,{0.01 To 10.00};lin;s"
'
Announce18:
'Befehl &H12; 1 byte / 4 byte
'Zeit für Wechsellast lesen
'read time for on - off mode
Data "18;ap,as17"
'
Announce19:
'Befehl &H13; 1 byte / 1 byte + string
'Betriebsart lesen
'read mode
Data "19;aa,read mode;b,{idle,V,I,P,R};20"
'
Announce20:
'Befehl &H14; 1 byte / -
'schaltet Last ab
'switch off
Data "20;ou,switch off;1;0,idle;1,off"
'
Announce21:
'Befehl &H15; 2 byte / -
'Hysterese an schreiben
'write hysteresys on
Data "21;or;hysteresys;1;0,off;1,on"
'
Announce22:
'Befehl &H16; 1 byte / 2 byte
'Hysterese an lesen
'read hysteresys on
Data "22;ar,as21"
'
Announce23:
'Befehl &H17; 2 byte / -
'Hysterese schreiben
'write hysteresys
Data "23;op;hysteresys;1;100,{0,1 To 10};lin;%"
'
Announce24:
'Befehl &H18; 1 byte / 2 byte
'Hysterese lesen
'read hysteresys
Data "24;ap,as23"
'
Announce25:
'Befehl &H19 (0 to 127); 2  byte / -
'Aktive FETs binaer schreiben
'write active FETS binary
Data "25;ka,active FETs, binary;b,127,{0 To 127}"
'
Announce26:
'Befehl &H1A; 1 byte / 2 Byte
'Aktive Fets binaer lesen
'read active FETS binary
Data "26;aa,as25"
'
Announce27:
'Befehl &H1B; 1 byte / 2 Byte
'Zahl der aktiven Fets lesen
'read number of active FETs
Data "27;ar,read number of active FETs;1;b,{1 to 7}"
'
Announce28:
'Befehl &H1C; 1 byte / 4 byte
'Maximale Leistung pro Fet lesen
'read maximum power per FET
Data "28;lp,maximum power per FET;1;150001,15000,{0 to 150,000};lin;Watt"
'
Announce29:
'Befehl &HE3; 3 byte / -
'Maximale Leistung pro Fet
'maximum power per FET
Data "227;kp;maximum power per FET;1;150001,15000,{0 to 150,000};lin;Watt"
'
Announce30:
'Befehl &HE4 0 to 6 , 0 to 4095; 4 byte / -
'Fet control register einstellen
'set fet control register
Data "228;km,set fet control register;6;w,{0 To 4095}"
'
Announce31:
'Befehl &HE5; 2 byte / 4 byte
'Fet control register lesen
'read fet control register
Data "229; lm,as228"
'
Announce32:
'Befehl &HE6 0 to 90000; 4 byte / -
'Spannung für Spannungseichung schreiben
'write voltage for voltage calibration
Data "230;ap,calibration voltage;1;70001,{20000 To 90000};lin:mV"
'
Announce33:
'Befehl &HE7; 1 byte / 4 byte
'Spannung für Spannungseichung lesen
'read voltage for calibration
Data "231;la,as230"
'
Announce34:
'Befehl &4E8; 1 byte / -
'Spannung eichen
'calibrate Voltage
Data "232;ku,calibrate voltage;1;0,,idle;1 calibrate voltage"
'
Announce35:
'Befehl &HE9:1 byte / 2 byte
'Spannungseichung lesen
'read voltage calibration
Data "234;lp,read voltage calibration;1;4000,{0.8000 To 1.2000};lin;-" :
'
Announce36:
'Befehl &HEA 0 to 30000; 3 byte / -
'Strom für Stromeichung schreiben
'write current for current calibration
Data "234;op,current for calibration;1;20001,{2000 To 22000};lin:mA"
'
Announce37:
'Befehl &HEB; 1 byte / 3 byte
'Strom für Stromeichung lesen
'read current for calibration
Data "235;ap,as234"
'
Announce38:
'Befehl &HEC 0 - 6 ; 2 byte / -
'Fet kurzschliessen
'shorten FET
Data "236;ku,shorten Fet;0,FET1;1,FET2;2,FET3;3FET4;4,FET5;5,FET6;6,FET7"
'
Announce39:
'Befehl &HED 0 - 6 ; 2 byte / -
'Strom eichen
'calibrate Current
'Data "236;ku,calibrate current;0,FET1;1,FET2;2,FET3;3FET4;4,FET5;5,FET6;6,FET7"
'
Announce40:
'Befehl &HEE; 2 byte / 4 byte
'Stromeichung lesen
'read current calibration
Data "237;lp,read current calibration;7;4000,{0.8000 To 1.2000};lin;-" :
'
Announce41:
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;49"
'
Announce42:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce43:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce44:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,SERIAL,1"
'
Announce45:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'
Announce46:
' Undervoltage
Data "R !$9 !$11 !$13 IF $1<400"
'
Announce47:
' Undervoltage
Data "R !$7 IF $1<10"
'
Announce48:
' On - off mode only during operation
Data "R $15 IF $19>0 AND $19<5"
'
Announce49:
' Switch off, if power is exceeded
Data "R $20=1! IF $4>$27*$27"
'
Announce50:
' Switch off, if current is exceeded
Data "R $20=1! IF $2&*>150000"
'
Announce51:
Data "S !E8 IF $1<400"