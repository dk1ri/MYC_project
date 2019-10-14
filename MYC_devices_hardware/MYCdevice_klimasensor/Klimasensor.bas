'name : Klimasensor_bascom.bas
'Version V03.0, 20191014
'purpose : Program for mesuring temperature, humidity and pressure with the BME280 sensor
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware Klimasensor Version V02.0 by DK1RI
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
' MISO MOSI
'-----------------------------------------------------
' Inputs /Outputs : see file __config
' For announcements and rules see Data section at the end
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'
' Detailed description
'
'----------------------------------------------------
$regfile = "m168def.dat"
'for ATMega328
'
'-----------------------------------------------------
$crystal = 10000000
$include "common_1.7\_Processor.bas"
'
'----------------------------------------------------
'
' 8: for 8/32pin, ATMEGAx8; 4 for 40/44pin, ATMEGAx4 packages
' used for reset now: different portnumber of SPI SS pin
Const Processor = "8"
Const Command_is_2_byte    = 0
'1...127:
Const I2c_address = 44
Const No_of_announcelines = 21
'announcements start with 0 -> minus 1
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
'
'----------------------------------------------------
$include "common_1.7\_Constants_and_variables.bas"
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
Dim Tl AS Long
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
Declare Function Pressure_64() As Dword
'
'----------------------------------------------------
$include "common_1.7\_Macros.bas"
'
'----------------------------------------------------
Config PinB.2 = Input
Reset__ Alias PinB.2
$include "common_1.7\_Config.bas"
'
'----------------------------------------------------
$include "common_1.7\_Main.bas"
'
'----------------------------------------------------
$include "common_1.7\_Loop_start.bas"
'
'----------------------------------------------------
$include "common_1.7\_Serial.bas"
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
Function Pressure_64() As Dword
  Local Var1 As Double
  Local Var2 As Double
  Local X As Double
  Local Y As Double
  Local Z As Double
  Local S1 As Single
  Local L1 As Long

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

  L1 = Var1
  If L1 = 0 Then
    Pressure_64 = Pressure_old
    Exit Function
  End If

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

  Pressure_64 = X
  Pressure_old = Pressure_64
End Function
'
'----------------------------------------------------
   $include "common_1.7\_Commandparser.bas"
'
'-----------------------------------------------------
   Case 1
'Befehl &H01
'liest Temperatur
'read temperature
'Data "1;ap,read temperature;1;12500,{-40.00 to 84.99};lin;DegC"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H01
      Tx_b(2) = Temperature_b(2)
      Tx_b(3) = Temperature_b(1)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 2
'Befehl &H02
'liest Feuchtigkeit
'read humidity
'Data "2;ap,read humidity;1;100001,{0.000 to 100.000};lin;%"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H02
      Tx_b(2) = Humidity_b(3)
      Tx_b(3) = Humidity_b(2)
      Tx_b(4) = Humidity_b(1)
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 3
'Befehl &H03
'liest Druck
'read pressure
'Data "3;ap,read pressure;1;1100001,{0.000 to 1100.000};lin;hPa"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H03
      Tx_b(2) = Pressure_b(3)
      Tx_b(3) = Pressure_b(2)
      Tx_b(4) = Pressure_b(1)
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 4
'Befehl &H04 0 to 5
'schreibt Oversampling Feuchte
'write Oversampling humidity
'Data "4;oa,oversampling humidity;b,{0,1,2,4,8,16}"
      If Commandpointer = 2 Then
         If Command_b(2) < 6 Then
            Reg_F2 = Command_b(2)
            Reg_F2_eeram = Reg_F2
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 5
'Befehl &H05
'liest Oversampling Feuchte
'read Oversampling humidity
'Data "5;aa,as4"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H05
      Tx_b(2) = Reg_F2
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 6
'Befehl &H06 0 to 5
'schreibt Oversampling Druck
'write Oversampling pressure
'Data "6;oa,oversampling pressure;b,{0,1,2,4,8,16}"
       If Commandpointer >= 2 Then
         If Command_b(2) < 6 Then
            Shift Command_b(2), Left, 2
            Reg_F4 = Reg_F4 And &B11100011
            Reg_F4 = Reg_F4 OR Command_b(2)
            Reg_F4_eeram = Reg_F4
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 7
'Befehl &H07
'liest Oversampling Druck
'read Oversampling pressure
'Data "7;aa,as6"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H07
      B_temp1 = Reg_F4
      B_temp1 = B_temp1 AND &B00011100
      Shift B_temp1, Right, 2
      Tx_b(2) = B_temp1
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 8
'Befehl &H08
'schreibt Oversampling Temperatur
'write Oversampling Temperature
'Data "8;oa,oversampling Temperatur;b,{0,1,2,4,8,16}"
      If Commandpointer >= 2 Then
         If Command_b(2) < 6 Then
            Shift Command_b(2), Left, 5
            Reg_F4 = Reg_F4 And &B00011111
            Reg_F4 = Reg_F4 OR Command_b(2)
            Reg_F4_eeram = Reg_F4
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
      Case 9
'Befehl &H09
'liest Oversampling Temperatur
'read Oversampling Temperatur
'Data "1;aa,as8"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H09
      B_temp1 = Reg_F4
      B_temp1 = B_temp1 AND &B11100000
      Shift B_temp1, Right, 5
      Tx_b(2) = B_temp1
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 10
'Befehl &H0A
'schreibt Pause Zeit
'write non active time
'Data "10;oa,non activ time;b,{0.5,62.5,125,500,1000,10,20},ms"
      If Commandpointer = 2 Then
         If Command_b(2) < 8 Then
            Shift Command_b(2), Left, 5
            Reg_F5 = Reg_F5 And &B00011111
            Reg_F5 = Reg_F5 OR Command_b(2)
            Reg_F5_eeram = Reg_F5
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 11
'Befehl &H0B
'liest Pause Zeit
'read non active time
'Data "11;aa,as10"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H0B
      B_temp1 = Reg_F5
      B_temp1 = B_temp1 AND &B11100000
      Shift B_temp1, Right, 5
      Tx_b(2) = B_temp1
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 12
'Befehl &H0C
'schreibt Filter
'write Filter
'Data "12;oa,filter;b,{0,2,4,8,16}"
      If Commandpointer = 2 Then
         If Command_b(2) < 5 Then
            Shift Command_b(2), Left, 2
            Reg_F5 = Reg_F5 And &B11100011
            Reg_F5 = Reg_F5 OR Command_b(2)
            Reg_F5_eeram = Reg_F5
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else_Incr_Commandpointer
'
   Case 13
'Befehl &H0D
'liest Filter
'read Filter
'Data "13;aa,as12"
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H0D
      B_temp1 = Reg_F5
      B_temp1 = B_temp1 AND &B00011100
      Shift B_temp1, Right, 2
      Tx_b(2) = B_temp1
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 14
'Befehl &H0E
'liest ID
'read ID
'Data "14;aa,read ID;b"
      Spi_buffer(1) = &HD0
      Reset Spi_cs
      Spiout Spi_buffer(1) , 1
      Spiin Spi_buffer_in(1) , 1
      Set Spi_cs
      Tx_busy = 2
      Tx_time = 1
      Tx_b(1) = &H0E
      Tx_b(2) = Spi_buffer_in(1)
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
'
   Case 15
'Befehl &H0F
'Reset
'Reset
'Data "15;ot,reset;0"
      Stop Watchdog
      Spi_buffer(1) = &H60
      'E0 MSB reset for write
      Reset Spi_cs
      Spi_buffer(2) = &HB6
      Spiout Spi_buffer(1) , 2
      Set Spi_cs
      Gosub Start_BM280
      Gosub Read_correction
      Start Watchdog
      Gosub Command_received
'
'
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
'announce text
'
Announce0:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Klimasensor;V02.2;1;145;1;21;1-1"
'
Announce1:
'Befehl &H01
'liest Temperatur
'read temperature
Data "1;ap,read temperature;1;12500,{-40.00 to 84.99};lin;DegC"
'
Announce2:
'Befehl &H02
'liest Feuchtigkeit
'read humidity
Data "2;ap,read humidity;1;100001,{0.000 to 100.000};lin;%"
'
Announce3:
'Befehl &H03
'liest Druck
'read pressure
Data "3;ap,read pressure;1;1100001,{0.000 to 1100.000};lin;hPa"
'
Announce4:
'Befehl &H04 0 to 5
'schreibt Oversampling Feuchte
'write Oversampling humidity
Data "4;oa,oversampling humidity;b,{0,1,2,4,8,16}"
'
Announce5:
'Befehl &H05
'liest Oversampling Feuchte
'read Oversampling humidity
Data "5;aa,as4"
'
Announce6:
'Befehl &H06 0 to 5
'schreibt Oversampling Druck
'write Oversampling pressure
Data "6;oa,oversampling pressure;b,{0,1,2,4,8,16}"
'
Announce7:
'Befehl &H07
'liest Oversampling Druck
'read Oversampling pressure
Data "7;aa,as6"
'
Announce8:
'Befehl &H08
'schreibt Oversampling Temperatur
'write Oversampling Temperature
Data "8;oa,oversampling Temperatur;b,{0,1,2,4,8,16}"
'
Announce9:
'Befehl &H09
'liest Oversampling Temperatur
'read Oversampling Temperatur
Data "1;aa,as8"
'
Announce10:
'Befehl &H0A
'schreibt Pause Zeit
'write non active time
Data "10;oa,non activ time;b,{0.5,62.5,125,500,1000,10,20},ms"
'
Announce11:
'Befehl &H0B
'liest Pause Zeit
'read non active time
Data "11;aa,as10"
'
Announce12:
'Befehl &H0C
'schreibt Filter
'write Filter
Data "12;oa,filter;b,{0,2,4,8,16}"
'
Announce13:
'Befehl &H0D
'liest Filter
'read Filter
Data "13;aa,as12"
'
Announce14:
'Befehl &H0E
'liest ID
'read ID
Data "14;aa,read ID;b"
'
Announce15:
'Befehl &H0F
'Reset
'Reset
'Data "15;ot,reset;0"
'
Announce16:
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;21"
'
Announce17:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce18:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce19:
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,22,{0 to 127};a,SERIAL,1"
'
Announce20:
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,22,{0 to 127};a,SERIAL,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1"
'