'-----------------------------------------------------------------------
'name : electronic_load.bas
'Version V05.2, 20240625
'purpose : This is a electronic load for 7 fets IRFP150
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware electronic_load V04.1 by DK1RI
'
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory common_1,13 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.13\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
' SPI
'-----------------------------------------------------
' Inputs /Outputs : see file __config
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'
'Something about the programm design:
'This programm workes with 1 to 7 FETs IRFP150:
'The program uses these limits (contants Component_u ...)
'Vmax = 90V (100V)
'Imax = 26A   (30A at 100 degC)
'Ptot = 200W -> 150W
'Ron = 50mOhm
'so the minimum voltage to be applied and will work under all conditions is
' (10mOhm resistor for measuring)
' (50 + 10 mOhm) * 30A = 1,8V
' If current (per FET) is lower, lower voltage can be used.
' The Fets will not swich on if the voltage is below 400mV.
'
'Most internal calculation are in V, A and W and Ohm and use single variables.

'The resolution used by commands is 1mV, 1mA, 1mW and 1mOhm
'
'The board uses the ADS1115 chip (16Bit) but 15bit are used only (no negative values of the ADC)
'
'The el load will not switch on for voltages below 400mV.
'
'The full scale range of the AD Converter is .256V. This limits the current to 25.6A with 10mOhm resistor.
'The current resolution is 25.6A / 32767 = 0.78mA  (15bit)
'
'The voltage resolution is nominal 3mV ( 90V / 32700)
'
'The maximum of the required resistor is given by the max voltage and the minimum current:
' 90V / 0.7mA ~ 120kOhm
'The required resistor has a range from 1 to 120.000.000 mOhm
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
'During startup the FET voltage is increased by a specific value for all available FETs in turn.
'After the first overshot the gate voltage is increased / decreased for the FET with the current most away from the
'required value as required.
'The check of current / power for overload is done on a per FET base after each measurement.
'
'Each ADC handles two chanals. The input of the ADC must be configured for each chanal, and after a wait time
'the data can be read.
'All active Fets are measured always in two loops: adc_chanal1: U, Fetno 2,4,6 than adc_chanal0:  Fetno 1,3,5,7,
'check and modfication is made after the second loop:
'
'- configure ADCs (MUX) for chanal 0, start timer1
'- after Timer1 = 32 (860SPS, start), 350 (128SPS, regulation):
'- read data of all available ADCs, configure ADC (MUX) for chanal 1, start timer1 again
'- after Timer1 = 32 (860SPS, start), 350 (128SPS, regulation):
'- read data, do check and analyze
'- configure ADC (MUX) for chanal 0, start timer1 again
'..
'- analyze data
' ...
'
:
'Calculation of resistors:
'Voltage (90V):
' R38 = 100, R39 = 5k6 ; R38||R39 = 98,24561
' Umes = V * R38||R39 / (33k + 1k5 + R38||R39) = 90 * 98,24561 * (33k + 1k5 + 98,24561) = 0,255565 V
' nominal error = 0.255565 / 0,256 = 0,,16%
'
'
'Fetvoltage:
'For Fet control
'Vin- = 0... 5V        Voutmust = 10V ... 3V        (Threshhold Voltage is 4V about at 50V 100mA)
'
'complete formula for subtraction amplifier (for IC11D):
'Vout = V+ * ((R18 + R17)*R8))/((R7+R8) * R17) - V- * R18 /R17
'real circuit:
'          V+           9        V
'         R18 =        12        kOhm
'        R999 =         8,2      kOhm
'          R7 =         1,3      kOhm
'          R8 =         1        kOhm
'       VIN-1 =         0        V
'      Vin- 2 =         4,75     V
'       Vin-3 =         5        V
'Vout for Vin = 0V        9,63944856839873
'Vout for Vin = 4,75V     2,68822905620361
'Vout for Vin = 5V        2,32237539766702
'
'----------------------------------------------------
$regfile = "m328pdef.dat"

'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.13\_Processor.bas"
'
$initmicro
'----------------------------------------------------
'
'1...127:
Const I2c_address = 21
Const No_of_announcelines = 63
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'If other FETs are used or less then 7 FETs are installed, the constants must be modified.
'Modification of announcements may be necessary as well.
'
'el load specific Constants:
Const Max_number_of_fets = 7
Const Component_u = 90
Const Component_i = 26 * Max_number_of_fets
' by cooling:
Const Component_p = 150
Const Component_pp = 150
Const Max_power_default = 50.0
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
'for voltage mode
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
Const Hyst_default = 0.0
' 1%
'
' connected to SDA
Const Adc_adress_F1_U  = &B10010100
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
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
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
'default: 0: off, 1: V, 2:I, 3: P, 4: R, 5: Testmode, 6: calibrate V, 7: calibrate I
' 6: Voltage calibration, 7: current calibration
Dim Timer1_value As Word
'
Dim Error_req As Byte
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
$include "common_1.13\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.13\_Config.bas"
'
'----------------------------------------------------
$include "common_1.13\_Main.bas"
'
'----------------------------------------------------
$include "common_1.13\_Loop_start.bas"
'
'----------------------------------------------------
'
If TCNT1 = 0 Then Start Timer1
If Tcnt1 >= Timer1_value Then
   ' waittime ealpsed -> measure
   Stop Timer1
   If Adc_chanal = 1 Then
      Current_min = &H7FFF
      Current_max = 0
      Adc_adress = Adc_adress_F1_U
      ' voltage
      Measure_v = 1
      Gosub Receive_adc_data
      If Temp_w > &H7FFF Then Temp_w = 0
      Voltage_w = Temp_w
      If Active_fets.1 = 1 Then
         Measure_fet = 2
         Adc_adress = Adc_adress_F3_F2
         Gosub Receive_adc_data
      End If
      If Active_fets.3 = 1 Then
         Measure_fet = 4
         Adc_adress = Adc_adress_F5_F4
         Gosub Receive_adc_data
      End If
      If Active_fets.5 = 1 Then
         Measure_fet = 6
         Adc_adress = Adc_adress_F7_F6
         Gosub Receive_adc_data
      End If
      ' chanal for next measurement
      Adc_chanal = 0
      Gosub Send_i2c_config
   Else
      If Active_fets.0 = 1 Then
         Measure_fet = 1
         Adc_adress = Adc_adress_F1_U
         Gosub Receive_adc_data
      End If
      If Active_fets.2 = 1 Then
         Measure_fet = 3
         Adc_adress = Adc_adress_F3_F2
         Gosub Receive_adc_data
      End If
      If Active_fets.4 = 1 Then
         Measure_fet = 5
         Adc_adress = Adc_adress_F5_F4
         Gosub Receive_adc_data
      End If
      If Active_fets.6 = 1 Then
         Measure_fet = 7
         Adc_adress = Adc_adress_F7_F6
         Gosub Receive_adc_data
      End If
      Adc_chanal = 1
      Gosub Send_i2c_config
      ' all data availanble:
      Gosub Calculate
      Gosub Modify_if_necessary
   End If
'
   Tcnt1 = 0
   Start Timer1
End If
'
If On_off_mode > 0 Then Gosub Operate_On_off_mode
'
'----------------------------------------------------
$include "common_1.13\_Main_end.bas"
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.13\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.13\_Init.bas"
'
'----------------------------------------------------
$include "common_1.13\_Subs.bas"
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
      Gosub Send_to_fet
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
Adc_speed = 0
Stop Timer1
Adc_chanal = 0
Tcnt1 = 0
Start Timer1
Gosub Info_at_reset
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
      If Hyst = 0 Then
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
      If Hyst = 0 Then
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
      If Hyst = 0 Then
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
      If Hyst = 0 Then
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
            If Resistance > Required_r_p Then Gosub Increase_dac_out_voltage
         End If
      End If
   Case Else
      Return
End Select
Return
'
Lower_dac_out_voltage:
' increase I -> lower resistance -> raise fetvoltage
' lower Dac_out_voltage due to inverting LM324
'
   If Adc_speed = 3 Then
      ' final approach
      ' use Fet with lowest current
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
   ' decrease I -> increase resistance -> lower fetvoltage
   ' Increase ADC accuracy after 1st overshot
   Adc_speed = 3
   ' use fet with highest current
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
NOP
NOP
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
   If Current(Measure_fet) > Max_current Then
      Actual_Current_too_high
      Gosub  Reset_load
   Else
      If Power_(Measure_fet) > Max_power Then
         Actual_power_too_high
         Gosub  Reset_load
      End If
   End If
End If
Measure_v = 0
Return
'
Info_at_reset:
   Tx_b(1) = &H02
   Tx_b(2) = 0
   Tx_b(3) = 0
   Tx_b(4) = 0
   Tx_write_pointer = 5
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
   Tx_b(1) = &H04
   Tx_b(2) = 0
   Tx_b(3) = 0
   Tx_b(4) = 0
   Tx_write_pointer = 5
   If Command_mode = 1 Then Gosub Print_tx
    Gosub Command_received
   Tx_b(1) = &H04
   Tx_b(2) = 0
   Tx_b(3) = 0
   Tx_b(4) = 0
   Tx_b(5) = 0
   Tx_write_pointer = 6
   If Command_mode = 1 Then Gosub Print_tx
Return
'----------------------------------------------------
$include "_Commands.bas"
$include "common_1.13\_Commands_required.bas"
'
$include "common_1.13\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'