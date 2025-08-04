'name : air_sensor_w
'Version V01.0, 20250803
'purpose : Program for Adafruit CCS811 airsensor (TM)
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware Wireless_interface Version V02.3 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1.14 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.14\_Introduction_master_copyright.bas"
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
$regfile = "m644def.dat"
'
'-----------------------------------------------------
$include "common_1.14\_Processor.bas"
$crystal = 20000000
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
'
'Radiotype 0: RFM95 900MHz; 1: RFM95 450MHz, 2: RFM95 150MHz, 3: nRF24 4: WLAN 5: RYFA689
'default RFM95 900MHz:
Const Radiotype = 1
Const Radioname = "radi"
Const Name_len = 5
'Interface: 0 other FU: 1:
Const InterfaceFU = 1
Const CCs_mode_default = 1
'----------------------------------------------------
$include "__use.bas"
$include "common_1.14\_Constants_and_variables.bas"
$include "common_1.14\wireless_constants.bas"
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
Dim Ccs_mode As Byte
Dim CCs_mode_eeram As Eram Byte
'
$lib "i2c_twi.lbx"
Wait 1
'----------------------------------------------------
$include "common_1.14\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.14\_Config.bas"
'
Restart:
'----------------------------------------------------
$include "common_1.14\_Main.bas"
'
'----------------------------------------------------
$include "common_1.14\_Loop_start.bas"
If wireless_active = 1 Then
   Select Case Radio_type
      Case 0
         Gosub Receive_wireless0
   End Select
End If
'
$include "common_1.14\_Main_end.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.14\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.14\_Init.bas"
'
'----------------------------------------------------
$include "common_1.14\_Subs.bas"
'
'----------------------------------------------------
'
Start_CCS811:
   ' as per datasheet
   ' start: CCS811 is in bootloader mode
   ' write to register APP_START (&HF4) with no data start it
   B_temp1 = &HF4
   Gosub S
   ' mode 1 to mode register(&H01)
   ' only bit 6:4 must bet; other not changed (set 0:1 to 00)!!!!
B:
   Gosub Read_status
   If CCs_status.4 = 1 Then
      Dat(1) = Ccs_mode
      ' default: Mod1; other bits: no interrupt
      Dat(2) = &B00010000
      waitms 100
      I2csend I2c_adr, Dat(1), 2
   Else
      Print CCs_status
      Goto B
   End If
   '
   ' in App mode now
Return
'
Read_status:
   B_temp1 = &H00
   B_temp3 = 1
   Gosub S
   Gosub R
   Ccs_status = Dat(1)
Return
'
Read_data:
   Gosub Read_status
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
      Ccs_error_flag = 0
   End If
Return
'
S:
   Stop Watchdog
   I2csend I2c_adr, B_temp1
   If Err = 1 Then
      I2c_error
      print "error"
   End If
   Start Watchdog
Return
'
R:
   Stop Watchdog
   I2creceive I2c_adr, Dat(1), 0, B_temp3
   If Err = 1 Then
      I2c_error
      print "error"
   End If
   Start Watchdog
Return
'
'***************************************************************************
$include "common_1.14\_RFM95.bas"
$include "common_1.14\nrf24.bas"
   '$include "common_1.14\A7129_setup.bas"
   '$include  "common_1.14\A7129.bas"
   '$include "common_1.14\_RRYFA689.bas"
'----------------------------------------------------
$include "_Commands.bas"
$include "common_1.14\_Commands_required.bas"
'
$include "common_1.14\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'