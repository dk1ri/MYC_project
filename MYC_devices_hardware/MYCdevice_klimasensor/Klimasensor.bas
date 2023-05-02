'name : Klimasensor_bascom.bas
'Version V04.0 20230415
'purpose : Program for mesuring temperature, humidity and pressure with the BME280 sensor
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware Klimasensor Version V02.1 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1.12 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.12\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
' MISO MOSI
'-----------------------------------------------------
' Inputs /Outputs : see file __config
' For announcements and rules see Data section at the end
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
' Detailed description
'
'----------------------------------------------------
$regfile = "m168def.dat"
'for ATMega168
'$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 10000000
$include "common_1.12\_Processor.bas"
'
'----------------------------------------------------
'
'2...254:
Const I2c_address = 22
Const No_of_announcelines = 21
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.12\_Constants_and_variables.bas"
'
'BM280:
Const Reg_F2_default = &B00000101
'osrd_h = 101        Oversampling humidity = 16
Const Reg_F4_default = &B10110111
'osrs_t  = 101    oversampling Temp = 16
'osrs_p  = 101    Oversampling Pressure =16
'Mode    = 11     Mode =normal
Const Reg_F5_default = &B00010000
't_sb = 000  wait Time 0.5ms (normal mode)
'Filter = 100 Filter coefficient 16 (slow)
'spi3w = 0
'
Dim Tl As Long
Dim L1 As Long
Dim HVar1 As Long
Dim HVar2 As Long
Dim HX As Long
Dim HY As Long
Dim HZ As Long
Dim Spi_buffer(6) As Byte
'For write
Dim Spi_buffer_in(26) As Byte
'For read
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
Dim Up As Long
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
'----------------------------------------------------
$include "common_1.12\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.12\_Config.bas"
'
'----------------------------------------------------
$include "common_1.12\_Main.bas"
'
'----------------------------------------------------
$include "common_1.12\_Loop_start.bas"
'
'----------------------------------------------------
$include "common_1.12\_Main_end.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.12\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.12\_Init.bas"
'
'----------------------------------------------------
$include "common_1.12\_Subs.bas"
'
'----------------------------------------------------
Write_config:
   Spi_buffer(1) = &H72
   'F2 MSB reset
   Spi_buffer(2) = Reg_F2
   Spi_buffer(3) = &H75
   Spi_buffer(4) = Reg_F5
   '  must be the last
   Spi_buffer(5) = &H74
   Spi_buffer(6) = Reg_F4
   Reset Spi_cs
   Spiout Spi_buffer(1) , 6
   Set Spi_cs
Return
'
Start_BM280:
   Waitms 5
   Reset Spi_cs
   Waitms 10
   Set Spi_cs
   'Initiate SPI on BM240
Return
'
Read_correction:
  'BME280 read calibration 24 + 4 Byte
   Spi_buffer(1) = &H88
   Reset Spi_cs
   Spiout Spi_buffer(1) , 1
   Spiin Spi_buffer_in(1) , 24
   Set Spi_cs
'
   Dig_t1 = Spi_buffer_in(2)
   Shift Dig_t1 , Left , 8
   Dig_t1 = Dig_t1 + Spi_buffer_in(1)
   Dig_t1_eeram = Dig_t1
'
   Dig_t2 = Spi_buffer_in(4)
   Shift Dig_t2 , Left , 8
   Dig_t2 = Dig_t2 + Spi_buffer_in(3)
   Dig_t2_eeram = Dig_t2
'
   Dig_t3 = Spi_buffer_in(6)
   Shift Dig_t3 , Left , 8
   Dig_t3 = Dig_t3 + Spi_buffer_in(5)
   Dig_t3_eeram = Dig_t3
'
   Dig_p1 = Spi_buffer_in(8)
   Shift Dig_p1 , Left , 8
   Dig_p1 = Dig_p1 + Spi_buffer_in(7)
   Dig_p1_eeram = Dig_p1
'
   Dig_p2 = Spi_buffer_in(10)
   Shift Dig_p2 , Left , 8
   Dig_p2 = Dig_p2 + Spi_buffer_in(9)
   Dig_p2_eeram = Dig_p2
'
   Dig_p3 = Spi_buffer_in(12)
   Shift Dig_p3 , Left , 8
   Dig_p3 = Dig_p3 + Spi_buffer_in(11)
   Dig_p3_eeram = Dig_p3
'
   Dig_p4 = Spi_buffer_in(14)
   Shift Dig_p4 , Left , 8
   Dig_p4 = Dig_p4 + Spi_buffer_in(13)
   Dig_p4_eeram = Dig_p4
'
   Dig_p5 = Spi_buffer_in(16)
   Shift Dig_p5 , Left , 8
   Dig_p5 = Dig_p5 + Spi_buffer_in(15)
   Dig_p5_eeram = Dig_p5
'
   Dig_p6 = Spi_buffer_in(18)
   Shift Dig_p6 , Left , 8
   Dig_p6 = Dig_p6 + Spi_buffer_in(17)
   Dig_p6_eeram = Dig_p6
'
   Dig_p7 = Spi_buffer_in(20)
   Shift Dig_p7 , Left , 8
   Dig_p7 = Dig_p7 + Spi_buffer_in(19)
   Dig_p7_eeram = Dig_p7
'
   Dig_p8 = Spi_buffer_in(22)
   Shift Dig_p8 , Left , 8
   Dig_p8 = Dig_p8 + Spi_buffer_in(21)
   Dig_p8_eeram = Dig_p8
'
   Dig_p9 = Spi_buffer_in(24)
   Shift Dig_p9 , Left , 8
   Dig_p9 = Dig_p9 + Spi_buffer_in(23)
   Dig_p9_eeram = Dig_p9
'
   Spi_buffer(1) = &HA1
   Reset Spi_cs
   Spiout Spi_buffer(1) , 1
   Spiin Spi_buffer_in(1),1
   Set Spi_cs
'
   Dig_h1 = Spi_buffer_in(1)
   Dig_h1_eeram = Dig_h1
'
   Spi_buffer(1) = &HE1
   Reset Spi_cs
   Spiout Spi_buffer(1) , 1
   Spiin Spi_buffer_in(1),8
   Set Spi_cs

   Dig_h2 = Spi_buffer_in(2)
   Shift Dig_h2 , Left , 8
   Dig_h2 = Dig_h2 + Spi_buffer_in(1)
   Dig_h2_eeram = Dig_h2
'
   Dig_h3 = Spi_buffer_in(3)
   Dig_h3_eeram = Dig_h3
'
   Dig_h4 = Spi_buffer_in(4)
   Shift Dig_h4 , Left , 4
   B_temp1 = Spi_buffer_in(5)
   B_temp1 = B_temp1 And &HF
   Dig_h4 = Dig_h4 + B_temp1
   Dig_h4_eeram = Dig_h4
'
   Dig_h5 = Spi_buffer_in(7)
   Shift Dig_h5 , Left , 4
   B_temp1 = Spi_buffer_in(6)
   Shift B_temp1, Right, 4
   Dig_h5 = Dig_h5 + B_temp1
   Dig_h5_eeram = Dig_h5

   Dig_h6 = Spi_buffer_in(8)
   Dig_h6_eeram = Dig_h6
Return
'
Read_data:
'read uncorrected data
   Spi_buffer(1) = &HF7
   Reset Spi_cs
   Spiout Spi_buffer(1) , 1
   Spiin Spi_buffer_in(1),8
   Set Spi_cs
'
   Up = Spi_buffer_in(1)
  Shift Up , Left , 8
  Up = Up + Spi_buffer_in(2)
  Shift Up , Left , 8
  Up = Up + Spi_buffer_in(3)
  Shift Up , Right , 4
'
  Ut = Spi_buffer_in(4)
  Shift Ut , Left , 8
  Ut = Ut + Spi_buffer_in(5)
  Shift Ut , Left , 8
  Ut = Ut + Spi_buffer_in(6)
  Shift Ut , Right , 4
'
  Uh = Spi_buffer_in(7)
  Shift Uh , Left , 8
  Uh = Uh + Spi_buffer_in(8)
Return
'
Correct_temperature:
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
Return
'
Correct_humidity:
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
Return
'
Pressure_64:
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
      S1 = Up
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
$include "_Commands.bas"
$include "common_1.12\_Commands_required.bas"
'
$include "common_1.12\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'