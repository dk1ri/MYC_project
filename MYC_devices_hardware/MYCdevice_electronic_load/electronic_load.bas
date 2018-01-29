'-----------------------------------------------------------------------
'name : electronic_load_bascom.bas
'Version V02.0, 20180126
'purpose : This is a electronic load for 7 fets IRFP150
'This Programm workes as I2C slave or serial protocol
'Can be used with hardware  electronic_load V01.2 by DK1RI
'
'The Programm supports the MYC protocol
'Slave max length of I2C string is 250 Bytes.
'Please modify clock frequency and processor type, if necessary
'
'When doing modifying, please check / modify:
' Const No_of_announcelines =
' Const Aline_length (also in F0 command)
' number of announcements in the 0 and 240 command announcements
' add lines in Sub_restore
' IC2 Adress in reset and announcements
' check Const Tx_factor
'
'Fuse Bits :
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
'JTAG Disabled (if applicable)
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other right are affected, this programm can be used
'under GPL (Gnu public licence)
'-----------------------------------------------------------------------
'Templates:
'slave_core_V01.5
'-----------------------------------------------------------------------
'Used Hardware:
' serial
' I2C
' ADC Inputs: all,
'-----------------------------------------------------------------------
' Inputs: see below
' Outputs : see below
' For announcements and rules see Data section at the end
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'Something about the devicedesign:
'If other FETs are used, the constants must be modified.
'This programm workes with 1 to 7 FETs IRFP150:
'Vmax = 90V (100V)
'Imax = 30A   (at 100 degC)
'Ptot = 200W
'Ron = 50mOhm
'so the minimum voltage to be applied and will work under all conditions is
' (10mOhm resistor for measuring)
' (50 + 10 mOhm) * 30A = 1,8V
' If current (per FET) is lower, lower Voltage can be used
'
'All internal calculation are in mV, mA and mW

'The resolution used by commands is 10mV, 10mA, 10mW and mOhm. Some rounding is done.

'The effective voltage resolution is nominal 88mV (2,562 / 2,56) * ( 90V / 1023)
' (2.562V at AD input with 90V)

'Because the AD converter needs 4 - 5 steps for an acceptable accuracy
'the el load will not switch on for voltages below 400mV (AD Converter = 4)
'
'The current resolution is nominal 29mA (30A *0.01Ohm * (154kOhm / 18kOhm) / 2,56V)*(30 / 1023)
'so the minimum current (1 Fet active) to be applied for an acceptable current result is 120mA
' (AD Converter = 4)
'
'The minimum resistor value of the load is (50 + 10 mOhm + 3mOhm) / 7 ~ 9 mOhm  (3mOhm: wire)
'The maximum is given by the max voltage and the minimum current:
' 90V / 28mA ~ 3kOhm
'The required resistor has a range from 9 mOhm to 3.000.000 mOhm
'
'The usable maximum power depends on cooling and may be modified.
'default value is 50W per fet (350W total)
'Absolute maximimum is 1400W with IRFP150
' The range is 000 W to 1400.00 W
'
'To improve accuracy the number of used FETs is as low as possible
'So the requested power is either given or calculated, when the voltage is applied
'If the requested power is < n * (max_power_per_FET * 0.8) then only n FETs are used
'starting with FET1.
'The Number_of_used_fets is calculated once only after sending the "requested I / P / R" command.
' This strategy limited the minimum voltage, but 1.8V will work always.
'
'-----------------------------------------------------------------------
$regfile = "m1284pdef.dat"
$crystal = 20000000
$baud = 19200
'use baud rate
$hwstack = 32
'default use 32 for the hardware stack
$swstack = 10
'default use 10 for the SW stack
$framesize = 40
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
Const I2c_buff_length = 254
'that is maximum
Const Stringlength = I2c_buff_length - 4
'I2c_buff_length - command - parameter
Const Not_valid_cmd = &H80
'a non valid commandtoken
Const Cmd_watchdog_time = 200
'Number of main loop * 256  before command reset
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
Const Tx_timeout = 20
'ca 5s: 10 for 10MHZ 20 for 20 MHz
'Number of loops: 256 * 30 * Tx_timeout
'timeout, when I2c_Tx_b is cleared and new commands allowed
'
Const No_of_announcelines = 41
'
'el load specific:
Const Calibrate_i_factor_default = 5
'100% is 30A, used if 30A is not available(default = 1,5A)
Const Calibrate_u_factor_default = 25
'100% is 90V, used if 90V is not available (default = 22.5V)
Const Correction_u_default = 89.736
' (90000mV / 1023) * 1.02  (1.02: my device)
Const Correction_i_default = 29.3255
' 30000mA / 1023 * 1.0
'
Const On_off_time_default = 128 * 4
'about 1 s
Const Minimum_voltage = 400
'400mV necessary to switch on the load
'
Const Max_voltage = 90000
'90V
Const Max_current = 30000
'30A
Const Resolution_i = Max_current / 1023
'29mA
Const Hysterese_factor = 2
'multiplier for Resolution_i
Const Hysterese_i = Resolution_i * Hysterese_factor
'
Const Ad_resolutuion = 1023
'
Const Da_resolution = 4095
'for MCP4921 12 Bit
Const Dac_adder = &H30
'DAC config, to be added to the high byte
'bit 15: 0 DAC activ
'bit 14: 0 unbuffered (Vref = 5V)
'bit 13: 1 Gain 1
'bit 12: 1 output enabled
Const Ad_resolution = 1024
'Atmega
Const Fet_voltage_min = 0
'min dac out voltage; LM324 can handle 0 V
Const Fet_voltage_adder = 1
'change of FET voltage per step; digital value
Const Max_power_default = 50000
'50W per fet
Const Active_fets_default = &B01111111
'Fet1 is LSB, all Fets working
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
Dim Usb_active_eeram As Eram Byte
'
Dim L As Byte
Dim Tempa As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temps As String * 20
Dim Temps_b(20) As Byte At Temps Overlay
'
Dim I As Byte
Dim J As Byte

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
Dim I2c_tx As String * I2c_buff_length
Dim I2c_tx_b(I2c_buff_length) As Byte At I2c_tx Overlay
Dim I2c_pointer As Byte
Dim I2c_write_pointer As Byte
Dim I2c_tx_busy As Byte
' 0: new commands ok
' 2. answer in progress, new command wait, until data transfer finished or timeout
Dim Command As String * I2c_buff_length
'Command Buffer
Dim Command_b(I2c_buff_length) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
'
Dim Twi_status As Byte
'
Dim Error_no As Byte
Dim Error_cmd_no As Byte
Dim Cmd_watchdog As Word
'Watchdog for loop
'Watchdog for I2c sending
Dim Tx_time As Byte
Dim Command_mode As Byte
'0: I2C input 1: seriell
'
Dim Max_power As Dword
'per FET in W
Dim Max_power_eeram As Eram Dword
Dim Active_fets As Byte
Active_fet_1 Alias Active_fets.0
Active_fet_2 Alias Active_fets.1
Active_fet_3 Alias Active_fets.2
Active_fet_4 Alias Active_fets.3
Active_fet_5 Alias Active_fets.4
Active_fet_6 Alias Active_fets.5
Active_fet_7 Alias Active_fets.6
Dim Active_fets_eeram As Eram Byte
Dim On_off_time As Word
Dim On_off_time_eeram As Eram Word
' for electronic load:
Dim Calibrate_i_factor As Byte
Dim Calibrate_i_factor_eeram As Eram Byte
Dim Calibrate_u_factor As Byte
Dim Calibrate_u_factor_eeram As Eram Byte
Dim Correction_u As Single
'error in %
Dim Correction_u_eeram As Eram Single
Dim Correction_i(7) As Single
'error in %
Dim Correction_i1_eeram As Eram Single
Dim Correction_i2_eeram As Eram Single
Dim Correction_i3_eeram As Eram Single
Dim Correction_i4_eeram As Eram Single
Dim Correction_i5_eeram As Eram Single
Dim Correction_i6_eeram As Eram Single
Dim Correction_i7_eeram As Eram Single
'
Dim Voltage As Dword
'0 - 90000 mV
'
Dim Current(7) As Word
Dim Required_i_min As Word
Dim Required_i_max As Word
Dim Required_i As Word
'0 - 30000mA
Dim All_current As Dword
'0 - 210000mA
'
Dim Power_(7) As Dword
Dim All_power As Dword
Dim Required_p As Dword
'0 - 1400000mW (200W / Fet)
'
Dim Resistance As Dword
Dim Required_r As Dword
'
Dim On_off_mode As Bit
Dim On_off As Bit
Dim On_off_counter As Word
'
Dim Adc_register(7) as Word
Dim Fet_number As Byte
'Fet in use
'
'available Fets:
Dim Number_of_active_fets As Byte
'each Fet coded as a bit: bit 0:FET1
'used Fets
Dim Number_of_used_fets As Byte
Dim Used_fets As Byte
Used_fets_1 Alias Used_fets.0
Used_fets_2 Alias Used_fets.1
Used_fets_3 Alias Used_fets.2
Used_fets_4 Alias Used_fets.3
Used_fets_5 Alias Used_fets.4
Used_fets_6 Alias Used_fets.5
Used_fets_7 Alias Used_fets.6
'Fets used for a measurement
Dim R_or_p as Byte
'default: 0: off, 1: check for R, 2: check for P, 3: check for I (calibrate)
Dim No_more_fets As Bit
Dim Dac_out_voltage(7) As Word
Dim Fet_voltage_temp As Word
Dim Spi_buffer(3) As Byte
Dim Temp_w As Word
Dim Temp_w_b1 As Byte At Temp_w Overlay
Dim Temp_w_b2 As Byte At Temp_w + 1 Overlay
Dim Temp_single As Single
Dim Temp_single1 As Single
Dim Temp_dw As Dword
Dim Temp_dw_b1 As Byte At Temp_dw Overlay

Dim Temp_dw_b2 As Byte At Temp_dw +1 Overlay
Dim Temp_dw_b3 As Byte At Temp_dw +2 Overlay
Dim Temp_dw_b4 As Byte At Temp_dw +3 Overlay
Dim Temp_dw1 As Dword
'
Blw = peek (0)
If Blw.WDRF = 1 Then
   Error_no = 3
Else
   Error_no = 255
End If
'
'**************** Config / Init
Config PortD.5 = Output
Gon Alias PortD.5
Reset Gon
'disable Gate Voltage for fets
Config PinB.1 = Input
PortB.1 = 1
Reset__ Alias PinB.1
Config PortB.0 = Output
LED1 Alias PortB.0
'
Config PortC = Output
Set Portc
Fet1 Alias PortC.4
Fet2 Alias PortC.7
Fet3 Alias PortC.5
Fet4 Alias PortC.6
Fet5 Alias PortC.2
Fet6 Alias PortC.3
Config PortD.7 = Output
Fet7 Alias PortD.7
set Fet7
Config PortD.6 = Output
LDAC Alias PortD.6
Set Ldac
'
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = High, Phase = 1, Clockrate = 4, Noss = 0
Spiinit
'
Config Adc = Single , Prescaler = Auto , Reference = Internal_2.56
Start ADC
'must, will not work without start
'
Config Watchdog = 2048
'
'****************Interrupts
'Enable Interrupts
'
'**************** Main ***************************************************
'
Wait 1
Set Gon
'enable Gate Voltage for fets
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
'Blink and timeoout
Incr J
If J = 255 Then
   J = 0
   Incr I
   Select Case I
      Case 30
         If Tx_time > 0 Then
            Incr Tx_time
            If Tx_time > Tx_timeout Then
               Gosub Reset_i2c_tx
               Error_no = 6
               Error_cmd_no = Command_no
            End If
         End If
      Case 255
         I = 0
         'twint set?
         If TWCR.7 = 0 Then Gosub Reset_i2c
   End Select
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong commands will be deleted
'commandbuffers is reset
   If Cmd_watchdog > 0 Then Incr Cmd_watchdog
      If Cmd_watchdog > Cmd_watchdog_time Then
      Error_no = 5
      Error_cmd_no = Command_no
      Gosub Command_received
   End If
End If
'
Gosub Measure_v
'
If Used_fets > 0 Then
   'R_or_p > 0; load active!
   If Voltage < Minimum_voltage Then
      Gosub Switch_off
   Else
      If On_off_mode = 1 Then
         Gosub Operate_On_of_mode
         'no more modifications
      Else
         If R_or_p > 1 Then Gosub Calculate_required_i
         Gosub Modify_fet_voltage
         Gosub Measure_i
         Gosub Next_fet_to_use
      End If
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
   If I2c_tx_busy = 0 Then
      Command_b(Commandpointer) = A
      If RS232_active = 1 Or Usb_active = 1 Then
         Gosub Slave_commandparser
      Else
         'allow &HFE only
         If Command_b(1) <> 254 Then
            Gosub  Command_received
         Else
            Gosub Slave_commandparser
         End If
      End If
   Else
      Error_no = 7
      Error_cmd_no = Command_no
   End If
End If
'
'I2C
'This part should be executed as fast as possible to continue I2C:
'twint set?
If TWCR.7 = 1 Then
   'twsr 60 -> start, 80-> data, A0 -> stop
      Twi_status = TWSR And &HF8
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
      'slave send:
      'a slave send command must always be completed (or until timeout)
      'incoming commands are ignored as long as i2c_tx is not empty
      'for multi line F0 command I2c_tx may be loaded a few times if necessary.
      'multiple announcelines are loaded by line
      If I2c_write_pointer = 1 Or I2c_active = 0 Then
         'nothing to send
         Twdr = Not_valid_cmd
      Else
         If I2c_pointer < I2c_write_pointer Then
            'continue sending
            TWDR = I2c_tx_b(I2c_pointer)
            Incr I2c_pointer
            If I2c_pointer >= I2c_write_pointer Then
               If Number_of_lines > 0 Then
                  Gosub Sub_restore
               Else
                  Gosub Reset_i2c_tx
               End If
            End If
         End If
      End If
   Else
      If Twi_status = &H80 Or Twi_status = &H88 Then
         'I2C receives data and and interpret as commands.
         If I2c_tx_busy = 0 Then
            If Command_mode = 1 Then
            'restart if rs232mode
               Command_mode = 0
               'i2c mode
               Gosub  Command_received
            End If
            Command_b(Commandpointer) = TWDR
            If I2c_active = 0 And Command_b(1) <> 254 Then
               'allow &HFE only
               Gosub  Command_received
            Else
               Gosub Slave_commandparser
            End If
         Else
            Error_no = 7
            Error_cmd_no = Command_no
         End If
      End If
   End If
   Twcr = &B11000100
End If
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
Dev_number = 1
Dev_number_eeram = Dev_number
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
'
Adress_eeram = 42
'internal: even figures only
Adress_eeram = Adress
I2C_active = 1
I2C_active_eeram = I2C_active
RS232_active = 1
RS232_active_eeram = RS232_active
USB_active = 1
Usb_active_eeram = Usb_active
'
Calibrate_i_factor_eeram = Calibrate_i_factor_default
Calibrate_u_factor_eeram = Calibrate_u_factor_default
Max_power_eeram = Max_power_default
'50W
Active_fets_eeram = Active_fets_default
On_off_time_eeram = On_off_time_default
Correction_u_eeram = Correction_u_default
Correction_i1_eeram = Correction_i_default
Correction_i2_eeram = Correction_i_default
Correction_i3_eeram = Correction_i_default
Correction_i4_eeram = Correction_i_default
Correction_i5_eeram = Correction_i_default
Correction_i6_eeram = Correction_i_default
Correction_i7_eeram = Correction_i_default

'
'This should be the last
First_set = 5
'set at first use
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
Error_cmd_no = 0
Send_lines = 0
Gosub Command_received
Gosub Reset_i2c_tx
Gosub Reset_i2c
I = 0
J = 0
Command_mode = 0
Announceline = 255
I2c_tx_busy = 0
'
Correction_u = Correction_u_eeram
Correction_i(1) = Correction_i1_eeram
Correction_i(2) = Correction_i2_eeram
Correction_i(3) = Correction_i3_eeram
Correction_i(4) = Correction_i4_eeram
Correction_i(5) = Correction_i5_eeram
Correction_i(6) = Correction_i6_eeram
Correction_i(7) = Correction_i7_eeram
Max_power = Max_power_eeram
Calibrate_i_factor = Calibrate_i_factor_eeram
Calibrate_u_factor = Calibrate_u_factor_eeram
On_off_time = On_off_time_eeram
'will be switched of by on_off_mode
Active_fets = Active_fets_eeram
Number_of_active_fets = 0
If Active_fet_1 = 1 Then Incr Number_of_active_fets
If Active_fet_2 = 1 Then Incr Number_of_active_fets
If Active_fet_3 = 1 Then Incr Number_of_active_fets
If Active_fet_4 = 1 Then Incr Number_of_active_fets
If Active_fet_5 = 1 Then Incr Number_of_active_fets
If Active_fet_6 = 1 Then Incr Number_of_active_fets
If Active_fet_7 = 1 Then Incr Number_of_active_fets
Gosub Reset_load
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
I2c_tx_busy = 0
Tx_time = 0
Return
'
Command_received:
Commandpointer = 1
Incr Command_no
If Command_no = 255 Then Command_no = 1
If Command_no = Error_cmd_no Then
   Error_cmd_no = 0
   Error_no = 255
End If
Cmd_watchdog = 0
Return
'
Sub_restore:
' read one line
Select Case Send_lines
   'select the start of text
   Case 1
      Tempd = 1
   Case 3
      Tempd = 2
   Case 2
      Tempd = 4
End Select
'
Select Case A_line
'
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
   Case 21
      Restore Announce21
   Case 22
      Restore Announce22
   Case 23
      Restore Announce23
   Case 24
      Restore Announce24
   Case 25
      Restore Announce25
   Case 26
      Restore Announce26
   Case 27
      Restore Announce27
   Case 28
      Restore Announce28
   Case 29
      Restore Announce29
   Case 30
      Restore Announce30
   Case 25
      Restore Announce30
   Case 31
      Restore Announce31
   Case 32
      Restore Announce32
   Case 33
      Restore Announce33
   Case 34
      Restore Announce34
   Case 35
      Restore Announce35
   Case 36
      Restore Announce36
   Case 37
      Restore Announce37
   Case 38
      Restore Announce38
   Case 39
      Restore Announce39
   Case 40
      Restore Announce40
   Case Else
         'will not happen
End Select
Read I2c_tx
Tempc = Len(I2c_tx)
For Tempb = Tempc To 1 Step - 1
   Tempa = Tempb + Tempd
   I2c_tx_b(Tempa) = I2c_tx_b(Tempb)
Next Tempb
Select Case Send_lines
   Case 1
      I2c_tx_b(1) = Tempc
      I2c_write_pointer = Tempc + 2
      'additional announcement lines
   Case 3
      'start basic announcement
      I2c_tx_b(1) = &H00
      I2c_tx_b(2) = Tempc
      I2c_write_pointer = Tempc + 3
      Send_lines = 1
   Case 2
      'start of announceline(s), send 3 byte first
      I2c_tx_b(1) = &HF0
      I2c_tx_b(2) = A_line
      I2c_tx_b(3) = Number_of_lines
      I2c_tx_b(4) = Tempc
      I2c_write_pointer = Tempc + 5
      Send_lines = 1
End Select
Incr A_line
If A_line >= No_of_announcelines Then A_line = 0
Decr Number_of_lines
'Else
'happens, for &HF=xx00
'send header only
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
Switch_off:
'This is faster than calling Send_to_fet
Set Ldac
Spi_buffer(1) = High(Da_resolution)
Spi_buffer(1) = Spi_buffer(1) + Dac_adder
Spi_buffer(2) = Low(Da_resolution)
'highest value is off
Reset Fet1
Reset Fet2
Reset Fet3
Reset Fet4
Reset Fet5
Reset Fet6
Reset Fet7
Spiout Spi_buffer , 2
'send to all in parallel
Set Fet1
Set Fet2
Set Fet3
Set Fet4
Set Fet5
Set Fet6
Set Fet7
Reset Ldac
Reset Ldac
'min time is 100ns
Set Ldac
For Tempb = 1 to  7
   Dac_out_voltage(Tempb) = Da_resolution - 1
Next Tempb
Return
'
Reset_load:
Gosub Switch_off
R_or_p = 0
Required_r = 2000000
'3kOhm
Required_p = 0
Required_i = 0
Fet_voltage_temp = 0
Used_fets = 0
Number_of_used_fets = 0
On_off_mode = 0
On_off = 0
On_off_counter = 0
All_current = 0
All_power = 0
Fet_number = 7
For Tempb = 1 to 7
   ' for all fets
   Power_(Tempb) = 0
   Current(Tempb) = 0
Next Tempb
Reset LED1
Return
'
Modify_fet_voltage:
   If All_current < Required_i_min Then
      'complete I too low -> raise fetvoltage
      Temp_w = Da_resolution - Fet_voltage_adder
      If Dac_out_voltage(Fet_number) < Temp_w Then
         'must raise due to inverting LM324
         Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Fet_voltage_adder
         Gosub Send_to_fet
      End If
   Else
      If All_current > Required_i_max Then
         'complete I too high, current to low -> reduce fetvoltage
         If Dac_out_voltage(Fet_number) > Fet_voltage_adder Then
            Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) - Fet_voltage_adder
            Gosub Send_to_fet
         End If
      End If
   End If
Return
'
Send_to_FET:
Spi_buffer(1) = High(Dac_out_voltage(Fet_number))
Spi_buffer(1) = Spi_buffer(1) + Dac_adder
'add config bits
Spi_buffer(2) = Low(Dac_out_voltage(Fet_number))
Tempb =  Spi_buffer(1)
printbin fet_number
printbin Tempb
Tempb = Spi_buffer(2)
printbin Tempb
Select Case Fet_number
   Case 1
      Reset Fet1
      Spiout Spi_buffer(1) , 2
      Set Fet1
   Case 2
      Reset Fet2
      Spiout Spi_buffer(1) , 2
      Set Fet2
   Case 3
      Reset Fet3
      Spiout Spi_buffer(1) , 2
      Set Fet3
   Case 4
      Reset Fet4
      Spiout Spi_buffer(1) , 2
      Set Fet4
   Case 5
      Reset Fet5
      Spiout Spi_buffer(1) , 2
      Set Fet5
   Case 6
      Reset Fet6
      Spiout Spi_buffer(1) , 2
      Set Fet6
   Case 7
      Reset Fet7
      Spiout Spi_buffer(1) , 2
      Set Fet7
End Select
Reset Ldac
'transfer to Output
Reset Ldac
'min time is 100ns
Set Ldac
Return
'
Measure_v:
Temp_dw = Getadc(0)
Temp_single = Temp_dw * Correction_u
Voltage = Temp_single
'mV
Return
'
I_measure:
   Select Case Fet_number
      Case 1
         Temp_w = Getadc(1)
      Case 2
         Temp_w = Getadc(2)
      Case 3
         Temp_w = Getadc(3)
      Case 4
         Temp_w = Getadc(4)
      Case 5
         Temp_w = Getadc(5)
      Case 6
         Temp_w = Getadc(6)
      Case 7
         Temp_w = Getadc(7)
   End Select
Return
'
Measure_i:
'measure I for Fet_number
'Calculate I, P and R (all active FETs)
'switch off if power is exceeded
'
   Gosub I_measure
'
   Adc_register(Fet_number) = Temp_w
   Temp_single = Temp_w * Correction_i(Fet_number)
   Current(Fet_number) = Temp_single
   Temp_single = Voltage * Current(Fet_number)
   Temp_single = Temp_single / 1000
   Power_(Fet_number) = Temp_single
   If Power_(Fet_number) > Max_power Then
      Error_no = 11
      Error_cmd_no = Command_no
      Gosub Reset_load
      Return
   Else
      All_current = 0
      All_power = 0
      For Tempb = 1 To 7
         All_current = All_current + Current(Tempb)
         All_power = All_power + Power_(Tempb)
      Next Tempb
      If All_current > 0 Then
         Temp_single = Voltage / All_current
         Resistance = Temp_single * 1000
         If Resistance > 2000000 Then Resistance = 2000000
         'mOhm
      Else
         Resistance = 2000000
      End If
   End If
Return
'
Calculate_required_i:
   'For Require_p and require_R after measuring the voltage the required_i must be recalculated
   Temp_single = Required_p / Voltage
   'mW / mV
   Required_i = Temp_single * 1000
   Required_i_min = Required_i - Hysterese_i
   Required_i_max = Required_i + Hysterese_i
   'mA
Return
'
Next_fet_to_use:
Incr Fet_number
If Fet_number = 8 Then Fet_number = 1
Tempb = 1
Tempc = 1
While Tempb = 1 And Tempc < 8
   If Fet_number = 1 And Used_fets_1 = 1 Then Tempb = 0
   If Fet_number = 2 And Used_fets_2 = 1 Then Tempb = 0
   If Fet_number = 3 And Used_fets_3 = 1 Then Tempb = 0
   If Fet_number = 4 And Used_fets_4 = 1 Then Tempb = 0
   If Fet_number = 5 And Used_fets_5 = 1 Then Tempb = 0
   If Fet_number = 6 And Used_fets_6 = 1 Then Tempb = 0
   If Fet_number = 7 And Used_fets_7 = 1 Then Tempb = 0
   If Tempb = 1 Then
      Incr Fet_number
      If Fet_number = 8 Then Fet_number = 1
   End If
   'skip unused fet
   Incr Tempc
   'To leave the loop :)
Wend
Return
'
Operate_On_of_mode:
   Incr On_off_counter
   If On_off_counter > On_off_time Then
   'time to switch
      If On_off = 0 Then
      'off -> switch on
         Reset Led1
         On_off = 1
         For Fet_number = 1 To 7
         'set to latest voltage
             Fet_voltage_temp = Dac_out_voltage(Fet_number)
             Gosub Send_to_fet
         Next Fet_number
      Else
      'on -> switch off
         Set Led1
         On_off = 0
         For Fet_number = 1 To 7
            Fet_voltage_temp = Da_resolution
            'switch off
            Gosub Send_to_fet
            Gosub Measure_i
            'Measure all Fets
         Next Fet_number
      End If
      On_off_counter = 0
   End If
Return
'
Calculate_Number_of_fets_to_use:
'called by required p / I / R only
   If Active_fets = 0 Then
      Error_no = 12
      Error_cmd_no = Command_no
      Gosub Reset_load
      Return
   End If
   Temp_single = Max_power * Number_of_active_fets
   Temp_dw = Temp_single
   If Required_p > Temp_dw Then
      Error_no = 9
      Error_cmd_no = Command_no
      Return
   End If
   Temp_single = Max_power * 0.8
   Temp_w = Temp_single
   '80 % of max power per Fet
'
   'Temp_dw1 is reqired power
   Temp_dw = 0
   'Power , which Tempb Fets handle (80%)
   Number_of_used_fets = 0
   Used_fets = 0
   No_more_fets = 0
   If Active_fet_1 = 1 Then
      Temp_dw = Temp_dw + Temp_w
      Incr Number_of_used_fets
      Used_fets_1 = 1
      If Temp_dw > Temp_dw1 Then No_more_fets = 1
   End If
   If Active_fet_2 = 1 And No_more_fets = 0 Then
      Temp_dw = Temp_dw + Temp_w
      Incr Number_of_used_fets
      Used_fets_2 = 1
      If Temp_dw > Temp_dw1 Then No_more_fets = 1
   End If
   If Active_fet_3 = 1 And No_more_fets = 0 Then
      Temp_dw = Temp_dw + Temp_w
      Incr Number_of_used_fets
      Used_fets_3 = 1
      If Temp_dw > Temp_dw1 Then No_more_fets = 1
   End If
   If Active_fet_4 = 1 And No_more_fets = 0 Then
      Temp_dw = Temp_dw + Temp_w
      Incr Number_of_used_fets
      Used_fets_4 = 1
      If Temp_dw > Temp_dw1 Then No_more_fets = 1
   End If
   If Active_fet_5 = 1 And No_more_fets = 0 Then
      Temp_dw = Temp_dw + Temp_w
      Incr Number_of_used_fets
      Used_fets_5 = 1
      If Temp_dw > Temp_dw1 Then No_more_fets = 1
   End If
   If Active_fet_6 = 1 And No_more_fets = 0 Then
      Temp_dw = Temp_dw + Temp_w
      Incr Number_of_used_fets
      Used_fets_6 = 1
      If Temp_dw > Temp_dw1 Then No_more_fets = 1
   End If
   If Active_fet_7 = 1 And No_more_fets = 0 Then
      Temp_dw = Temp_dw + Temp_w
      Incr Number_of_used_fets
      Used_fets_7 = 1
   End If
   'It may be, that 80% Power is exceeded
'
   Required_i_min = Required_i - Resolution_i
   Required_i_max = Required_i + Resolution_i
Return
'
Slave_commandparser:
'checks to avoid commandbuffer overflow are within commands !!
'
'start watchdog if 0
Incr Cmd_watchdog
'
Select Case Command_b(1)
   Case 0
'Befehl &H00
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
'Data "0;m;DK1RI;electronic load for 7 IRFP150;V02.0;1;145;1;41;1-1"
      I2c_tx_busy = 2
      Tx_time = 1
      A_line = 0
      Number_of_lines = 1
      Send_lines = 3
      Gosub Sub_restore
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 1
'Befehl &H01 (resolution 10mV);  1 byte / 3 byte
'lese aktuelle Spannung
'read actual voltage
'Data "1;ap,read actual voltage;1;10001,{0.00 to 100.00};lin:V"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_single = Voltage / 10
      'mV -> 10mV
      Temp_w = Temp_single
      I2c_tx_b(1) = &H01
      I2c_tx_b(2) = High(Temp_w)
      I2c_tx_b(3) = Low(Temp_w)
      I2c_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 2
'Befehl &H02; 1 byte / 3 byte
'liest gesamten Strom (1Bit -> 10mA)
'read all current
'Data "2;ap,read actual current;1;21001,{0.00 to 210.00};lin:A"
      If On_off_mode = 0 Then
         I2c_tx_busy = 2
         Tx_time = 1
         Temp_dw = All_current / 10
         'mA -> 10mA
         Temp_w = Temp_dw
         I2c_tx_b(1) = &H02
         I2c_tx_b(2) = High(Temp_w)
         I2c_tx_b(3) = Low(Temp_w)
         I2c_write_pointer = 4
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 4
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 3
'Befehl &H03  0 - 6 (resolution 10mA); 2 byte / 4 byte
'liest aktuellen Strom eines FETs
'read actual current of a FET
'Data "3;ap,read actual current;7;30001,{0.00 to 30.00};lin:A"
      If On_off_mode = 0 Then
         If Commandpointer >= 2 Then
            I2c_tx_busy = 2
            Tx_time = 1
            Tempb = Command_b(2) + 1
            Temp_dw = Current(Tempb) / 10
            'mA -> 10mA
            Temp_w = Temp_dw
            I2c_tx_b(1) = &H03
            I2c_tx_b(2) = Command_b(2)
            I2c_tx_b(3) = High(Temp_w)
            I2c_tx_b(4) = Low(Temp_w)
            I2c_write_pointer = 5
            If Command_mode = 1 Then Gosub Print_i2c_tx
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      Else
         Error_no = 4
         Error_cmd_no = Command_no
         Gosub Command_received
      End If
'
   Case 4
'Befehl &H04  (resolution 10mW); 1 byte / 5 byte
'liest gesamte Leistung
'read all current
'Data "4;ap,read actual power;1;140001,{0.00 to 1400.00};lin;W"
      If On_off_mode = 0 Then
         I2c_tx_busy = 2
         Tx_time = 1
         Temp_dw = All_power / 100
         'mW -> 10mW
         Temp_w = Temp_dw
         I2c_tx_b(1) = &H04
         I2c_tx_b(2) = Temp_dw_b4
         I2c_tx_b(3) = Temp_dw_b3
         I2c_tx_b(4) = Temp_dw_b2
         I2c_tx_b(5) = Temp_dw_b1
         I2c_write_pointer = 6
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 4
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 5
'Befehl &H05  0 - 6 (resolution 10mW); 2 byte / 4 Byte
'liest aktuelle Leistung eines FETs
'read actual power of a FET
'Data "5;ap,read actual power;7;20001,{0.00 to 200.00};lin;W"
      If On_off_mode = 0 Then
         If Commandpointer >= 2 Then
            If Command_b(2) < 7 Then
               I2c_tx_busy = 2
               Tx_time = 1
               Tempb = Command_b(2) + 1
               Temp_dw = Power_(Tempb)
               Temp_dw = Temp_dw / 10
               'mW -> 10mW
               Temp_w = Temp_dw
               I2c_tx_b(1) = &H05
               I2c_tx_b(2) = Command_b(2)
               I2c_tx_b(3) = High(Temp_w)
               I2c_tx_b(4) = Low(Temp_w)
               I2c_write_pointer = 5
               If Command_mode = 1 Then Gosub Print_i2c_tx
            Else
               Error_no = 4
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      Else
         Error_no = 4
         Error_cmd_no = Command_no
         Gosub Command_received
      End If
'
   Case 6
'Befehl &H06 (resolution mOhm); 1 byte / 5 byte
'liest aktuellen Widerstand
'read actual resistor
'Data "6;ap,read actual resistor;1;3000000,{1 to 3000000};lin;mOhm"
      If On_off_mode = 0 Then
         I2c_tx_busy = 2
         Tx_time = 1
         Temp_dw = Resistance
         If Temp_dw > 3000000 Then Temp_dw = 3000000
         I2c_tx_b(1) = &H06
         I2c_tx_b(2) = Temp_dw_b4
         I2c_tx_b(3) = Temp_dw_b3
         I2c_tx_b(4) = Temp_dw_b2
         I2c_tx_b(5) = Temp_dw_b1
         I2c_write_pointer = 6
         If Command_mode = 1 Then Gosub Print_i2c_tx
      Else
         Error_no = 4
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 7
'Befehl &H07 0 - 21000 (10mA resolution); 3 byte / -
'gewuenschten Strom
'required current
'Data "7;op,required current;1;21001,{0.00 to 210,00};lin;A"
      If Commandpointer >= 3 Then
         Gosub Reset_load
         Temp_w_b1 = command_b(3)
         'low byte first
         Temp_w_b2 = command_b(2)
         Temp_single = Temp_w * 10
         Temp_single1 = Hysterese_factor * Resolution_i
         If Temp_single > Temp_single1 Then
         'do nothing, if lower
            Temp_dw = Temp_single
            Temp_dw1 = Max_current * Number_of_active_fets
            If Temp_dw <= Temp_dw1 Then
            'must not be higher than allowed
               If Voltage > Minimum_voltage Then
                  Required_i = Temp_dw
                  R_or_p = 1
                  'Current given -> calculate required Power
                  Temp_single = Voltage * Required_i
                  'required_p uW
                  Temp_single = Temp_single / 1000
                  Required_p = Temp_single
                  'mW
                  Gosub Calculate_Number_of_fets_to_use
               Else
                  Error_no = 4
                  Error_cmd_no = Command_no
               End If
            Else
               Error_no = 14
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
   Case 8
'Befehl &H08  (10mA resolution); 1 byte / 3 byte
'gewuenschten Strom lesen
'read required current
'Data "8;ap,as7"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_w = Required_i / 10
      I2c_tx_b(1) = &H08
      I2c_tx_b(2) = High(Temp_w)
      I2c_tx_b(3) = Low(Temp_w)
      I2c_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 9
'Befehl &H09 0 - 65535 (10mW resolution); 4 byte / -
'gewuenschte Leistung
'required power
'Data "9;op,required power;1;140001,{0.00 to 1400.00};lin;W"
      If Commandpointer >= 4 Then
         Gosub Reset_load
         Temp_dw_b1 = command_b(4)
         'low byte first
         Temp_dw_b2 = command_b(3)
         Temp_dw_b3 = command_b(2)
         Temp_dw_b4 = 0
         Temp_dw = Temp_dw * 10
         '-> mW
         Temp_dw1 = Max_power * Number_of_active_fets
         If Temp_dw <= Temp_dw1 Then
         'must not be higher than allowed
            If Voltage > Minimum_voltage Then
               Required_p = Temp_dw
               R_or_p = 2
               Gosub Calculate_required_i
               Gosub Calculate_Number_of_fets_to_use
            Else
               Error_no = 14
               Error_cmd_no = Command_no
            End If
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End IF
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 10
'Befehl &H0A (10mW resolution); 1 byte / 4 byte
'gewuenschte Leistung lesen
'read required power
'Data "10;ap,as9"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_single = Required_p / 10
      Temp_dw = Temp_single
      I2c_tx_b(1) = &H0A
      I2c_tx_b(2) = Temp_dw_b4
      I2c_tx_b(3) = Temp_dw_b3
      I2c_tx_b(4) = Temp_dw_b2
      I2c_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'

   Case 11
'Befehl &H0B 9mOhm - 3kOhm (resolution 1mOhm); 4 byte / -
'gewuenschten Widerstand schreiben
'write required resistor
'Data "11;op,required resistor:1;2999991,{9 to 3000000};lin;mOhm"
      If Commandpointer = 4 Then
         Temp_dw_b4 = command_b(2)
         'high byte first
         Temp_dw_b3 = command_b(3)
         Temp_dw_b2 = command_b(4)
         Temp_dw_b1 = command_b(5)
         If Temp_dw < 2999991 Then
         '0 based
            If Voltage > Minimum_voltage Then
               Gosub Reset_load
               Required_r = Temp_dw + 9
               'in mOhm
               R_or_p = 3
               'Resistor given -> calculate required Power
               Temp_single = Voltage / Required_r
               'I A (mV / mOhm)
               Temp_single = Temp_single * Voltage
               'A * mV = mW
               Required_p = Temp_single
               Gosub Calculate_required_i
               Gosub Calculate_Number_of_fets_to_use
               On_off = 1
            Else
               Error_no = 14
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
   Case 12
'Befehl &H0C (resolution 1mOhm); 1 byte / 4 byte
'gewuenschter Widerstand mOhm lesen
'read required resistor
'Data "12;ap,as11"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_dw = Required_r - 9
      I2c_tx_b(1) = &H0A
      I2c_tx_b(2) = Temp_dw_b4
      I2c_tx_b(3) = Temp_dw_b3
      I2c_tx_b(4) = Temp_dw_b2
      I2c_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 13
'Befehl &H0D 0|1; 2 byte / -
'Wechsellast schreiben
'write (start) on /off mode
'Data "13;or,on off mode;1;0,off,on"
      If R_or_p > 0 Then
         If Commandpointer >= 2 Then
            If Command_b(2) < 2  Then
               If Command_b(2) = 1 Then
                  On_off_mode = 1
                  On_off = 0
                  On_off_counter = 0
                  Set Led1
               Else
                  On_off_mode = 0
                  On_off = 1
                  ' enable normal usage
                  On_off_counter = 0
                  Reset Led1
               End If
            Else
               Error_no = 4
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      Else
         Error_no = 4
         Error_cmd_no = Command_no
         Gosub Command_received
      End If
   Case 14
'Befehl &H0E; 1 byte / 2 byte
'Wechsellast lesen
'read on /off mode
'Data "14;ar,as13"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_single = Required_p / 20
      Temp_w = Temp_single
      I2c_tx_b(1) = &H0E
      I2c_tx_b(2) = On_off_mode
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 15
'Befehl &H0F; 2 byte / -
'Zeit für Wechsellast schreiben
'write time for on - off mode
'Data "15;op,time for on off mode;1;128,{0 to 2.55};lin;s"
      If Commandpointer >= 2 Then
         On_off_time = Command_b(2) * 50
         On_off_time_eeram = On_off_time
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 16
'Befehl &H10; 1 byte / 2 byte
'Zeit für Wechsellast lesen
'read time for on - off mode
'Data "16;aa,as15"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_w = On_off_time
      Temp_w = Temp_w / 50
      Tempb = Temp_w
      I2c_tx_b(1) = &H10
      I2c_tx_b(2) = Tempb
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 17
'Befehl &H11; 1 byte / 2 byte
'Mode lesen
'read mode
'Data "17;ar,read mode;1;0,off;1,I;2,P;3,R"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H11
      I2c_tx_b(2) = R_or_p
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 18
'Befehl &H12; 1 byte / -
'schaltet Last ab
'switch off
'Data "18;ou,switch off;1;0,idle;1,off"
      Gosub Reset_load
      Gosub Command_received
'
   Case 225
'Befehl &HE1; 2 byte / -
'Maximale Leistung pro Fet
'maximum power per FET
'Data "225;kp;maximum power per FET;1;201;lin;Watt"
      If Commandpointer >= 2 Then
         If Command_b(2) < 201 Then
            Max_power = Command_b(2)
            Max_power = Max_power * 1000
            'mW
            Max_power_eeram = Max_power
            Gosub Reset_load
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 226
'Befehl &HE2; 1 byte / 2 byte
'Maximale Leistung pro Fet lesen
'read maximum power per FET
'Data "226;lp,as225"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_dw = Max_power / 1000
      Tempb = Temp_dw
      I2c_tx_b(1) = &HE2
      I2c_tx_b(2) = Tempb
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 227
'Befehl &HE3 (0 to 127); 2  byte / -
'Aktive FETs binaer schreiben
'write active FETS binary
'Data "227;ka,active FETs, binary;b,{0 to 127}"
      If Commandpointer >= 2 Then
         If Command_b(2) < 128 Then
            Active_fets = Command_b(2)
            Active_fets_eeram = Active_fets
            Gosub Reset_load
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 228
'Befehl &HE4; 1 bytte / 2 byte
'Aktive FETs binaer lesen
'read active FETS binary
'Data "228;la,as227"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &HE4
      I2c_tx_b(2) = Active_fets
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 229
'Befehl &HE5 0 to 6 , 0 to 4095; 4 byte / -
'Fet control register einstellen
'set fet control register
'Data "229;km,set fet control register;6;w,{0 to 4095}"
      If Commandpointer >= 4 Then
         If Command_b(2) < 7 Then
            Temp_w = Command_b(3) * 256
            Temp_w = Temp_w + Command_b(4)
            If Temp_w <= Da_resolution Then
               Fet_number = Command_b(2) + 1
               Dac_out_voltage(Fet_number) = Temp_w
               printbin 34
               Gosub Send_to_fet
            Else
               Error_no = 4
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
   Case 230
'Befehl &HE6; 2 byte / 4 byte
'Fet control register lesen
'read fet control register
'Data "230; lm,as229"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            I2c_tx_busy = 2
            Tx_time = 1
            Tempb = Command_b(2) + 1
            I2c_tx_b(1) = &HE6
            I2c_tx_b(2) = Command_b(2)
            Tempc = High(Dac_out_voltage(Tempb))
            I2c_tx_b(3) = Tempc
            Tempc = low(Dac_out_voltage(Tempb))
            I2c_tx_b(4) = Tempc
            I2c_write_pointer = 5
            If Command_mode = 1 Then Gosub Print_i2c_tx
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 231
'Befehl &HE7; 2 byte / 4 byte
'ADC register lesen
'read ADC register
'Data "231; lp,read ADC register;6;1024;lin;-"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            I2c_tx_busy = 2
            Tx_time = 1
            Tempb = Command_b(2)
            I2c_tx_b(1) = &HE7
            I2c_tx_b(2) = Command_b(2)
            Tempc = Low(Adc_register(Tempb))
            I2c_tx_b(3) = Tempc
            Tempc = High(Adc_register(Tempb))
            I2c_tx_b(4) = Tempc
            I2c_write_pointer = 5
            If Command_mode = 1 Then Gosub Print_i2c_tx
            If Command_mode = 1 Then Gosub Print_i2c_tx
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 232
'Befehl &HE8 0 to 100; 2 byte / -
'Faktor für Spannungseichung schreiben
'write factor for voltage calibration
'Data "232;kp,voltage calibtation factor;1:101;lin;%"
      If Commandpointer >= 2 Then
         If Command_b(2) < 101 Then
            Calibrate_u_factor = Command_b(2)
            Calibrate_u_factor_eeram = Calibrate_i_factor
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 233
'Befehl &HE9; 1 byte / 2 byte
'Faktor für Spannungseichung lesen
'read factor for voltage calibration
'Data "233;la,as232"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &HE9
      I2c_tx_b(2) = Calibrate_u_factor
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 234
'Befehl &HEA; 1 byte / -
'Spannung eichen
'calibrate Voltage
'Data "234;ku,calibrate voltage;1;0,,idle;1 calibrate voltage"
      Temp_dw = Getadc(0)
      Temp_single = Temp_dw
      Temp_single = Temp_single / Calibrate_u_factor
      Temp_single = Temp_single * 100
      'If correct, should be 1023
      If Temp_single > 800 and Temp_single < 1200 Then
         'assumed.that initial accuracy is with 20%
         Temp_single  = Ad_resolution / Temp_single
         'Corection factor
         Correction_u = Temp_single * Max_voltage
         Correction_u =  Correction_u / Ad_resolution
         Correction_u_eeram = Correction_u
      Else
         Error_no = 9
         Error_cmd_no = Command_no
      End If
      Gosub Command_received
'
   Case 235
'Befehl &HEB:1 byte / 2 byte
'Spannungseichung lesen
'read voltage calibration
'Data "235;lp,read voltage calibration;1:201,{0 to 200};lin;%"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_single = Correction_u / 90000
      Temp_single = Temp_single * 1023
      Temp_single =Temp_single * 100
      Tempb = Temp_single
      I2c_tx_b(1) = &HEB
      I2c_tx_b(2) = Tempb
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 236
'Befehl &HEC 0 to 100; 2 byte / -
'Faktor für Stromeichung schreiben
'write factor for current calibration
'Data "236;op,current calibration factor;1;101;lin;%"
      If Commandpointer >= 2 Then
         If Command_b(2) < 101 Then
            Calibrate_i_factor = Command_b(2)
            Calibrate_i_factor_eeram = Calibrate_i_factor
         Else
            Error_no = 4
            Error_cmd_no = Command_no
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
      Case 237
'Befehl &HED; 1 byte / 2 byte
'Faktor für Stromeichung lesen
'read factor for current calibration
'Data "237;ap,as236"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &HED
      I2c_tx_b(2) = Calibrate_i_factor
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 238
'Befehl &HEE 0 - 7 ; 2 byte / -
'Strom eichen
'calibrate Current
'Data "238;ku,calibrate current;1;0,off;1,FET1;2,FET2;3,FET3;34FET4;5,FET5;6,FET6;7,FET7"
      If Commandpointer = 2 Then
         If Command_b(2) < 8 Then
            Gosub Reset_load
            'all off
            If Command_b(2) > 0 Then
               Fet_number = Command_b(2)
               Dac_out_voltage(Fet_number) = 0
               'minimum resistace for one fet
               Gosub Send_to_fet
               Stop Watchdog
               Waitms 5000
               Start Watchdog
               Gosub I_measure
               'delivers Temp_w
               Temp_single = Temp_w /  Calibrate_i_factor
               Temp_single = Temp_single * 100
               'If correct, should be 1023
               If Temp_single > 800 and Temp_single < 1200 Then
                  'assumed.that initial accuracy is with 20%
                  Temp_single  = Ad_resolution / Temp_single
                  'Corection factor
                  Correction_i(Fet_number) = Temp_single * Max_current
                  Correction_i(Fet_number) =  Correction_u / Ad_resolution
                  If Fet_number = 1 Then Correction_i1_eeram = Correction_i(1)
                  If Fet_number = 2 Then Correction_i2_eeram = Correction_i(2)
                  If Fet_number = 3 Then Correction_i3_eeram = Correction_i(3)
                  If Fet_number = 4 Then Correction_i4_eeram = Correction_i(4)
                  If Fet_number = 5 Then Correction_i5_eeram = Correction_i(5)
                  If Fet_number = 6 Then Correction_i6_eeram = Correction_i(6)
                  If Fet_number = 7 Then Correction_i7_eeram = Correction_i(7)
               Else
                  Error_no = 9
                  Error_cmd_no = Command_no
               End If
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
      Case 239
'Befehl &HEF; 2 byte / 3 byte
'Stromeichung lesen
'read current calibration
'Data "239;lp,read current calibration;7;201;lin;%"
         If Commandpointer >= 2 Then
            If Command_b(2) < 7 Then
               I2c_tx_busy = 2
               Tx_time = 1
               Temp_single = Correction_i(Tempb + 1)
               Temp_single = Temp_single * 100
               Tempb = Temp_single
               I2c_tx_b(1) = &HEF
               I2c_tx_b(2) = Command_b(2)
               I2c_tx_b(3) = Tempb
               I2c_write_pointer = 4
               If Command_mode = 1 Then Gosub Print_i2c_tx
            Else
               Error_no = 7
               Error_cmd_no = Command_no
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'

      Case 240
   Case 240
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
'Data "240;ln,ANNOUNCEMENTS;145;41"
      If Commandpointer >= 3 Then
         If Command_b(2) < No_of_announcelines And Command_b(3) < No_of_announcelines Then
            I2c_tx_busy = 2
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
      I2c_tx_busy = 2
      Tx_time = 1
      Select Case Error_no
         Case 0
            I2c_tx = ": command not found: "
         Case 1
            I2c_tx = ": I2C error: "
         Case 3
            I2c_tx = ": Watchdog reset: "
         Case 4
            I2c_tx = ": parameter error: "
         Case 5
            I2c_tx = ": command watchdog: "
         Case 6
            I2c_tx = ": Tx timeout: "
         Case 7
            I2c_tx = ": not valid at that time: "
         Case 8
            I2c_tx = ": i2c_buffer overflow: "
         Case 255
            I2c_tx = ": No error: "
      End Select
      Tempc = Len (I2c_tx)
      For Tempb = Tempc To 1 Step - 1
         I2c_tx_b(Tempb + 5) = I2c_tx_b(Tempb)
      Next Tempb
      I2c_tx_b(1) = &HFC
      I2c_tx_b(2) = &H20
      I2c_tx_b(3) = &H20
      I2c_tx_b(4) = &H20
      I2c_tx_b(5) = &H20
      Temps = Str(Command_no)
      Tempd = Len (Temps)
      For Tempb = 1 To Tempd
         I2c_tx_b(Tempb + 2) = Temps_b(Tempb)
      Next Tempb
      I2c_write_pointer = Tempc + 6
      Temps = Str(Error_cmd_no)
      Tempd = Len (Temps)
      For Tempb = 1 To Tempd
         I2c_tx_b(I2c_write_pointer) = Temps_b(Tempb)
         Incr I2c_write_pointer
      Next Tempb
      Tempc = Tempc + 3
      I2c_tx_b(2) = Tempc + Tempd
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 253
'Befehl &HFD
'Geraet aktiv antwort
'Life signal
'Data "253;aa,MYC INFO;b,ACTIVE"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &HFD
      I2c_tx_b(2) = 4
      'no info
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 254
'Befehl &HFE <n><data>
'eigene Individualisierung schreiben
'write individualization
'Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,21;b,ADRESS,1,{0 to 127};a,RS232,1;a,USB,1"
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
                     L = Command_b(3) + 3
                     If Commandpointer >= L Then
                        Dev_name = String(20 , 0)
                        If L > 23 Then L = 23
                        For Tempb = 4 To L
                           Dev_name_b(Tempb - 3) = Command_b(Tempb)
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
               Error_no = 4
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
'Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,21;b,ADRESS,1,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
      If Commandpointer >= 2 Then
         I2c_tx_busy = 2
         Tx_time = 1
         If Command_b(2) < 8 Then
            I2c_tx_b(1) = &HFF
            I2c_tx_b(2) = Command_b(2)
            Select Case Command_b(2)
               Case 0
                  'Will send &HFF0000 for empty string
                  Tempc = Len(Dev_name)
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
'Befehl &H00; 1 byte / 1 byte + string
'eigenes basic announcement lesen
'basic announcement is read to I2C or output
Data "0;m;DK1RI;electronic load for 7 IRFP150;V02.0;1;145;1;41;1-1"
'
Announce1:
'Befehl &H01 (resolution 10mV);  1 byte / 3 byte
'lese aktuelle Spannung
'read actual voltage
Data "1;ap,read actual voltage;1;10001,{0.00 to 100.00};lin:V"
 '
Announce2:
'Befehl &H02; 1 byte / 3 byte
'liest gesamten Strom (1Bit -> 10mA)
'read all current
Data "2;ap,read actual current;1;21001,{0.00 to 210.00};lin:A"
'
Announce3:
'Befehl &H03  0 - 6 (resolution 10mA); 2 byte / 4 byte
'liest aktuellen Strom eines FETs
'read actual current of a FET
Data "3;ap,read actual current;7;30001,{0.00 to 30.00};lin:A"
'
Announce4:
'Befehl &H04  (resolution 10mW); 1 byte / 5 byte
'liest gesamte Leistung
'read all current
Data "4;ap,read actual power;1;140001,{0.00 to 1400.00};lin;W"
'
Announce5:
'Befehl &H05  0 - 6 (resolution 10mW); 2 byte / 4 Byte
'liest aktuelle Leistung eines FETs
'read actual power of a FET
Data "5;ap,read actual power;7;20001,{0.00 to 200.00};lin;W"
'
Announce6:
'Befehl &H06 (resolution mOhm); 1 byte / 5 byte
'liest aktuellen Widerstand
'read actual resistor
Data "6;ap,read actual resistor;1;3000000,{1 to 3000000};lin;mOhm"
'
Announce7:
'Befehl &H07 0 - 21000 (10mA resolution); 3 byte / -
'gewuenschten Strom
'required current
Data "7;op,required current;1;21001,{0.00 to 210,00};lin;A"
'
Announce8:
'Befehl &H08  (10mA resolution); 1 byte / 3 byte
'gewuenschten Strom lesen
'read required current
Data "8;ap,as7"
'
Announce9:
'Befehl &H09 0 - 65535 (10mW resolution); 4 byte / -
'gewuenschte Leistung
'required power
Data "9;op,required power;1;140001,{0.00 to 1400.00};lin;W"
'
Announce10:
'Befehl &H0A (10mW resolution); 1 byte / 4 byte
'gewuenschte Leistung lesen
'read required power
Data "10;ap,as9"
'
Announce11:
'Befehl &H0B 9mOhm - 3kOhm (resolution 1mOhm); 4 byte / -
'gewuenschten Widerstand schreiben
'write required resistor
Data "11;op,required resistor:1;2999991,{9 to 3000000};lin;mOhm"
'
Announce12:
'Befehl &H0C (resolution 1mOhm); 1 byte / 4 byte
'gewuenschter Widerstand mOhm lesen
'read required resistor
Data "12;ap,as11"
'
Announce13:
'Befehl &H0D 0|1; 2 byte / -
'Wechsellast schreiben
'write (start) on /off mode
Data "13;or,on off mode;1;0,off,on"
'
Announce14:
'Befehl &H0E; 1 byte / 2 byte
'Wechsellast lesen
'read on /off mode
Data "14;ar,as13"
'
Announce15:
'Befehl &H0F; 2 byte / -
'Zeit für Wechsellast schreiben
'write time for on - off mode
Data "15;op,time for on off mode;1;128,{0 to 2.55};lin;s"
'
Announce16:
'Befehl &H10; 1 byte / 2 byte
'Zeit für Wechsellast lesen
'read time for on - off mode
Data "16;aa,as15"
'
Announce17:
'Befehl &H11; 1 byte / 2 byte
'Mode lesen
'read mode
Data "17;ar,read mode;1;0,off;1,I;2,P;3,R"
'
Announce18:
'Befehl &H12; 1 byte / -
'schaltet Last ab
'switch off
Data "18;ou,switch off;1;0,idle;1,off"
'
Announce19:
'Befehl &HE1; 2 byte / -
'Maximale Leistung pro Fet
'maximum power per FET
Data "225;kp;maximum power per FET;1;201;lin;Watt"
'
Announce20:
'Befehl &HE2; 1 byte / 2 byte
'Maximale Leistung pro Fet lesen
'read maximum power per FET
Data "226;lp,as225"
'
Announce21:
'Befehl &HE3 (0 to 127); 2  byte / -
'Aktive FETs binaer schreiben
'write active FETS binary
Data "227;ka,active FETs, binary;b,{0 to 127}"
'
Announce22:
'Befehl &HE4; 1 bytte / 2 byte
'Aktive FETs binaer lesen
'read active FETS binary
Data "228;la,as227"
'
Announce23:
'Befehl &HE5 0 to 6 , 0 to 4095; 4 byte / -
'Fet control register einstellen
'set fet control register
Data "229;km,set fet control register;6;w,{0 to 4095}"
'
Announce24:
'Befehl &HE6; 2 byte / 4 byte
'Fet control register lesen
'read fet control register
Data "230; lm,as229"
'
Announce25:
'Befehl &HE7; 2 byte / 4 byte
'ADC register lesen
'read ADC register
Data "231; lp,read ADC register;6;1024;lin;-"
'
Announce26:
'Befehl &HE8 0 to 100; 2 byte / -
'Faktor für Spannungseichung schreiben
'write factor for voltage calibration
Data "232;kp,voltage calibtation factor;1:101;lin;%"
'
Announce27:
'Befehl &HE9; 1 byte / 2 byte
'Faktor für Spannungseichung lesen
'read factor for voltage calibration
Data "233;la,as232"
'
Announce28:
'Befehl &HEA; 1 byte / -
'Spannung eichen
'calibrate Voltage
Data "234;ku,calibrate voltage;1;0,,idle;1 calibrate voltage"
'
Announce29:
'Befehl &HEB:1 byte / 2 byte
'Spannungseichung lesen
'read voltage calibration
Data "235;lp,read voltage calibration;1:201,{0 to 200};lin;%"
'
Announce30:
'Befehl &HEC 0 to 100; 2 byte / -
'Faktor für Stromeichung schreiben
'write factor for current calibration
Data "236;op,current calibration factor;1;101;lin;%"
'
Announce31:
'Befehl &HED; 1 byte / 2 byte
'Faktor für Stromeichung lesen
'read factor for current calibration
Data "237;ap,as236"
'
Announce32:
'Befehl &HEE 0 - 7 ; 2 byte / -
'Strom eichen
'calibrate Current
Data "238;ku,calibrate current;1;0,off;1,FET1;2,FET2;3,FET3;34FET4;5,FET5;6,FET6;7,FET7"
'
Announce33:
'Befehl &HEF; 2 byte / 3 byte
'Stromeichung lesen
'read current calibration
Data "239;lp,read current calibration;7;201;lin;%"
'
Announce34:
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;41"
'
Announce35:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce36:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce37:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,RS232,1;a,USB,11"
'
Announce38:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
Announce39:
Data "R !$13 IF $17 = 0"
'
Announce40:
Data "R !$7 !$9 !$11 IF $1 < 400"