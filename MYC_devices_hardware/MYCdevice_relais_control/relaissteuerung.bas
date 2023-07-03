'-----------------------------------------------------------------------
'name : relaisteuerung_basom.bas
'Version V06.1, 20230629
'purpose : Control of a board with 4 Relais and 11 Inputs
'Can be used with hardware relaisteuerung Version V05.0 by DK1RI
'Pin description was changed with V03,0, so it is not compatible with earlier boards!!
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,13 with includefiles must be copied to the directory of this file!
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
' AD Converter 0 - 3
' I2C
' Inputs / Outputs : see file __config.bas
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'
' Detailed description
'
'----------------------------------------------------
'$regfile = "m168pdef.dat"
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.13\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 8
Const No_of_announcelines = 32
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim Adc_value As Word
Dim Adc_reference As Byte
Dim Adc_reference_eeram As Eram Byte
'
'----------------------------------------------------
$include "common_1.13\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.13\_Config.bas"
'
'----------------------------------------------------
' procedures at start
'
'----------------------------------------------------
$include "common_1.13\_Main.bas"
'
'----------------------------------------------------
$include "common_1.13\_Loop_start.bas"
'
'----------------------------------------------------
'
' ---> Specific actions
'
'----------------------------------------------------
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
Send_input_2:
Start Adc
Tx_b(1) = Command_b(1)
Select Case Tx_b(1)
   Case &H0C
      Adc_value = Getadc(3)
      Adc_value = Getadc(3)
   Case &H0D
      Adc_value = Getadc(2)
      Adc_value = Getadc(2)
   Case &H0E
      Adc_value = Getadc(1)
      Adc_value = Getadc(1)
   Case &H0F
      Adc_value = Getadc(0)
      Adc_value = Getadc(0)
End Select
Stop Adc
Tx_b(2) = High(Adc_value)
Tx_b(3) = Low(Adc_value)
Tx_time = 1
Tx_write_pointer = 4
If Command_mode = 1 Then Gosub Print_tx
Gosub Command_received
Return
'----------------------------------------------------
$include "_Commands.bas"
$include "common_1.13\_Commands_required.bas"
'
'
'-----------------------------------------------------
'    $include "_Commands.bas"
$include "common_1.13\_Commands_required.bas"
'
$include "common_1.13\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'