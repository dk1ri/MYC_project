'-----------------------------------------------------------------------
'name : Klimasensor.bas
'Version V02.0, 20160824
'purpose : Program for mesuring temperature, humidity and pressure with the BME280 sensor
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware Klimasensor Version V01.1 by DK1RI
'The Programm supports the MYC protocol
'Slave max length of  I2C string is 252 Bytes.
'Please modify clock frequency and processor type, if necessary
'
'micro : ATMega168 or higher
'Fuse Bits :
'External Crystal, high frequency
'clock output enabled
'divide by 8 disabled
'$PROG &HFF,&HC6,&HDF,&HF9' generated. Take care that the chip supports all fuse bytes.
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other right are affected, this programm can be used
'under GPL (Gnu public licence)
'
'code for BM280 correction and Read_correction is copied and partly modified from
'  BME280 Beispiel Code
'
'  (c) 2015 by Michael Lehmann
'  mlehmann(a)mgkulm.ch
'http://www.mikrocontroller.net/attachment/276997/BME280.bas
'
'-----------------------------------------------------------------------
'Templates:
'slave_core_V01.0
'-----------------------------------------------------------------------
'Used Hardware:
' serial
' I2C
' MISO MOSI
'-----------------------------------------------------------------------
' Inputs: see below
' Outputs : see below
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'$regfile = "m88pdef.dat"
'for ATMega8P
'$regfile = "m88def.dat"
'for ATMega8
'$regfile = "m328pdef.dat"
'for ATMega328
$regfile = "m168def.dat"
'for ATMega168
$crystal = 10000000
$baud = 19200
'use baud rate
$hwstack = 128
'default use 32 for the hardware stack
$swstack = 30
'default use 10 for the SW stack
$framesize = 60
'default use 40 for the frame space
'
' Simulation!!!!
' $sim
'
'**************** libs
'use byte library for smaller code
'$lib "mcsbyte.lbx"
'
'**************** Variables
Const Lf = 10
Const I2c_buff_length = 252
'that is maximum
Const Stringlength = 252
Const Command_length = 50
' reduced from slave_core, but enaugh
Const A_line_length = 145
'max length of announcelines
Const Cystal = 20000000
Const Blinktime = 5000
Const Cmd_watchdog_time = Blinktime * 10
'Number of main loop before command reset
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
Const Tx = 4 * Tx_factor
Const Tx_timeout = Cmd_watchdog_time * Tx
Const Not_valid_cmd = &H80
'a non valid commandtoken
'
Const No_of_announcelines = 21
'announcements start with 0 -> minus 1
'
'BM280:
Const Reg_F2_default = &B00000101
'osrd_h = 101        16
Const Reg_F4_default = &B10110111
'osrs_t  = 101    16
'osrs_p  = 101    16
'Mode    = 11     normal
Const Reg_F5_default = &B00010000
't_sb =  000
'Filter =   100
'spi3w =        0
'
'************************
Dim First_set As Eram Byte
Dim Dev_name As String * 20
Dim Dev_name_eeram As Eram String * 20
Dim Dev_name_b(20) As Byte At Dev_name Overlay
Dim Dev_number As Byte
Dim Dev_number_eeram As Eram Byte
Dim Adress As Byte
Dim Adress_eeram As Eram Byte
'I2C adress
Dim I2C_active As Byte
Dim I2C_active_eeram As Eram Byte
Dim RS232_active As Byte
Dim RS232_active_eeram As Eram Byte
Dim USB_active As Byte
'************************
Dim Usb_active_eeram As Eram Byte
'
Dim L As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * A_line_length
Dim Temps_b(20) As Byte At Temps Overlay
'
Dim I As Integer
'Blinkcounter
Dim J As Integer

Dim A As Byte
'actual input
Dim Blw As Byte
'
Dim Announceline As Byte
'notifier for multiple announcelines
Dim A_line As Byte
' Announcline for 00 and F0 command
Dim Number_of_lines As Byte
Dim Send_lines As Byte
' Temporaray Marker
' 0: idle; 1: in work; 2: F0 command; 3 : 00 command
Dim I2c_action As Byte
' 0 no action, 1: Commandparser, 2: send ready
Dim I2c_tx As String * I2c_buff_length
Dim I2c_tx_b(I2c_buff_length) As Byte At I2c_tx Overlay
Dim I2c_pointer As Byte
Dim I2c_write_pointer As Byte
Dim I2c_tx_busy As Bit
'There are bytes to transmit
Dim Command As String * Command_length
'Command Buffer
Dim Command_b(Command_length) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
'
Dim Twi_status As Byte
Dim Twi_control As Byte
'
Dim Error_no As Byte
Dim Error_cmd_no As Byte
Dim Cmd_watchdog As Dword
'Watchdog for loop
Dim Tx_time As Dword
'Watchdog for I2c sending
Dim Command_mode As Byte
'0: I2C input 1: seriell
'
Dim L1 As Long
Dim HVar1 As Long
Dim HVar2 As Long
Dim HX As Long
Dim HY As Long
Dim HZ As Long
Dim S1 As Single
Dim Var1 As Double
Dim Var2 As Double
Dim X As Double
Dim Y As Double
Dim Z As Double
Dim Spi_buffer(3) As Byte
'For write
Dim Spi_buffer_in(24) As Byte
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
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'**************** Config / Init
' Jumper:
Config PinB.1 = Input
PortB.1 = 1
Reset__ Alias PinB.1
Config PortB.2 = Output
Spi_cs Alias PortB.2
Config Spi = Hard, Interrupt = Off, Data Order = Msb, Master = Yes, Polarity = High, Phase = 1, Clockrate = 4, Noss = 1
Spiinit
'
Config Watchdog = 2048
'
'****************Interrupts
'Enable Interrupts
' serialin not buffered!!
' serialout not buffered!!!
'
'**************** Main ***************************************************
'
If Reset__ = 0 Then Gosub Reset_
'
If First_set <> 5 Then Gosub Reset_
'
Gosub Init
'
Slave_loop:
Start Watchdog
'Loop must be less than 2s
'
'Blink
J = J + 1
If J = Blinktime Then
   J = 0
   Select Case I
   Case 10
      I = 0
      'reset I2c if not busy
      Twi_control = Twcr And &H80
      'twint set?
      If Twi_control = &H00 Then Gosub Reset_i2c
   End Select
   Incr I
End If
'
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong commands will be deleted
'commandbuffers is reset
If Cmd_watchdog > 0 Then Incr Cmd_watchdog
If Cmd_watchdog > Cmd_watchdog_time Then
   Error_no = 5
   Error_cmd_no = Command_no
   Gosub Command_received
End If
'
If Tx_time > 0 Then
   Incr Tx_time
   If Tx_time > Tx_timeout Then
      Gosub Reset_i2c_tx
      Error_no = 6
      Error_cmd_no = Command_no
   End If
End If
'
'RS232 got data?
A = Ischarwaiting()
If A = 1 Then
   A = Inkey()
   If Command_mode = 0 Then
      'restart if i2cmode
      Command_mode = 1
      Gosub  Command_received
   End If
   If Commandpointer < Stringlength Then
      Command_b(commandpointer) = A
      If Rs232_active = 0 And Usb_active = 0 Then
         'allow &HFE only
         If A = 254 Then
            Gosub Slave_commandparser
         Else
            Gosub  Command_received
         End If
      Else
         Gosub Slave_commandparser
      End If
   'Else
      'If Buffer is full, chars are ignored !!
   End If
End If
'
'I2C
'This part should be executed as fast as poosible to continue I2C:
Twi_control = Twcr And &H80
'twint set?
If Twi_control = &H80 Then
   'twsr 60 -> start, 80-> data, A0 -> stop
   Twi_status = Twsr
   Twi_status = Twi_status And &HF8
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
      'slave send:
      'a slave send command must always be done completely (or until timeout)
      'incoming new send commands are ignored if i2c_tx is not empty
      'for multi line F0 command I2c_tx may be loaded a few times if necessary.
      'multiple announcelines are loaded by line
      'So the will be no i2c_tx_overflow; -> no ring buffer
      If I2c_tx_busy = 1 Then
         'continue sending
         TWDR = I2c_tx_b(I2c_pointer)
         Incr I2c_pointer
         If I2c_pointer >= I2c_write_pointer Then I2c_action = 2
      Else
         TwdR = Not_valid_cmd
      End If
   Else
      'slave receive:
      'I2C receives data and and interpret as commands.
      If Twi_status = &H80 Or Twi_status = &H88 Then
         'Command overflow is avoided during command handling
         Command_b(Commandpointer) = TWDR
         I2c_action = 1
      End If
   End If
   Twcr = &B11000100
End If
'
Select Case I2c_action
   Case 0
      NOP
      'nothing to do, NOP necessary here
   Case 1
      If Command_mode = 1 Then
         'restart if rs232mode
         Command_mode = 0
         'i2c mode
         Gosub  Command_received
      End If
      Gosub Slave_commandparser
      I2c_action = 0
   Case 2
      If Number_of_lines > 0 Then
         Gosub Sub_restore
      Else
         Gosub Reset_i2c_tx
      End If
      I2c_action = 0
End Select
'
Stop Watchdog                                               '
Goto Slave_loop
'
'===========================================
'
Reset_:
'This wait is necessary, because some programmers provide the chip
'with power for a short time after programming.
'This may start the reset_ sub, but stop before ending.
Wait 1
'set at first use
Dev_number = 1
Dev_number_eeram = Dev_number
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Dev_name = Dev_name_eeram
Adress = 44
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
'This should be the last
First_set = 5
'
Reg_F2 = Reg_F2_default
Reg_F2_eeram = Reg_F2
Reg_F4 = Reg_F4_default
Reg_F4_eeram = Reg_F4
Reg_F5 = Reg_F5_default
Reg_F5_eeram = Reg_F5
Return
'
Init:
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram
I2C_active = I2C_active_eeram
RS232_active = RS232_active_eeram
Usb_active = Usb_active_eeram
Command_no = 1
Announceline = 255
Error_cmd_no = 0
Send_lines = 0
Gosub Command_received
Gosub Reset_i2c_tx
Gosub Reset_i2c
I = 0
J = 0
Command_mode = 0
Announceline = 255
Command_mode = 0
'
Reg_F2 = Reg_F2_eeram
Reg_F4 = Reg_F4_eeram
Reg_F5 = Reg_F5_eeram
Wait 1
'to start BM280
Gosub Start_BM280
Gosub Read_correction
Return
'
Reset_i2c:
Twsr = 0
'status und Prescaler auf 0
Twdr = Not_valid_cmd
'default
Twar = Adress
'Slaveadress
Twcr = &B01000100
Return
'
Reset_i2c_tx:
I2c_pointer = 1
I2c_write_pointer = 1
Send_lines = 0
Tx_time = 0
I2c_tx_busy = 0
Twdr = Not_valid_cmd
Return
'
Command_received:
Commandpointer = 1
Command = String(Command_length , 0)
Incr Command_no
If Command_no = 255 Then Command_no = 0
Cmd_watchdog = 0
Return
'
Sub_restore:
' read one line
Select Case Send_lines
   Case 1
      I2c_write_pointer = 1
   Case 3
      'start basic announcement
      I2c_tx_b(1) = &H00
      I2c_write_pointer = 2
      Send_lines = 1
   Case 2
      'start of announceline(s), send 3 byte first
      I2c_tx_b(1) = &HF0
      I2c_tx_b(2) = A_line
      I2c_tx_b(3) = Number_of_lines
      I2c_write_pointer = 4
      Send_lines = 1
End Select
'
If Number_of_lines > 0 Then
   'another announcelines to send
   'This fills I2c_tx again
   Select Case A_line
   Case 0
      Restore Announce0
   Case 1
      Restore Announce1
   Case 2
      Restore Announce2
   Case 3
      Restore Announce3
   Case 4
      Restore Announce4
   Case 5
      Restore Announce5
   Case 6
      Restore Announce6
   Case 7
      Restore Announce7
   Case 8
      Restore Announce8
   Case 9
      Restore Announce9
   Case 10
      Restore Announce10
   Case 11
      Restore Announce11
   Case 12
      Restore Announce12
   Case 13
      Restore Announce13
   Case 14
      Restore Announce14
   Case 15
      Restore Announce15
   Case 16
      Restore Announce16
   Case 17
      Restore Announce17
   Case 18
      Restore Announce18
   Case 19
      Restore Announce19
   Case 20
      Restore Announce20
      Case Else
         'will not happen
   End Select
   Read Temps
   Tempc = Len(Temps)
   I2c_tx_b(I2c_write_pointer) = Tempc
   Incr I2c_write_pointer
   For Tempd = 1 To Tempc
      I2c_tx_b(I2c_write_pointer) = Temps_b(Tempd)
      Incr I2c_write_pointer
   Next Tempd
   Incr A_line
   If A_line >= No_of_announcelines Then A_line = 0
   Decr Number_of_lines
'Else
   'happens, for &HF=xx00
   'send header only
End If
I2c_pointer = 1
Return
'
Print_i2c_tx:
Decr  I2c_Write_pointer
For Tempb = 1 To I2c_Write_pointer
   Tempc = I2c_tx_b(Tempb)
   Printbin Tempc
Next Tempb
Gosub Reset_I2c_tx
Return
'
Write_config:
   Spi_buffer(1) = &H72
   'F2 MSB reset
   Spi_buffer(2) = Reg_F2
   Spi_buffer(3) = &H75
   Spi_buffer(4) = Reg_F5
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
'
   Gosub Write_config
Return
'
Read_correction:
  'BME280 read calibration 24 Byte
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
   Tempb = Spi_buffer_in(5)
   Tempb = Tempb And &HF
   Dig_h4 = Dig_h4 + Tempb
   Dig_h4_eeram = Dig_h4
'
   Dig_h5 = Spi_buffer_in(6)
   Shift Dig_h5 , Left , 4
   Tempb = Spi_buffer_in(5)
   Shift Tempb , Right , 4
   Dig_h5 = Dig_h5 + Tempb
   Dig_h5_eeram = Dig_h5

   Dig_h6 = Spi_buffer_in(7)
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
Correct_pressure:
   'var1 = t_fine - 128000
   S1 = T_fine
   Y = S1
   X = 128000
   Var1 = Y - X
'
   'var2 = var1 * var1 * dig_P6
   Var2 = Var1 * Var1
   S1 = Dig_p6
   X = S1
   Var2 = Var2 * X
'
   'var2 = var2 + ((var1*dig_P5)<<17);
   S1 = Dig_p5
   X = S1
   X = Var1 * X
   Y = 2 ^ 17
   X = X * Y
   Var2 = Var2 + X
'
   'var2 = var2 + (dig_P4<<35);
   S1 = Dig_p4
   X = S1
   Y = 2 ^ 35
   X = X * Y
   Var2 = Var2 + X
'
   'var1 = ((var1 * var1 * dig_P3)>>8) + ((var1 * dig_P2)<<12);
   X = Var1 * Var1
   S1 = Dig_p3
   Z = S1
   X = X * Z
   Y = 2 ^ 8
   X = X / Y
'
   S1 = Dig_p2
   Z = S1
   Y = Var1 * Z
   Z = 2 ^ 12
   Y = Y * Z
   Var1 = X + Y
'
   'var1 = ((1<<47)+var1)*dig_P1>>33;
   X = &H800000000000
   X = X + Var1
   S1 = Dig_p1
   Z = S1
   Var1 = X * Z
   Y = 2 ^ 33
   Var1 = Var1 / Y
'
   L1 = Var1
   If L1 = 0 Then
      Pressure = Pressure_old
      Return
   End If

   'x = 1048576-up;
   X = 1048576
   S1 = Up
   Z = S1
   X = X - Z
'
   'x = (((x<<31)-var2)*3125)/var1;
   Y = 2 ^ 31
   X = X * Y
   X = X - Var2
   Y = 3125
   X = X * Y
   X = X / Var1
'
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
'
   'var2 = (dig_P8 * x) >> 19;
   S1 = Dig_p8
   Y = S1
   Var2 = Y * X
   Y = 2 ^ 19
   Var2 = Var2 / Y
'
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
'
   Y = 25.6
   X = X / Y
'
   X = X - 300000
   Pressure = x
   ' start at 300000 hPa (= 0)
   Pressure_old = Pressure
Return
'
'
Slave_commandparser:
'checks to avoid commandbuffer overflow are within commands !!
If I2c_active = 0 And Command_mode = 0 Then
   'allow &HFE only: enable I2C
   If Command_b(1) <> 254 Then
      Gosub  Command_received
      Return
   End If
End If
'
If Cmd_watchdog = 0 Then
   Cmd_watchdog = 1
   'start watchdog
End If
'
Select Case Command_b(1)
   Case 0
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
'Data "0;m;DK1RI;Klimasensor;V02.0;1;100;15"
      If I2c_tx_busy = 0 Then
         A_line = 0
         Number_of_lines = 1
         Send_lines = 3
         I2c_tx_busy = 1
         Tx_time = 1
         Gosub Sub_restore
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 1
'Befehl &H01
'liest Temperatur
'read temperature
'Data "1;aa,read temperature;w,{-40.00 to 84.99},DegC"
      Gosub Read_data
      Gosub Correct_temperature
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &H01
         I2c_tx_b(2) = Temperature_b(2)
         I2c_tx_b(3) = Temperature_b(1)
         I2c_write_pointer = 4
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 2
'Befehl &H02
'liest Feuchtigkeit
'read humidity
'Data "2;aa,read humidity;L,{0.000 to 100.000},%"
      Gosub Read_data
      Gosub Correct_temperature
      Gosub Correct_humidity
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &H02
         I2c_tx_b(2) = Humidity_b(4)
         I2c_tx_b(3) = Humidity_b(3)
         I2c_tx_b(4) = Humidity_b(2)
         I2c_tx_b(5) = Humidity_b(1)
         I2c_write_pointer = 6
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 3
'Befehl &H03
'liest Druck
'read pressure
'Data "3;aa,read pressure;L,{0.000 to 1100.000},hPa"
      Gosub Read_data
      Gosub Correct_temperature
      Gosub Correct_pressure
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &H03
         I2c_tx_b(2) = Pressure_b(4)
         I2c_tx_b(3) = Pressure_b(3)
         I2c_tx_b(4) = Pressure_b(2)
         I2c_tx_b(5) = Pressure_b(1)
         I2c_write_pointer = 6
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
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
            Error_no =4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 5
'Befehl &H05
'liest Oversampling Feuchte
'read Oversampling humidity
'Data "5;aa,as4"
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &H05
         I2c_tx_b(2) = Reg_F2
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
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
            Error_no =4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 7
'Befehl &H07
'liest Oversampling Druck
'read Oversampling pressure
'Data "7;aa,as6"
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &H07
         Tempb = Reg_F4
         Tempb = Tempb AND &B00011100
         Shift Tempb, Right, 2
         I2c_tx_b(2) = Tempb
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
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
            Error_no =4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
      Case 9
'Befehl &H09
'liest Oversampling Temperatur
'read Oversampling Temperatur
'Data "1;aa,as8"
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &H09
         Tempb = Reg_F4
         Tempb = Tempb AND &B11100000
         Shift Tempb, Right, 5
         I2c_tx_b(2) = Tempb
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 10
'Befehl &H0A
'schreibt Pause Zeit
'write non active time
'Data "10;oa,non activ time;b,{0,5,62.5,125,500,1000,10,20},ms"
      If Commandpointer = 2 Then
         If Command_b(2) < 8 Then
            Shift Command_b(2), Left, 5
            Reg_F5 = Reg_F5 And &B00011111
            Reg_F5 = Reg_F5 OR Command_b(2)
            Reg_F5_eeram = Reg_F5
            Gosub Write_config
         Else
            Error_no =4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 11
'Befehl &H0B
'liest Pause Zeit
'readnon active time
'Data "11;aa,as10"
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &H0B
         Tempb = Reg_F5
         Tempb = Tempb AND &B11100000
         Shift Tempb, Right, 5
         I2c_tx_b(2) = Tempb
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
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
            Error_no =4
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 13
'Befehl &H0D
'liest Filter
'read Filter
'Data "13;aa,as12"
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &H0D
         Tempb = Reg_F5
         Tempb = Tempb AND &B00011100
         Shift Tempb, Right, 2
         I2c_tx_b(2) = Tempb
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
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
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &H0B
         I2c_tx_b(2) = Spi_buffer_in(1)
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
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
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;100;21"
      If Commandpointer >= 3 Then
         If Command_b(2) < No_of_announcelines And Command_b(3) < No_of_announcelines Then
            If I2c_tx_busy = 0 Then
               I2c_tx_busy = 1
               Tx_time = 1
               Send_lines = 2
               Number_of_lines = Command_b(3)
               A_line = Command_b(2)
               Gosub Sub_restore
               If Command_mode = 1 Then
                  Gosub Print_i2c_tx
                  While Number_of_lines > 0
                     Gosub Sub_restore
                     Gosub Print_i2c_tx
                  Wend
               End If
            Else
               Error_no = 7
               Error_cmd_no = Command_no
            End If
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 252
'Befehl &HFC
'Liest letzten Fehler
'read last error
'Data 252;aa,LAST ERROR;20,last_error"
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &HFC
         I2c_tx_b(2) = &H80
         'Dummy
         Temps = Str(command_no)
         Tempc = Len (Temps)
         I2c_write_pointer = 3
         For Tempb = 1 To Tempc
            I2c_tx_b(I2c_write_pointer) = Temps_b(Tempb)
            Incr I2c_write_pointer
         Next Tempb
         Select Case Error_no
            Case 0
               Temps = ": command not found: "
            Case 1
               Temps = ": I2C error: "
            Case 3
               Temps = ": Watchdog reset: "
            Case 4
               Temps = ": parameter error: "
            Case 5
               Temps = ": command watchdog: "
            Case 6
               Temps = ": Tx timeout: "
            Case 7
               Temps = ": not valid at that time: "
            Case 8
               Temps = ": i2c_buffer overflow: "
            Case 255
               Temps = ": No error: "
         End Select
         Tempc = Len (Temps)
         For Tempb = 1 To Tempc
            I2c_tx_b(I2c_write_pointer) = Temps_b(Tempb)
            Incr I2c_write_pointer
         Next Tempb
         Temps = Str(Error_cmd_no)
         Tempc = Len(Temps)
         For Tempb = 1 To Tempc
            I2c_tx_b(I2c_write_pointer) = Temps_b(Tempb)
            Incr I2c_write_pointer
         Next Tempb
         I2c_tx_b(2) = I2c_write_pointer - 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
         Gosub Command_received
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
'
   Case 253
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
'Data "253;aa,MYC INFO;b,ACTIVE"
      If I2c_tx_busy = 0 Then
         I2c_tx_busy = 1
         Tx_time = 1
         I2c_tx_b(1) = &HFD
         I2c_tx_b(2) = 4
         'no info
         I2c_write_pointer = 3
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 7
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 254
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127};a,RS232,1;a,USB,1"
      If Commandpointer >= 2 Then
         Select Case Command_b(2)
            Case 0
               If Commandpointer < 3 Then
                  Incr Commandpointer
               Else
                  If Commandpointer = 3 Then
                     Incr Commandpointer
                     If Command_b(3) = 0 Then Gosub Command_received
                  Else
                     L = Command_b(3)
                     If L > 20 Then L = 20
                     L = L + 3
                     If Commandpointer = L Then
                        Dev_name = String(20 , 0)
                        For Tempb = 4 To L
                           Dev_name_b(tempb - 3) = Command_b(tempb)
                        Next Tempb
                        Dev_name_eeram = Dev_name
                        Gosub Command_received
                     Else
                        Incr Commandpointer
                     End If
                  End If
               End If
            Case 1
               If Commandpointer = 3 Then
                  Dev_number = Command_b(3)
                  Dev_number_eeram = Dev_number
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            Case 2
               If Commandpointer < 3 Then
                  Incr Commandpointer
               Else
               'as per announcement: bit
                  If Command_b(3) < 2 Then
                     I2C_active = Command_b(3)
                     I2C_active_eeram = I2C_active
                  Else
                     Error_no = 4
                     Error_cmd_no = Command_no
                  End If
                  Gosub Command_received
               End If
            Case 3
               If Commandpointer = 3 Then
                  Tempb = Command_b(3)
                  If Tempb < 128 Then
                     Tempb = Tempb * 2
                     Adress = Tempb
                     Adress_eeram = Adress
                     Gosub Reset_i2c
                  Else
                     Error_no = 4
                     Error_cmd_no = Command_no
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            Case 4
               If Commandpointer = 3 Then
                  Tempb = Command_b(3)
                  If Tempb < 2 Then
                     Rs232_active = Tempb
                     Rs232_active_eeram = Rs232_active
                  Else
                     Error_no = 4
                     Error_cmd_no = Command_no
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If
            Case 5
               If Commandpointer = 3 Then
                  Tempb = Command_b(3)
                  If Tempb < 2 Then
                     Usb_active = Tempb
                     Usb_active_eeram = Usb_active
                  Else
                     Error_no = 4
                     Error_cmd_no = Command_no
                  End If
                  Gosub Command_received
               Else
                  Incr Commandpointer
               End If

            Case Else
               Error_no = 0
               Error_cmd_no = Command_no
         End Select
      Else
        Incr Commandpointer
      End If
'
   Case 255
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;a,RADIO,1"
      If Commandpointer >= 2 Then
         If I2c_tx_busy = 0 Then
            If Command_b(2) < 8 Then
               Tx_time = 1
               I2c_tx_b(1) = &HFF
               I2c_tx_b(2) = Command_b(2)
               I2c_tx_busy = 1
               Select Case Command_b(2)
                  Case 0
                     'Will send &HFF0000 for empty string
                     Tempc = Len(dev_name)
                     I2c_tx_b(3) = Tempc
                     I2c_write_pointer = 4
                     Tempb = 1
                     While Tempb <= Tempc
                        I2c_tx_b(I2c_write_pointer) = Dev_name_b(tempb)
                        Incr I2c_write_pointer
                        Incr Tempb
                     Wend
                  Case 1
                     I2c_tx_b(3) = Dev_number
                     I2c_write_pointer = 4
                  Case 2
                     I2C_tx_b(3) = I2c_active
                     I2c_write_pointer = 4
                  Case 3
                     Tempb = Adress / 2
                     I2c_tx_b(3) = Tempb
                     I2c_write_pointer = 4
                  Case 4
                     I2c_tx_b(3) = Rs232_active
                     I2c_write_pointer = 4
                  Case 5
                     I2c_tx_b(3) = 0
                     I2c_write_pointer = 4
                  Case 6
                     I2c_tx_b(3) = 3
                     I2c_tx_b(4) = "8"
                     I2c_tx_b(5) = "N"
                     I2c_tx_b(6) = "1"
                     I2c_write_pointer = 7
                  Case 7
                     I2c_tx_b(3) = Usb_active
                     I2c_write_pointer = 4
               End Select
            Else
               Error_no = 4
               Error_cmd_no = Command_no
               'ignore anything else
            End If
            If Command_mode = 1 Then Gosub Print_i2c_tx
            Gosub Command_received
         Else
         Error_no = 7
         Error_cmd_no = Command_no
         End If
      Else
         Incr Commandpointer
      End If
'
   Case Else
      Error_no = 0
      'ignore anything else
      Error_cmd_no = Command_no
      Gosub Command_received
End Select
Stop Watchdog
Return
'
'==================================================
'
End
'
'announce text
'
Announce0:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;Klimasensor;V02.0;1;100;15"
'
Announce1:
'Befehl &H01
'liest Temperatur
'read temperature
Data "1;aa,read temperature;w,{-40.00 to 84.99},DegC"
'
Announce2:
'Befehl &H02
'liest Feuchtigkeit
'read humidity
Data "2;aa,read humidity;L,{0.000 to 100.000},%"
'
Announce3:
'Befehl &H03
'liest Druck
'read pressure
Data "3;aa,read pressure;L,{300.000 to 1100.000},hPa"
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
Data "10;oa,non activ time;b,{0,5,62.5,125,500,1000,10,20},ms"
'
Announce11:
'Befehl &H0B
'liest Pause Zeit
'readnon active time
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
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;100;21"
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
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127};a,RS232,1;a,USB,1"
'
Announce20:
'Befehl &HFF <n>
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,1,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1;a,RADIO,1"
'