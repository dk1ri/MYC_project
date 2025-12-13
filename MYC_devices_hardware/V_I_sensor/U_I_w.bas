'name : U_I_w.bas
'Version V3.0, 20251210
'purpose : Program for U / I Sensor INA219
'This Programm workes with serial protocol or use a wireless interface
'Can be used with hardware Wireless_interface Version V05.0 by DK1RI
'
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1.14 (202512) with includefiles must be copied to the directory of this file!
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
$regfile = "m1284pdef.dat"
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
' &H40  * 2 of INA219
I2c_addr = &H80
Const No_of_announcelines = 21
'
'Radiotype 0: no radio; 1:RFM95 433MHz; 2:WLAN 3: RYFA689 4: nRF24, 5: Bluetooth
'default nRF24
Const Radiotype_default = 4
Const Radioname_default = "radix"
' 433.05 - 434,79MHz -> 433 - 434,7; 1kHz spacing
' 434MHZ:
Const Radio_frequency_default0 = 1000
Const Radio_frequency_start0 = 433000000
' WLAN: 2,4GHZ - 2.48GHz
'
' RYFA689 ???
'
'nrf24:  2,4 - 2.5 GHz; 1MHz spacing; 128 chanals
' Bluetooth:   2,4 - 2.5 GHz;
'
Const Radio_frequency_default4 = 40
'
Const Name_len = 5
'Interface: 0 other FU: 1:
Const InterfaceFU = 1
'
Const DIO_length = 5000
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
'
$lib "i2c_twi.lbx"
wait 10
print "start"
'----------------------------------------------------
$include "common_1.14\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.14\_Config.bas"
'
'----------------------------------------------------
Restart:
'
If Pin_reset = 0 Then Gosub Reset_
'
If First_set <> 5 Then Gosub Reset_
'
$include "common_1.14\_Init.bas"
'
'Gosub Ina_setup
'
'----------------------------------------------------
$include "common_1.14\_Loop_start.bas"
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
$include "common_1.14\_Subs.bas"
'
'----------------------------------------------------
Ina_setup:
' Config register not modified:
' Full range 32V; 8mV rsolution
' Gain 8 range:320mV   100uA resolution
' 12 bit 532ms
' shunt / bus continious
'
I2c_data_b(1) = Calibration_reg
' LSB = 3000/32768 = 92uA  -> 100uA
' Reg = 0,0496/(100uA * 0.1) = 4096/A -> &H1000
' last bit 0 _shift left 1 bit -> &H2000
I2c_data_b(2) = &H20
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
$include "common_1.14\RFM95.bas"
$include "common_1.14\Bluetooth.bas"
$include "common_1.14\nrf24.bas"
'$include  "common_1.14\A7129.bas"
'$include "common_1.14\_RRYFA689.bas"

'
$include "_Commands.bas"
$include "common_1.14\_Commands_required.bas"
'
$include "__Select_command.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'