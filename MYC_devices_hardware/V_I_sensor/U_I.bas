'name : U_I.bas
'Version V02.1, 20250809
'purpose : Program for U / I Sensor INA219
'This Programm workes with serial protocol or use a wireless interface
'Can be used with hardware Wireless_interface Version V02.3 by DK1RI
'
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
' Inputs / Outputs : see file __config.bas
'
'------------------------------------------------------
' Missing/errors:

'------------------------------------------------------
' Detailed description

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
' Dies Werte koennen bei Bedarf geaendert werden!!!
' These values must be modified on demand!!!!

'
'I2C address of Sensor (default)
Dim I2c_addr As Byte
' &H40  * 2
I2c_addr = &H80
Const No_of_announcelines = 24
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 50

'
'Radiotype 0: RFM95 900MHz; 1: RFM95 450MHz, 2: RFM95 150MHz, 3: nRF24 4: WLAN 5: RYFA689
'default RFM95 900MHz:
Const Radiotype = 3
Const Radioname = "radi"
Const Name_len = 5
'Interface: 0 other FU: 1:
Const InterfaceFU = 1
'----------------------------------------------------
$include "__use.bas"
$include "common_1.14\_Constants_and_variables.bas"
$include "common_1.14\wireless_constants.bas"
'
Const Shunt_voltage_reg = &H01
Const Bus_voltage_reg = &H02
Const Current_reg = &H04
Const Power_reg = &H03
Const Calibration_reg = &H05
Dim I2c_data As String * 4
Dim I2c_data_b(3) As Byte At I2c_data Overlay
Dim Is_minus As Byte
Dim S As Single
'
$lib "i2c_twi.lbx"
waitms 100
'----------------------------------------------------
$include "common_1.14\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.14\_Config.bas"
'
'----------------------------------------------------
Restart:
'
$include "common_1.14\_Main.bas"
'
Gosub Ina_setup
'----------------------------------------------------
$include "common_1.14\_Loop_start.bas"
'
If wireless_active = 1 Then
   Select Case Radio_type
      Case 0
         Gosub Receive_wireless0
   End Select
End If
:
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
'
'----------------------------------------------------
'
Ina_setup:
I2c_data_b(1) = Calibration_reg
' LSB = 3000/32768 = 92uA  -> 100uA
' Reg = 0,0496/(100uA * 0.1) = 4096/A -> &H1000
I2c_data_b(2) = &H10
I2c_data_b(3) = &H00
B_temp1 = 3
Gosub Write_i2c_data
Return
'
Write_i2c_data:
   i2csend  I2c_addr, I2c_data_b(1), B_temp1
   i2c_error
Return
'
Read_i2c_data:
   B_temp1 = 1
   B_temp2 = 2
   i2creceive I2c_addr, I2c_data_b(1), B_temp1, B_temp2
   i2c_error
Return
'

Complement:
Is_minus = 0
W_temp1_h = I2c_data_b(1)
W_temp1_l = I2c_data_b(2)
If W_temp1_h > &B01111111 Then
   ' negative
   W_temp1_h = W_temp1_h Xor &HFFFF
   W_temp1_l = W_temp1_l Xor &HFFFF
   W_temp1_h = W_temp1_h And &B01111111
   Incr W_temp1
   Is_minus = 1
End If
Return
'
'***************************************************************************
$include "common_1.14\_RFM95.bas"
$include "common_1.14\nrf24.bas"
   '$include "common_1.14\A7129_setup.bas"
   '$include  "common_1.14\A7129.bas"
   '$include "common_1.14\_RRYFA689.bas"
'
$include "_Commands.bas"
$include "common_1.14\_Commands_required.bas"
'
$include "common_1.14\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"