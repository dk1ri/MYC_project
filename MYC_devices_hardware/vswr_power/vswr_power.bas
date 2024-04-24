'name : vswr_power.bas
'Version V01.0, 20240423
'purpose : This is a measurement device for VSWP and power with AD8318 modules
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware vswr_power V01.0 by DK1RI
'
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1.13 with includefiles must be copied to the directory of this file!
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
'-----------------------------------------------------
' Inputs /Outputs : see file __config.bas
' For announcements and rules see Data section in announcements.bas
'
'------------------------------------------------------
' Missing/errors:
'
'------------------------------------------------------
' Detailed description
'
'----------------------------------------------------
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$include "common_1.13\_Processor.bas"
$crystal = 20000000
'
'----------------------------------------------------
'
'=========================================
' Dies Werte koennen bei Bedarf geaendert werden!!!
' These values must be modified on demand!!!!
'
Const I2c_address = &H27
Const No_of_announcelines = 18
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
Const count_0 = 930
Const count_60 = 3210
Const Difference = (Count_60 - Count_0)

'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim Forward As Word
Dim Reflected As Word
Dim Temp_single1 As Single
Dim Temp_single2 As Single
Dim Temp_single3 As Single
Dim Vswr As Byte
Dim Attf As Word
Dim Attr As Word
Dim Temp_val As Word
'
$lib "i2c_twi.lbx"
Wait 1
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
$include "common_1.13\_Main_end.bas"
'
'----------------------------------------------------
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
Measure_forward:
   Reset CS2
   W_temp1 = 0
   Waitus 3
   Set CLK2
   Waitus 3
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   ' bit 11
   W_temp1.11 = Miso2
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   W_temp1.10 = Miso2
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   W_temp1.9 = Miso2
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   W_temp1.8 = Miso2
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   W_temp1.7 = Miso2
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   W_temp1.6 = Miso2
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   W_temp1.5 = Miso2
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   W_temp1.4 = Miso2
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   W_temp1.3 = Miso2
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   W_temp1.2 = Miso2
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   W_temp1.1 = Miso2
   Reset CLK2
   Waitus 3
   Set CLK2
   Waitus 3
   W_temp1.0 = Miso2
   Reset CLK2
   Set CS2
   Gosub Calc_dB
   Forward = W_temp1 + Attf
Return
'
Measure_reflected:
   Reset CS1
   W_temp1 = 0
   Waitus 3
   Set CLK1
   Waitus 3
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   ' bit 11
   W_temp1.11 = Miso1
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   W_temp1.10 = Miso1
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   W_temp1.9 = Miso1
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   W_temp1.8 = Miso1
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   W_temp1.7 = Miso1
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   W_temp1.6 = Miso1
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   W_temp1.5 = Miso1
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   W_temp1.4 = Miso1
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   W_temp1.3 = Miso1
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   W_temp1.2 = Miso1
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   W_temp1.1 = Miso1
   Reset CLK1
   Waitus 3
   Set CLK1
   Waitus 3
   W_temp1.0 = Miso1
   Reset CLK1
   Set CS1
   Gosub Calc_dB
   Reflected = W_temp1 + Attr
Return
'
Calc_vswr:
   Temp_single1 = Reflected / Forward
   Temp_single2 = 1 + Temp_single1
   Temp_single3 = 1 - Temp_single1
   Temp_single2 = Temp_single2 / Temp_single3
   Temp_single1 = Temp_single2 * 10
   Vswr = Temp_single1
Return
'
Calc_dB:
' Count_60: -60dBm -> 3210 counts (measured mean)
' Count_0: 0 dBm -> 930 counts (measured)
' 3210 - 930) / (600 -0) = 3.82 counts /db
' dBm: result: ((counts - 952)/3.82) * -1) + 600 (0.1 dB reslution)
' ( -60dBm -> 0
   Temp_single2 = Difference / 600
   Temp_single2 = Temp_single2 * -1
   Temp_single1 = W_temp1 - Count_0
   Temp_single1 = Temp_single1 / Temp_single2
   Temp_single1 = Temp_single1 + 600
   If Temp_single1 >= 0 Then
      W_temp1 = Temp_single1
   Else
      W_temp1 = 0
   End If
Return
'
Read_temp_f:
   Temp_val = Getadc(0)
   Temp_val = Getadc(0)
   Gosub Temperatur
Return
'
Read_temp_r:
   Temp_val = Getadc(1)
   Temp_val = Getadc(1)
   Gosub Temperatur
Return
'
Temperatur:
' 1.1V refenrence -> V = count / 1048 * 1.1
' 2mV / degC
' Temp = V * 1000 / 2 - 2730   (0.1 degC resolution)
   Temp_single1 = Temp_val * 5.248091
   Temp_single1 = Temp_single1 - 2730
   If Temp_single1 > 0 Then
      Temp_val = Temp_single1
   Else
      Temp_val = 0
   End If
Return

'***************************************************************************
'
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