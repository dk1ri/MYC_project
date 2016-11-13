'-----------------------------------------------------------------------
'name : electronic_load.bas
'Version V01.3, 20161109
'purpose : This is a electronic load for 7 fets IRFP150
'This Programm workes as I2C slave or serial protocol
'Can be used with hardware  electronic_load V01.2 by DK1RI
'The Programm supports the MYC protocol
'Please modify clock frequncy and processor type, if necessary
'
'micro : ATMega32 or higher
'Fuse Bits :
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
'$PROG &HFF,&HC6,&HDF,&HF9' generated. Take care that the chip supports all fuse bytes.
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other right are affected, this programm can be used
'under GPL (Gnu public licence)
'-----------------------------------------------------------------------
'Templates:
' dtmf_sender.bas  V03.1
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
'The voltage resolution is nominal 88mV (2,562 / 2,56) * ( 90V / 1023)

'Because the AD converter needs 3 -4 steps for an acceptable accuracy
'the el load will not switch on for voltages below 400mV (AD Converter = 4)
'The voltage resolution for I/O is 10mV
'
'The current resolution is nominal 29mA (30A *0.01Ohm * 8,5 / 2,56V)*(30 /1023)
'so the minimum voltage to be applied for an acceptable current result is
' 100mA * 60mOhm = 6mV (3 - 4 steps for one FET)
'The resolution for current I/O is 10mA
'
'The minimum resistor value of the load is (50 + 10 mOhm + 3mOhm) / 7 ~ 9 mOhm  (3mOhm: wire)
'The maximum is given by the max voltage and the minimum current:
' 90V / 28mA ~ 3kOhm (-> 2kOm used)
'The required resistor has a range from 9mOhm to 2kOhm
'The resolution for resistor I/O is 1mOhm
'the conductance range is:
'1/3kOhm * 10E6 uS bis 1/mOhm * 10E6 uS
'0.3 * E3  bis 1 * E9 uS
'
'The usable maximum power depends on cooling and may be modified.
'default value is 50W per fet (350W total)
'Absolute maximimum is 1400W
'Power resolution for I/O is 20mW
'so range is 0 mW to 1.310700 kW (20mW * 65535)
'
'To improve accuracy the number of used FETs is as low as possible
'So the requested power is either given or calculated, when the voltage is applied
'If the requested power is < n * (max_power_per_FET * 0.8) then only n FETs are used
'starting with FET1.
'The Number_of_used_fets is calculated once only after applying voltage or changing
'required power current or resistor.
'
'The Units used internally are different:
'Dword is used for all
'all Voltages: mV
'all Currents: mA
'all Power: mW
'all Resistors as conductance in uS
'-----------------------------------------------------------------------
$regfile = "m644def.dat"
' for ATmega644
'$regfile = "m32def.dat"
' (for ATmega32)
$crystal = 20000000
$baud = 19200
' use baud rate
$hwstack = 64
' default use 32 for the hardware stack
$swstack = 20
' default use 10 for the SW stack
$framesize = 50
' default use 40 for the frame space
' Simulation!!!!
' $sim
'
'**************** libs
'use byte library for smaller code
'$lib "mcsbyte.lbx"
'
'**************** Variables
Const Stringlength = 254
Const Cmd_watchdog_time = 65000
'Number of main loop before command reset
Const Blinktime = 1200
Const No_of_announcelines = 37
'
'el load specific:
Const Calibrate_i_factor_default = 5
'100% is 30A, used if 30A is not available
Const Correction_u_default = 90
'must be a simple figure : 90000 / 1000
'10 bit AD converter, has 1023 steps for 90V, Resolution ~ 90mV
Const Correction_i_default = 30
'must be a simple figure : 30000 / 1000
'
Const On_off_time_default = 128
Const Minimum_voltage = 400
'400mV necessary to switch on the load
Const Max_current = 30000
'30A
Const Resolution_i = Max_current / 1023
'29mA
Const Hysterese_factor = 2
'multiplier for Resolution_i
'
Const Da_resolution = 4095
'for MCP4921 12 Bit
Const Dac_adder = &B00110000
'DAC config, to be added to the high byte
'bit 15: 0 DAC A
'bit 14: 0 unbuffered
'bit 13: 1 Gain 1
'bit 12: 1 output enabled
Const Fet_voltage_min = 0
'min dac out voltage; LM324 can handle 0 V
Const Fet_voltage_adder = 1
'change of FET voltage per step; digital value
Const Max_power_default = 50000
'50W per fet
Const Active_fets_default = &B01111111
'Fet1 is LSB, all Fets working
'
Dim First_set As Eram Byte
'first run after reset
Dim L As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temp_w As Word
Dim Temp_w_b1 As Byte At Temp_w Overlay
Dim Temp_w_b2 As Byte At Temp_w + 1 Overlay
Dim Temp_dw As Dword
Dim Temp_dw_b1 As Byte At Temp_dw Overlay
Dim Temp_dw_b2 As Byte At Temp_dw +1 Overlay
Dim Temp_dw_b3 As Byte At Temp_dw +2 Overlay
Dim Temp_dw_b4 As Byte At Temp_dw +3 Overlay
Dim Temp_dw1 As Dword
Dim Temp_single As Single
Dim Temp_single1 As Single
Dim Temps As String * 20
Dim Temps_b(20) As Byte At Temps Overlay
Dim I As Word
Dim A As Byte
'actual input
Dim Announceline As Byte
'notifier for multiple announcelines
Dim A_line As Byte
'actual announline
Dim Dev_name As String * 20
Dim Dev_name_eeram As Eram String * 20
Dim Dev_name_b(20) As Byte At Dev_name Overlay
Dim Dev_number As Byte
Dim Dev_number_eeram As Eram Byte
Dim Adress As Byte
'I2C adress
Dim Adress_eeram As Eram Byte
'I2C Buffer
Dim I2c_tx As String * Stringlength
Dim I2c_tx_b(stringlength) As Byte At I2c_tx Overlay
Dim I2c_pointer As Byte
Dim I2c_length As Byte
Dim Command As String * Stringlength
'Command Buffer
Dim Command_b(stringlength) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
Dim Twi_status As Byte
'HW I2C
Dim Twi_control As Byte
Dim Last_error As String * 30
'Error Buffer
Dim Last_error_b(30) As Byte At Last_error Overlay
Dim Error_no As Byte
Dim Cmd_watchdog As Word
'Watchdog notifier
Dim I2C_active As Byte
Dim I2C_active_eeram As Eram Byte
Dim RS232_active As Byte
Dim RS232_active_eeram As Eram Byte
Dim USB_active As Byte
Dim Usb_active_eeram As Eram Byte
Dim Send_lines As Byte
Dim Number_of_lines As Byte
Dim Command_mode As Byte
'0: I2C input 1: seriell
'
' for electronic load:
Dim Voltage As Single
'mV
Dim Correction_u As Single
Dim Correction_u_eeram As Eram Single
'
Dim Current(7) As Dword
Dim Correction_i(7) As Single
Dim Correction_i_eeram(7) As Eram Single
Dim Required_i_min As Dword
Dim Required_i_max As Dword
Dim Required_i As Dword
Dim All_current As Dword
'all in mA
'
Dim Power_(7) As Dword
Dim Mean_power As Dword
Dim Mean_power_min As Dword
Dim Mean_power_max As Dword
Dim All_power As Dword
Dim Max_power As Dword
'per FET in W
Dim Max_power_eeram As Eram Dword
Dim Required_p As Dword
Dim Required_p_min As Dword
Dim Required_p_max As Dword
'including Hysteresys
'all power in mW
'
Dim Conductance As Dword
Dim Required_c As Dword
Dim Required_c_min As Dword
'including Hysteresys
Dim Required_c_max As Dword
'all Resistor im mOhm
'
Dim Fet_number As Byte
Dim On_off_mode As Bit
Dim On_off As Bit
Dim On_off_counter As Word
'available Fets:
Dim Number_of_active_fets As Byte
'each Fet coded as a bit: bit 0:FET1
Dim Active_fets As Byte
Active_fet_1 Alias Active_fets.0
Active_fet_2 Alias Active_fets.1
Active_fet_3 Alias Active_fets.2
Active_fet_4 Alias Active_fets.3
Active_fet_5 Alias Active_fets.4
Active_fet_6 Alias Active_fets.5
Active_fet_7 Alias Active_fets.6
Dim Active_fets_eeram As Eram Byte
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
Dim Fet_to_modify As Byte
Dim Voltage_on_started As Bit
Dim Calibrate_i_started As Bit
Dim Overload As Bit
Dim Reset_done As Bit
Dim No_more_fets As Bit
Dim Found_calibrate As Bit
Dim Dac_out_voltage(7) As Word
Dim Fet_voltage_temp As Word
Dim Spi_buffer(3) As Byte
Dim Fet_to_calibrate As Byte
Dim Calibrate_i_factor As Byte
Dim Calibrate_i_factor_eeram As Eram Byte
Dim On_off_time As Word
Dim On_off_time_eeram As Eram Word
Dim Test As Bit

'**************** Config / Init
Config PortD.5 = Output
Gon Alias PortD.5
Reset Gon
'disable Gate Voltage for fets
Config PinB.1 = Input
PortB.1 = 1
Resetpin Alias PinB.1
Config PortB.0 = Output
LED1 Alias PortB.0
'
Config PortC.7 = Output
Fet2 Alias PortC.7
Config PortC.6 = Output
Fet4 Alias PortC.6
Config PortC.5 = Output
Fet3 Alias PortC.5
Config PortC.4 = Output
Fet1 Alias PortC.4
Config PortC.3 = Output
Fet6 Alias PortC.3
Config PortC.2 = Output
Fet5 Alias PortC.2
Config PortD.7 = Output
Fet7 Alias PortD.7
Config PortD.6 = Output
LDAC Alias PortD.6
'
Config Spi = Hard, Interrupt = Off, Data Order = Msb, Master = Yes, Polarity = High, Phase = 0, Clockrate = 4, Noss = 0
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
'Disable Pcint2
'
'**************** Main ***************************************************
'
If Resetpin = 0 Then Gosub Reset_
'
If First_set <> 5 Then Gosub Reset_
'
Wait 1
Gosub Init
Gosub Reset_all
'el load specific
Set Gon
'enable Gate Voltage for fets
'
Slave_loop:
Start Watchdog
'Loop must be less than 2 seconds
'
If On_off_mode = 0 And Calibrate_i_started = 0 Then Gosub Blink_
'for tests
'
Gosub Cmd_watch
'
Temp_w = Getadc(0)
Voltage = Temp_w * Correction_u
'mV
If Voltage < Minimum_voltage Then
   'switched off
   Voltage_on_started = 0
   If Reset_done = 0 Then Gosub Reset_all
Else
   If R_or_p > 0 THen
      Reset_done = 0
      If Voltage_on_started = 0 Then
      'first loop after voltage above limit
         Stop Watchdog
         Wait 1
         Start Watchdog
         'wait 1 Second for voltage to settle
         Temp_w = Getadc(0)
         'measure voltage again
         Voltage = Temp_w * Correction_u
         'mV
         If Calibrate_i_started = 0 Then Gosub Calculate_Number_of_fets_to_use
         'no need in calbrate mode (use 1 Fet only)
         Voltage_on_started = 1
      Else
         If On_off_mode = 0 Then
         'static normal mode
            If Found_calibrate = 0 Or Calibrate_i_started = 0 Then Gosub Modify_fet_voltage
         Else
         'switch on and off
            Gosub Operate_On_of_mode
         End If
      End If
   End If
End If
'
'RS232 got data?
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
   If Command_mode = 0 Then
   'restart if i2cmode
      Command_mode = 1
      Gosub  Command_received
   End If
   If Commandpointer < Stringlength Then
   'If Buffer is full, chars are ignored !!
       Command_b(Commandpointer) = A
       If Cmd_watchdog = 0 Then
          Cmd_watchdog = 1
          'start watchdog
       End If
      If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1
            'start watchdog
         End If
         If Rs232_active = 0 And Usb_active = 0 Then
         'allow &HFE only
            If Command_b(1) = 254 Then
               Gosub Slave_commandparser
            Else
               Gosub  Command_received
            End If
         Else
            Gosub Slave_commandparser
         End If
   End If
End If
'
'I2C
Twi_control = Twcr And &H80
'twint set?
If Twi_control = &H80 Then
'twsr 60 -> start, 80-> daten, A0 -> stop
   Twi_status = Twsr
   Twi_status = Twi_status And &HF8
'slave send:
If Twi_status = &HA8 Or Twi_status = &HB8 Then
      If I2c_pointer <= I2c_length Then
         Twdr = I2c_tx_b(i2c_pointer)
         Incr I2c_pointer
      Else
      'last Byte, String finished
         If Send_lines = 1 Then
         'lines to send
            If Number_of_lines > 1 Then
               Tempb = No_of_announcelines - 1
               'A_line is incremented before READ, -> No_of_announcelines -1 is last valid line
               If A_line < Tempb Then
                  Cmd_watchdog = 0
                  Decr Number_of_lines
                  Incr A_line
                  Gosub Sub_restore
                  Twdr = I2c_tx_b(i2c_pointer)
                  Incr I2c_pointer
               Else
                  Cmd_watchdog = 0
                  Decr Number_of_lines
                  A_line = 0
                  Gosub Sub_restore
                  Twdr = I2c_tx_b(i2c_pointer)
                  Incr I2c_pointer
               End If
            Else
               Twdr =&H00
               Send_lines = 0
               I2c_length = 0
            End If
         Else
            Twdr =&H00
            Send_lines = 0
            I2c_length = 0
         End If
      End If
   End If
'I2C receives data and and interpet as commands.
'slave receive:
   If Twi_status = &H80 Or Twi_status = &H88 Then
      If Command_mode = 1 Then
      'restart if rs232mode
         Command_mode = 0
         'i2c mode
         Gosub  Command_received
      End If
      Tempb = Twdr
      If Commandpointer <= Stringlength Then
         Command_b(commandpointer) = Tempb
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1
            'start watchdog
         End If                                             '
         If I2c_active = 0 Then
         'allow &HFE only
            If Command_b(1) = 254 Then
               Gosub Slave_commandparser
            Else
               Gosub  Command_received
            End If
         Else
            Gosub Slave_commandparser
         End If
      End If
   End If
   Twcr = &B11000100
End If
Stop Watchdog                                               '
Goto Slave_loop
'
'===========================================
'
Reset_:
First_set = 5
Dev_number_eeram = 1
Dev_name_eeram = "Device 1"
Adress_eeram = 42
I2C_active_eeram = 1
RS232_active_eeram = 1
Usb_active_eeram = 1
'
Calibrate_i_factor_eeram = Calibrate_i_factor_default
Max_power_eeram = Max_power_default
'50W
Active_fets_eeram = Active_fets_default
Correction_u_eeram = Correction_u_default
On_off_time_eeram = On_off_time_default * 50
For Tempb = 1 to 7
   Correction_i_eeram(Tempb) = Correction_i_default
Next Tempb
Return
'
Init:
I = 0
Set LED1
Command_no = 1
Command_mode = 0
Announceline = 255
Last_error = " No Error"
Error_no = 255
'No Error
L = 0
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram
I2C_active = I2C_active_eeram
RS232_active = RS232_active_eeram
Usb_active = Usb_active_eeram
Gosub Command_received
Gosub Command_finished
Gosub Reset_i2c_tx
'
For Tempb = 1 to 7
   Correction_i(Tempb) = Correction_i_eeram(Tempb)
Next Tempb
Correction_u = Correction_u_eeram
Max_power = Max_power_eeram
Active_fets = Active_fets_eeram
Calibrate_i_factor = Calibrate_i_factor_eeram
On_off_time = On_off_time_eeram
Gosub Reset_all
Return
'
Cmd_watch:
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong commands will be deleted
'all buffers are reset
If Cmd_watchdog > Cmd_watchdog_time Then
   Error_no = 3
   Gosub Command_received
   'reset commandinput
   Gosub Reset_i2c_tx
   'after that time also read must be finished
Else
   If Cmd_watchdog <> 0 Then Incr Cmd_watchdog
End If
Return
'
Last_err:
Last_error = Str(0 , 30)
Select Case Error_no
   Case 0
      Last_error = ": command not found: "
   Case 1
      Last_error = ": I2C error: "
   Case 3
      Last_error = ": cmd Watchdog: "
   Case 4
      Last_error = ": parameter error: "
   Case 5
      Last_error = ": voltage too low: "
   Case 6
      Last_error = ": current too low: "
   Case 7
      Last_error = ": max power exceeded: "
   Case 8
      Last_error = ": Fet(s) not active: "
   Case 9
      Last_error = ": cannot handle power: "
End Select
Temps = Str(command_no)
Tempb = Len(temps)
Tempc = Len(last_error)
For Tempd = 1 To Tempb
   Incr Tempc
   Insertchar Last_error , Tempc , Temps_b(tempd)
Next Tempd
Error_no= 255
Return
'
Blink_:
'for tests
'Led Blinks To Show Life
If I <= Blinktime Then
   Incr I
   Temp_w = Blinktime / 2
   If I = Temp_w Then Set Led1
Else
   I = 0
   Reset Led1
End If
Return
'
Command_finished:
Twsr = 0
'status und Prescaler auf 0
Twdr = &HFF
'default
Twar = Adress
'Slaveadress
Twcr = &B01000100
Return
'
Command_received:
Commandpointer = 1
Command = String(stringlength , 0)
'no multiple announcelines, if not finished
Cmd_watchdog = 0
Gosub Command_finished
If Error_no < 255 Then Gosub Last_err
Incr Command_no
If Command_no = 255 Then Command_no = 0
Return
'
Sub_restore:
Gosub Reset_i2c_tx
Error_no = 255
'no error
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
   Case Else
      Error_no = 4
End Select
If Error_no = 255 Then
   Read I2c_tx
   I2c_length = Len(i2c_tx)
   For Tempb = I2c_length To 1 Step -1
   'shift 1 pos right
      I2c_tx_b(tempb + 1) = I2c_tx_b(tempb)
   Next Tempb
   I2c_tx_b(1) = I2c_length
   Incr I2c_length
   If Command_mode = 1 Then
      For Tempb = 1 To I2c_length
         Tempc = I2c_tx_b(Tempb)
         Printbin Tempc
      Next Tempb
   End If
   'complete length of string
End If
Return
'
Reset_i2c_tx:
I2c_length = 0
I2c_pointer = 1
I2c_tx = String(Stringlength,0)
Return
'
Reset_all:
Gosub Reset_load
R_or_p = 0
Conductance = 300
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
Reset_load:
Set Ldac
NOP
Spi_buffer(1) = &B00111111
Spi_buffer(2) = &B11111111
Reset Fet1
Reset Fet2
Reset Fet3
Reset Fet4
Reset Fet5
Reset Fet6
Reset Fet7
Spiout Spi_buffer(1) , 2
Set Fet1
Set Fet2
Set Fet3
Set Fet4
Set Fet5
Set Fet6
Set Fet7
Reset Ldac
NOP
'min time is 100ns
Set Ldac
'This is faster than calling Send_to_fet
'
Required_c = 300
'3kOhm
Required_p = 0
Required_i = 0
Mean_power = 0
Fet_voltage_temp = 0
Found_calibrate = 0
Overload = 0
Used_fets = 0
Number_of_used_fets = 0
On_off_mode = 0
Fet_to_modify = 1
On_off_counter = 0
Voltage_on_started = 0
Calibrate_i_started = 0
For Fet_number = 1 to 7
   Dac_out_voltage(Fet_number) = Da_resolution
   Power_(Fet_number) = 0
   Current(Fet_number) = 0
Next Fet_number
Reset_done = 1
Return
'
Modify_fet_voltage:
   If R_or_p = 0 Then Return
   Fet_number = 0
   Select Case Fet_to_modify
      Case 1
         If Used_fets_1 = 1 Then Fet_number = 1
      Case 2
         If Used_fets_2 = 1 Then Fet_number = 2
      Case 3
         If Used_fets_3 = 1 Then Fet_number = 3
      Case 4
         If Used_fets_4 = 1 Then Fet_number = 4
      Case 5
         If Used_fets_5 = 1 Then Fet_number = 5
      Case 6
         If Used_fets_6 = 1 Then Fet_number = 6
      Case 7
         If Used_fets_7 = 1 Then Fet_number = 7
   End Select
   If Fet_number > 0 Then
   'skip, if Fet_to_modify is not active
      Gosub Measure_i
      'measure and calculate all I, P, and conductance values
      Select Case R_or_p
         Case 1
         'I mode
            If All_current < Required_i_min Then
            'complete I too low -> raise fetvoltage
               Gosub Raise_fet_voltage
            Else
               If All_current > Required_i_max Then
               'complete I too high, current to low -> reduce fetvoltage
                  Gosub Reduce_fet_voltage
               End If
            End If
         Case 2
         'P mode
            If All_power > Required_p_max Then
            'Power too high -> reduce fetvoltage
               Gosub Reduce_fet_voltage
            Else
               If All_power < Required_p_min Then
               'Power Too low -> raise fetvoltage
                  Gosub Raise_fet_voltage
               'Else
               'within Hysteresys
               End If
            End If
         Case 3
         'R mode
            If Conductance > Required_c_min Then
            'complete Conductance too high, current to high -> reduce fetvoltage
               Gosub Reduce_fet_voltage
            Else
               If Conductance < Required_c_max Then
               'complete Conductance too low, current to low -> raise fetvoltage
                  Gosub Raise_fet_voltage
               Else
               'within Hysteresys
               End If
            End If
         Case 4
         'I mode (calibration; one Fet active only
         'stop , if current is too high, no need to regulate down
            If All_current < Required_i Then
            'current too low -> raise fetvoltage
               Gosub Raise_fet_voltage
            Else
            'current reached
               Tempb = 7 - Fet_to_calibrate
               Temp_w = Getadc(Tempb)
               Found_calibrate = 1
               Reset Led1
               'show, that current may be adjusted
            End If
      End Select
   End If
   Incr Fet_to_modify
   If Fet_to_modify > 7 Then Fet_to_modify = 1
   'cyclic check all fets
Return
'
Reduce_fet_voltage:
'--> Fet raise R
If Power_(Fet_number) >= Mean_Power_min Then
'Actual power is greater than 0.9 * meanpower and can be further reduced
   Temp_w = Da_resolution - Fet_voltage_adder
   If Dac_out_voltage(Fet_number) < Temp_w Then
   'must raise due to inverting LM324
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) + Fet_voltage_adder
      Fet_voltage_temp = Dac_out_voltage(Fet_number)
      Gosub Send_to_fet
   End If
End If
Return
'
Raise_fet_voltage:
If Power_(Fet_number) <= Mean_power_max Then
'Power is lower than 1.1 * meanpower and can be further raised
   If Dac_out_voltage(Fet_number) > Fet_voltage_adder Then
      Dac_out_voltage(Fet_number) = Dac_out_voltage(Fet_number) - Fet_voltage_adder
      Fet_voltage_temp = Dac_out_voltage(Fet_number)
      Gosub Send_to_fet
   End If
End If
Return
'
Send_to_FET:
Spi_buffer(1) = High(Fet_voltage_temp)
Spi_buffer(1) = Spi_buffer(1) + Dac_adder
'add config bits
Spi_buffer(2) = Low(Fet_voltage_temp)
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
NOP
'min time is 100ns
Set Ldac
Return
'
Measure_i:
'measure U, I, P and R
'switch off if power of one fet is exceeded
'called by Modify_fet_voltage only
'for ADC numbers check circuit diagram
Overload = 0
All_current = 0
   Temp_w = Getadc(1)
   If Test = 1 Then
      Tempb = High(Temp_w)
      Printbin Tempb
      Tempb = Low(Temp_w)
      Printbin Tempb
   End If
If Used_fets_1 = 1 Then
   Temp_single = Temp_w * Correction_i(1)
   Current(1) = Temp_single
   All_current = Current(1)
   Power_(1) = Voltage * Current(1)
   Power_(1) = Power_(1) / 1000
   If Power_(1) > Max_power Then Overload = 1
End If
'
   Temp_w = Getadc(2)
   If Test = 1 Then
      Tempb = High(Temp_w)
      Printbin Tempb
      Tempb = Low(Temp_w)
      Printbin Tempb
   End If
If Used_fets_2 = 1 Then
   Temp_single = Temp_w * Correction_i(2)
   Current(2) = Temp_single
   All_current = All_current + Current(2)
   Power_(2) = Voltage * Current(2)
   Power_(2) = Power_(2) / 1000
   If Power_(2) > Max_power Then Overload = 1
End If
'
   Temp_w = Getadc(3)
   If Test = 1 Then
      Tempb = High(Temp_w)
      Printbin Tempb
      Tempb = Low(Temp_w)
      Printbin Tempb
   End If
If Used_fets_3 = 1 Then
   Temp_single = Temp_w * Correction_i(3)
   Current(3) = Temp_single
   All_current = All_current + Current(3)
   Power_(3) = Voltage * Current(3)
   Power_(3) = Power_(3) / 1000
   If Power_(3) > Max_power Then Overload = 1
End If
'
   Temp_w = Getadc(4)
   If Test = 1 Then
      Tempb = High(Temp_w)
      Printbin Tempb
      Tempb = Low(Temp_w)
      Printbin Tempb
   End If
If Used_fets_4 = 1 Then
   Temp_single = Temp_w * Correction_i(4)
   Current(4) = Temp_single
   All_current = All_current + Current(4)
   Power_(4) = Voltage * Current(4)
   Power_(4) = Power_(4) / 1000
   If Power_(4) > Max_power ThenOverload = 1
End If
'
   Temp_w = Getadc(5)
   If Test = 1 Then
      Tempb = High(Temp_w)
      Printbin Tempb
      Tempb = Low(Temp_w)
      Printbin Tempb
   End If
If Used_fets_5 = 1 Then
   Temp_single = Temp_w * Correction_i(5)
   Current(5) = Temp_single
   All_current = All_current + Current(5)
   Power_(5) = Voltage * Current(5)
   Power_(5) = Power_(5) / 1000
   If Power_(5) > Max_power Then Overload = 1
End If
'
   Temp_w = Getadc(6)
   If Test = 1 Then
      Tempb = High(Temp_w)
      Printbin Tempb
      Tempb = Low(Temp_w)
      Printbin Tempb
   End If
If Used_fets_6 = 1 Then
   Temp_single = Temp_w * Correction_i(6)
   Current(6) = Temp_single
   All_current = All_current + Current(6)
   Power_(6) = Voltage * Current(6)
   Power_(6) = Power_(6) / 1000
   If Power_(6) > Max_power Then Overload = 1
End If
'
   Temp_w = Getadc(7)
   If Test = 1 Then
      Tempb = High(Temp_w)
      Printbin Tempb
      Tempb = Low(Temp_w)
      Printbin Tempb
   End If
If Used_fets_7 = 1 Then
   Temp_single = Temp_w * Correction_i(7)
   Current(7) = Temp_single
   All_current = All_current + Current(7)
   Power_(7) = Voltage * Current(7)
   Power_(7) = Power_(7) / 1000
   If Power_(7) > Max_power Then Overload = 1
End If
'
If Overload = 1 Then
'   print "overload"
'   Gosub Reset_all
   Error_no = 7
   Gosub Last_err
   Gosub Reset_all
Else
   Temp_single = All_current / Voltage
   'S
   Conductance = Temp_single * 1000000
   'uS
'
   Temp_single = Voltage * All_current
   'Power uW
   All_power = Temp_single / 1000
   'mW
   Mean_power = All_power / Number_of_used_fets
   Temp_single = Mean_power  * 0.9
   Mean_power_min = Temp_single
   Temp_single = Mean_power * 1.1
   Mean_power_max = Temp_single
   'Each Fet should have similar power
End If
Return
'
Operate_On_of_mode:
Incr On_off_counter
If On_off_counter < On_off_time Then
   If On_off = 1 Then
   'on
      Gosub Measure_i
      'no modification of load
      'Overload check is done during measurement
   'Else: off: do nothing
   End If
Else
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
      Next Fet_number
   End If
   On_off_counter = 0
End If
Return
'
Calculate_Number_of_fets_to_use:
If R_or_P = 0 Or R_or_p = 4 Then Return
   If Active_fets = 0 Then
      Error_no = 8
      Gosub Last_err
      Gosub Reset_all
      Return
   End If
   Temp_single = Max_power * 0.8
   Temp_w = Temp_single
   '80 % of max power per Fet
   Select Case R_or_P
      Case 1
         'Current given -> calculate required Power
         Temp_single = Voltage * Required_i
         'required_p uW
         Temp_single = Temp_single / 1000
         Temp_dw1 = Temp_single
         'mW
      Case 2
         Temp_dw1 = Required_p
         'mW
      Case 3
      'Resistor given -> calculate required Power
         Temp_single = Required_c / Voltage
         'I A (mS / mV)
         Temp_single = Temp_single * Voltage
         'mW
         Temp_dw1 = Temp_single
   End Select
   'Temp_dw1 is reqired power
   Temp_dw = 0
   'Power , which Tempb Fets can handle (80%)
   Number_of_used_fets = 0
   Used_fets = 0
   Tempb = 1
   No_more_fets = 0
   While Tempb < 8 And No_more_fets = 0
      Select Case  Tempb
         Case 1
            If Active_fet_1 = 1 Then
               Temp_dw = Temp_dw + Temp_w
               Incr Number_of_used_fets
               Used_fets_1 = 1
               If Temp_dw > Temp_dw1 Then No_more_fets = 1
            End If
         Case 2
            If Active_fet_2 = 1 Then
               Temp_dw = Temp_dw + Temp_w
               Incr Number_of_used_fets
               Used_fets_2 = 1
               If Temp_dw > Temp_dw1 Then No_more_fets = 1
            End If
         Case 3
            If Active_fet_3 = 1 Then
               Temp_dw = Temp_dw + Temp_w
               Incr Number_of_used_fets
               Used_fets_3 = 1
               If Temp_dw > Temp_dw1 Then No_more_fets = 1
            End If
         Case 4
            If Active_fet_4 = 1 Then
               Temp_dw = Temp_dw + Temp_w
               Incr Number_of_used_fets
               Used_fets_4 = 1
               If Temp_dw > Temp_dw1 Then No_more_fets = 1
            End If
         Case 5
            If Active_fet_5 = 1 Then
               Temp_dw = Temp_dw + Temp_w
               Incr Number_of_used_fets
               Used_fets_5 = 1
               If Temp_dw > Temp_dw1 Then No_more_fets = 1
            End If
         Case 6
            If Active_fet_6 = 1 Then
               Temp_dw = Temp_dw + Temp_w
               Incr Number_of_used_fets
               Used_fets_6 = 1
               If Temp_dw > Temp_dw1 Then No_more_fets = 1
            End If
         Case 7
            If Active_fet_7 = 1 Then
               Temp_dw = Temp_dw + Temp_w
               Incr Number_of_used_fets
               Used_fets_7 = 1
               If Temp_dw < Temp_dw1 Then
               'cannot handle power
                  Error_no = 9
                  Gosub Last_err
                  Gosub Reset_all
                  Return
               End If
            End If
      End Select
      Incr Tempb
   Wend
   Select Case R_or_p
   'calculate Hysteresys depend on Number_of_used_fets
      Case 1
      'I mode
         Required_i_min = Required_i - Resolution_i
         Required_i_max = Required_i + Resolution_i
      Case 2
      'P mode
         Temp_single = Resolution_i * Voltage
         Temp_single = Temp_single / 1000
         Temp_dw = Temp_single
         Required_p_min = Required_p - Temp_dw
         Required_p_max = Required_p + Temp_dw
      Case 3
      'R mode (conductance)
         Temp_single = Resolution_i * 1000000
         'nA
         Temp_single = Temp_single / Voltage
         'nA / mV -> uS
         Temp_dw = Temp_single
         Required_c_min = Required_c - Temp_dw
         Required_c_max = Required_c + Temp_dw
   End Select
Return
'
Slave_commandparser:
If Commandpointer > 253 Then
'Error, do nothing
   Gosub Command_received
Else
'
   Select Case Command_b(1)
      Case 0
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
'Data "0;m;DK1RI;electronic load for 7 IRFP150;V01.3;1;120;1;33"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl &H01
'lese aktuelle Spannung (1Bit -> 10mV)
'read actual voltage
'Data "1;aa,read actual voltage;w,{0 to 100.00},V"
         Temp_single = Voltage / 10
         'mV -> 10mV
         Temp_w = Temp_single
         If Command_mode = 1 Then
            Tempb = High(Temp_w)
            Printbin Tempb
            Tempb = Low(Temp_w)
            Printbin Tempb
         Else
            Gosub Reset_i2c_tx
            I2c_length = 2
            I2c_tx_b(2) = High(Temp_w)
            I2c_tx_b(3) = Low(Temp_w)
         End If
         Gosub Command_received
'
      Case 2
'Befehl &H02
'liest gesamten Strom (1Bit -> 10mA)
'read all current
'Data "2;aa,read actual current;w,{0 to 210.00},A"
         If On_off_mode = 0 Then
            Temp_dw = All_current / 10
            'mA -> 10mA
            Temp_w = Temp_dw
            If Command_mode = 1 Then
               Tempb =  High(Temp_w)
               Printbin Tempb
               Tempb = Low(Temp_w)
               Printbin Tempb
            Else
               Gosub Reset_i2c_tx
               I2c_length = 2
               I2c_tx_b(1) = High(Temp_w)
               I2c_tx_b(2) = Low(Temp_w)
            End If
         Else
            Error_no = 4
         End If
         Gosub Command_received
'

      Case 3
'Befehl &H03  0 - 6
'liest aktuellen Strom eines FETs (1Bit -> 10mA)
'read actual current of a FET
'Data "3;am,read actual current;w,{0 to 30.00},A;7"
         If On_off_mode = 0 Then
            If Commandpointer = 2 Then
               If Command_b(2) < 7 Then
                  Tempb = Command_b(2) + 1
                  Temp_dw = Current(Tempb) / 10
                  'mA -> 10mA
                  Temp_w = Temp_dw
                  If Command_mode = 1 Then
                     Tempb =  High(Temp_w)
                     Printbin Tempb
                     Tempb = Low(Temp_w)
                     Printbin Tempb
                  Else
                     Gosub Reset_i2c_tx
                     I2c_length = 2
                     I2c_tx_b(1) = High(Temp_w)
                     I2c_tx_b(2) = Low(Temp_w)
                  End If
               Else
                  Error_no = 4
               End If
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         Else
            Error_no = 4
            Gosub Command_received
         End If
      Case 4
'Befehl &H04  (1Bit -> 10mW)
'liest gesamte Leistung
'read all current
'Data "4;aa,read actual power;w,{0 to 1400.0},W"
         If On_off_mode = 0 Then
            Temp_dw = All_power / 10
            'mW -> 10mW
            Temp_w = Temp_dw
            If Command_mode = 1 Then
               Tempb =  High(Temp_w)
               Printbin Tempb
               Tempb = Low(Temp_w)
               Printbin Tempb
            Else
               Gosub Reset_i2c_tx
               I2c_length = 2
               I2c_tx_b(1) = High(Temp_w)
               I2c_tx_b(2) = Low(Temp_w)
            End If
         Else
            Error_no = 4
         End If
         Gosub Command_received
'
      Case 5
'Befehl &H05  0 - 6 (1Bit -> 10mW)
'liest aktuelle Leistung eines FETs
'read actual power of a FET
'Data "5;am,read actual power;w,{0 to 200.0},W;7"
         If On_off_mode = 0 Then
            If Commandpointer = 2 Then
               If Command_b(2) < 7 Then
                  Tempb = Command_b(2) + 1
                  Temp_dw = Power_(Tempb)
                  Temp_dw = Temp_dw / 10
                  'mW -> 100mW
                  Temp_w = Temp_dw
                  If Command_mode = 1 Then
                     Tempb =  High(Temp_w)
                     Printbin Tempb
                     Tempb = Low(Temp_w)
                     Printbin Tempb
                  Else
                     Gosub Reset_i2c_tx
                     I2c_length = 2
                     I2c_tx_b(1) = High(Temp_w)
                     I2c_tx_b(2) = Low(Temp_w)
                  End If
               Else
                  Error_no = 4
                End If
               Gosub Command_received
            Else
               Incr Commandpointer
            End If
         Else
            Error_no = 4
            Gosub Command_received
         End If
'
      Case 6
'Befehl &H06
'lese aktuellen Widerstand  (1Bit -> 1mOhm)
'read actual resistor
'Data "6;ap,read actual resistor;2000000,{1 to 2000000};lin;mOhm"
         If On_off_mode = 0 Then
            Temp_single = 1 / Conductance
            Temp_single = Temp_single * 1000000000
            Temp_dw = Temp_single
            If Temp_dw > 2000000 Then Temp_dw = 2000000
            If Command_mode = 1 Then
               Printbin Temp_dw_b4
               Printbin Temp_dw_b3
               Printbin Temp_dw_b2
               Printbin Temp_dw_b1
            Else
               Gosub Reset_i2c_tx
               I2c_length = 4
               I2c_tx_b(1) = Temp_dw_b4
               I2c_tx_b(2) = Temp_dw_b3
               I2c_tx_b(3) = Temp_dw_b2
               I2c_tx_b(4) = Temp_dw_b1
            End If
         Else
            Error_no = 4
         End If
         Gosub Command_received
'
      Case 7
'Befehl &H07 0 - 21000
'gewuenschten Strom (10mA resolution)
'required current  (10mA resolution)
'Data "7;op,required current;21001,{0 to 210,00};lin;A"
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
                  Required_i = Temp_dw
                  R_or_p = 1
               Else
                  Error_no = 4
               End If
            Else
               Error_no = 4
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 8
'Befehl &H08
'gewuenschten Strom (10mA resolution) lesen
'read required current  (10mA resolution)
'Data "8;ap,as7"
         Temp_w = Required_i / 10
         If Command_mode = 1 Then
            Tempb = High(Temp_w)
            Printbin Tempb
            Tempb = Low(Temp_w)
            Printbin Tempb
         Else
            Gosub Reset_i2c_tx
            I2c_length = 2
            I2c_tx_b(2) = High(Temp_w)
            I2c_tx_b(3) = Low(Temp_w)
         End If
         Gosub Command_received
'
      Case 9
'Befehl &H09 0 - 65535
'gewuenschte Leistung (20mW resolution)
'required power  (20mW resolution)
'Data "9;op,required power;65536,{0 to 1310700};lin;mW"
         If Commandpointer >= 3 Then
            Gosub Reset_load
            Temp_w_b1 = command_b(3)
            'low byte first
            Temp_w_b2 = command_b(2)
            Temp_dw = Temp_w * 20
            Temp_dw1 = Max_power * Number_of_active_fets
            If Temp_dw <= Temp_dw1 Then
            'must not be higher than allowed
               Required_p = Temp_dw
               R_or_p = 2
            Else
               Error_no = 4
            End IF
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 10
'Befehl &H0A
'gewuenschte Leistung  (20mW resolution) lesen
'required power  (20mW resolution)
'Data "10;ap,as9"
         Temp_single = Required_p / 20
         Temp_w = Temp_single
         If Command_mode = 1 Then
            Tempb = High(Temp_w)
            Printbin Tempb
            Tempb = Low(Temp_w)
            Printbin Tempb
         Else
            Gosub Reset_i2c_tx
            I2c_length = 2
            I2c_tx_b(2) = High(Temp_w)
            I2c_tx_b(3) = Low(Temp_w)
         End If
         Gosub Command_received
'

      Case 11
'Befehl &H0B 0 - 1999990
'gewuenschten Widerstand schreiben (Auflösung 1mOhm)
'write required resistor (resolution 1mOhm)
'Data "11;op,required resistor;1999991,{9 to 2000000};lin;mOhm"
         If Commandpointer = 5 Then
            Temp_dw_b4 = command_b(2)
            'high byte first
            Temp_dw_b3 = command_b(3)
            Temp_dw_b2 = command_b(4)
            Temp_dw_b1 = command_b(5)
            If Temp_dw < 1999991 Then
            '0 based
               Gosub Reset_load
               Temp_single = Temp_dw + 9
               'in mOhm
               Temp_single = 1 / Temp_single
               'in kS
               Temp_single = Temp_single * 1000000000
               'in uS
               Required_c = Temp_single
               R_or_p = 3
            Else
               Error_no = 4
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 12
'Befehl &H0C
'gewuenschter Widerstand mOhm lesen
'read required resistor
'Data "12;ap,as11"
            Temp_single = 1 / Required_c
            Temp_single = Temp_single * 1000000000
            Temp_dw = Temp_single - 9
         If Command_mode = 1 Then
            Printbin Temp_dw_b4
            'print high byte first
            Printbin Temp_dw_b3
            Printbin Temp_dw_b2
            Printbin Temp_dw_b1
         Else
            Gosub Reset_i2c_tx
            I2c_length = 4
            I2c_tx_b(1) = Temp_dw_b4
            I2c_tx_b(2) = Temp_dw_b3
            I2c_tx_b(3) = Temp_dw_b2
            I2c_tx_b(4) = Temp_dw_b1
         End If
         Gosub Command_received
'
      Case 13
'Befehl &H0D 0|1
'Wechsellast schreiben
'write (start) on /off mode
'Data "13;or,on off mode;0,off,on"
         If Commandpointer >= 2 Then
            If Command_b(2) < 2  Then
               If Command_b(2) = 1 Then
                  If R_or_p = 1 Or R_or_p = 2 Or R_or_p = 3 Then
                     On_off_mode = 1
                     On_off_counter = 0
                     Set Led1
                  Else
                     Error_no = 4
                  End If
               Else
                  If On_off_mode = 1 Then
                     Gosub Reset_all
                     'reset switch off on_off_mode off
                  Else
                     Error_no = 4
                  End If
               End If
            Else
               Error_no = 4
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 14
'Befehl &H0E
'Wechsellast lesen
'read on /off mode
'Data "14;ar,as13"
         Tempb = On_off_mode
         If Command_mode = 1 Then
            Printbin Tempb
         Else
            Gosub Reset_i2c_tx
            I2c_length = 1
            I2c_tx_b(1) = Tempb
         End If
         Gosub Command_received
'
      Case 15
'Befehl &H0F 0 - 256
'Maximale Leistung pro Fet
'maximum power per FET
'Data "15;op;maximum power per FET;200,{1 to 200};lin;Watt"
         If Commandpointer >= 2 Then
            If Command_b(2) < 200 Then
               Max_power = Command_b(2) + 1
               Max_power = Max_power * 1000
               'mW
               Max_power_eeram = Max_power
               Gosub Reset_all
            Else
               Error_no = 4
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 16
'Befehl &H10
'Maximale Leistung pro Fet lesen
'read maximum power per FET
'Data "16;ap,as15"
         Temp_dw = Max_power / 1000
         Tempb = Temp_dw
         If Tempb > 0 Then Decr Tempb
         If Command_mode = 1 Then
            Printbin Tempb
         Else
            Gosub Reset_i2c_tx
            I2c_length = 1
            I2c_tx_b(1) = Tempb
         End If
         Gosub Command_received
'
      Case 17
'Befehl &H11 0 to 127
'Aktive FETs binaer schreiben
'write active FETS binary
'Data "17;oa,active FETs, binary;b,{0 to 127}"
         If Commandpointer >= 2 Then
            If Command_b(2) < 128 Then
               Active_fets = Command_b(2)
               Active_fets_eeram = Active_fets
               Gosub Reset_all
            Else
               Error_no = 4
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 18
'Befehl &H12
'Aktive FETs binaer lesen
'read active FETS binary
'Data "18;aa,as17"
         If Command_mode = 1 Then
            Printbin Active_fets
         Else
            Gosub Reset_i2c_tx
            I2c_length = 1
            i2c_tx_b(1) = Active_fets
         End If
         Gosub Command_received
'
      Case 19
'Befehl &H13
'schaltet Last ab
'switch off
'Data "19;ou,switch off;0"
         Gosub Reset_all
'
      Case 20
'Befehl &H14
'Mode lesen
'read mode
'Data "20;ar,read mode;0,off;1,I;2,P;3,R"
         If Command_mode = 1 Then
            Printbin R_or_p
         Else
            Gosub Reset_i2c_tx
            I2c_length = 1
            i2c_tx_b(1) = r_or_p
         End If
         Gosub Command_received
'
      Case 21
'Befehl &H15 0 to 100
'Faktor für Stromeichung schreiben
'write factor for current calibration
'Data "21;oa,current calibtation factor;b,{0 to 100}"
         If Commandpointer >= 2 Then
            If Command_b(2) < 101 Then
               If Calibrate_i_started = 0 Then
                  Calibrate_i_factor = Command_b(2)
                  Calibrate_i_factor_eeram = Calibrate_i_factor
               Else
                  Error_no = 4
               End If
            Else
               Error_no = 4
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 22
'Befehl &H16
'Faktor für Stromeichung lesen
'read factor for current calibration
'Data "22;aa,as21"
         If Command_mode = 1 Then
            Printbin Calibrate_i_factor
         Else
            Gosub Reset_i2c_tx
            I2c_length = 1
            i2c_tx_b(1) = Calibrate_i_factor
         End If
         Gosub Command_received
'
      Case 23
'Befehl &H17 0 to 255
'Zeit für Wechsellast schreiben
'write time for on - off mode
'Data "23;oa,time for on off mode;b"
         If Commandpointer >= 2 Then
            On_off_time = Command_b(2) * 50
            On_off_time_eeram = On_off_time
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 24
'Befehl &H18
'Zeit für Wechsellast lesen
'read time for on - off mode
'Data "24;aa,as23"
         If Command_mode = 1 Then
            Temp_w = On_off_time
            Temp_w = Temp_w / 50
            Tempb = Temp_w
            Printbin Tempb
         Else
            Gosub Reset_i2c_tx
            I2c_length = 1
            i2c_tx_b(1) = Tempb
         End If
         Gosub Command_received
'
      Case 25
'Befehl &H19 0 to 6 , 0 to 4095
'für Tests: Widerstand eines Fets einstellen
'for tests: set resistor value of a fet
'Data "25;om,set resistance;6;w,{0 to 4095}"
         If Commandpointer >= 4 Then
            If Command_b(2) < 8 Then
               If Command_b(3) < 16 Then
                  If Command_b(2) = 0 Then
                     Gosub Reset_all
                  Else
                     Fet_voltage_temp = Command_b(3) * 256
                     Fet_voltage_temp = Fet_voltage_temp + Command_b(4)
                     Fet_number = Command_b(2)
                     Gosub Send_to_fet
                  End If
               Else
                  Error_no = 4
               End If
            Else
               Error_no = 4
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 26
'Befehl &H1A
'für Tests: Alle AD Wanler lesen
'for tests: read all AD outputs
'Data "26;am,read AD values;6;w,{0 to 1023}"
         Test = 1
         Gosub Measure_i
         Gosub Command_received
         Test = 0
'
      Case 237
'Befehl &HED
'Spannung eichen mit 90V
'calibrate Voltage with 90V
'Data "237;ou,calibrate voltage;0"
         Temp_w = Getadc(0)
         If Temp_w > 900 Then
            Temp_single = 90000 / Temp_w
            'mV resolution
            Correction_u = Temp_single
            Correction_u_eeram = Correction_u
         Else
            Error_no = 5
         End If
         Gosub Command_received
'
      Case 238
'Befehl &HEE 0 - 7
'Strom eichen
'calibrate Current
'Data "238;ou,calibrate current;0,off;1,FET1;2,FET2;3,FET3;34FET4;5,FET5;6,FET6;7,FET7"
         If Commandpointer = 2 Then
            If Command_b(2) < 8 Then
               If Command_b(2) = 0 Then
                  If Calibrate_i_started = 1 Then
                     Tempb = 7 - Fet_to_calibrate
                     Temp_w = Getadc(Tempb)
                     print Temp_w
                     If Temp_w > 200 Then
                        Temp_single = 30000 / Temp_w
                        'mA resolution
                        Correction_i(tempb) = Temp_single
                        Correction_i_eeram(Tempb) = Correction_i(tempb)
                        Calibrate_i_started = 0
                     Else
                        Error_no = 4
                     End If
                  Else
                     Error_no = 4
                  End If
                  Gosub Reset_all
               Else
                  If  Calibrate_i_started = 0 Then
                     Gosub Reset_all
                     Error_no = 0
                     Select Case Command_b(2)
                        Case 1
                           If Active_fet_1 = 1 Then
                              Used_fets_1 = 1
                           Else
                              Error_no = 8
                           End If
                        Case 2
                           If Active_fet_2 = 1 Then
                              Used_fets_2 = 1
                           Else
                              Error_no = 8
                           End If
                        Case 3
                           If Active_fet_3 = 1 Then
                              Used_fets_3 = 1
                           Else
                              Error_no = 8
                           End If
                        Case 4
                           If Active_fet_4 = 1 Then
                              Used_fets_4 = 1
                           Else
                              Error_no = 8
                           End If
                        Case 5
                           If Active_fet_5 = 1 Then
                              Used_fets_5 = 1
                           Else
                              Error_no = 8
                           End If
                        Case 6
                           If Active_fet_6 = 1 Then
                              Used_fets_6 = 1
                           Else
                              Error_no = 8
                           End If
                        Case 7
                           If Active_fet_7 = 1 Then
                              Used_fets_7 = 1
                           Else
                              Error_no = 8
                           End If
                     End Select
                     If Error_no = 0 Then
                        Fet_to_calibrate = Tempb
                        Number_of_used_fets = 1
                        R_or_p = 4
                        Temp_single = 30000 * Calibrate_i_factor
                        Temp_single = Temp_single / 100
                        Required_i = Temp_single
                        Mean_power_min =0
                        Mean_power_max = 200000
                        'one Fet only -> no limit
                        Calibrate_i_started = 1
                        Set Led1
                        'off until current found
                     End If
                  Else
                     Error_no = 4
                  End If
               End If
            Else
               Error_no = 4
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 239
'Befehl &HEF
'Stromeichung mode lesen
'read mode  of current calibration
'Data "20;ar,read mode;0,off;1,I;2,P;3,I;4,calibrate"
         Tempb = Calibrate_i_started
         If Command_mode = 1 Then
            Printbin Tempb
         Else
            Gosub Reset_i2c_tx
            I2c_length = 1
            i2c_tx_b(1) = Tempb
         End If
         Gosub Command_received
'

      Case 240
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
'Data "240;an,ANNOUNCEMENTS;100;33"
         If Commandpointer = 3 Then
            If Command_b(2) < No_of_announcelines And Command_b(3) <= No_of_announcelines Then
                If Command_b(3) > 0 Then
                  Send_lines = 1
                  Number_of_lines = Command_b(3)
                  A_line = Command_b(2)
                  Gosub Sub_restore
                  If Command_mode = 1 Then
                     Decr Number_of_lines
                     While  Number_of_lines > 0
                        Decr Number_of_lines
                        Incr A_line
                        If A_line >= No_of_announcelines Then
                           A_line = 0
                        End If
                        Gosub Sub_restore
                     Wend
                  End If
               End If
            Else
               Error_no = 4
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
'Data "252;aa,LAST ERROR;20,last_error"
         Gosub Reset_i2c_tx
         Temps = Str(command_no)
         I2c_length = Len(temps)
         For Tempb = 1 To I2c_length
            I2c_tx_b(tempb + 1) = Temps_b(tempb)
            '+1: leave space for length
         Next Tempb
         Incr I2c_length
         'because of 1 byte with length
         Tempb = Len(last_error)
         For Tempc = 1 To Tempb
            Tempd = Tempc + I2c_length
            'write at the end
            I2c_tx_b(tempd) = Last_error_b(tempc)
         Next Tempc
         I2c_length = Tempd
         'last tempd is length
         Decr Tempd
         I2c_tx_b(1) = Tempd
         If Command_mode = 1 Then
            For Tempb = 1 To I2c_length
               Tempc = I2c_tx_b(tempb)
               Printbin Tempc
            Next Tempb
         End If
         Gosub Command_received
'
      Case 253
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
'Data "253;aa,MYC INFO;b,ACTIVE"
         Gosub Reset_i2c_tx
         If Command_mode = 1 Then
            Printbin 4
         Else
            I2c_tx_b(1) = 4
            'no info
            I2c_length = 1
         End If
         Gosub Command_received
'
      Case 254
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,RS232,1;a,USB,11"
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
                     End If
                     Gosub Command_received
                  End If
               Case 3
                  If Commandpointer = 3 Then
                     Tempb = Command_b(3)
                     If Tempb < 129 Then
                        Tempb = Tempb * 2
                        Adress = Tempb
                        Adress_eeram = Adress
                     Else
                        Error_no = 4
                     End If
                     Gosub Command_received
                  Else
                     Incr Commandpointer
                  End If
               Case 4
                  If Commandpointer < 3 Then
                     Incr Commandpointer
                  Else
                     If Command_b(3) > 1 Then Command_b(3) = 1
                     RS232_active = Command_b(3)
                     RS232_active_eeram = RS232_active
                     Gosub Command_received
                  End If
               Case 5
                  If Commandpointer < 3 Then
                     Incr Commandpointer
                  Else
                     If Command_b(3) > 1 Then Command_b(3) = 1
                     Usb_active = Command_b(3)
                     Usb_active_eeram = Usb_active
                     Gosub Command_received
                  End If
               Case Else
                  Error_no = 4
                  Gosub Command_received
            End Select
         Else
           Incr Commandpointer
         End If
'
      Case 255
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
         If Commandpointer = 2 Then
            Gosub Reset_i2c_tx
            Select Case Command_b(2)
               Case 0
                  I2c_length = Len(Dev_name)
                  I2c_tx_b(1) = I2c_length
                  For Tempb = 1 To I2c_length
                     I2c_tx_b(tempb + 1) = Dev_name_b(tempb)
                  Next Tempb
                  Incr I2c_length
               Case 1
                  I2c_tx_b(1) = Dev_number
                  I2c_length = 1
               Case 2
                  I2C_tx_b(1) = I2C_active
                  I2c_length = 1
               Case 3
                  Tempb = Adress / 2
                  I2c_tx_b(1) = Tempb
                  I2c_length = 1
               Case 4
                  I2c_tx_b(1) = RS232_active
                  I2c_length = 1
               Case 5
                  I2c_tx_b(1) = 0
                  I2c_length = 1
               Case 6
                  I2c_tx = "8n1"
                  I2c_length = 3
               Case 7
                  I2c_tx_b(1) = USB_active
                  I2c_length = 1
               Case Else
                  Error_no = 4
                  'ignore anything else
                  Gosub Last_err
            End Select
            If Command_mode = 1 Then
               For Tempb = 1 To I2c_length
                  Tempc = I2c_tx_b(tempb)
                  Printbin Tempc
               Next Tempb
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
      Case Else
         Error_no = 0
         'ignore anything else
         Gosub Command_received
   End Select
End If
Return
'
'==================================================
'
End
'announce text
'
Announce0:
'Befehl &H00
'basic annoumement wird gelesen
'basic announcement is read
Data "0;m;DK1RI;electronic load for 7 IRFP150;V01.3;1;120;1;33"
'
Announce1:
'Befehl &H01
'lese aktuelle Spannung (1Bit -> 10mV)
'read actual voltage
Data "1;aa,read actual voltage;w,{0 to 100.00},V"
'
Announce2:
'Befehl &H02
'liest gesamten Strom (1Bit -> 10mA)
'read all current
Data "2;aa,read actual current;w,{0 to 210.00},A"
'
Announce3:
'Befehl &H03  0 - 6
'liest aktuellen Strom eines FETs (1Bit -> 10mA)
'read actual current of a FET
Data "3;am,read actual current;w,{0 to 30.00},A;7"
'
Announce4:
'Befehl &H04  (1Bit -> 10mW)
'liest gesamte Leistung
'read all current
Data "4;aa,read actual power;w,{0 to 1400.0},W"
'
Announce5:
'Befehl &H05  0 - 6 (1Bit -> 10mW)
'liest aktuelle Leistung eines FETs
'read actual power of a FET
Data "5;am,read actual power;w,{0 to 200.0},W;7"
'
Announce6:
'Befehl &H06
'lese aktuellen Widerstand  (1Bit -> 1mOhm)
'read actual resistor
Data "6;ap,read actual resistor;2000000,{1 to 2000000};lin;mOhm"
'
Announce7:
'Befehl &H07 0 - 21000
'gewuenschten Strom (10mA resolution)
'required current  (10mA resolution)
Data "7;op,required current;21001,{0 to 210,00};lin;A"
'
Announce8:
'Befehl &H08
'gewuenschten Strom (10mA resolution) lesen
'read required current  (10mA resolution)
Data "8;ap,as7"
'
Announce9:
'Befehl &H09 0 - 65535
'gewuenschte Leistung (20mW resolution)
'required power  (20mW resolution)
Data "9;op,required power;65536,{0 to 1310700};lin;mW"
'
Announce10:
'Befehl &H0A
'gewuenschte Leistung  (20mW resolution) lesen
'required power  (20mW resolution)
Data "10;ap,as9"
'
Announce11:
'Befehl &H0B 0 - 1999990
'gewuenschten Widerstand schreiben (Auflösung 1mOhm)
'write required resistor (resolution 1mOhm)
Data "11;op,required resistor;1999991,{9 to 2000000};lin;mOhm"

Announce12:
'Befehl &H0C
'gewuenschter Widerstand mOhm lesen
'read required resistor
Data "12;ap,as11"
'
Announce13:
'Befehl &H0D 0|1
'Wechsellast schreiben
'write (start) on /off mode
Data "13;or,on off mode;0,off,on"
'
Announce14:
'Befehl &H0E
'Wechsellast lesen
'read on /off mode
Data "14;ar,as13"
'
Announce15:
'Befehl &H0F 0 - 256
'Maximale Leistung pro Fet
'maximum power per FET
Data "15;op;maximum power per FET;200,{1 to 200};lin;Watt"
'
Announce16:
'Befehl &H10
'Maximale Leistung pro Fet lesen
'read maximum power per FET
Data "16;ap,as15"
'
Announce17:
'Befehl &H11 0 to 127
'Aktive FETs binaer schreiben
'write active FETS binary
Data "17;oa,active FETs, binary;b,{0 to 127}"
'
Announce18:
'Befehl &H12
'Aktive FETs binaer lesen
'read active FETS binary
Data "18;aa,as17"
'
Announce19:
'Befehl &H13
'schaltet Last ab
'switch off
Data "19;ou,switch off;0"
'
Announce20:
'Befehl &H14
'Mode lesen
'read mode
Data "20;ar,read mode;0,off;1,I;2,P;3,R"
'
Announce21:
'Befehl &H15 0 to 100
'Faktor für Stromeichung schreiben
'write factor for current calibration
Data "21;oa,current calibtation factor;b,{0 to 100}"
'
Announce22:                                                  '
'Befehl &H16
'Faktor für Stromeichung lesen
'read factor for current calibration
Data "22;aa,as21"
'
Announce23:
'Befehl &H17 0 to 255
'Zeit für Wechsellast schreiben
'write time for on - off mode
Data "23;oa,time for on off mode;b"
'
Announce24:
'Befehl &H18
'Zeit für Wechsellast lesen
'read time for on - off mode
Data "24;aa,as23"
'
Announce25:
'Befehl &H19 0 to 6 , 0 to 4095
'für Tests: Widerstand eines Fest einstellen
'for tests: set resistor value of a fet
Data "25;om,set resistance;6;w,{0 to 4095}"
'
Announce26:
'Befehl &H1A
'für Tests: Alle AD Wanler lesen
'for tests: read all AD outputs
Data "26;am,read AD values;6;w,{0 to 1023}"
'
Announce27:                                             '
'Befehl &HED
'Spannung eichen mit 90V
'calibrate Voltage with 90V
Data "237;ou,calibrate voltage;0"
'
Announce28:
'Befehl &HEE 0 - 7
'Strom eichen
'calibrate Current
Data "238;ou,calibrate current;0,off;1,FET1;2,FET2;3,FET3;34FET4;5,FET5;6,FET6;7,FET7"
'
Announce29:
'Befehl &HEF
'Stromeichung mode lesen
'read mode  of current calibration
Data "20;ar,read mode;0,off;1,I;2,P;3,I;4,calibrate"
'
Announce30:
'Befehl &HF0<n><m>
'liest announcements
'read n announcement lines
Data "240;an,ANNOUNCEMENTS;100;33"
'
Announce31:
'Befehl &HFC
'Liest letzten Fehler
'read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce32:
'Befehl &HFD
'Geraet aktiv Antwort
'Life signal
Data "253;aa,MYC INFO;b,ACTIVE"
'
Announce33:
'Befehl &HFE :
'eigene Individualisierung schreiben
'write individualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,RS232,1;a,USB,11"
'
Announce34:
'Befehl &HFF :
'eigene Individualisierung lesen
'read individualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;a,I2C,1;b,ADRESS,21,{0 to 127};a,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;a,USB,1"
'
Announce35:
Data"R !$2 !$3 !$4 !$5 !$6 IF $14=1"
'
Announce36:
Data "R !$21 IF $239=1"