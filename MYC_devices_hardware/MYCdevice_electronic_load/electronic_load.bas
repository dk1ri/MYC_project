'-----------------------------------------------------------------------
'name : electronic_load.bas
'Version V02.2, 20180812
'purpose : This is a electronic load for 7 fets IRFP150
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware  electronic_load V01.3 / 2.0 by DK1RI
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
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other rights are affected, this programm can be used
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
'If other FETs are used or less then 7 FETs are installed, the constants must be modified.
'Modification of announcements may be necessary as well.
'
'el load specific Constants:
Const Max_power_default = 50
'50W per fet
Const Max_voltage = 90
'90V
Const Max_current = 30
'30A per fet
'
' 1023 will result in ~30A
' my factors were between 294 and 303
'I = Measured * Correction_i / 10000
Const Correction_i_default = 298
' 1023 will result in ~90V
'U = Measured * Correction_u / 10000
Const Correction_u_default = 870
' in % :
Const Correction_tolerance = 15
'
' 0 to 254:
Const On_off_time_default = 1000
'about 1 s
' depends on number of operaring loops / s : will give correct On_off_time:
' Factor is divided by 100
' regulated on_off mode
Const On_off_t_factor_1 = 98
'fiexed_on_off_mode
Const On_off_t_factor_2 = 103
'
Const Minimum_voltage = 0.4
'400mV necessary to switch on the load
'
Const Ad_resolution = 1023
' ATMega
Const Da_resolution = 4095
'for MCP4921 12 Bit
'
Const I_min_calibrate = Max_current / 30
'
Const Resolution_i = Max_current / Ad_resolution
'29mA
Const Hysterese_factor = 1
'multiplier for Resolution_i
Const Hysterese_i = Resolution_i * Hysterese_factor
'
Const Dac_adder = &H30
'DAC config, to be added to the high byte
'bit 15: 0 DAC activ
'bit 14: 0 unbuffered (Vref = 5V)
'bit 13: 1 Gain 1
'bit 12: 1 output enabled
Const Fet_voltage_adder_start = 10
'change of AD output per step
Const Active_fets_default = &B01111111
'Fet1 is LSB, all Fets working
Const Reduction = 100
' If power is too high the DACout is increased by that value
Const Reduction_limit = Da_resolution - Reduction  '
'
' MYC Constants
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
Const Tx_timeout = Cmd_watchdog_time * Tx_factor
'timeout, when I2c_Tx_b is cleared and new commands allowed
'
Const No_of_announcelines = 47
'
'-----------------------------------------------------------------------
'
'Something about the programm design:
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
'All internal calculation are in V, A and W and Ohm

'The resolution used by commands is 10mV, 10mA, 10mW and 10mOhm. Some rounding is done.

'The effective voltage resolution is nominal 88mV (2,562 / 2,56) * ( 90V / 1023)
' (2.562V at AD input with 90V)

'Because the AD converter needs 4 - 5 steps for an acceptable accuracy
'the el load will not switch on for voltages below 400mV (AD Converter = 4)
'
'The current resolution is nominal 29mA
' (30A *0.01Ohm * (154kOhm / 18kOhm) / 2,56V)*(30 / 1023)
'so the minimum current (1 Fet active) to be applied for an acceptable current result
'is 120mA (AD Converter = 4)
'
'The minimum resistor value of the load is
' (50mOhm + 10mOhm + 3mOhm) / 7 ~ 9 mOhm  (3mOhm: wire)
'The maximum is given by the max voltage and the minimum current:
' 90V / 28mA ~ 3kOhm
'The required resistor has a range from 10 mOhm to 3.000.000 mOhm
'
'The usable maximum power depends on cooling and may be modified.
'default value is 50W per fet (350W total)
'Absolute maximimum is 1400W with IRFP150
' The range is 0 W to 1400.00 W
'
'To improve accuracy the number of used FETs is as low as possible
'So the requested power is either given or calculated, when the voltage is applied
'If the requested power is < n * (max_power_per_FET * 0.8) then only n FETs are used
'starting with 1st active FET.
'If the current or power exceeds the max value a additional FET is added
'
'The gate voltage is modified for all used FETs in turn by a specific value
'The current should be similar for all FETs to have a good power distribution.
'Therefore the check of power during measurement ist done on a per FET base only.
'
'Because the current of different FETs varies with same Fet Gate voltage, the gate
'voltage of a FET is changed only if the current to modify will decrease the spread
'of all currents; otherwise this FET is skipped.
'
'-----------------------------------------------------------------------
'Fuse Bits :
' for 1284:
'$PROG &HFF,&HC6,&H50,&HFF' generated. Take care that the chip supports all fuse bytes.
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
'JTAG Disabled (if applicable)
'
$regfile = "m1284pdef.dat"
'$regfile = "m644def.dat"
$crystal = 20000000
$baud = 19200
'use baud rate
$hwstack = 64
'default use 32 for the hardware stack
$swstack = 20
'default use 10 for the SW stack
$framesize = 80
'default use 40 for the frame space
'
' Simulation!!!!
' $sim
'
'**************** libs
'use byte library for smaller code
'$lib "mcsbyte.lbx"
'----------------------------------------------------------------------------
'
'**************** Variables
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
Dim Send_line_gaps As Byte
' Temporaray Marker
' 0: idle; 1: 1 gap, F0 command ; 2: 2 gaps 00 command; 4: 4 gaps, F0 command start
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
Dim Tx_time As Word
Dim Command_mode As Byte
'0: I2C input 1: seriell
'
' Electronic load specific variables
Dim Active_fets As Byte
Active_fet_1 Alias Active_fets.0
Active_fet_2 Alias Active_fets.1
Active_fet_3 Alias Active_fets.2
Active_fet_4 Alias Active_fets.3
Active_fet_5 Alias Active_fets.4
Active_fet_6 Alias Active_fets.5
Active_fet_7 Alias Active_fets.6
Dim Active_fets_eeram As Eram Byte
Dim Number_of_active_fets As Byte
'
Dim Calibrate_u As Single
Dim Correction_u As Single
Dim Correction_u_eeram As Eram Single
Dim Correction_u_min As Single
Dim Correction_u_max As Single
'
Dim Calibrate_i As Single
Dim Correction_i(7) As Single
Dim Correction_i_eeram(7) As Eram Single
Dim Correction_i_min As Single
Dim Correction_i_max As Single
'
Dim Voltage As Single
'0 - 90000 mV
Dim Voltage_last As Single
'
Dim Current(7) As Single
Dim Required_i_min As Single
Dim Required_i_max As Single
Dim Required_i As Single
Dim All_current As Single
'0 - 210000mA
Dim Mean_current As Single
'
Dim Power_(7) As Single
Dim All_power As Single
Dim Required_p As Single
'0 - 1400000mW (200W / Fet)
Dim Max_power As Single
'per FET in W
Dim Max_power_eeram As Eram Single
'
Dim Resistance As Single
Dim Required_r As Single
'
Dim On_off_mode As Byte
Dim Off_on As Byte
Dim On_off_counter As Word
Dim On_off_time As Word
Dim On_off_t As Word
' for command
Dim On_off_t_eeram As Eram Word
'
'Fet in use    :
Dim Fet_number As Byte
Dim Highest_fet_number As Byte
'each Fet coded as a bit: bit 0:FET1
Dim Used_fets As Byte
Used_fets_1 Alias Used_fets.0
Used_fets_2 Alias Used_fets.1
Used_fets_3 Alias Used_fets.2
Used_fets_4 Alias Used_fets.3
Used_fets_5 Alias Used_fets.4
Used_fets_6 Alias Used_fets.5
Used_fets_7 Alias Used_fets.6
'Fets used for a measurement
Dim Number_of_used_fets  As Byte
'
Dim El_mode as Byte
'default: 0: off, 1: Testmode for command 239, 2:I, 3: R, 4: P
'
Dim Error_req As Byte
Dim I_ok As Byte
' 0: ok, 1: too Low, 2: too high
Dim No_more_fets As Bit
Dim Adc_register(7) as Word
Dim Spi_buffer(3) As Byte
'
Dim Dac_out_voltage(7) As Word
Dim Fet_voltage_temp(7) As Word
Dim Fet_voltage_adder As Byte
'
Dim Temp_w As Word
Dim Temp_w_b1 As Byte At Temp_w Overlay
Dim Temp_w_b2 As Byte At Temp_w + 1 Overlay
Dim Temp_single As Single
Dim Temp_single2 As Single
Dim Temp_dw As Dword
Dim Temp_dw_b1 As Byte At Temp_dw Overlay

Dim Temp_dw_b2 As Byte At Temp_dw +1 Overlay
Dim Temp_dw_b3 As Byte At Temp_dw +2 Overlay
Dim Temp_dw_b4 As Byte At Temp_dw +3 Overlay
Dim Temp_req_i As Single
Dim Temp_req_p As Single
Dim Temp_req_p_dw As Dword
Dim Temp_req_p_dw_b1 As Byte At Temp_req_p_dw Overlay
Dim Temp_req_p_dw_b2 As Byte At Temp_req_p_dw + 1 Overlay
Dim Temp_req_p_dw_b3 As Byte At Temp_req_p_dw + 2 Overlay
Dim Temp_req_p_dw_b4 As Byte At Temp_req_p_dw + 3 Overlay
Dim Temp_req_r As Single
Dim Temp_req_r_dw As Dword
Dim Temp_req_r_dw_b1 As Byte At Temp_req_r_dw Overlay
Dim Temp_req_r_dw_b2 As Byte At Temp_req_r_dw + 1 Overlay
Dim Temp_req_r_dw_b3 As Byte At Temp_req_r_dw + 2 Overlay
Dim Temp_req_r_dw_b4 As Byte At Temp_req_r_dw + 3 Overlay
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
'
Config PortC.4 = Output
Fet1 Alias PortC.4
Set Fet1
Config PortC.7 = Output
Fet2 Alias PortC.7
Set Fet2
Config PortC.5 = Output
Fet3 Alias PortC.5
Set Fet3
Config PortC.6 = Output
Fet4 Alias PortC.6
Set Fet4
Config PortC.2 = Output
Fet5 Alias PortC.2
Set Fet5
Config PortC.3 = Output
Fet6 Alias PortC.3
Set Fet6
Config PortD.7 = Output
Fet7 Alias PortD.7
Set Fet7
Config PortD.6 = Output
LDAC Alias PortD.6
Set Ldac
Config PortB.0 = Output
Led Alias PortB.0
Set Led
Config PortD.4 = Output
'
Config Spi = Hard, Interrupt = Off, Data_Order = Msb, Master = Yes, Polarity = High, Phase = 1, Clockrate = 4, Noss = 0
Spiinit
'
Config Adc = Single , Prescaler = Auto , Reference = Internal_2.56
Start ADC
'must, will not work without start
'
'Config Watchdog = 2048
'
'****************Interrupts
'Enable Interrupts
'
'**************** Main ***************************************************
'
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
'Start Watchdog
'Loop must be less than 2s
'
'Blink and timeout
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
Gosub Measure_and_check
'
If El_mode > 0 Then
   If Voltage < Minimum_voltage Then
      Gosub Reset_load
      Error_no = 8
      Error_cmd_no = Command_no
   Else
      If El_mode > 1 Then
         If On_off_mode > 0 Then Gosub Operate_On_off_mode

         If On_off_mode = 0 Then
            Gosub Modify_if_necessary
         Else
            If On_off_mode = 1 And Off_on = 1 Then
               ' not in fixed mode or in off state of regulated mode
               Gosub Modify_if_necessary
            End If
         End If
      ' Else El_mode = 1 (register) : no modification
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
               Gosub Reset_i2c_tx
               If Number_of_lines > 0 Then Gosub Sub_restore
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
'Stop Watchdog                                               '
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
Max_power_eeram = Max_power_default
'50W
Active_fets_eeram = Active_fets_default
On_off_t_eeram = On_off_time_default
Correction_u = Correction_u_default
Correction_u = Correction_u / 10000
Correction_u_eeram = Correction_u
Correction_i = Correction_i_default
Correction_i = Correction_i_default / 10000
For Tempb = 1 To 7
   Correction_i_eeram(Tempb) = Correction_i
Next Tempb
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
Send_line_gaps = 0
Gosub Command_received
Gosub Reset_i2c_tx
Gosub Reset_i2c
I = 0
J = 0
Command_mode = 0
Announceline = 255
I2c_tx_busy = 0
'
' el load specific
Correction_u = Correction_u_eeram
Temp_single = Correction_tolerance / 100
Temp_single2 = 1 - Temp_single
Correction_u_min = Correction_u * Temp_single2
Temp_single2 = 1 + Temp_single
Correction_u_max = Correction_u * Temp_single2
For Tempb = 1 To 7
   Correction_i(Tempb) = Correction_i_eeram(Tempb)
   ' switch off
   Fet_voltage_temp(Fet_number) = Da_resolution
Next Tempb
Temp_single2 = 1 - Temp_single
Correction_i_min = Correction_i * Temp_single2
Temp_single2 = 1 + Temp_single
Correction_i_max = Correction_i * Temp_single2
Max_power = Max_power_eeram
On_off_mode = 0
On_off_t = On_off_t_eeram
On_off_time = 0
Active_fets = Active_fets_eeram
Calibrate_u = 0
Calibrate_i = 0
Gosub Count_Number_of_active_fets
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
'
'Byte beyond restored data must be 0:
Tempc = Len(I2c_tx)
For Tempb = 1 To I2c_buff_length
   I2c_tx_b(Tempb) = 0
Next Tempb
'
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
   Case 41
      Restore Announce41
   Case 42
      Restore Announce42
   Case 43
      Restore Announce43
   Case 44
      Restore Announce44
   Case 45
      Restore Announce45
   Case 46
      Restore Announce46
   Case Else
         'will not happen
End Select
Read I2c_tx
Tempc = Len(I2c_tx)
For Tempb = Tempc To 1 Step - 1
   Tempa = Tempb + Send_line_gaps
   I2c_tx_b(Tempa) = I2c_tx_b(Tempb)
Next Tempb
Select Case Send_line_gaps
   Case 1
      'additional announcement lines
      I2c_tx_b(1) = Tempc
      I2c_write_pointer = Tempc + 2
      Send_line_gaps = 1
      Incr A_line
      I2c_write_pointer = Tempc + 2
      If A_line >= No_of_announcelines Then A_line = 0
   Case 2
      'start basic announcement
      I2c_tx_b(1) = &H00
      I2c_tx_b(2) = Tempc
      I2c_write_pointer = Tempc + 3
   Case 4
      'start of announceline(s), send 3 byte first
      I2c_tx_b(1) = &HF0
      I2c_tx_b(2) = A_line
      I2c_tx_b(3) = Number_of_lines
      I2c_tx_b(4) = Tempc
      I2c_write_pointer = Tempc + 5
      Send_line_gaps = 1
      Incr A_line
      If A_line >= No_of_announcelines Then A_line = 0
End Select
Decr Number_of_lines
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
Fet_active:
Error_req = 1
' check, Fet_number is a active Fet
   If Command_b(2) = 0 And Active_fet_1 = 1 Then
      Error_req = 0
   Else
      If Command_b(2) = 1 And Active_fet_2 = 1 Then
         Error_req = 0
      Else
         If Command_b(2) = 2 And Active_fet_3 = 1 Then
            Error_req = 0
         Else
            If Command_b(2) = 3 And Active_fet_4 = 1 Then
               Error_req = 0
            Else
               If Command_b(2) = 4 And Active_fet_5 = 1 Then
                  Error_req = 0
               Else
                  If Command_b(2) = 5 And Active_fet_6 = 1 Then
                     Error_req = 0
                  Else
                     If Command_b(2) = 6 And Active_fet_7 = 1 Then Error_req = 0
                  End If
               End If
            End If
         End If
      End If
   End If
Return
'
Count_number_of_active_fets:
Number_of_active_fets = 0
If Active_fet_1 = 1 Then Incr Number_of_active_fets
If Active_fet_2 = 1 Then Incr Number_of_active_fets
If Active_fet_3 = 1 Then Incr Number_of_active_fets
If Active_fet_4 = 1 Then Incr Number_of_active_fets
If Active_fet_5 = 1 Then Incr Number_of_active_fets
If Active_fet_6 = 1 Then Incr Number_of_active_fets
If Active_fet_7 = 1 Then Incr Number_of_active_fets
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
Set Ldac
'
Return
'
Reset_load:
Gosub Switch_off
El_mode = 0
Error_req = 0
Required_r = 3000
'3kOhm
Required_p = 0
Required_i = 0
Required_i_min = 0
Required_i_max = 0
Used_fets = 0
Voltage_last = 0
Number_of_used_fets = 0
Off_on = 0
On_off_counter = 0
All_current = 0
All_power = 0
Resistance = 3000
For Fet_number = 1 to 7
   ' for all fets
   Power_(Fet_number) = 0
   Current(Fet_number) = 0
   Adc_register(Tempb) = 0
   Dac_out_voltage(Fet_number) = Da_resolution
Next Fet_number
Fet_number = 1
Highest_fet_number = 1
Fet_voltage_adder = Fet_voltage_adder_start
Set Led
Return
'
Modify_if_necessary:
If Voltage = Voltage_last Then
   ' calculate new required_i  , required_p and check
   Select Case El_mode
      Case 2
         ' I mode
         Temp_req_i = Required_i
         Temp_req_p = Voltage * Temp_req_i
         Temp_req_r = Voltage / Temp_req_i
         If Temp_req_r > 3000 Then Temp_req_r = 3000
         ' mOhm
         Gosub Check_required
      Case 3
         ' P mode
         Temp_req_p = Required_p
         Temp_req_i = Temp_req_p / Voltage
         Temp_req_r = Voltage / Temp_req_i
         If Temp_req_r > 3000000 Then Temp_req_r = 3000
         Gosub Check_required
      Case 4
         ' R mode
         Temp_req_r = Required_r
         Temp_req_i = Voltage / Temp_req_r
         Temp_req_p = Voltage * Temp_req_i
         Gosub Check_required
   End Select
End If
If All_current < Required_i_min Then
   ' complete I too low -> raise fetvoltage
   ' lower Dac_out_voltage due to inverting LM324
   If Dac_out_voltage(Fet_number) > Fet_voltage_adder Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) - Fet_voltage_adder
      Gosub Send_to_fet
   End If
Else
   ' Before this is reached the first time, Fet_voltage_adder is Fet_voltage_adder_start
   Fet_voltage_adder = 1
   If All_current > Required_i_max Then
      ' complete I too high -> lower fetvoltage
      ' raise Dac_out_voltage due to inverting LM324
      Temp_w = Da_resolution - Fet_voltage_adder
      If Dac_out_voltage(Fet_number) < Temp_w Then
         Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Fet_voltage_adder
         Gosub Send_to_fet
      End If
   End If
End If
If Number_of_used_fets > 1 Then Gosub Next_fet_to_use
Return
'
Send_to_FET:
Spi_buffer(1) = High(Dac_out_voltage(Fet_number))
Spi_buffer(1) = Spi_buffer(1) + Dac_adder
'add config bits
Spi_buffer(2) = Low(Dac_out_voltage(Fet_number))
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
Measure_and_check:
   ' voltage
   If El_mode > 1 Then
      If On_off_mode = 0 Then
         Voltage_last = Voltage
      Else
         If On_off_mode = 1 And Off_on = 1 Then Voltage_last = Voltage
      End If
   End If
   Temp_w = Getadc(0)
   Voltage = Temp_w * Correction_u
   'V
   '
   'current:for a FET
   Select Case Fet_number
      Case 1
         Adc_register(1) = Getadc(1)
      Case 2
         Adc_register(2) = Getadc(2)
      Case 3
         Adc_register(3) = Getadc(3)
      Case 4
         Adc_register(4) = Getadc(4)
      Case 5
         Adc_register(5) = Getadc(5)
      Case 6
         Adc_register(6) = Getadc(6)
      Case 7
         Adc_register(7) = Getadc(7)
   End Select
'
   Current(Fet_number) = Adc_register(Fet_number) * Correction_i(Fet_number)
   ' A
   Power_(Fet_number) = Voltage * Current(Fet_number)
   ' W
   All_current = 0
   All_power = 0
' Id Usd_fts = 0: measure anyway
   If Used_fets_1 = 1 Then
      All_current = All_current + Current(1)
      All_power = All_power + Power_(1)
   End If
   If Used_fets_2 = 1 Then
      All_current = All_current + Current(2)
      All_power = All_power + Power_(2)
   End If
   If Used_fets_3 = 1 Then
      All_current = All_current + Current(3)
      All_power = All_power + Power_(3)
   End If
   If Used_fets_4 = 1 Then
      All_current = All_current + Current(4)
      All_power = All_power + Power_(4)
   End If
   If Used_fets_5 = 1 Then
      All_current = All_current + Current(5)
      All_power = All_power + Power_(5)
   End If
   If Used_fets_6 = 1 Then
      All_current = All_current + Current(6)
      All_power = All_power + Power_(6)
   End If
   If Used_fets_7 = 1 Then
      All_current = All_current + Current(7)
      All_power = All_power + Power_(7)
   End If
'
   If All_current > 0 Then
      Resistance = Voltage / All_current
      If Resistance > 3000 Then Resistance = 3000
   Else
      Resistance = 3000
   End If
'
   If Number_of_used_fets > 0 Then
      Mean_current = All_current / Number_of_used_fets
   Else
      Mean_current = 0
   End If
'
' check for limits:
   If Current(Fet_number) <= Max_current Then
      If Power_(Fet_number) > Max_power Then
         Gosub Reduce_current
         If Error_req = 1 Then
            Error_no = 11
            Error_cmd_no = Command_no
            Gosub Reset_load
         End If
      End If
   Else
      Gosub Reduce_current
      If Error_req = 1 Then
         Error_no = 13
         Error_cmd_no = Command_no
         Gosub Reset_load
      End If
   End If
Return
'
Reduce_current:
Error_req = 1
'
' Work in normal modes only, switch off in register mode or current calibrate mode:
If El_mode < 2 Or El_mode = 5 Then Return
If Used_fets_1 = 1 Then
   Fet_number = 1
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End If
If Used_fets_2 = 1 Then
   Fet_number = 2
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End If
If Used_fets_3 = 1 Then
   Fet_number = 3
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End If
If Used_fets_4 = 1 Then
   Fet_number = 4
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End If
If Used_fets_5 = 1 Then
   Fet_number = 5
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End IF
If Used_fets_6 = 1 Then
   Fet_number = 6
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End If
If Used_fets_7 = 1 Then
   Fet_number = 7
   If Dac_out_voltage(Fet_number) < Reduction_limit Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Reduction
   Else
      Dac_out_voltage(Fet_number) = Da_resolution
   End If
   Gosub Send_to_fet
End If
'
' Add one more FET and reduce current in all FETS
Tempd = Highest_fet_number + 1
While Error_req = 1 And Tempd < 8
   If Tempd = 2 Then
      If Active_fet_2 = 1 Then
         Used_fets_2 = 1
         Error_req = 0
         Incr Number_of_used_fets
         Highest_fet_number = Tempd
      Else
         Incr Tempd
      End If
   Else
      If Tempd = 3 Then
         If Active_fet_3 = 1 Then
            Used_fets_3 = 1
            Error_req = 0
            Incr Number_of_used_fets
            Highest_fet_number = Tempd
         Else
            Incr Tempd
         End If
      Else
         If Tempd = 4 Then
            If Active_fet_4 = 1 Then
               Used_fets_4 = 1
               Error_req = 0
               Incr Number_of_used_fets
               Highest_fet_number = Tempd
            Else
               Incr Tempd
            End If
         Else
            If Tempd = 5 Then
               If Active_fet_5 = 1 Then
                  Used_fets_5 = 1
                  Error_req = 0
                  Incr Number_of_used_fets
                  Highest_fet_number = Tempd
               Else
                  Incr Tempd
               End If
            Else
               If Tempd = 6 Then
                  If Active_fet_6 = 1 Then
                     Used_fets_6 = 1
                     Error_req = 0
                     Incr Number_of_used_fets
                     Highest_fet_number = Tempd
                  Else
                     Incr Tempd
                  End If
               Else
                  If Tempd = 7 Then
                     If Active_fet_7 = 1 Then
                        Used_fets_7 = 1
                        Error_req = 0
                        Incr Number_of_used_fets
                        Highest_fet_number = Tempd
                     'Else  do nothing,
                     End If
                  End If
               End If
            End If
         End If
      End If
   End If
Wend
If Error_req = 0 Then
   Mean_current = All_current / Number_of_used_fets
End If
Return
'
Switch_on:
If Used_fets_1 = 1 Then
   Dac_out_voltage(1) = Fet_voltage_temp(1)
   Gosub Send_to_fet
End If
If Used_fets_2 = 1 Then
   Dac_out_voltage(2) = Fet_voltage_temp(2)
   Gosub Send_to_fet
End If
If Used_fets_3 = 1 Then
   Dac_out_voltage(3) = Fet_voltage_temp(3)
   Gosub Send_to_fet
End If
If Used_fets_4 = 1 Then
   Dac_out_voltage(4) = Fet_voltage_temp(4)
   Gosub Send_to_fet
End If
If Used_fets_5 = 1 Then
   Dac_out_voltage(5) = Fet_voltage_temp(5)
   Gosub Send_to_fet
End If
If Used_fets_6 = 1 Then
   Dac_out_voltage(6) = Fet_voltage_temp(6)
   Gosub Send_to_fet
End If
If Used_fets_7 = 1 Then
   Dac_out_voltage(7) = Fet_voltage_temp(7)
   Gosub Send_to_fet
End If
Reset Led
Return
'
Operate_On_off_mode:
   If On_off_counter > On_off_time Then
      'time to switch
      If Off_on = 0 Then
         'off -> switch on
         Off_on = 1
         Gosub Switch_on
      Else
         Off_on = 0
         Gosub Switch_off
         If Used_fets_1 = 1 Then Fet_voltage_temp(1) = Dac_out_voltage(1)
         If Used_fets_2 = 1 Then Fet_voltage_temp(2) = Dac_out_voltage(2)
         If Used_fets_4 = 1 Then Fet_voltage_temp(4) = Dac_out_voltage(4)
         If Used_fets_5 = 1 Then Fet_voltage_temp(5) = Dac_out_voltage(5)
         If Used_fets_6 = 1 Then Fet_voltage_temp(6) = Dac_out_voltage(6)
         If Used_fets_7 = 1 Then Fet_voltage_temp(7) = Dac_out_voltage(7)
         Set Led
      End If
      On_off_counter = 0
   End If
   Incr On_off_counter
Return
'
Find_used_fets:
' called only if Active_fet > 0
' require Temp_req_p (required power)
' calculate used FETs
' defines the Fet_number to start (will be the highest active FET)
   Number_of_used_fets = 0
   Temp_dw = 0

   Used_fets = 0
   If Active_fet_1 = 1 Then
      Temp_single = Max_power
      Used_fets_1 = 1
      Incr Number_of_used_fets
      Fet_number = 1
      If Temp_single < Temp_req_p Then
         If Active_fet_2 = 1 Then
            Temp_single = Temp_single + Max_power
            Used_fets_2 = 1
            Incr Number_of_used_fets
            Fet_number = 2
         End If
         If Temp_single < Temp_req_p Then
            If Active_fet_3 = 1 Then
               Temp_single = Temp_single + Max_power
               Used_fets_3 = 1
               Incr Number_of_used_fets
               Fet_number = 3
            End If
            If Temp_single < Temp_req_p Then
               If Active_fet_4 = 1 Then
                  Temp_single = Temp_single + Max_power
                  Used_fets_4 = 1
                  Incr Number_of_used_fets
                  Fet_number = 4
               End If
               If Temp_single < Temp_req_p Then
                  If Active_fet_5 = 1 Then
                     Temp_single = Temp_single + Max_power
                     Used_fets_5 = 1
                     Incr Number_of_used_fets
                     Fet_number = 5
                  End If
                  If Temp_single < Temp_req_p Then
                     If Active_fet_6 = 1 Then
                        Temp_single = Temp_single + Max_power
                        Used_fets_6 = 1
                        Incr Number_of_used_fets
                        Fet_number = 6
                     End If
                     If Temp_single < Temp_req_p Then
                        If Active_fet_7 = 1 Then
                           Used_fets_7 = 1
                           Incr Number_of_used_fets
                           Fet_number = 7
                        End If
                     End If
                  End If
               End If
            End If
         End If
      End If
   End If
   ' If near the limit add one FET
   Temp_single = Number_of_used_fets * Max_power
   Temp_single = Temp_single * 0.8
   If Temp_req_p > Temp_single Then
      If Number_of_used_fets < 7 Then
         ' add one (next active) Fet
         Tempb = Fet_number + 1
         ' check FETs with higher number only
         Tempc = 1
         While Tempc = 1 And Tempd < 7
            If Fet_number = 1 And Active_fet_2 = 1 Then
               Used_fets_2 = 1
               Tempc = 0
               Incr Number_of_used_fets
               Fet_number = 2
            Else
               If Fet_number <= 2 And Active_fet_3 = 1 Then
                  Used_fets_3 = 1
                  Tempc = 0
                  Incr Number_of_used_fets
                  Fet_number =3
               Else
                  If Fet_number <= 3 And Active_fet_4 = 1 Then
                     Used_fets_4 = 1
                     Tempc = 0
                     Incr Number_of_used_fets
                     Fet_number = 4
                  Else
                     If Fet_number <= 4 And Active_fet_5 = 1 Then
                        Used_fets_5 = 1
                        Tempc = 0
                        Incr Number_of_used_fets
                        Fet_number = 5
                     Else
                        If Fet_number <= 5 And Active_fet_6 = 1 Then
                           Used_fets_6 = 1
                           Tempc = 0
                           Incr Number_of_used_fets
                           Fet_number = 6
                        Else
                           If Fet_number <= 6 And Active_fet_7 = 1 Then
                              Used_fets_7 = 1
                              Tempc = 0
                              Incr Number_of_used_fets
                              Fet_number = 7
                           Else
                              ' do nothing, do not increase Nimber_of_used_fets
                           End If
                        End If
                     End If
                  End If
               End If
            End If
            Incr Tempd
         Wend
      End If
   End If
   Highest_fet_number = Fet_number
Return
'
Next_fet_to_use:
' I_ok > 0 !!
Tempb = 1
Tempc = 1
While Tempb = 1 And Tempc < 8
' called for Number_used_fets > 1 only!!
   Incr Fet_number
   If Fet_number = 8 Then Fet_number = 1
   If Fet_number = 1 And Used_fets_1 = 1 Then Gosub Diff_to_mean
   If Fet_number = 2 And Used_fets_2 = 1 Then Gosub Diff_to_mean
   If Fet_number = 3 And Used_fets_3 = 1 Then Gosub Diff_to_mean
   If Fet_number = 4 And Used_fets_4 = 1 Then Gosub Diff_to_mean
   If Fet_number = 5 And Used_fets_5 = 1 Then Gosub Diff_to_mean
   If Fet_number = 6 And Used_fets_6 = 1 Then Gosub Diff_to_mean
   If Fet_number = 7 And Used_fets_7 = 1 Then Gosub Diff_to_mean
   Incr Tempc
   'To leave the loop :)
Wend
Return
'
Diff_to_mean:
' Can Current of FET be changed to correct direction?
If All_current < Required_i Then
   ' too low
   If Current(Fet_number) < Mean_current Then
      ' use this (increase), if current is lower than mean
      Tempb = 0
   End If
End If
If All_current > Required_i Then
   ' too high
   If Current(Fet_number) > Mean_current Then
      ' use this (decrease), if current is higher than mean
      Tempb = 0
   End If
End If
Return
'
Check_required:
Temp_single = Max_power * Number_of_active_fets
If Temp_req_p <= Temp_single Then
   Temp_single = Max_current * Number_of_active_fets
   If Temp_req_i <= Temp_single Then
      Required_i = Temp_req_i
      Required_i_min = Required_i - Hysterese_i
      Required_i_max = Required_i + Hysterese_i
      Required_p = Temp_req_p
      Required_r = Temp_req_r
   Else
      Error_no = 10
      Error_cmd_no = Command_no
   End If
Else
   Error_no = 9
   Error_cmd_no = Command_no
End If
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
'Data "0;m;DK1RI;electronic load for 7 IRFP150;V02.2;1;145;1;47;1-1"
      I2c_tx_busy = 2
      Tx_time = 1
      A_line = 0
      Number_of_lines = 1
      Send_line_gaps = 2
      Gosub Sub_restore
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 1
'Befehl &H01 (resolution 10mV);  1 byte / 3 byte
'lese aktuelle Spannung
'read actual voltage
'Data "1;ap,read actual voltage;1;9001,{0.00 to 90.00};lin;V"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_w = Voltage * 100
      If Temp_w > 9000 Then Temp_w = 9000
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
'Data "2;ap,read actual current;1;21001,{0.00 to 210.00};lin;A"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_w = All_current * 100
      I2c_tx_b(1) = &H02
      I2c_tx_b(2) = High(Temp_w)
      I2c_tx_b(3) = Low(Temp_w)
      I2c_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 3
'Befehl &H03  0 - 6 (resolution 10mA); 2 byte / 4 byte
'liest aktuellen Strom eines FETs
'read actual current of a FET
'Data "3;ap,read actual current;7;30001,{0.00 to 30.00};lin;A"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            Gosub Fet_active
            If Error_req = 0 Then
               I2c_tx_busy = 2
               Tx_time = 1
               Tempb = Command_b(2) + 1
               Temp_w = Current(Tempb) * 100
               I2c_tx_b(1) = &H03
               I2c_tx_b(2) = Command_b(2)
               I2c_tx_b(3) = High(Temp_w)
               I2c_tx_b(4) = Low(Temp_w)
               I2c_write_pointer = 5
               If Command_mode = 1 Then Gosub Print_i2c_tx
            Else
               Error_no = 15
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
   Case 4
'Befehl &H04  (resolution 10mW); 1 byte / 4 byte
'liest gesamte Leistung
'read all power
'Data "4;ap,read actual power;1;35001,{0.00 to 350.00};lin;W"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_dw = All_power * 100
      I2c_tx_b(1) = &H04
      I2c_tx_b(2) = Temp_dw_b3
      I2c_tx_b(3) = Temp_dw_b2
      I2c_tx_b(4) = Temp_dw_b1
      I2c_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 5
'Befehl &H05  0 - 6 (resolution 10mW); 2 byte / 4 Byte
'liest aktuelle Leistung eines FETs
'read actual power of a FET
'Data "5;ap,read actual power;7;5001,{0.00 to 50.00};lin;W"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            Gosub Fet_active
            If Error_req = 0 Then
               I2c_tx_busy = 2
               Tx_time = 1
               Tempb = Command_b(2) + 1
               Temp_w = Power_(Tempb) * 100
               'mW -> 10mW
               I2c_tx_b(1) = &H05
               I2c_tx_b(2) = Command_b(2)
               I2c_tx_b(3) = High(Temp_w)
               I2c_tx_b(4) = Low(Temp_w)
               I2c_write_pointer = 5
               If Command_mode = 1 Then Gosub Print_i2c_tx
            Else
               Error_no = 15
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
   Case 6
'Befehl &H06 (resolution mOhm); 1 byte / 4 byte
'liest aktuellen Widerstand
'read actual resistor
'Data "6;ap,read actual resistor;1;300000,{10 to 3000000};lin;mOhm"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_dw = Resistance * 1000
      I2c_tx_b(1) = &H06
      I2c_tx_b(2) = Temp_dw_b3
      I2c_tx_b(3) = Temp_dw_b2
      I2c_tx_b(4) = Temp_dw_b1
      I2c_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 7
'Befehl &H07 0 - 21000 (10mA resolution); 3 byte / -
'gewuenschten Strom
'required current
'Data "7;op,required current;1;21001,{0.00 to 210,00};lin;A"
      If Commandpointer >= 3 Then
         If Voltage > Minimum_voltage Then
            If Active_fets > 0 Then
               Temp_w_b1 = command_b(3)
               'low byte first
               Temp_w_b2 = command_b(2)
               If Temp_w > 0 Then
                  Temp_req_i = Temp_w / 100
                  Temp_req_p = Temp_req_i * Voltage
                  Temp_req_r = Voltage / Temp_req_i
                  If Temp_req_r > 3000 Then Temp_req_r = 3000
                  Gosub Check_required
                  Gosub Find_used_fets
                  El_mode = 2
                  Reset Led
               Else
                  Gosub Reset_load
               End If
            Else
               Error_no = 15
               Error_cmd_no = Command_no
            End If
         Else
            Error_no = 8
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
      Temp_w  = Required_i * 100
      I2c_tx_b(1) = &H08
      I2c_tx_b(2) = High(Temp_w)
      I2c_tx_b(3) = Low(Temp_w)
      I2c_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 9
'Befehl &H09 0 - 140000 (10mW resolution); 4 byte / -
'gewuenschte Leistung
'required power
'Data "9;op,required power;1;140001,{0.00 to 1400.00};lin;W"
      If Commandpointer >= 4 Then
         Temp_req_p_dw_b1 = command_b(4)
         'low byte first
         Temp_req_p_dw_b2 = command_b(3)
         Temp_req_p_dw_b3 = command_b(2)
         Temp_req_p_dw_b4 = 0
         If Voltage > Minimum_voltage Then
            If Active_fets > 0 Then
               If Temp_req_p_dw > 0 Then
                  Temp_req_p = Temp_req_p_dw /  100
                  Temp_req_i = Temp_req_p / Voltage
                  Temp_req_r = Voltage / Temp_req_i
                  If Temp_req_r > 3000 Then Temp_req_r = 3000
                  Gosub Check_required
                  Gosub Find_used_fets
                  El_mode = 3
                  Reset Led
               Else
                  Gosub Reset_load
               End If
            Else
               Error_no = 15
               Error_cmd_no = Command_no
            End If
         Else
            Error_no = 8
            Error_cmd_no = Command_no
         End If
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
      Temp_dw = Required_p * 100
      I2c_tx_b(1) = &H0A
      I2c_tx_b(2) = Temp_dw_b3
      I2c_tx_b(3) = Temp_dw_b2
      I2c_tx_b(4) = Temp_dw_b1
      I2c_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'

   Case 11
'Befehl &H0B 10mOhm - 3kOhm (resolution 1mOhm); 4 byte / -
'gewuenschten Widerstand schreiben
'write required resistor
'Data "11;op,required resistor:1;2999999,{1 to 3000000};lin;mOhm"
      If Commandpointer >= 4 Then
         Temp_req_r_dw_b1 = command_b(4)
         'low byte first
         Temp_req_r_dw_b2 = command_b(3)
         Temp_req_r_dw_b3 = command_b(2)
         Temp_req_r_dw_b4 = 0
         If Temp_req_r_dw < 2999999 Then
            If Voltage > Minimum_voltage Then
               If Active_fets > 0 Then
                  Incr Temp_dw
                  Temp_req_r = Temp_req_r_dw / 1000
                  Temp_req_i = Voltage / Temp_req_r
                  Temp_req_p = Temp_req_i * Voltage
                  Gosub Check_required
                  Gosub Find_used_fets
                  El_mode = 4
                  Reset Led
               Else
                  Error_no = 15
                  Error_cmd_no = Command_no
               End If
            Else
               Error_no = 8
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
'Befehl &H0C (resolution 10mOhm); 1 byte / 4 byte
'gewuenschter Widerstand lesen
'read required resistor
'Data "12;ap,as11"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_dw = Required_r * 1000
      If Temp_dw > 0 Then Decr Temp_dw
      I2c_tx_b(1) = &H0C
      I2c_tx_b(2) = Temp_dw_b3
      I2c_tx_b(3) = Temp_dw_b2
      I2c_tx_b(4) = Temp_dw_b1
      I2c_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 13
'Befehl &H0D 0|1|2; 2 byte / -
'Wechsellast schreiben
'write on /off mode
'Data "13;or,on off mode;1;0,off,1,regulated;2,fixed"
      If Commandpointer >= 2 Then
         If Command_b(2) < 3  Then
            If Command_b(2) <> On_off_mode Then
               If Command_b(2) = 0 Then
                  On_off_mode = 0
                  On_off_time = 0
                  If El_mode > 1 And El_mode < 5 Then Gosub Switch_on
               Else
                  Select Case On_off_mode
                     Case 0
                        If Command_b(2) = 1 Then
                           Temp_single = On_off_t_factor_1 / 100
                        Else
                           Temp_single = On_off_t_factor_2 / 100
                        End If
                        On_off_time = On_off_t * Temp_single
                        On_off_counter = On_off_time
                        'On_off = 1 will switch off at next loop
                        Off_on = 1
                     Case 1
                        Temp_single = On_off_t_factor_2 / 100
                        On_off_time = On_off_t * Temp_single
                     Case 2
                        Temp_single = On_off_t_factor_1 / 100
                        On_off_time = On_off_t * Temp_single
                  End Select
                  On_off_mode = command_b(2)
               ' Else: do nothing
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
   Case 14
'Befehl &H0E; 1 byte / 2 byte
'Wechsellast lesen
'read on /off mode
'Data "14;ar,as13"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H0E
      I2c_tx_b(2) = On_off_mode
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 15
'Befehl &H0F; 3 byte / -
'Zeit für Wechsellast schreiben
'write time for on - off mode
'Data "15;op,time for on off mode;1;10000,{0.001 to 10.000};lin;s"
      If Commandpointer >= 3 Then
         On_off_t = Command_b(2)
         On_off_t = On_off_t * 256
         On_off_t = On_off_t + Command_b(3)
         On_off_t_eeram = On_off_t
         On_off_time = On_off_t + 1
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 16
'Befehl &H10; 1 byte / 3 byte
'Zeit für Wechsellast lesen
'read time for on - off mode
'Data "16;aa,as15"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H10
      I2c_tx_b(2) = High(On_off_t)
      I2c_tx_b(3) = Low(On_off_t)
      I2c_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 17
'Befehl &H11; 1 byte / 2 byte
'Mode lesen
'read mode
'Data "17;ar,read mode;1;0,off;1,register;2,I;3,P;4,R;5,I calibration"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H11
      I2c_tx_b(2) = El_mode
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
   Case 19
'Befehl &H13; 2 byte / -
'Zahl der aktiven Fets lesen
'read number of active FETs
'Data "19;ar,read number of active FETs;1;b,{1 to 7}
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H13
      I2c_tx_b(2) = Number_of_active_fets
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 20
'Befehl &H14; 2 byte / -
'Zahl der benutzten Fets lesen
'read number of used FETs
'Data "20;ar,read number of used FETs;1;b,{1 to 7}"
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &H14
      I2c_tx_b(2) = Number_of_used_fets
      I2c_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 21
'Befehl &H15; 1 byte / 3 byte
'Maximale Leistung pro Fet lesen
'read maximum power per FET
'Data "21;lp,maximum power per FET;1;5001,{0 to 50,00};lin;Watt"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_w = Max_power * 100
      I2c_tx_b(1) = &H15
      I2c_tx_b(2) = High(Temp_w)
      I2c_tx_b(3) = Low(Temp_w)
      I2c_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 226
'Befehl &HE2; 3 byte / -
'Maximale Leistung pro Fet
'maximum power per FET
'Data "226;kp;maximum power per FET;1;5001,{0 to 50,00};lin;Watt"
      If Commandpointer >= 3 Then
         Temp_w = Command_b(2) * 256
         Temp_w = Temp_w + Command_b(3)
         If Temp_w <= Max_power_default Then
            Max_power = Temp_w / 100
            ' W
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
   Case 227
'Befehl &HE3 (0 to 127); 2  byte / -
'Aktive FETs binaer schreiben
'write active FETS binary
'Data "227;ka,active FETs, binary;b,{0 to 127}"
      If Commandpointer >= 2 Then
         If Command_b(2) < 128 Then
            Active_fets = Command_b(2)
            Active_fets_eeram = Active_fets
            Gosub Count_number_of_active_fets
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
'Befehl &HE4; 1 byte / 2 byte
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
            Fet_voltage_temp = Command_b(3) * 256
            Fet_voltage_temp = Fet_voltage_temp + Command_b(4)
            If Fet_voltage_temp <= Da_resolution Then
               Gosub Fet_active
               If Error_req = 0 Then
                  If Voltage > Minimum_voltage Then
                     If Active_fets > 0 Then
                         Gosub Reset_load
                         Fet_number = Command_b(2) + 1
                         Dac_out_voltage(Fet_number) = Fet_voltage_temp
                         Gosub Send_to_fet
                         El_mode = 1
                         ' One FET only
                         Number_of_used_fets = 1
                         If Fet_number = 1 Then Used_fets_1 = 1
                         If Fet_number = 2 Then Used_fets_2 = 1
                         If Fet_number = 3 Then Used_fets_3 = 1
                         If Fet_number = 4 Then Used_fets_4 = 1
                         If Fet_number = 5 Then Used_fets_5 = 1
                         If Fet_number = 6 Then Used_fets_6 = 1
                         If Fet_number = 7 Then Used_fets_7 = 1
                         Reset Led
                     Else
                        Error_no = 15
                        Error_cmd_no = Command_no
                     End If
                  Else
                     Error_no = 8
                     Error_cmd_no = Command_no
                  End If
                Else
                  Error_no = 15
                  Error_cmd_no = Command_no
               End If
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
            Gosub Fet_active
            If Error_req = 0 Then
               I2c_tx_busy = 2
               Tx_time = 1
               I2c_tx_b(1) = &HE6
               I2c_tx_b(2) = Command_b(2)
               Tempb = Command_b(2) + 1
               Tempc = High(Dac_out_voltage(Tempb))
               I2c_tx_b(3) = Tempc
               Tempc = Low(Dac_out_voltage(Tempb))
               I2c_tx_b(4) = Tempc
               I2c_write_pointer = 5
               If Command_mode = 1 Then Gosub Print_i2c_tx
            Else
               Error_no = 15
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
   Case 231
'Befehl &HE7; 2 byte / 4 byte
'ADC register lesen
'read ADC register
'Data "231; lp,read ADC register;6;1024;lin;-"
      If Commandpointer >= 2 Then
         If Command_b(2) < 7 Then
            Gosub Fet_active
            If Error_req = 0 Then
               I2c_tx_busy = 2
               Tx_time = 1
               I2c_tx_b(1) = &HE7
               I2c_tx_b(2) = Command_b(2)
               Tempb = Command_b(2) + 1
               Tempc = High(Adc_register(Tempb))
               I2c_tx_b(3) = Tempc
               Tempc = Low(Adc_register(Tempb))
               I2c_tx_b(4) = Tempc
               I2c_write_pointer = 5
               If Command_mode = 1 Then Gosub Print_i2c_tx
            Else
               Error_no = 15
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
   Case 232
'Befehl &HE8 0 to 9000; 4 byte / -
'Spannung für Spannungseichung schreiben
'write voltage for voltage calibration
'Data "232;ap,calibration voltage;1;90001;lin:mV"
      If Commandpointer >= 4 Then
         Temp_dw_b1 = command_b(4)
         'low byte first
         Temp_dw_b2 = command_b(3)
         Temp_dw_b3 = command_b(2)
         Temp_dw_b4 = 0
          'mV
          Temp_single = Temp_dw / 1000
         If Temp_single <= Max_voltage Then
            Calibrate_u = Temp_single
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
'Befehl &HE9; 1 byte / 4 byte
'Spannung für Spannungseichung lesen
'read voltage for calibration
'Data "233;la,as232"
      Temp_dw = Calibrate_u * 1000
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &HE9
      I2c_tx_b(2) = Temp_dw_b3
      I2c_tx_b(3) = Temp_dw_b2
      I2c_tx_b(4) = Temp_dw_b1
      I2c_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 234
'Befehl &HEA; 1 byte / -
'Spannung eichen
'calibrate Voltage
'Data "234;ku,calibrate voltage;1;0,,idle;1 calibrate voltage"
      If Calibrate_u > 0 Then
         Temp_w = Getadc(0)
         Temp_single = Calibrate_u / Temp_w
         'should be 90 / 1023  +- 20%
         If Temp_single > Correction_u_min And Temp_single < Correction_u_max Then
            If Voltage > Minimum_voltage Then
               Correction_u = Temp_single
               Correction_u_eeram = Correction_u
            Else
               Error_no = 8
               Error_cmd_no = Command_no
            End If
         Else
            Error_no = 14
            Error_cmd_no = Command_no
         End If
      End If
      Gosub Command_received
'
   Case 235
'Befehl &HEB:1 byte / 2 byte
'Spannungseichung lesen
'read voltage calibration
'Data "235;lp,read voltage calibration;1:10001;lin;-"
      I2c_tx_busy = 2
      Tx_time = 1
      Temp_single =  Correction_u * 10000
      Temp_w = Temp_single
      I2c_tx_b(1) = &HEB
      I2c_tx_b(2) = High(Temp_w)
      I2c_tx_b(3) = Low(Temp_w)
      I2c_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 236
'Befehl &HEC 0 to 30000; 3 byte / -
'Strom für Stromeichung schreiben
'write current for current calibration
'Data "236;op,current for calibration;1;30001;lin:mA"
      If Commandpointer >= 3 Then
         Temp_w = Command_b(2) * 256
         Temp_w = Temp_w + Command_b(3)
         If Temp_w = 0 Then
            If El_mode = 1 Then
               ' fixes current, Fetnumber is set
               If Current(Fet_number) > I_min_calibrate Then
                  Required_i = Current(Fet_number)
                  Required_i_min = Required_i - Hysterese_i
                  Required_i_max = Required_i + Hysterese_i
                  Number_of_used_fets = 1
                  El_mode = 5
               Else
                  Error_no = 16
                  Error_cmd_no = Command_no
               End If
            Else
               Error_no = 7
               Error_cmd_no = Command_no
            End If
         Else
            Temp_single = Temp_w  / 1000
            If Temp_single <= Max_current Then
               Calibrate_i = Temp_single
            Else
               Error_no = 4
               Error_cmd_no = Command_no
            End If
         End If
         Gosub Command_received
      Else
         Incr Commandpointer
      End If
'
   Case 237
'Befehl &HED; 1 byte / 3 byte
'Strom für Stromeichung lesen
'read current for calibration
'Data "237;ap,as236"
      Temp_w = Calibrate_i * 1000
      I2c_tx_busy = 2
      Tx_time = 1
      I2c_tx_b(1) = &HED
      I2c_tx_b(2) = High(Temp_w)
      I2c_tx_b(3) = Low(Temp_w)
      I2c_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_i2c_tx
      Gosub Command_received
'
   Case 238
'Befehl &HEE 0 - 6 ; 2 byte / -
'Strom eichen
'calibrate Current
'Data "238;ku,calibrate current;0,FET1;1,FET2;2,FET3;3FET4;4,FET5;5,FET6;6,FET7"
      If Commandpointer = 2 Then
         If Command_b(2) < 7 Then
            If Calibrate_i > 0 Then
               If Voltage > Minimum_voltage Then
                  Fet_number = Command_b(2) + 1
                  Temp_w = Getadc(Fet_number)
                  Temp_single = Calibrate_i / Temp_w
                  'should be 30000 / 1023  +- 20%
                  If Temp_single > Correction_i_min And Temp_single < Correction_i_max Then
                     Correction_i(Fet_number) = Temp_single
                     Correction_i_eeram(Fet_number) = Correction_i(Fet_number)
                  Else
                     Error_no = 14
                     Error_cmd_no = Command_no
                  End If
               Else
                  Error_no = 8
                  Error_cmd_no = Command_no
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
      Case 239
'Befehl &HEF; 2 byte / 4 byte
'Stromeichung lesen
'read current calibration
'Data "239;lp,read current calibration;7;4001;lin;-"
         If Commandpointer >= 2 Then
            If Command_b(2) < 7 Then
               I2c_tx_busy = 2
               Tx_time = 1
               Tempb = Command_b(2) + 1
               Temp_single = Correction_i(Tempb)
               Temp_single = Temp_single * 10000
               Temp_w = Temp_single
               I2c_tx_b(1) = &HEF
               I2c_tx_b(2) = Command_b(2)
               I2c_tx_b(3) = High(Temp_w)
               I2c_tx_b(4) = Low(Temp_w)
               I2c_write_pointer = 5
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
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
'Data "240;ln,ANNOUNCEMENTS;145;47"
      If Commandpointer >= 3 Then
         If Command_b(2) < No_of_announcelines And Command_b(3) < No_of_announcelines Then
            If Command_b(3) > 0 Then
               I2c_tx_busy = 2
               Tx_time = 1
               Send_line_gaps = 4
               Number_of_lines = Command_b(3)
               A_line = Command_b(2)
               Gosub Sub_restore
               If Command_mode = 1 Then
                  Gosub Print_i2c_tx
                  While Number_of_lines > 0
                     Gosub Sub_restore
                     Gosub Print_i2c_tx
                  Wend
                  Gosub Reset_i2c_tx
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
            I2c_tx = ": voltage too low: "
         Case 9
            I2c_tx = ": required power too high: "
         Case 10
            I2c_tx = ": required current too high: "
         Case 11
            I2c_tx = ": actual power too high: "
         Case 12
            I2c_tx = ": no active FETs: "
         Case 13
            I2c_tx = ": actual current too high: "
         Case 14
            I2c_tx = ": out of limit: "
         Case 15
            I2c_tx = ": FET not active: "
         Case 16
            I2c_tx = ": calibrate current too low: "
         Case 255
            I2c_tx = ": No error: "
         Case Else
            I2c_tx = ": other error: "
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
Data "0;m;DK1RI;electronic load for 7 IRFP150;V02.2;1;145;1;47;1-1"
'
Announce1:
'Befehl &H01 (resolution 10mV);  1 byte / 3 byte
'lese aktuelle Spannung
'read actual voltage
Data "1;ap,read actual voltage;1;10001,{0.00 to 900.00};lin;V"
 '
Announce2:
'Befehl &H02; 1 byte / 3 byte
'liest gesamten Strom (1Bit -> 10mA)
'read all current
Data "2;ap,read actual current;1;21001,{0.00 to 210.00};lin;A"
'
Announce3:
'Befehl &H03  0 - 6 (resolution 10mA); 2 byte / 4 byte
'liest aktuellen Strom eines FETs
'read actual current of a FET
Data "3;ap,read actual current;7;30001,{0.00 to 30.00};lin;A"
'
Announce4:
'Befehl &H04  (resolution 10mW); 1 byte / 4 byte
'liest gesamte Leistung
'read all current
Data "4;ap,read actual power;1;35001,{0.00 to 350.00};lin;W"
'
Announce5:
'Befehl &H05  0 - 6 (resolution 10mW); 2 byte / 4 Byte
'liest aktuelle Leistung eines FETs
'read actual power of a FET
Data "5;ap,read actual power;7;5001,{0.00 to 50.00};lin;W"
'
Announce6:
'Befehl &H06 (resolution mOhm); 1 byte / 4 byte
'liest aktuellen Widerstand
'read actual resistor
Data "6;ap,read actual resistor;1;300000,{10 to 3000000};lin;mOhm"
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
'Befehl &H0B 10mOhm - 3kOhm (resolution 1mOhm); 4 byte / -
'gewuenschten Widerstand schreiben
'write required resistor
Data "11;op,required resistor:1;2999999,{1 to 3000000};lin;mOhm"
'
Announce12:
'Befehl &H0C (resolution 10mOhm); 1 byte / 4 byte
'gewuenschter Widerstand lesen
'read required resistor
Data "12;ap,as11"
'
Announce13:
'Befehl &H0D 0|1|2; 2 byte / -
'Wechsellast schreiben
'write on /off mode
Data "13;or,on off mode;1;0,off,1,regulated;2,fixed"
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
Data "15;op,time for on off mode;1;10000,{0.001 to 10.000};lin;s"
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
Data "17;ar,read mode;1;0,off;1,register;2,I;3,P;4,R;;5,I calibration"
'
Announce18:
'Befehl &H12; 1 byte / -
'schaltet Last ab
'switch off
Data "18;ou,switch off;1;0,idle;1,off"
'
Announce19:
'Befehl &H13; 2 byte / -
'Zahl der aktiven Fets lesen
'read number of active FETs
Data "19;ar,read number of active FETs;1;b,{1 to 7}"
'
Announce20:
'Befehl &H14; 2 byte / -
'Zahl der benutzten Fets lesen
'read number of used FETs
Data "20;ar,read number of used FETs;1;b,{1 to 7}"
'
Announce21:
'Befehl &H15; 1 byte / 3 byte
'Maximale Leistung pro Fet lesen
'read maximum power per FET
Data "21;lp,maximum power per FET;1;5001,{0 to 50,00};lin;Watt"
'
Announce22:
'Befehl &HE1; 3 byte / -
'Maximale Leistung pro Fet
'maximum power per FET
Data "225;kp;maximum power per FET;1;5001,{0 to 50,00};lin;Watt"
'
Announce23:
'Befehl &HE3 (0 to 127); 2  byte / -
'Aktive FETs binaer schreiben
'write active FETS binary
Data "227;ka,active FETs, binary;b,{0 to 127}"
'
Announce24:
'Befehl &HE4; 1 byte / 2 byte
'Aktive FETs binaer lesen
'read active FETS binary
Data "228;la,as227"
'
Announce25:
'Befehl &HE5 0 to 6 , 0 to 4095; 4 byte / -
'Fet control register einstellen
'set fet control register
Data "229;km,set fet control register;6;w,{0 to 4095}"
'
Announce26:
'Befehl &HE6; 2 byte / 4 byte
'Fet control register lesen
'read fet control register
Data "230; lm,as229"
'
Announce27:
'Befehl &HE7; 2 byte / 4 byte
'ADC register lesen
'read ADC register
Data "231; lp,read ADC register;6;1024;lin;-"
'
Announce28:
'Befehl &HE8 0 to 9000; 3 byte / -
'Spannung für Spannungseichung schreiben
'write voltage for voltage calibration
Data "232;ap,calibration voltage;1;9001,{0.00 to 90.00};lin:V"
'
Announce29:
'Befehl &HE9; 1 byte / 3 byte
'Spannung für Spannungseichung lesen
'read voltage for calibration
Data "233;la,as232"
'
Announce30:
'Befehl &HEA; 1 byte / -
'Spannung eichen
'calibrate Voltage
Data "234;ku,calibrate voltage;1;0,,idle;1 calibrate voltage"
'
Announce31:
'Befehl &HEB:1 byte / 2 byte
'Spannungseichung lesen
'read voltage calibration
'Data "235;lp,read voltage calibration;1:10001;lin;-"
'
Announce32:
'Befehl &HEC 0 to 30000; 3 byte / -
'Strom für Stromeichung schreiben
'write current for current calibration
Data "236;op,current for calibration;1;3001,{0.00 to 30.00};lin:A"
'
Announce33:
'Befehl &HED; 1 byte / 3 byte
'Strom für Stromeichung lesen
'read current for calibration
Data "237;ap,as236"
'
Announce34:
'Befehl &HEE 0 - 6 ; 2 byte / -
'Strom eichen
'calibrate Current
Data "238;ku,calibrate current;0,FET1;1,FET2;2,FET3;3FET4;4,FET5;5,FET6;6,FET7"
'
Announce35:
'Befehl &5EF; 2 byte / 4 byte
'Stromeichung lesen
'read current calibration
Data "239;lp,read current calibration;7;4001;lin;-"
'
Announce36:
'Befehl &HF0<n><m>
'liest announcements
'read m announcement lines
Data "240;ln,ANNOUNCEMENTS;145;47"
'
Announce37:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce38:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce39:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;ka,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,RS232,1;a,USB,11"
'
Announce40:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;la,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
Announce41:
' Undervoltage
Data "R !$7 !$9 !$11 IF $1<400"
'
Announce42:
' On- off mode only during operation
Data "R $0D IF &11>0"
'
Announce43:
' Switch off, if power is exceeded
Data "R $11=0! IF $4>$14*$15"
'
Announce44:
' Switch off, if current is exceeded
Data "R $11=0! IF $3>3000"
'
Announce45:
Data "S !E5 !EA !EE IF $1<400"
'
Announce46:
Data "S E5&0 IF $11 = 1"