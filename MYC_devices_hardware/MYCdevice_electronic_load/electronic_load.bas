'-----------------------------------------------------------------------
'name : electronic_load.bas
'Version V03.0, 20190718
'purpose : This is a electronic load for 7 fets IRFP150
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware  electronic_load V03.1 by DK1RI
'
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
' ADC Inputs: all,
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
'Imax = 30A   (at 100 degC)
'Ptot = 200W
'Ron = 50mOhm
'so the minimum voltage to be applied and will work under all conditions is
' (10mOhm resistor for measuring)
' (50 + 10 mOhm) * 30A = 1,8V
' If current (per FET) is lower, lower Voltage can be used
'
'All internal calculation are in V, A and W and Ohm

'The resolution used by commands is 10mV, 10mA, 10mW and 10mOhm. Some rounding is done.

'The effective voltage resolution is nominal 88mV (2,562 / 2,56) * ( 90V / 1023)
' (2.562V at AD input with 90V)

'Because the AD converter needs 4 - 5 steps for an acceptable accuracy
'the el load will not switch on for voltages below 400mV (AD Converter = 4)
'
'The current resolution is nominal 29mA
' (30A *0.01Ohm * (154kOhm / 18kOhm) / 2,56V)*(30 / 1023)
'so the minimum current (1 Fet active) to be applied for an acceptable current result
'is 120mA (AD Converter = 4)
'
'The minimum resistor value of the load is
' (50mOhm + 10mOhm + 3mOhm) / 7 ~ 9 mOhm  (3mOhm: wire)
'The maximum is given by the max voltage and the minimum current:
' 90V / 28mA ~ 3kOhm
'The required resistor has a range from 0.01 Ohm to 3.000.00 Ohm
'
'The usable maximum power depends on cooling and may be modified.
'default value is 50W per fet (350W total)
'Absolute maximimum is 1400W with IRFP150
' The required power range is 0 W to 1400.00 W
'
'To improve accuracy the number of used FETs is as low as possible
'So the requested power is either given or calculated, when the voltage is applied
'If the requested power is < n * (max_power_per_FET * 0.8) then only n FETs are used
'starting with 1st active FET.
'If the current or power exceeds the max value a additional FET is added
'
'For regulation the current is measured.
'requiredI, requiredR and requiredP are valid values all the time an vary with change of voltage
'
'The gate voltage is modified for all used FETs in turn by a specific value
'The current should be similar for all FETs to have a good power distribution.
'Therefore the check of power during measurement is done on a per FET base.
'
'Because the current of different FETs varies with same Fet Gate voltage, the gate
'voltage of a FET is changed only if the current to modify will decrease the spread
'of all currents; otherwise this FET is skipped.
'
'----------------------------------------------------
$regfile = "m1284def.dat"
'$regfile = "m644def.dat"
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
Const I2c_address = 21
Const No_of_announcelines = 49
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'If other FETs are used or less then 7 FETs are installed, the constants must be modified.
'Modification of announcements may be necessary as well.
'
'el load specific Constants:
Const Max_power_default = 50.0
'50W per fet
Const Max_voltage = 90
'90V
Const Save_factor = 0.9
Const Max_current_default = 30.0
Const Max_current_default_save = Max_current_default * Save_factor
'30A per fet
'
' 1023 will result in 30A
' I = Measured * Correction_i  (0.0293)
Const Correction_i_default = Max_current_default / 1023
' 1023 should result in 90V
' U = Measured * Correction_u (0.0879)
Const Correction_u_default = Max_voltage / 1023
' Min voltage for correction measurement (V)
Const Min_cor_measure_voltage = 20
' Min current for correction measurement (mA)
Const Min_cor_measure_current = 1.0
'
Const On_off_time_default = 1000
'about 1 s
'
Const Minimum_voltage = 0.4
'400mV necessary to switch on the load
'
Const Ad_resolution = 1023
' ATMega
Const Da_resolution = 4095
'for MCP4921 12 Bit
'
Const I_min_calibrate = Max_current_default / 30
'
Const Resolution_i = Max_current_default / Ad_resolution
'29mA
Const Hysterese_factor = 1
'multiplier for Resolution_i
Const Hysterese_i = Resolution_i * Hysterese_factor
'
Const Dac_adder = &H30
'DAC config, to be added to the high byte
'bit 15: 0 DAC activ
'bit 14: 0 unbuffered (Vref = 5V)
'bit 13: 1 Gain 1
'bit 12: 1 output enabled
Const Fet_voltage_adder_start = 10
'change of AD output per step
Const Active_fets_default = &B01111111
'Fet1 is LSB, all Fets working
Const Reduction = 100
' If power is too high the DACout is increased by that value
Const Reduction_limit = Da_resolution - Reduction  '
'
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
Dim Max_power_save As Single
'
Dim Calibrate_u As Single
Dim Correction_u As Single
Dim Correction_u_eeram As Eram Single
'
Dim Calibrate_i As Single
Dim Correction_i(7) As Single
Dim Correction_i_eeram(7) As Eram Single
Dim Correction_i_min As Single
Dim Correction_i_max As Single
'
Dim Voltage As Single
'0 - 90000 mV
Dim Voltage_last As Single
'
Dim Current(7) As Single
Dim Required_i_min As Single
Dim Required_i_max As Single
Dim Required_i As Single
Dim All_current As Single
'0 - 210000mA
Dim Mean_current As Single
Dim Max_total_current As Single
'
Dim Power_(7) As Single
Dim All_power As Single
Dim Required_p As Single
'0 - 1400000mW (200W / Fet)
Dim Max_power As Single
'per FET in W
Dim Max_power_eeram As Eram Single
Dim Max_total_power As Single
'
Dim Resistance As Single
Dim Required_r As Single
'
Dim On_off_mode As Byte
Dim Off_on As Byte
Dim On_off_counter As Word
Dim On_off_time As Word
Dim On_off_time_eeram As Eram Word
'
'Fet in use    :
Dim Fet_number As Byte
Dim Highest_fet_number As Byte
'each Fet coded as a bit: bit 0:FET1
Dim Used_fets As Byte
Used_fets_1 Alias Used_fets.0
Used_fets_2 Alias Used_fets.1
Used_fets_3 Alias Used_fets.2
Used_fets_4 Alias Used_fets.3
Used_fets_5 Alias Used_fets.4
Used_fets_6 Alias Used_fets.5
Used_fets_7 Alias Used_fets.6
'Fets used for a measurement
Dim Number_of_used_fets  As Byte
'
Dim El_mode as Byte
'default: 0: off, 1: Testmode for command 239, 2:I, 3: R, 4: P
'
Dim Error_req As Byte
Dim Adc_register(7) as Word
Dim Spi_buffer(3) As Byte
'
Dim Dac_out_voltage(7) As Word
Dim Fet_voltage_adder As Byte
'
Dim Temp_w As Word
Dim Temp_w_b1 As Byte At Temp_w Overlay
Dim Temp_w_b2 As Byte At Temp_w + 1 Overlay
Dim Temp_single As Single
Dim Temp_single2 As Single
Dim Temp_single3 As SIngle
Dim Temp_dw As Dword
Dim Temp_dw_b1 As Byte At Temp_dw Overlay

Dim Temp_dw_b2 As Byte At Temp_dw +1 Overlay
Dim Temp_dw_b3 As Byte At Temp_dw +2 Overlay
Dim Temp_dw_b4 As Byte At Temp_dw +3 Overlay
Dim Temp_req_i As Single
Dim Temp_req_p As Single
Dim Temp_req_p_dw As Dword
Dim Temp_req_p_dw_b1 As Byte At Temp_req_p_dw Overlay
Dim Temp_req_p_dw_b2 As Byte At Temp_req_p_dw + 1 Overlay
Dim Temp_req_p_dw_b3 As Byte At Temp_req_p_dw + 2 Overlay
Dim Temp_req_p_dw_b4 As Byte At Temp_req_p_dw + 3 Overlay
Dim Temp_req_r As Single
Dim Temp_req_r_dw As Dword
Dim Temp_req_r_dw_b1 As Byte At Temp_req_r_dw Overlay
Dim Temp_req_r_dw_b2 As Byte At Temp_req_r_dw + 1 Overlay
Dim Temp_req_r_dw_b3 As Byte At Temp_req_r_dw + 2 Overlay
Dim Temp_req_r_dw_b4 As Byte At Temp_req_r_dw + 3 Overlay
'
'
'----------------------------------------------------
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.7\_Config.bas"
'
'----------------------------------------------------
$include "common_1.7\_Main.bas"
Set Gon
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
'
'----------------------------------------------------

Gosub Measure_and_check
'
If El_mode > 0 Then
   If Voltage < Minimum_voltage Then
      Gosub Reset_load
      Voltage_too_low
   Else
      If El_mode > 1 Then
         If On_off_mode = 0 Then
            Gosub Modify_if_necessary
         Else
            Gosub Operate_On_off_mode
            If On_off_mode = 1 And Off_on = 1 Then
               ' regulated mode in on state
               Gosub Modify_if_necessary
            End If
         End If
      ' Else El_mode = 1 (register) or 0 (off) : no modification
      End If
   End If
End If
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
Config PortD.5 = Output
Reset Portd.5
'disable Gate Voltage for fets
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
      B_temp1 = B_temp1 AND Active_fets
      If B_temp1 > 0 Then Error_req = 0
   End If
Return
'
Count_number_of_active_fets:
Number_of_active_fets = 0
For B_temp1 = 0 To 6
   If Active_fets.B_temp1 = 1 Then Incr Number_of_active_fets
Next B_temp1
Return
'
Is_fet_used:
' check, if command_b(2) (0 to 6) is a used Fet
' Used_fet = 0 to 127
   Error_req = 1
   If Used_fets > 0 Then
      ' This is Fet1:
      B_temp1 = 1
      Shift B_temp1, Left, Command_b(2)
      B_temp1 = B_temp1 AND Used_fets
      If B_temp1 > 0 Then Error_req = 0
   End If
Return
'
Switch_off:
'This is faster than calling Send_to_fet
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
Return
'
Reset_load:
Gosub Switch_off
El_mode = 0
Error_req = 0
Required_r = 3000
'3kOhm
Required_p = 0
Required_i = 0
Required_i_min = 0
Required_i_max = 0
Used_fets = 0
Voltage_last = 0
Number_of_used_fets = 0
Off_on = 0
On_off_counter = 0
All_current = 0
All_power = 0
Resistance = 3000
For Fet_number = 1 to 7
   ' for all fets
   Power_(Fet_number) = 0
   Current(Fet_number) = 0
   Adc_register(B_temp1) = 0
   Dac_out_voltage(Fet_number) = Da_resolution
Next Fet_number
Fet_number = 1
Highest_fet_number = 1
Fet_voltage_adder = Fet_voltage_adder_start
Max_total_current = Max_current_default * Number_of_active_fets
Max_total_power = Max_power * Number_of_active_fets
Max_power_save = Max_power * Save_factor
Set Led
Return
'
Modify_if_necessary:
If Voltage <> Voltage_last Then
   'volatege changed:  calculate new required_i, required_p and required_r
   Select Case El_mode
      Case 2
         ' I mode
         Temp_req_i = Required_i
         Temp_req_p = Voltage * Temp_req_i
         Temp_req_r = Voltage / Temp_req_i
         If Temp_req_r > 3000 Then Temp_req_r = 3000
         ' mOhm
         Gosub Find_fets_to_use
      Case 3
         ' P mode
         Temp_req_p = Required_p
         Temp_req_i = Temp_req_p / Voltage
         Temp_req_r = Voltage / Temp_req_i
         If Temp_req_r > 3000 Then Temp_req_r = 3000
         Gosub Find_fets_to_use
      Case 4
         ' R mode
         Temp_req_r = Required_r
         Temp_req_i = Voltage / Temp_req_r
         Temp_req_p = Voltage * Temp_req_i
         Gosub Find_fets_to_use
   End Select
   Voltage_last = Voltage
End If
'
' modify current by Fet voltage
If All_current < Required_i_min Then
   'find next fet with current < meancurrent
   ' mofified by Diff_to_mean:
   B_temp1 = 1
   B_temp2 = 1
   While B_temp1 = 1 And B_temp2 < 8
   ' called for Number_used_fets > 1 only!!
      Incr Fet_number
      If Fet_number = 8 Then Fet_number = 1
      If Fet_number = 1 And Used_fets_1 = 1 Then Gosub Diff_to_mean_low
      If Fet_number = 2 And Used_fets_2 = 1 Then Gosub Diff_to_mean_low
      If Fet_number = 3 And Used_fets_3 = 1 Then Gosub Diff_to_mean_low
      If Fet_number = 4 And Used_fets_4 = 1 Then Gosub Diff_to_mean_low
      If Fet_number = 5 And Used_fets_5 = 1 Then Gosub Diff_to_mean_low
      If Fet_number = 6 And Used_fets_6 = 1 Then Gosub Diff_to_mean_low
      If Fet_number = 7 And Used_fets_7 = 1 Then Gosub Diff_to_mean_low
      Incr B_temp2
      'To leave the loop :)
   Wend
   ' complete I too low -> raise fetvoltage
   ' lower Dac_out_voltage due to inverting LM324
   If Dac_out_voltage(Fet_number) > Fet_voltage_adder Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) - Fet_voltage_adder
      Gosub Send_to_fet
   End If
Else
   ' Before this is reached the first time, Fet_voltage_adder is Fet_voltage_adder_start
   Fet_voltage_adder = 1
   If All_current > Required_i_max Then
      'find next fet with current < meancurrent
      ' mofified by Diff_to_mean:
      B_temp1 = 1
      B_temp2 = 1
      While B_temp1 = 1 And B_temp2 < 8
      ' called for Number_used_fets > 1 only!!
         Incr Fet_number
         If Fet_number = 8 Then Fet_number = 1
         If Fet_number = 1 And Used_fets_1 = 1 Then Gosub Diff_to_mean_high
         If Fet_number = 2 And Used_fets_2 = 1 Then Gosub Diff_to_mean_high
         If Fet_number = 3 And Used_fets_3 = 1 Then Gosub Diff_to_mean_high
         If Fet_number = 4 And Used_fets_4 = 1 Then Gosub Diff_to_mean_high
         If Fet_number = 5 And Used_fets_5 = 1 Then Gosub Diff_to_mean_high
         If Fet_number = 6 And Used_fets_6 = 1 Then Gosub Diff_to_mean_high
         If Fet_number = 7 And Used_fets_7 = 1 Then Gosub Diff_to_mean_high
         Incr B_temp2
         'To leave the loop :)
      Wend
      ' complete I too high -> lower fetvoltage
      ' raise Dac_out_voltage due to inverting LM324
      Temp_w = Da_resolution - Fet_voltage_adder
      If Dac_out_voltage(Fet_number) < Temp_w Then
         Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Fet_voltage_adder
         Gosub Send_to_fet
      End If
   End If
   ' do nothing, if within hystersis
End If
Return
'
Diff_to_mean_low:
If Current(Fet_number) < Mean_current Then
   ' use this (increase), if current is lower than mean
   B_temp1 = 0
End If
Return
'
Diff_to_mean_high:
If Current(Fet_number) > Mean_current Then
   ' use this (decrease), if current is higher than mean
   B_temp1 = 0
End If
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
      Spiout Spi_buffer(1) , 2
      Set Fet1
   Case 2
      Reset Fet2
      Spiout Spi_buffer(1) , 2
      Set Fet2
   Case 3
      Reset Fet3
      Spiout Spi_buffer(1) , 2
      Set Fet3
   Case 4
      Reset Fet4
      Spiout Spi_buffer(1) , 2
      Set Fet4
   Case 5
      Reset Fet5
      Spiout Spi_buffer(1) , 2
      Set Fet5
   Case 6
      Reset Fet6
      Spiout Spi_buffer(1) , 2
      Set Fet6
   Case 7
      Reset Fet7
      Spiout Spi_buffer(1) , 2
      Set Fet7
End Select
Reset Ldac
'transfer to Output
Reset Ldac
'min time is 100ns
Set Ldac
Return
'
Measure_and_check:
   ' voltage
   Temp_w = Getadc(0)
   Voltage = Temp_w * Correction_u
   'V
   '
   ' Used fet are measured only for better accuracy
   All_current = 0
   All_power = 0
   If Used_fets_1 = 1 Then
      Adc_register(1) = Getadc(1)
      Current(1) = Adc_register(1) * Correction_i(1)
      Power_(1) = Voltage * Current(1)
      All_current = All_current + Current(1)
      All_power = All_power + Power_(1)
   End If
   If Used_fets_2 = 1 Then
      Adc_register(2) = Getadc(2)
      Current(2) = Adc_register(2) * Correction_i(2)
      Power_(2) = Voltage * Current(2)
      All_current = All_current + Current(2)
      All_power = All_power + Power_(2)
   End If
   If Used_fets_3 = 1 Then
      Adc_register(3) = Getadc(3)
      Current(3) = Adc_register(3) * Correction_i(3)
      Power_(3) = Voltage * Current(3)
      All_current = All_current + Current(3)
      All_power = All_power + Power_(3)
   End If
   If Used_fets_4 = 1 Then
      Adc_register(4) = Getadc(4)
      Current(4) = Adc_register(4) * Correction_i(4)
      Power_(4) = Voltage * Current(4)
      All_current = All_current + Current(4)
      All_power = All_power + Power_(4)
   End If
   If Used_fets_5 = 1 Then
      Adc_register(5) = Getadc(5)
      Current(5) = Adc_register(5) * Correction_i(5)
      Power_(5) = Voltage * Current(5)
      All_current = All_current + Current(5)
      All_power = All_power + Power_(5)
   End If
   If Used_fets_6 = 1 Then
      Adc_register(6) = Getadc(6)
      Current(6) = Adc_register(6) * Correction_i(6)
      Power_(6) = Voltage * Current(6)
      All_current = All_current + Current(6)
      All_power = All_power + Power_(6)
   End If
   If Used_fets_7 = 1 Then
      Adc_register(7) = Getadc(7)
      Current(7) = Adc_register(7) * Correction_i(7)
      Power_(7) = Voltage * Current(7)
      All_current = All_current + Current(7)
      All_power = All_power + Power_(7)
   End If
'
   Resistance = 3000
   If All_current > 0 Then
      Resistance = Voltage / All_current
      If Resistance > 3000 Then Resistance = 3000
   End If
'
   Mean_current = 0
   If Number_of_used_fets > 0 Then Mean_current = All_current / Number_of_used_fets
'
' check for limits:
   If Current(Fet_number) <= Max_current_default Then
      If Power_(Fet_number) > Max_power Then
         Gosub Reduce_current
         If Error_req = 1 Then
            Actual_power_too_high
            Gosub Reset_load
         End If
      End If
   Else
      Gosub Reduce_current
      If Error_req = 1 Then
         Actual_current_too_high
         Gosub Reset_load
      End If
   End If
Return
'
Reduce_current:
Error_req = 1
'
' Work in normal modes only, switch off in register mode or current calibrate mode:
If El_mode < 2 Or El_mode = 5 Then Return
If Used_fets_1 = 1 Then
   Fet_number = 1
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End If
If Used_fets_2 = 1 Then
   Fet_number = 2
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End If
If Used_fets_3 = 1 Then
   Fet_number = 3
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End If
If Used_fets_4 = 1 Then
   Fet_number = 4
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End If
If Used_fets_5 = 1 Then
   Fet_number = 5
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End IF
If Used_fets_6 = 1 Then
   Fet_number = 6
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End If
If Used_fets_7 = 1 Then
   Fet_number = 7
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End If
'
' Add one more FET and reduce current in all FETS
B_temp3 = Highest_fet_number + 1
While Error_req = 1 And B_temp3 < 8
   If B_temp3 = 2 Then
      If Active_fet_2 = 1 Then
         Used_fets_2 = 1
         Error_req = 0
         Incr Number_of_used_fets
         Highest_fet_number = B_temp3
      Else
         Incr B_temp3
      End If
   Else
      If B_temp3 = 3 Then
         If Active_fet_3 = 1 Then
            Used_fets_3 = 1
            Error_req = 0
            Incr Number_of_used_fets
            Highest_fet_number = B_temp3
         Else
            Incr B_temp3
         End If
      Else
         If B_temp3 = 4 Then
            If Active_fet_4 = 1 Then
               Used_fets_4 = 1
               Error_req = 0
               Incr Number_of_used_fets
               Highest_fet_number = B_temp3
            Else
               Incr B_temp3
            End If
         Else
            If B_temp3 = 5 Then
               If Active_fet_5 = 1 Then
                  Used_fets_5 = 1
                  Error_req = 0
                  Incr Number_of_used_fets
                  Highest_fet_number = B_temp3
               Else
                  Incr B_temp3
               End If
            Else
               If B_temp3 = 6 Then
                  If Active_fet_6 = 1 Then
                     Used_fets_6 = 1
                     Error_req = 0
                     Incr Number_of_used_fets
                     Highest_fet_number = B_temp3
                  Else
                     Incr B_temp3
                  End If
               Else
                  If B_temp3 = 7 Then
                     If Active_fet_7 = 1 Then
                        Used_fets_7 = 1
                        Error_req = 0
                        Incr Number_of_used_fets
                        Highest_fet_number = B_temp3
                     'Else  do nothing,
                     End If
                  End If
               End If
            End If
         End If
      End If
   End If
Wend
If Error_req = 0 Then
   Mean_current = All_current / Number_of_used_fets
End If
Return
'
Switch_on:
' Dac_out is set
If Used_fets_1 = 1 Then
   Fet_number = 1
   Gosub Send_to_fet
End If
If Used_fets_2 = 1 Then
   Fet_number = 2
   Gosub Send_to_fet
End If
If Used_fets_3 = 1 Then
   Fet_number = 3
   Gosub Send_to_fet
End If
If Used_fets_4 = 1 Then
   Fet_number = 4
   Gosub Send_to_fet
End If
If Used_fets_5 = 1 Then
   Fet_number = 5
   Gosub Send_to_fet
End If
If Used_fets_6 = 1 Then
   Fet_number = 6
   Gosub Send_to_fet
End If
If Used_fets_7 = 1 Then
   Fet_number = 7
   Gosub Send_to_fet
End If
Reset Led
Return
'
Operate_On_off_mode:
   If On_off_counter > On_off_time Then
      'time to switch
      If Off_on = 0 Then
         'off -> switch on
         Off_on = 1
         Gosub Switch_on
      Else
         Off_on = 0
         Gosub Switch_off
      End If
      On_off_counter = 0
   End If
   Incr On_off_counter
Return
'
Find_fets_to_use:
' require Temp_req_p and Temp_req_i
' called by require commands
' defines the Fet_number to start (will be the highest used FET)
Error_req = 1
Temp_single = Max_power * Number_of_active_fets
If Temp_req_p <= Temp_single Then
   Temp_single = Max_current_default * Number_of_active_fets
   If Temp_req_i <= Temp_single Then
      Number_of_used_fets = Temp_req_p / Max_power_save
      B_temp1 =  Temp_req_i / Max_current_default_save
      If B_temp1 > Number_of_used_fets Then Number_of_used_fets = B_temp1
      Incr Number_of_used_fets
      If Number_of_used_fets > 7 Then Number_of_used_fets = 7
      B_temp1 = 0
      Used_fets = 0
      If Active_fet_1 = 1 Then
         Used_fets_1 = 1
         Fet_number = 1
         Incr B_temp1
      End If
      If B_temp1 < Number_of_used_fets Then
         If Active_fet_2 = 1 Then
            Used_fets_2 = 1
            Fet_number = 2
            Incr B_temp1
         End If
      End If
      If B_temp1 < Number_of_used_fets Then
         If Active_fet_3 = 1 Then
            Used_fets_3 = 1
            Fet_number = 3
            Incr B_temp1
         End If
      End If
      If B_temp1 < Number_of_used_fets Then
         If Active_fet_4 = 1 Then
            Used_fets_4 = 1
            Fet_number = 4
            Incr B_temp1
         End If
      End If
      If B_temp1 < Number_of_used_fets Then
         If Active_fet_5 = 1 Then
            Used_fets_5 = 1
            Fet_number = 5
            Incr B_temp1
         End If
      End If
      If B_temp1 < Number_of_used_fets Then
         If Active_fet_5 = 1 Then
            Used_fets_4 = 1
            Fet_number = 4
            Incr B_temp1
         End If
      End If
      If B_temp1 < Number_of_used_fets Then
         If Active_fet_6 = 1 Then
            Used_fets_6 = 1
            Fet_number = 6
           Incr B_temp1
         End If
      End If
      If B_temp1 < Number_of_used_fets Then
         If Active_fet_7 = 1 Then
            Used_fets_7 = 1
            Fet_number = 7
         End If
      End If
      Highest_fet_number = Fet_number
      Error_req = 0
      Required_i = Temp_req_i
      Required_i_min = Required_i - Hysterese_i
      Required_i_max = Required_i + Hysterese_i
      Required_p = Temp_req_p
      Required_r = Temp_req_r
      Voltage_last = Voltage
   Else
      Required_current_too_high
   End If
Else
   Required_power_too_high
End If
Return
'
'----------------------------------------------------
   $include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
'
   Case 1
'Befehl &H01 (resolution 10mV);  1 byte / 3 byte
'lese aktuelle Spannung
'read actual voltage
'Data "1;ap,read actual voltage;1;9001,{0.00 to 90.00};lin;V"
      Tx_busy = 2
      Tx_time = 1
      Temp_w = Voltage * 100
      If Temp_w > 9000 Then Temp_w = 9000
      Tx_b(1) = &H01
      Tx_b(2) = High(Temp_w)
      Tx_b(3) = Low(Temp_w)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 2
'Befehl &H02; 1 byte / 3 byte
'liest gesamten Strom (1Bit -> 10mA)
'read all current
'Data "2;ap,read actual current;1;21001,{0.00 to 210.00};lin;A"
      Tx_busy = 2
      Tx_time = 1
      Temp_single = All_current * 100
      Temp_w = Temp_single
      Tx_b(1) = &H02
      Tx_b(2) = High(Temp_w)
      Tx_b(3) = Low(Temp_w)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 3
'Befehl &H03  0 - 6 (resolution 10mA); 2 byte / 4 byte
'liest aktuellen Strom eines FETs
'read actual current of a FET
'Data "3;ap,read actual current;7;30001,{0.00 to 30.00};lin;A"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            Gosub Is_fet_active
            If Error_req = 0 Then
               Tx_busy = 2
               Tx_time = 1
               Fet_number = Command_b(2) + 1
               Temp_w = Current(Fet_number) * 100
               Tx_b(1) = &H03
               Tx_b(2) = Command_b(2)
               Tx_b(3) = High(Temp_w)
               Tx_b(4) = Low(Temp_w)
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
   Case 4
'Befehl &H04  (resolution 10mW); 1 byte / 4 byte
'liest gesamte Leistung
'read all power
'Data "4;ap,read actual power;1;35001,{0.00 to 350.00};lin;W"
      Tx_busy = 2
      Tx_time = 1
      Temp_dw = All_power * 100
      Tx_b(1) = &H04
      Tx_b(2) = Temp_dw_b3
      Tx_b(3) = Temp_dw_b2
      Tx_b(4) = Temp_dw_b1
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 5
'Befehl &H05  0 - 6 (resolution 10mW); 2 byte / 4 Byte
'liest aktuelle Leistung eines FETs
'read actual power of a FET
'Data "5;ap,read actual power;7;5001,{0.00 to 50.00};lin;W"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            Gosub Is_fet_active
            If Error_req = 0 Then
               Tx_busy = 2
               Tx_time = 1
               B_temp1 = Command_b(2) + 1
               Temp_w = Power_(B_temp1) * 100
               'mW -> 10mW
               Tx_b(1) = &H05
               Tx_b(2) = Command_b(2)
               Tx_b(3) = High(Temp_w)
               Tx_b(4) = Low(Temp_w)
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
   Case 6
'Befehl &H06 (resolution mOhm); 1 byte / 4 byte
'liest aktuellen Widerstand
'read actual resistor
'Data "6;ap,read actual resistor;1;300000,{10 To 3000000};lin;mOhm"
      Tx_busy = 2
      Tx_time = 1
      Temp_dw = Resistance * 1000
      Tx_b(1) = &H06
      Tx_b(2) = Temp_dw_b3
      Tx_b(3) = Temp_dw_b2
      Tx_b(4) = Temp_dw_b1
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 7
'Befehl &H07 0 - 21000 (10mA resolution); 3 byte / -
'gewuenschten Strom
'required current
'Data "7;op,required current;1;21001,{0.00 To 210,00};lin;A"
      If Commandpointer >= 3 Then
         If Voltage > Minimum_voltage Then
            If Active_fets > 0 Then
               Temp_w_b1 = command_b(3)
               'low byte first
               Temp_w_b2 = command_b(2)
               Gosub Reset_load
               If Temp_w <= 21000 Then
                  If Temp_w > 0 Then
                     Temp_req_i = Temp_w / 100
                     Temp_req_p = Temp_req_i * Voltage
                     Temp_req_r = Voltage / Temp_req_i
                     If Temp_req_r > 3000 Then Temp_req_r = 3000
                     Gosub Find_fets_to_use
                     If Error_req = 0 Then
                        El_mode = 2
                        Reset Led
                     End If
                  Else
                     Parameter_error
                  End If
               End If
            Else
               Fet_not_active
            End If
         Else
            Voltage_too_low
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 8
'Befehl &H08  (10mA resolution); 1 byte / 3 byte
'gewuenschten Strom lesen
'read required current
'Data "8;ap,as7"
      Tx_busy = 2
      Tx_time = 1
      Temp_w  = Required_i * 100
      Tx_b(1) = &H08
      Tx_b(2) = High(Temp_w)
      Tx_b(3) = Low(Temp_w)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 9
'Befehl &H09 0 - 140000 (10mW resolution); 4 byte / -
'gewuenschte Leistung
'required power
'Data "9;op,required power;1;140001,{0.00 To 1400.00};lin;W"
      If Commandpointer >= 4 Then
         Temp_req_p_dw_b1 = command_b(4)
         'low byte first
         Temp_req_p_dw_b2 = command_b(3)
         Temp_req_p_dw_b3 = command_b(2)
         Temp_req_p_dw_b4 = 0
         If Voltage > Minimum_voltage Then
            If Active_fets > 0 Then
               Gosub Reset_load
               Temp_req_p = Temp_req_p_dw
               Temp_req_p = Temp_req_p /  100
               If Temp_req_p <= Max_total_power Then
                  If Temp_req_p_dw > 0 Then
                     Temp_req_i = Temp_req_p / Voltage
                     Temp_req_r = Voltage / Temp_req_i
                     If Temp_req_r > 3000 Then Temp_req_r = 3000
                     Gosub Find_fets_to_use
                     If Error_req  = 0 Then
                        El_mode = 3
                        Reset Led
                     End If
                  End If
               Else
                  Parameter_error
               End If
            Else
               Fet_not_active
            End If
         Else
            Voltage_too_low
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 10
'Befehl &H0A (10mW resolution); 1 byte / 4 byte
'gewuenschte Leistung lesen
'read required power
'Data "10;ap,as9"
      Tx_busy = 2
      Tx_time = 1
      Temp_dw = Required_p * 100
      Tx_b(1) = &H0A
      Tx_b(2) = Temp_dw_b3
      Tx_b(3) = Temp_dw_b2
      Tx_b(4) = Temp_dw_b1
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'

   Case 11
'Befehl &H0B 10mOhm - 3kOhm (resolution 1mOhm); 4 byte / -
'gewuenschten Widerstand schreiben
'write required resistor
'Data "11;op,required resistor:1;2999999,{1 To 3000000};lin;mOhm"
      If Commandpointer >= 4 Then
         Temp_req_r_dw_b1 = command_b(4)
         'low byte first
         Temp_req_r_dw_b2 = command_b(3)
         Temp_req_r_dw_b3 = command_b(2)
         Temp_req_r_dw_b4 = 0
         If Temp_req_r_dw < 2999999 Then
            If Voltage > Minimum_voltage Then
               If Active_fets > 0 Then
                  Incr Temp_req_r_dw
                  Temp_req_r = Temp_req_r_dw
                  Temp_req_r = Temp_req_r / 1000
                  Temp_req_i = Voltage / Temp_req_r
                  Temp_req_p = Temp_req_i * Voltage
                  Gosub Find_fets_to_use
                  If Error_req = 0 Then
                     El_mode = 4
                     Reset Led
                  End If
               Else
                  Fet_not_active
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
   Case 12
'Befehl &H0C (resolution 10mOhm); 1 byte / 4 byte
'gewuenschter Widerstand lesen
'read required resistor
'Data "12;ap,as11"
      Tx_busy = 2
      Tx_time = 1
      Temp_dw = Required_r * 1000
      Tx_b(1) = &H0C
      Tx_b(2) = Temp_dw_b3
      Tx_b(3) = Temp_dw_b2
      Tx_b(4) = Temp_dw_b1
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 13
'Befehl &H0D 0|1|2; 2 byte / -
'Wechsellast schreiben
'write on /off mode
'Data "13;or,on off mode;1;0,off,1,regulated;2,fixed"
      If Commandpointer >= 2 Then
         If Command_b(2) < 3  Then
            If El_mode > 0 Then
               On_off_mode = Command_b(2)
               If On_off_mode = 1 And El_mode = 1 Then On_off_mode = 2
               On_off_counter = 0
            Else
               Parameter_error
            ENd If
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 14
'Befehl &H0E; 1 byte / 2 byte
'Wechsellast lesen
'read on /off mode
'Data "14;ar,as13"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H0E
      Tx_b(2) = On_off_mode
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 15
'Befehl &H0F; 3 byte / -
'Zeit für Wechsellast schreiben
'write time for on - off mode
'Data "15;op,time for on off mode;1;10000,{0.001 To 10.000};lin;s"
      If Commandpointer >= 3 Then
         Temp_w = Command_b(2)
         Temp_w = Temp_w * 256
         Temp_w = Temp_w + Command_b(3)
         If Temp_w < 10000 Then
            On_off_time = Temp_w + 1
            On_off_time_eeram = On_off_time
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 16
'Befehl &H10; 1 byte / 3 byte
'Zeit für Wechsellast lesen
'read time for on - off mode
'Data "16;aa,as15"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H10
      Temp_w = On_off_time - 1
      Tx_b(2) = High(Temp_w)
      Tx_b(3) = Low(Temp_w)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 17
'Befehl &H11; 1 byte / 1 byte + string
'status info lesen
'read status info
'Data "17;aa,read status;b,{idle,test,I,P,R};20"
      If Commandpointer >= 2 Then
         Tx_busy = 2
         Tx_time = 1
         Tx_b(1) = &H11
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
                  B_temp1 = 11
                  Temps = "1: Testmode"
               Case 2
                  B_temp1 = 15
                  Temps = "2: current mode"
               Case 3
                  B_temp1 = 13
                  Temps = "3: power mode"
               Case 4
                  B_temp1 = 17
                  Temps = "4: resistor mode"
            End Select
            Tx_b(3) = B_temp1
            B_temp2 = 4
            For B_temp3 = 1 To B_temp1
               Tx_b(B_temp2) = Temps_b(B_Temp3)
               Incr B_Temp2
            Next B_Temp3
            Tx_write_pointer = B_temp1 + 3
         End If
         If Command_mode = 1 Then Gosub Print_tx
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 18
'Befehl &H12; 1 byte / -
'schaltet Last ab
'switch off
'Data "18;ou,switch off;1;0,idle;1,off"
      Gosub Reset_load
      Gosub Command_received
'
   Case 19
'Befehl &H13; 1 byte / 2 Byte
'Zahl der aktiven Fets lesen
'read number of active FETs
'Data "19;ar,read number of active FETs;1;b,{1 to 7}
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H13
      Tx_b(2) = Number_of_active_fets
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 20
'Befehl &H14; 1 byte / 2 Byte
'Zahl der benutzten Fets lesen
'read number of used FETs
'Data "20;ar,read number of used FETs;1;b,{1 to 7}"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H14
      Tx_b(2) = Number_of_used_fets
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 21
'Befehl &H15; 1 byte / 2 Byte
'Benutzte Fets lesen
'read used FETs
'Data "21;ar,read used FETs;1;b0 to 127"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H15
      Tx_b(2) = Used_fets
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 22
'Befehl &H16; 1 byte / 3 byte
'Maximale Leistung pro Fet lesen
'read maximum power per FET
'Data "22;lp,maximum power per FET;1;5001,{0 to 50,00};lin;Watt"
      Tx_busy = 2
      Tx_time = 1
      Temp_w = Max_power * 100
      Tx_b(1) = &H16
      Tx_b(2) = High(Temp_w)
      Tx_b(3) = Low(Temp_w)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 224
'Befehl &HE0; 3 byte / -
'Maximale Leistung pro Fet
'maximum power per FET
'Data "224;kp;maximum power per FET;1;5001,{0 to 50,00};lin;Watt"
      If Commandpointer >= 3 Then
         Temp_w = Command_b(2) * 256
         Temp_w = Temp_w + Command_b(3)
         Temp_single = Temp_w / 100
         ' W
         If Temp_single <= Max_power_default Then
            Max_power = Temp_single
            Max_power_eeram = Max_power
            Gosub Reset_load
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_incr_commandpointer
'
   Case 225
'Befehl &HE1 (0 to 127); 2  byte / -
'Aktive FETs binaer schreiben
'write active FETS binary
'Data "225;ka,active FETs, binary;b,{0 To 127}"
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
   Case 226
'Befehl &HE2; 1 byte / 2 byte
'Aktive FETs binaer lesen
'read active FETS binary
'Data "226;la,as225"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &HE2
      Tx_b(2) = Active_fets
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 227
'Befehl &HE3 0 to 6 , 0 to 4095; 4 byte / -
'Fet control register einstellen
'set fet control register
'Data "227;km,set fet control register;6;w,{0 To 4095}"
      If Commandpointer >= 4 Then
         If Command_b(2) < 7 Then
            W_temp1 = Command_b(3) * 256
            W_temp1 = W_temp1 + Command_b(4)
            If W_temp1 <= Da_resolution Then
               Gosub Is_fet_active
               If Error_req = 0 Then
                  If Voltage > Minimum_voltage Then
                     Gosub Reset_load
                     Fet_number = Command_b(2) + 1
                     Dac_out_voltage(Fet_number) = W_temp1
                     Gosub Send_to_fet
                     El_mode = 1
                     ' One FET only
                     Number_of_used_fets = 1
                     Used_fets = 1
                     Shift Used_fets, Left, Command_b(2)
                     Reset Led
                  Else
                     Voltage_too_low
                  End If
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
   Case 228
'Befehl &HE4; 2 byte / 4 byte
'Fet control register lesen
'read fet control register
'Data "228; lm,as227"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            Gosub Is_fet_active
            If Error_req = 0 Then
               Tx_busy = 2
               Tx_time = 1
               Tx_b(1) = &HE4
               Tx_b(2) = Command_b(2)
               Fet_number = Command_b(2) + 1
               Tx_b(3) = High(Dac_out_voltage(Fet_number))
               Tx_b(4) = Low(Dac_out_voltage(Fet_number))
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
   Case 229
'Befehl &HE5; 2 byte / 4 byte
'ADC register lesen
'read ADC register
'Data "229; lp,read ADC register;6;1024;lin;-"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            Gosub Is_fet_active
            If Error_req = 0 Then
               Tx_busy = 2
               Tx_time = 1
               Tx_b(1) = &HE5
               Tx_b(2) = Command_b(2)
               B_temp1 = Command_b(2) + 1
               Tx_b(3) = High(Adc_register(B_temp1))
               Tx_b(4) = Low(Adc_register(B_temp1))
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
'Data "230;ap,calibration voltage;1;90001;lin:mV"
      If Commandpointer >= 4 Then
         Temp_dw_b1 = command_b(4)
         'low byte first
         Temp_dw_b2 = command_b(3)
         Temp_dw_b3 = command_b(2)
         Temp_dw_b4 = 0
          'mV
          Temp_single = Temp_dw / 1000
         If Temp_single >= Min_cor_measure_voltage And Temp_single <= Max_voltage Then
            Calibrate_u = Temp_single
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
      Temp_dw = Calibrate_u * 1000
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
      If Calibrate_u > 0 Then
         If Voltage > Minimum_voltage Then
            Temp_w = Getadc(0)
            Temp_single3 = Temp_w
            'should be 90 * Temp_single3 / 1023  +- 20%  -> Volt
            Temp_single3 = Temp_single3 * 0.0879765
            Temp_single2 = Calibrate_u * 1.2
            Temp_single = Calibrate_u * 0.8
            If Temp_single3 > Temp_single And Temp_single3 < Temp_single2 Then
               ' Calibrate_u / Temp_w
               Correction_u = Calibrate_u / Temp_w
               Correction_u_eeram = Correction_u
            Else
               Out_of_limit
            End If
         Else
            Voltage_too_low
         End If
      End If
      Gosub Command_received
'
      Case 233
'Befehl &HE9; 2 byte / -
'Spannungseichung inkrementell ändern
'change voltage calibration by increment
'Data "233;kp,set voltage calibration by increment;255,{0 To -127,0 To 127};lin;-"
         If Commandpointer >= 2 Then
            Temp_single = Correction_u * 100000
            B_temp1 = Command_b(2)
            If B_temp1 < 127 Then
               If Temp_single > 7800 Then
                  Temp_single = Temp_single - B_Temp1
               End If
            Else
               If Temp_single < 10600 Then
                  B_temp1 =  B_temp1 - 128
                  Temp_single = Temp_single + B_temp1
               End If
            End If
            Correction_u = Temp_single / 100000
            Gosub Command_received
         Else_Incr_Commandpointer
'
   Case 234
'Befehl &HEA:1 byte / 2 byte
'Spannungseichung lesen
'read voltage calibration
'Data "234;lp,read voltage calibration;1:10801;lin;-"
      Tx_busy = 2
      Tx_time = 1
      Temp_single =  Correction_u * 100000
      Temp_w = Temp_single
      Tx_b(1) = &HEA
      Tx_b(2) = High(Temp_w)
      Tx_b(3) = Low(Temp_w)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 235
'Befehl &HEB 0 to 30000; 3 byte / -
'Strom für Stromeichung schreiben
'write current for current calibration
'Data "235;op,current for calibration;1;30001;lin:mA"
      If Commandpointer >= 3 Then
         Temp_w = Command_b(2) * 256
         Temp_w = Temp_w + Command_b(3)
         Temp_single3 = Temp_w
         Temp_single3 = Temp_single3 / 1000
         If Temp_single3 >= Min_cor_measure_current And Temp_single3 <= Max_current_default Then
            Calibrate_i = Temp_single3
            ' Ampere
         Else
            Calibrate_current_too_low
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 236
'Befehl &HEC; 1 byte / 3 byte
'Strom für Stromeichung lesen
'read current for calibration
'Data "236;ap,as235"
      Temp_single  = Calibrate_i * 1000
      Temp_w = Temp_single
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &HEC
      Tx_b(2) = High(Temp_w)
      Tx_b(3) = Low(Temp_w)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 237
'Befehl &HED 0 - 6 ; 2 byte / -
'Strom eichen
'calibrate Current
'Data "237;ku,calibrate current;0,FET1;1,FET2;2,FET3;3FET4;4,FET5;5,FET6;6,FET7"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            If Calibrate_i > 0 Then
               Stop Watchdog
               Fet_number = Command_b(2) + 1
               Dac_out_voltage(Fet_number) = 0
               Gosub Send_to_fet
               Tx = "{017}{001}Please set current to {001}{001}{001}{001} mA within 5 seconds{000}"
               Temps = "{032}{032}{032}{032}"
               Temp_single = Calibrate_i * 1000
               Temp_w = Temp_single
               Temps = Str(Temp_w)
               B_temp2 = 1
               B_temp3 = Len(Temps)
               B_temp3 = B_temp3 + 25
               For B_temp1 = 25 To B_temp3
                  Tx_b(B_temp1) = Temps_b(B_temp2)
                  Incr B_temp2
               Next B_temp1
               Tx_b(2) = 51
               Tx_write_pointer = 49
               If Command_mode = 1 Then Gosub Print_tx
               Wait 5
               Temp_w = Getadc(Fet_number)
               Gosub Reset_load
               If Temp_w > 0 Then
                  print Temp_w
                  Temp_single3 = Temp_w
                  'should be 30 * Temp_single3 / 1023  +- 20%  -> Ampere
                  Temp_single3 = Temp_single3 * 0.0293255
                  Temp_single2 = Calibrate_i * 1.2
                  Temp_single = Calibrate_i * 0.8
                  If Temp_single3 > Temp_single And Temp_single3 < Temp_single2 Then
                     ' Calibrate_i / Temp_w
                     Correction_i(Fet_number) = Calibrate_i / Temp_w
                     Correction_i_eeram(Fet_number) = Correction_i(Fet_number)
                     Tx = "{017}{029}Current measurement: success!"
                     Tx_write_pointer = 32
                     If Command_mode = 1 Then Gosub Print_tx
                  Else
                     Out_of_limit
                     Tx = "{017}{028}Current measurement: failed!"
                     Tx_write_pointer = 31
                     If Command_mode = 1 Then Gosub Print_tx
                  End If
               End If
               Start Watchdog
            Else
               Not_valid_at_this_time
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
      Case 238
'Befehl &HEE; 3 byte / -
'Stromeichung inkrementell aendern
'set current calibration by increment
'Data "238;kp,set current calibration by increment;7;255,{0 To -127,0 To 127};lin;-"
         If Commandpointer >= 3 Then
            If Command_b(2) < 7 Then
               B_temp1 = COmmand_b(2) + 1
               B_temp2 = Command_b(3)
               Temp_single = Correction_i(B_temp1)  * 100000
               If B_temp2 < 127 Then
                  If Temp_single > 2400 Then
                     Temp_single = Temp_single - B_Temp2
                  End If
               Else
                  B_temp2 =  B_temp2 - 128
                  If Temp_single < 3600 Then
                     Temp_single = Temp_single + B_temp2
                  End If
               End If
               Temp_single = Temp_single / 100000
               Correction_i(B_temp1) = Temp_single
            Else
               Parameter_error
            End If
            Gosub Command_received
         Else_Incr_Commandpointer
'
      Case 239
'Befehl &HEF; 2 byte / 4 byte
'Stromeichung lesen
'read current calibration
'Data "239;lp,read current calibration;7;4001;lin;-"
         If Commandpointer >= 2 Then
            If Command_b(2) < 7 Then
               Tx_busy = 2
               Tx_time = 1
               B_temp1 = Command_b(2) + 1
               Temp_single = Correction_i(B_temp1)
               Temp_single = Temp_single * 100000
               Temp_w = Temp_single
               Tx_b(1) = &HEF
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
Data "0;m;DK1RI;electronic load for 7 IRFP150;V03.0;1;145;1;49;1-1"
'
Announce1:
'Befehl &H01 (resolution 10mV);  1 byte / 3 byte
'lese aktuelle Spannung
'read actual voltage
Data "1;ap,read actual voltage;1;9001,{0.00 to 90.00};lin;V"
 '
Announce2:
'Befehl &H02; 1 byte / 3 byte
'liest gesamten Strom (1Bit -> 10mA)
'read all current
Data "2;ap,read actual current;1;21001,{0.00 to 210.00};lin;A"
'
Announce3:
'Befehl &H03  0 - 6 (resolution 10mA); 2 byte / 4 byte
'liest aktuellen Strom eines FETs
'read actual current of a FET
Data "3;ap,read actual current;7;30001,{0.00 to 30.00};lin;A"
'
Announce4:
'Befehl &H04  (resolution 10mW); 1 byte / 4 byte
'liest gesamte Leistung
'read all power
Data "4;ap,read actual power;1;35001,{0.00 To 350.00};lin;W"
'
Announce5:
'Befehl &H05  0 - 6 (resolution 10mW); 2 byte / 4 Byte
'liest aktuelle Leistung eines FETs
'read actual power of a FET
Data "5;ap,read actual power;7;5001,{0.00 To 50.00};lin;W"
'
Announce6:
'Befehl &H06 (resolution mOhm); 1 byte / 4 byte
'liest aktuellen Widerstand
'read actual resistor
Data "6;ap,read actual resistor;1;300000,{10 To 3000000};lin;mOhm"
'
Announce7:
'Befehl &H07 0 - 21000 (10mA resolution); 3 byte / -
'gewuenschten Strom
'required current
Data "7;op,required current;1;21001,{0.00 to 210,00};lin;A"
'
Announce8:
'Befehl &H08  (10mA resolution); 1 byte / 3 byte
'gewuenschten Strom lesen
'read required current
Data "8;ap,as7"
'
Announce9:
'Befehl &H09 0 - 140000 (10mW resolution); 4 byte / -
'gewuenschte Leistung
'required power
Data "9;op,required power;1;140001,{0.00 To 1400.00};lin;W"
'
Announce10:
'Befehl &H0A (10mW resolution); 1 byte / 4 byte
'gewuenschte Leistung lesen
'read required power
Data "10;ap,as9"
'
Announce11:
'Befehl &H0B 10mOhm - 3kOhm (resolution 1mOhm); 4 byte / -
'gewuenschten Widerstand schreiben
'write required resistor
Data "11;op,required resistor:1;2999999,{1 To 3000000};lin;mOhm"
'
Announce12:
'Befehl &H0C (resolution 10mOhm); 1 byte / 4 byte
'gewuenschter Widerstand lesen
'read required resistor
Data "12;ap,as11"
'
Announce13:
'Befehl &H0D 0|1|2; 2 byte / -
'Wechsellast schreiben
'write on /off mode
Data "13;or,on off mode;1;0,off,1,regulated;2,fixed"
'
Announce14:
'Befehl &H0E; 1 byte / 2 byte
'Wechsellast lesen
'read on /off mode
Data "14;ar,as13"
'
Announce15:
'Befehl &H0F; 3 byte / -
'Zeit für Wechsellast schreiben
'write time for on - off mode
Data "15;op,time for on off mode;1;10000,{0.001 To 10.000};lin;s"
'
Announce16:
'Befehl &H10; 1 byte / 3 byte
'Zeit für Wechsellast lesen
'read time for on - off mode
Data "16;aa,as15"
'
Announce17:
'Befehl &H11; 1 byte / 1 byte + string
'status info lesen
'read status info
Data "17;aa,read status;b,{idle,test,I,P,R};20"
'
Announce18:
'Befehl &H12; 1 byte / -
'schaltet Last ab
'switch off
Data "18;ou,switch off;1;0,idle;1,off"
'
Announce19:
'Befehl &H13; 1 byte / 2 Byte
'Zahl der aktiven Fets lesen
'read number of active FETs
Data "19;ar,read number of active FETs;1;b,{1 to 7}"
'
Announce20:
'Befehl &H14; 1 byte / 2 Byte
'Zahl der benutzten Fets lesen
'read number of used FETs
Data "20;ar,read number of used FETs;1;b,{1 to 7}"
'
Announce21:
'Befehl &H15; 1 byte / 2 Byte
'Benutzte Fets lesen
'read used FETs
Data "21;ar,read used FETs;1;b0 to 127"
'
Announce22:
'Befehl &H16; 1 byte / 3 byte
'Maximale Leistung pro Fet lesen
'read maximum power per FET
Data "22;lp,maximum power per FET;1;5001,{0 to 50,00};lin;Watt"
'
Announce23:
'Befehl &HE0; 3 byte / -
'Maximale Leistung pro Fet
'maximum power per FET
Data "224;kp;maximum power per FET;1;5001,{0 to 50,00};lin;Watt"
'
Announce24:
'Befehl &HE1 (0 to 127); 2  byte / -
'Aktive FETs binaer schreiben
'write active FETS binary
Data "225;ka,active FETs, binary;b,{0 To 127}"
'
Announce25:
'Befehl &HE2; 1 byte / 2 byte
'Aktive FETs binaer lesen
'read active FETS binary
Data "226;la,as225"
'
Announce26:
'Befehl &HE3 0 to 6 , 0 to 4095; 4 byte / -
'Fet control register einstellen
'set fet control register
Data "227;km,set fet control register;6;w,{0 To 4095}"
'
Announce27:
'Befehl &HE4; 2 byte / 4 byte
'Fet control register lesen
'read fet control register
Data "228; lm,as227"
'
Announce28:
'Befehl &HE5; 2 byte / 4 byte
'ADC register lesen
'read ADC register
Data "229; lp,read ADC register;6;1024;lin;-"
'
Announce29:
'Befehl &HE6 0 to 90000; 4 byte / -
'Spannung für Spannungseichung schreiben
'write voltage for voltage calibration
Data "230;ap,calibration voltage;1;90001;lin:mV"
'
Announce30:
'Befehl &HE7; 1 byte / 4 byte
'Spannung für Spannungseichung lesen
'read voltage for calibration
Data "231;la,as230"
'
Announce31:
'Befehl &HE8; 1 byte / -
'Spannung eichen
'calibrate Voltage
Data "232;ku,calibrate voltage;1;0,,idle;1 calibrate voltage"
'
Announce32:
'Spannungseichung inkrementell ändern
'change voltage calibration by increment
Data "233;kp,set voltage calibration by increment;255,{0 To -127,0 To 127};lin;-"
'
Announce33:
'Befehl &HEA:1 byte / 2 byte
'Spannungseichung lesen
'read voltage calibration
Data "234;lp,read voltage calibration;1:10801;lin;-"
'
Announce34:
'Befehl &HEB 0 to 30000; 3 byte / -
'Strom für Stromeichung schreiben
'write current for current calibration
Data "235;op,current for calibration;1;30001;lin:mA"
'
Announce35:
'Befehl &HEC; 1 byte / 3 byte
'Strom für Stromeichung lesen
'read current for calibration
Data "236;ap,as235"
'
Announce36:
'Befehl &HED 0 - 6 ; 2 byte / -
'Strom eichen
'calibrate Current
Data "237;ku,calibrate current;0,FET1;1,FET2;2,FET3;3FET4;4,FET5;5,FET6;6,FET7"
'
Announce37:
'Befehl &HEE; 3 byte / -
'Stromeichung inkrementell aendern
'set current calibration by increment
Data "238;kp,set current calibration by increment;7;255,{0 To -127,0 To 127};lin;-"
'
Announce38:
'Befehl &HEF; 2 byte / 4 byte
'Stromeichung lesen
'read current calibration
'Data "239;lp,read current calibration;7;4001;lin;-"
'
Announce39:
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;49"
'
Announce40:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce41:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce42:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,SERIAL,1"
'
Announce43:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'
Announce44:
' Undervoltage
Data "R !$7 !$9 !$11 IF $1<40"
'
Announce45:
' On- off mode only during operation
Data "R $0D IF &11.0 > 0"
'
Announce46:
' Switch off, if power is exceeded
Data "R $11=0! IF $4>$14*$15"
'
Announce47:
' Switch off, if current is exceeded
Data "R ?$11=0 IF $3>3000 OR $5 > 5000"
'
Announce48:
Data "S !E3 !E8 !ED IF $1 < 40"