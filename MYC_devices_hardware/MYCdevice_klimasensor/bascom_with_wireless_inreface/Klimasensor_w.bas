'name : Klimasensor_w.bas
'Version V01.0 20250808
'purpose : Program for mesuring temperature, humidity and pressure with the BME280 sensor
'This Programm workes with serial protocol or uses awireless interface
' The BM280 modul is controlled via I2C
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
' Inputs /Outputs : see file __config
' For announcements and rules see Data section in _announcements.bas
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
' Detailed description
'
'----------------------------------------------------
$regfile = "m1284pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.14\_Processor.bas"
'
'----------------------------------------------------
'
'=========================================
' Diese Werte koennen bei Bedarf geaendert werden!!!
' These values must be modified on demand!!!!
'
'fixd default for Sparkfun modul:
Const I2c_address_klima = &B11101110
Const I2c_address_klima_r = &B11101111
' if not working: try
'Const I2c_address_klima = &B11101100
'
Const No_of_announcelines = 31
'announcements start with 0
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
'BM280:
Const Reg_F2_default = &B00000101
'osrd_h = 101        Oversampling humidity = 16
Const Reg_F4_default = &B10110100
'osrs_t  = 101    oversampling Temp = 16
'osrs_p  = 101    Oversampling Pressure = 16
'Mode    = 00     Mode = sleep
Const Reg_F5_default = &B00010000
't_sb = 000  wait Time 0.5ms (normal mode)
'Filter = 100 Filter coefficient 16 (slow)
'spi3w = 0
'
Dim HVar1 As Long
Dim HVar2 As Long
Dim HX As Long
Dim HY As Long
Dim HZ As Long
Dim I2c_buffer As String * 26
Dim I2c_buffer_b(25) As Byte at I2c_buffer Overlay
'
'BME280:
'Sensor calibration values
Dim Dig_t1 As Word
Dim Dig_t1_eeram As Eram Word
Dim Dig_t2 As Integer
Dim Dig_t2_eeram As Eram Integer
Dim Dig_t3 As Integer
Dim Dig_t3_eeram As Eram Integer
Dim Dig_p1 As Word
Dim Dig_p1_eeram As Eram Word
Dim Dig_p2 As Integer
Dim Dig_p2_eeram As Eram Integer
Dim Dig_p3 As Integer
Dim Dig_p3_eeram As Eram Integer
Dim Dig_p4 As Integer
Dim Dig_p4_eeram As Eram Integer
Dim Dig_p5 As Integer
Dim Dig_p5_eeram As Eram Integer
Dim Dig_p6 As Integer
Dim Dig_p6_eeram As Eram Integer
Dim Dig_p7 As Integer
Dim Dig_p7_eeram As Eram Integer
Dim Dig_p8 As Integer
Dim Dig_p8_eeram As Eram Integer
Dim Dig_p9 As Integer
Dim Dig_p9_eeram As Eram Integer
Dim Dig_h1 As Byte
Dim Dig_h1_eeram As Eram Byte
Dim Dig_h2 As Integer
Dim Dig_h2_eeram As Eram Integer
Dim Dig_h3 As Byte
Dim Dig_h3_eeram As Eram Byte
Dim Dig_h4 As Integer
Dim Dig_h4_eeram As Eram Integer
Dim Dig_h5 As Integer
Dim Dig_h5_eeram As Eram Integer
Dim Dig_h6 As Byte
Dim Dig_h6_eeram As Eram Byte

'uncompensated sensor values
Dim Ut As Long
Dim Upr As Long
Dim Uh As Long

'compensated sensor values
Dim T_fine As Long
Dim Pressure_old As Dword
Dim Pressure As Dword
Dim Pressure_b(4) As Byte At Pressure Overlay
Dim Humidity As Dword
Dim Humidity_b(4) As Byte At Humidity Overlay
Dim Temperature As Word
Dim Temperature_b(2) As Byte At Temperature Overlay
'
Dim Reg_F2 As Byte
Dim Reg_F2_eeram As Eram Byte
Dim Reg_F4 As Byte
Dim Reg_F4_eeram As Eram Byte
Dim Reg_F5 As Byte
Dim Reg_F5_eeram As Eram Byte
'
Dim Var1 As Double
Dim Var2 As Double
Dim X As Double
Dim Y As Double
Dim Z As Double
Dim S1 As Single
Dim L11 As Long
'
'Hardware TWI
$lib "i2c_twi.lbx"
'
wait 10
'----------------------------------------------------
$include "common_1.14\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.14\_Config.bas"
'
'
'----------------------------------------------------
Restart:
'
'----------------------------------------------------
$include "common_1.14\_Main.bas"
'
'----------------------------------------------------
$include "common_1.14\_Loop_start.bas"
'
'----------------------------------------------------
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
Receive_i2c:
   I2c_buffer = String(B_temp2,0)
   For B_temp3 = 1 to B_temp2
      ' This do not work ..??? :
      '  I2creceive I2c_address_klima. B_temp4
      ' Therfore:
      I2cstart
      I2cwbyte I2c_address_klima
      I2cwbyte B_temp1
      I2cstart
      I2cwbyte I2c_address_klima_r
      I2crbyte B_temp4, Nack
      I2cstop
'
      i2c_buffer_b(B_temp3) = B_temp4
      If Err = 1 Then
         i2c_error
      End If
      Incr B_temp1
      waitms 10
   Next B_temp3
'
Send_i2c:
   I2csend I2c_address_klima, I2c_buffer_b(1) , B_temp2
   If Err = 1 Then
      i2c_error
   End If
Return
'
Write_config:
   I2C_buffer_b(1) = &H72
   I2C_buffer_b(2) = Reg_F2
   B_temp2 = 2
   Gosub Send_i2c
   I2C_buffer_b(1) = &H75
   I2C_buffer_b(2) = Reg_F5
   Gosub Send_i2c
   '  must be the last; set to normal mode
   I2C_buffer_b(1) = &H74
   I2C_buffer_b(2) = Reg_F4
   Gosub Send_i2c
Return
'
Read_correction:
  'BME280 read calibration 24 + 1 + 8 Byte
   B_temp1 = &H88
   B_temp2 = 24
   Gosub Receive_i2c
'
   Dig_t1 = I2C_buffer_b(2)
   Shift Dig_t1 , Left , 8
   Dig_t1 = Dig_t1 + I2C_buffer_b(1)
   Dig_t1_eeram = Dig_t1
'
   Dig_t2 = I2C_buffer_b(4)
   Shift Dig_t2 , Left , 8
   Dig_t2 = Dig_t2 + I2C_buffer_b(3)
   Dig_t2_eeram = Dig_t2
'
   Dig_t3 = I2C_buffer_b(6)
   Shift Dig_t3 , Left , 8
   Dig_t3 = Dig_t3 + I2C_buffer_b(5)
   Dig_t3_eeram = Dig_t3
'
   Dig_p1 = I2C_buffer_b(8)
   Shift Dig_p1 , Left , 8
   Dig_p1 = Dig_p1 + I2C_buffer_b(7)
   Dig_p1_eeram = Dig_p1
'
   Dig_p2 = I2C_buffer_b(10)
   Shift Dig_p2 , Left , 8
   Dig_p2 = Dig_p2 + I2C_buffer_b(9)
   Dig_p2_eeram = Dig_p2
'
   Dig_p3 = I2C_buffer_b(12)
   Shift Dig_p3 , Left , 8
   Dig_p3 = Dig_p3 + I2C_buffer_b(11)
   Dig_p3_eeram = Dig_p3
'
   Dig_p4 = I2C_buffer_b(14)
   Shift Dig_p4 , Left , 8
   Dig_p4 = Dig_p4 + I2C_buffer_b(13)
   Dig_p4_eeram = Dig_p4
'
   Dig_p5 = I2C_buffer_b(16)
   Shift Dig_p5 , Left , 8
   Dig_p5 = Dig_p5 + I2C_buffer_b(15)
   Dig_p5_eeram = Dig_p5
'
   Dig_p6 = I2C_buffer_b(18)
   Shift Dig_p6 , Left , 8
   Dig_p6 = Dig_p6 + I2C_buffer_b(17)
   Dig_p6_eeram = Dig_p6
'
   Dig_p7 = I2C_buffer_b(20)
   Shift Dig_p7 , Left , 8
   Dig_p7 = Dig_p7 + I2C_buffer_b(19)
   Dig_p7_eeram = Dig_p7
'
   Dig_p8 = I2C_buffer_b(22)
   Shift Dig_p8 , Left , 8
   Dig_p8 = Dig_p8 + I2C_buffer_b(21)
   Dig_p8_eeram = Dig_p8
'
   Dig_p9 = I2C_buffer_b(24)
   Shift Dig_p9 , Left , 8
   Dig_p9 = Dig_p9 + I2C_buffer_b(23)
   Dig_p9_eeram = Dig_p9
'
   B_temp1 = &HA1
   B_temp2 = 1
   Gosub Receive_i2c
   Dig_h1 = I2C_buffer_b(1)
   Dig_h1_eeram = Dig_h1
   printbin Dig_h1
'
   B_temp1 = &HE1
   B_temp2 = 8
   Gosub Receive_i2c

   Dig_h2 = I2C_buffer_b(2)
   Shift Dig_h2 , Left , 8
   Dig_h2 = Dig_h2 + I2C_buffer_b(1)
   Dig_h2_eeram = Dig_h2
'
   Dig_h3 = I2C_buffer_b(3)
   Dig_h3_eeram = Dig_h3
'
   Dig_h4 = I2C_buffer_b(4)
   Shift Dig_h4 , Left , 4
   B_temp1 = I2C_buffer_b(5)
   B_temp1 = B_temp1 And &HF
   Dig_h4 = Dig_h4 + B_temp1
   Dig_h4_eeram = Dig_h4
'
   Dig_h5 = I2C_buffer_b(7)
   Shift Dig_h5 , Left , 4
   B_temp1 = I2C_buffer_b(6)
   Shift B_temp1, Right, 4
   Dig_h5 = Dig_h5 + B_temp1
   Dig_h5_eeram = Dig_h5

   Dig_h6 = I2C_buffer_b(8)
   Dig_h6_eeram = Dig_h6
Return
'
Read_data:
   'read uncorrected data forced mode
   I2c_buffer_b(1) = &HF4
   I2c_buffer_b(2) = Reg_F4 AND &B11111101
   B_temp2 = 2
   Gosub Send_i2c
   ' wait for measurement
   Waitms 120
   B_temp1 = &HF7
   B_temp2 = 8
   Gosub Receive_i2c
   ' BME280 go back to sleep mode
'
   Upr = I2C_buffer_b(1)
   Shift Upr , Left , 8
   Upr = Upr + I2C_buffer_b(2)
   Shift Upr , Left , 8
   Upr = Upr + I2C_buffer_b(3)
   Shift Upr , Right , 4
   '
   Ut = I2C_buffer_b(4)
   Shift Ut , Left , 8
   Ut = Ut + I2C_buffer_b(5)
   Shift Ut , Left , 8
   Ut = Ut + I2C_buffer_b(6)
   Shift Ut , Right , 4
   '
   Uh = I2C_buffer_b(7)
   Shift Uh , Left , 8
   Uh = Uh + I2C_buffer_b(8)
   print Uh
   '
   ' Correct_temperature:
   HVar1 = Ut
   Shift HVar1 , Right , 3 , Signed
   HX = Dig_t1
   Shift HX , Left , 1 , Signed
   HVar1 = HVar1 - HX
   HVar1 = HVar1 * Dig_t2
   Shift HVar1 , Right , 11 , Signed
   '
   HVar2 = Ut
   Shift HVar2 , Right , 4 , Signed
   HVar2 = HVar2 - Dig_t1
   HVar2 = HVar2 * HVar2
   Shift HVar2 , Right , 12 , Signed
   HVar2 = HVar2 * Dig_t3
   Shift HVar2 , Right , 14 , Signed
   '
   T_fine = HVar1 + HVar2
   HX = T_fine * 5
   HX = HX + 128
   Shift HX , Right , 8 , Signed
   If HX >= -4000 Then
      Temperature = HX + 4000
   Else
      Temperature = 0
   End If
'
' Correct_humidity:
   HVar1 = T_fine - 76800
'
   HX = Uh
   Shift HX , Left , 14 , Signed
   HY = Dig_h4
   Shift HY , Left , 20 , Signed
   HX = HX - HY
   HY = Dig_h5 * HVar1
   HX = HX - HY
   HX = HX + 16384
   Shift HX , Right , 15 , Signed
'
   HY = HVar1 * Dig_h6
   Shift HY , Right , 10 , Signed
'
   HZ = HVar1 * Dig_h3
   Shift HZ , Right , 11 , Signed
   HZ = HZ + 32768
'
   HY = HY * HZ
   Shift HY , Right , 10 , Signed
   HY = HY + 2097152
   HY = HY * Dig_h2
   HY = HY + 8192
   Shift HY , Right , 14 , Signed
'
   HVar1 = HX * HY
'
   HX = HVar1
   Shift HX , Right , 15 , Signed
   HX = HX * HX
   Shift HX , Right , 7 , Signed
   HX = HX * Dig_h1
   Shift HX , Right , 4 , Signed
   HVar1 = HVar1 - HX
'
   If HVar1 < 0 Then
      HVar1 = 0
   End If
'
   If HVar1 > 419430400 Then
      HVar1 = 419430400
   End If

   Shift HVar1 , Right , 12 , Signed
   Humidity = HVar1 / 1.024
'
' Correct_Pressure_64:
   'var1 = t_fine - 128000
   S1 = T_fine
   Y = S1
   X = 128000
   Var1 = Y - X

   'var2 = var1 * var1 * dig_P6
   Var2 = Var1 * Var1
   S1 = Dig_p6
   X = S1
   Var2 = Var2 * X

   'var2 = var2 + ((var1*dig_P5)<<17);
   S1 = Dig_p5
   X = S1
   X = Var1 * X
   Y = 2 ^ 17
   X = X * Y
   Var2 = Var2 + X

   'var2 = var2 + (dig_P4<<35);
   S1 = Dig_p4
   X = S1
   Y = 2 ^ 35
   X = X * Y
   Var2 = Var2 + X

   'var1 = ((var1 * var1 * dig_P3)>>8) + ((var1 * dig_P2)<<12);
   X = Var1 * Var1
   S1 = Dig_p3
   Z = S1
   X = X * Z
   Y = 2 ^ 8
   X = X / Y

   S1 = Dig_p2
   Z = S1
   Y = Var1 * Z
   Z = 2 ^ 12
   Y = Y * Z
   Var1 = X + Y

   'var1 = ((1<<47)+var1)*dig_P1>>33;
   X = &H800000000000
   X = X + Var1
   S1 = Dig_p1
   Z = S1
   Var1 = X * Z
   Y = 2 ^ 33
   Var1 = Var1 / Y

   L11 = Var1
   If L11 = 0 Then
      X = Pressure_old
   Else
      'x = 1048576-up;
      X = 1048576
      S1 = Upr
      Z = S1
      X = X - Z

      'x = (((x<<31)-var2)*3125)/var1;
      Y = 2 ^ 31
      X = X * Y
      X = X - Var2
      Y = 3125
      X = X * Y
      X = X / Var1

      'var1 = (dig_P9 * (x>>13) * (x>>13)) >> 25;
      Z = X
      Y = 2 ^ 13
      Z = Z / Y
      S1 = Dig_p9
      Y = S1
      Var1 = Y * Z
      Var1 = Var1 * Z
      Y = 2 ^ 25
      Var1 = Var1 / Y

      'var2 = (dig_P8 * x) >> 19;
      S1 = Dig_p8
      Y = S1
      Var2 = Y * X
      Y = 2 ^ 19
      Var2 = Var2 / Y

      'x = ((x + var1 + var2) >> 8) + (dig_P7<<4);
      X = X + Var1
      X = X + Var2
      Y = 2 ^ 8
      X = X / Y
      S1 = Dig_p7
      Y = S1
      Z = 2 ^ 4
      Y = Y * Z
      X = X + Y

      Y = 25.6
      X = X / Y
   Pressure_old = X
   End If
   Pressure = X
Return
'
'----------------------------------------------------
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
'