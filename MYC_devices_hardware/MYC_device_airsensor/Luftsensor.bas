'name : Luftsensor
'Version V01.2, 20240609
'purpose : Program for Adafruit CCS811 airsensor (TM)
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware Klimasensor V02.1 by DK1RI
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
'Uses Mode 1 of the sensor only
'Please read instructions for the sensor!
'
'----------------------------------------------------
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$include "common_1.13\_Processor.bas"
$crystal = 10000000
'
'----------------------------------------------------
'
'=========================================
' Dies Werte koenne bei Bedarf geaendert werden!!!
' These values must be modified on demand!!!!
'
' not used
Const I2c_address = &H0
Const No_of_announcelines = 20
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
' I2C adress of sensor
' 7Bit &H58B
Const I2c_adr = &B10110100
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim Dat(9) As Byte
Dim CO_w As Word
Dim TVOC As Word
Dim Check_time As Word
Dim CCs_status As Byte
Dim CCs_rawdata As Word
Dim CCs_error As Byte
Dim CCs_error_flag As Byte
Dim Ready_flag As Byte
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
Start_CCS811:
   ' as per datasheet
   ' start: CCS811 is in bootloader mode
   ' write to register APP_START with no data start it
   Stop Watchdog
   B_temp1 = &HF4
   Gosub S
   ' mde 1 to mode register
   ' only bit 6:4 must bet; other not changed (set 0:1 to 00)!!!!
   B_temp1 = &H01
   B_temp3 = 1
   Gosub S
   Gosub R
   B_temp1 =  B_temp1  AND &B10001100
   Dat(1) = &H01
   Dat(2) = B_temp1  OR &B00010000
   waitms 100
   I2csend I2c_adr, Dat(1), 2
   Start Watchdog
   '
   ' in App mode now
Return
'
Read_data:
   B_temp1 = &H00
   B_temp3 = 1
   Gosub S
   Gosub R
   Ccs_status = Dat(1)
   'error:
   If Ccs_status.0 = 1 Then
      ' error
      Ccs_error_flag = 1
   End If
   '
   Ready_flag =  Ccs_status.3
   If Ready_flag = 1 Then
      B_temp1 = &H03
      B_temp3 = 2
      Gosub S
      Gosub R
      Ccs_rawdata = Dat(1) * 256
      Ccs_rawdata = Ccs_rawdata + Dat(2)
      '
      B_temp1 = &H02
      B_temp3 = 4
      Gosub S
      Gosub R
      CO_w = Dat(1) * 256
      CO_w = CO_w + Dat(2)
      TVOC = Dat(3) * 256
      TVOC = TVOC + Dat(4)
      Ccs_status = 0
   End If
Return
'
S:
   Stop Watchdog
   I2csend I2c_adr, B_temp1
   If Err = 1 Then
      I2c_error
   End If
   Start Watchdog
Return
'
R:
   Stop Watchdog
   I2creceive I2c_adr, Dat(1), 0, B_temp3
   If Err = 1 Then
      I2c_error
   End If
   Start Watchdog
Return
'
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