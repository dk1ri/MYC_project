'-----------------------------------------------------------------------
'name : electronic_load.bas
'Version V01.0, 20160117
'purpose : Programm for control a electronic load
'Can be used with hardware electronic_load V01.0 by DK1RI
'This version is designed for 30A and 100V per  FET (full range of ADC input : 2,56V)
'The Programm supports the MYC protocol
'
'micro :  mega16
'Fuse Bits :
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
'JTAG disabled
'commercial addon needed : no
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no older rights are affected, this programm can be used
'under GPL (Gnu public licence)
'-----------------------------------------------------------------------
'Templates:
'I2c_slave_template V02.0
'-----------------------------------------------------------------------
'Used Hardware:
' I/O: I2C, RS232, SPI
' Inputs:
' ADC Inputs:all,
' Outputs :
'
'-----------------------------------------------------------------------
' For announcements and rules see Data section at the end
' Interface to MYC commandrouter via I2C or RS232
' Device is I2C slave
'-----------------------------------------------------------------------
'Missing/errors:
'
'Calibration necessary ?
'----------------------------------------------------------------------
$regfile = "m644pdef.dat"                                   ' for ATmega 328
$crystal = 20000000                                         ' used crystal frequency
'$baud = 19200                                               ' use baud rate
$hwstack = 32                                               ' default use 32 for the hardware stack                            ' generated. Take care that the chip supports all fuse bytes.
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space
' Simulation!!!!
' $sim
'
'**************** libs
'use byte library for smaller code
$lib "mcsbyte.lbx"
$lib "i2c_twi.lbx"
'
'**************** Variables
Const Lf = 10
Const Stringlength = 254                                    'that is maximum
Const Const Command_length = 20
Const Cmd_watchdog_time = 65000                             'Number of main loop before command reset
Const No_of_announcelines = 20                              'announcements start with 0 -> minus 1
Const Referenzfactor_u = 1000 / 1024                        '10 bit AD converter, full scale means 1000 steps per 0,1 V   -> 100V
Const Referenzfactor_i = 3000 / 1024                        'full scale means 3000 steps per 10mA (per FET)  -> 30A
Const Minimum_voltage = 10                                  'will not work below 1V
Const On_off_time = 3000                                    '1 sec
'
Dim First_set As Eram Byte                                 'first run after reset
Dim L As Byte                                               'Temps and local
Dim Tempb As Byte
Dim Tempc As Byte
Dim Tempd As Byte
Dim Temp_w As Word
Dim Temp_dw As Dword
Dim Temp_dw_b1 As Byte At Temp_dw Overlay
Dim Temp_dw_b2 As Byte At Temp_dw +1 Overlay
Dim Temp_dw_b3 As Byte At Temp_dw +2 Overlay
Dim Temp_dw_b4 As Byte At Temp_dw +3 Overlay
Dim Temp_single As Single
Dim Temps As String * 20
Dim A As Byte
Dim Temps_b(20) As Byte At Temps Overlay
Dim Announceline As Byte                                    'notifier for multiple announcelines
Dim A_line As Byte                                          'actual announline
Dim Dev_name As String * 20
Dim Dev_name_eeram As Eram String * 20
Dim Dev_name_b(20) As Byte At Dev_name Overlay
Dim Dev_number As Byte
Dim Dev_number_eeram As Eram Byte
Dim Adress As Byte                                          'I2C adress
Dim Adress_eeram As Eram Byte                              'I2C Buffer
Dim I2c_tx As String * Stringlength
Dim I2c_tx_b(stringlength) As Byte At I2c_tx Overlay
Dim I2c_pointer As Byte
Dim I2c_length As Byte
Dim Command As String * Stringlength                        'Command Buffer
Dim Command_b(stringlength) As Byte At Command Overlay
Dim Commandpointer As Byte
Dim Command_no As Byte
Dim Twi_status As Byte                                      'HW I2C
Dim Twi_control As Byte
Dim Last_error As String * 30                               'Error Buffer
Dim Last_error_b(30) As Byte At Last_error Overlay
Dim Error_no As Byte
Dim Cmd_watchdog As Word
Dim I2C_name As Byte
Dim I2C_name_eeram As Eram Byte                            'Watchdog notifier
Dim Command_mode As Bit
'
' for load:
Dim Fet_number As Byte
Dim Voltage As Word                                         '0 to 1000   -> 0 to 100,0V
Dim Current(7) As Word                                      '0 to 21000  -> 0 to 210.00A
Dim Current_temp As Word
Dim All_power As Dword                                      '0 to 21 000 000 -> 0 to 21000,000W  -> mW
Dim Power_temp As Dword
Dim Power_(7) As Dword                                      '0 to 3 000 000  -> 0 to 3000,000W
Dim Resistor As Dword                                       '0 to 1 000 000 -> 0 to 10000,00 Ohm
Dim Fet_voltage(7) As Word
Dim Fet_voltage_temp As Word
Dim Fet_voltage_adder As Word
Dim Required_r As Dword
Dim Required_r_b1 As Byte At Required_r Overlay
Dim Required_r_b2 As Byte At Required_r +1 Overlay
Dim Required_r_b3 As Byte At Required_r +2 Overlay
Dim Required_r_b4 As Byte At Required_r +3 Overlay
Dim Required_p As Word
Dim Required_p_b1 As Byte At Required_p Overlay
Dim Required_p_b2 As Byte At Required_p +1 Overlay
Dim Max_power As Byte                                       'per FET
Dim Max_power_eeram As Eram Byte

Dim On_off_mode As Byte
Dim On_off_counter As Word
Dim Number_of_fets As Byte
Dim Number_of_fets_eeram As Eram Byte
Dim R_or_p as Byte                                                   '0: check for R, 1: check for P, 2: not set
Dim Hysteresis As Byte
Dim On_off As Byte

'**************** Config / Init
Config PinB.1 = Input
PortB.1 = 1
Resetpin Alias PinB.1
Config PortB.0 = Output
Led1 Alias PortB.0
'
Config PortC.7 = Output
Fet1 Alias PortC.7
Config PortC.6 = Output
Fet2 Alias PortC.6
Config PortC.5 = Output
Fet3 Alias PortC.5
Config PortC.4 = Output
Fet4 Alias PortC.4
Config PortC.3 = Output
Fet5 Alias PortC.3
Config PortC.2 = Output
Fet6 Alias PortC.2
Config PortD.7 = Output
Fet7 Alias PortD.7
Config PortD.6 = Output
LDAC Alias PortD.6
'
Config Sda = Portc.4                                        'must !!, otherwise error
Config Scl = Portc.5
Config SPI = HARD , INTERRUPT = OFF , DATA_ORDER = MSB , MASTER = YES ,CLOCKRATE = 4
'
Config Adc = Single , Prescaler = Auto ,
'
Config Watchdog = 2048                                      '
'
'****************Interrupts
' not used
' Enable INTERRUPTS
' serialin not buffered!!
' serialout not buffered!!!
'
'**************** Main ***************************************************
'
If First_set <> 5 Then Gosub Reset_
'
If Resetpin = 0 Then Gosub Reset_
'
Gosub Init
'
Slave_loop:
Start Watchdog                                             'Loop must be less than 512 ms
'
Gosub Cmd_watch
'
Voltage = Getadc(1)
Temp_single = Voltage * Referenzfactor_u
Voltage = Temp_single                                       'real value in 0.1V steps
If Voltage < Minimum_voltage Then
   Fet_voltage_temp = 0                                     'switch off
   Gosub Send_to_fet
Else
   If On_off_mode = 0 Then
      Gosub Measure_u_i
      Gosub Modify_fet_voltage
   Else
      If On_off_counter < On_off_time Then
         If On_off = 1 Then                                 'on
            Gosub Measure_u_i                               'check overload
            If Power_(Fet_number) > Max_Power Then          'switch off
               Fet_voltage_temp = 0
               For Fet_number = 1 To 7
                  Gosub Send_to_fet
               Next Fet_number
               On_off_mode = 0
               On_off_counter = 0
               On_off = 0
            End If
         End If
      Else
         If On_off = 0 Then                                 'off -> switch on
            Set Led1
            On_off = 1
            For Fet_number = 1 To 7
               Fet_voltage_temp = Fet_voltage(Fet_number)
               Gosub Send_to_fet
            Next Fet_number
         Else                                               ' on -> switch off
            Reset Led1
            On_off = 0
            For Fet_number = 1 To 7
               Fet_voltage_temp = 0
               Gosub Send_to_fet
            Next Fet_number
         End If
         On_off_counter = 0
      End If
   End If
End If
Fet_number = Fet_number + 1
If Fet_number > Number_of_fets Then Fet_number = 1
'
'RS232 got data?
A = Ischarwaiting()
If A = 1 Then
   A = Waitkey()
   If Command_mode = 1 Then                                 'restart if i2cmode
      Command_mode = 0
      Gosub  Command_received
   End If
   If Commandpointer < Stringlength Then                    'If Buffer is full, chars are ignored !!
      Command_b(commandpointer) = A
      If Cmd_watchdog = 0 Then
         Cmd_watchdog = 1                                    'start watchdog
      End If
      Gosub Slave_commandparser
   End If
End If
'
'I2C
Twi_control = Twcr And &H80                                  'twint set?
If Twi_control = &H80 Then                                  'twsr 60 -> start, 80-> daten, A0 -> stop
   Twi_status = Twsr
   Twi_status = Twi_status And &HF8
'slave send:
   If Twi_status = &HA8 Or Twi_status = &HB8 Then
      If I2c_pointer <= I2c_length Then
         Twdr = I2c_tx_b(i2c_pointer)
         Incr I2c_pointer
      Else
         If Announceline <= No_of_announcelines Then        'multiple lines to send
            Cmd_watchdog = 0                                 'command may take longer
            A_line = Announceline
            Gosub Sub_restore
            Incr Announceline
            Twdr = I2c_tx_b(i2c_pointer)
            Incr I2c_pointer
         Else
            Announceline = 255
            TWDR=&H00
         End If                                             'for tests
      End If
   End If
'I2C receives data and and interpet as commands.
'slave receive:
   If Twi_status = &H80 Or Twi_status = &H88 Then
      If Command_mode = 0 Then                              'restart if rs232mode
         Command_mode = 1                                    'i2c mode
         Command = String(stringlength , 0)
         Commandpointer = 1
      End If
      Tempb = Twdr
      If Commandpointer <= Stringlength Then
         Command_b(commandpointer) = Tempb
         If Cmd_watchdog = 0 Then
            Cmd_watchdog = 1                                 'start watchdog
         End If
         Gosub Slave_commandparser
      End If
   End If
   Twcr = &B11000100
End If
Stop Watchdog
Goto Slave_loop
'
'===========================================
'
Reset_:
First_set = 5
Dev_number = 1                                               'unsigned , set at first use                                 'obviously not yet set
Dev_number_eeram = Dev_number                                'default values
Dev_name = "Device 1"
Dev_name_eeram = Dev_name
Adress = 21
Adress_eeram = Adress
I2C_name="1"
I2C_Name_eeram = I2C_name
Number_of_fets = 7
Number_of_fets_eeram = Number_of_fets
Max_power = 0
Max_power_eeram = Max_power_eeram
'
Return
'
Init:
Dev_number = Dev_number_eeram
Dev_name = Dev_name_eeram
Adress = Adress_eeram                                        'No Error
Cmd_watchdog = 0
Announceline = 255
Command_no = 1                                               'no multiple announcelines
I2c_tx = String(stringlength , 0)                           'will delete buffer and restart ponter
I2c_length = 0                                               'should not be 0 at any time
I2c_pointer = 1
Last_error = " No Error"
Error_no = 255
L = 0
Commandpointer = 1
SET Ldac
Number_of_fets = Number_of_fets_eeram
Max_power=Max_power_eeram
R_or_p = 2
Fet_number = 1
Fet_voltage_adder=1
Hysteresis = 2                                              ' for R or P
On_off_counter = 0
'
Gosub Command_received
Gosub Command_finished
Return
'
Cmd_watch:
'commands are expected as a string arriving in short time.
'this watchdog assures, that a wrong coomands will be deleted
If Cmd_watchdog > Cmd_watchdog_time Then                    'one loop without command finishes
   Error_no = 3
   Gosub Last_err
   Gosub Command_received                                   'reset commandinput
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
      Last_error = ":parameter error: "
End Select
Temps = Str(command_no)
Tempb = Len(temps)
Tempc = Len(last_error)
For Tempd = 1 To Tempb
   Incr Tempc
   Insertchar Last_error , Tempc , Temps_b(tempd)
Next Tempd
Error_no = 255
Return
'
Command_finished:
'i2c reset, only after error, at start and multiple announcements
'I2cinit                                                    'may be not neccessary
'Config Twi = 100000                                        ' 100KHz
Twsr = 0                                                    ' status und Prescaler auf 0
Twdr = &HFF                                                 ' default
Twar = Adress                                               ' Slaveadress
Twcr = &B01000100
Return
'
Command_received:
Commandpointer = 1
Command = String(stringlength , 0)                         'no multiple announcelines, if not finished
Cmd_watchdog = 0
Incr Command_no
Return
'
I2c_reset:
I2c_tx = String(stringlength , 0)                          'will delete buffer and restart ponter
I2c_pointer = 1
Return
'
Sub_restore:
Error_no = 255                                              'no error
I2c_tx = String(stringlength , 0)                          'will delete buffer , read appear 0 at end ???
I2c_pointer = 1
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
   Case Else
      Error_no = 0
      Gosub Last_err
End Select
If Error_no = 255 Then
   Read I2c_tx
   I2c_length = Len(i2c_tx)
   For Tempb = I2c_length To 1 Step -1                     'shift 1 pos right
      I2c_tx_b(tempb + 1) = I2c_tx_b(tempb)
   Next Tempb
   I2c_tx_b(1) = I2c_length
   Incr I2c_length                                         'complete length of string
End If
Return
'
Send_to_FET:
Select Case Fet_number
   Case 0
      Reset Fet1
   Case 1
      Reset Fet2
   Case 2
      Reset Fet3
   Case 3
      Reset Fet4
   Case 4
      Reset Fet5
   Case 5
      Reset Fet6
   Case 6
      Reset Fet7
End Select
Spiout Fet_voltage_temp ,2
Select Case Fet_number
   Case 0
      Set Fet1
   Case 1
      Set Fet2
   Case 2
      Set Fet3
   Case 3
      Set Fet4
   Case 4
      Set Fet5
   Case 5
      Set Fet6
   Case 6
      Set Fet7
End Select
Reset Ldac
Set Ldac
Return
'
Measure_u_i:
   Select Case Fet_number
      Case 1
         Current_temp = Getadc(2)
      Case 2
         Current_temp = Getadc(3)
      Case 3
         Current_temp = Getadc(4)
      Case 4
         Current_temp = Getadc(5)
      Case 5
         Current_temp = Getadc(6)
      Case 6
         Current_temp = Getadc(7)
      Case 7
         Current_temp = Getadc(8)
   End Select
   Temp_single = Current_temp * Referenzfactor_i
   Current_temp = Temp_single                               'real value in 0.10mA steps
   Current(Fet_number) = current_temp
   Power_(Fet_number) = Voltage * Current_temp
   Gosub Calculate_r_p
Return
'
Modify_fet_voltage:
   If Power_temp < Max_power Then
      Select case R_or_p
         Case 0                                             'R mode
            Temp_w =  Required_r - Hysteresis
            If Resistor < Temp_w Then                      'too low -> reduce fetvoltage
               Fet_voltage(Fet_number) = Fet_voltage(Fet_number) - Fet_voltage_adder
               Fet_voltage_temp = Fet_voltage(Fet_number)
               Gosub Send_to_fet
            Else
               Temp_w =  Required_r + Hysteresis
               If Resistor > Temp_w Then
                  Fet_voltage(Fet_number) = Fet_voltage(Fet_number) + Fet_voltage_adder
                  Fet_voltage_temp = Fet_voltage(Fet_number)
                  Gosub Send_to_fet
               End If
            End If
         Case 0
            Temp_w =  Required_p + Hysteresis                'P mode
            If All_power > Temp_w Then                      'too high -> reduce fetvoltage
               Fet_voltage(Fet_number) = Fet_voltage(Fet_number) - Fet_voltage_adder
               Fet_voltage_temp = Fet_voltage(Fet_number)
               Gosub Send_to_fet
            Else
               Temp_w =  Required_p - Hysteresis
               If All_power < Temp_w Then
                  Fet_voltage(Fet_number) = Fet_voltage(Fet_number) + Fet_voltage_adder
                  Fet_voltage_temp = Fet_voltage(Fet_number)
                  Gosub Send_to_fet
               End If
            End If
      End Select
   Else
      Fet_voltage(Fet_number) = Fet_voltage(Fet_number) - Fet_voltage_adder          'reduce power
   End If
Return
'
Calculate_r_p:
   Tempb = 1
   Temp_w = 0
   For Tempb = 1 To 7
      Temp_w = Temp_w + Current(Tempb)                         '* 10mA
   Next Tempb
   All_power = Voltage * Temp_w                                'mW                     '
   If Temp_w > 0 Then
      Temp_single = Voltage *1000                              '* 100V
      Temp_single =Temp_single / Temp_w
      Resistor = Temp_single                                   '* 10mOhm
   Else
      Resistor = &HFFFFFFFF
   End If
Return
'     '
Slave_commandparser:
   Select Case Command_b(1)
      Case 0
'Befehl &H00               basic annoumement wird gelesen
'                          basic announcement is read
'Data "0;m;DK1RI;electronic load;V01.0;1;120;14;20"
         A_line = 0
         Gosub Sub_restore
         Gosub Command_received
'
      Case 1
'Befehl &H01               lese aktuelle Spannung
'                          read actual voltage
'Data "1;aa,read actual voltage;b,[0 to 100]"
         If Command_mode = 0 Then
            Printbin Voltage
         Else
            I2c_tx = String(stringlength , 0)
            I2c_pointer = 1
            I2c_length = 2
            I2c_tx_b(1) = High(Voltage)
            I2c_tx_b(2) = Low(Voltage)
         End If
         Gosub Command_received
'
      Case 2
'Befehl &H02  0-6          liest aktuellen Strom
'                          read actual current
'Data "2;am,read actual current;L,[0 to 30,00];7"
         If Commandpointer = 2 Then
            If Command_b(2) < 7 Then
               Tempb= Command_b(2) + 1
               Temp_w = Current(Tempb)
               If Command_mode = 0 Then
                  Printbin Temp_w
               Else
                  I2c_tx = String(stringlength , 0)
                  I2c_pointer = 1
                  I2c_length = 2
                  I2c_tx_b(1) = High(Temp_w)
                  I2c_tx_b(2) = Low(Temp_w)
               End If
            Else
               Error_no = 4
               Gosub Last_err
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 3
'Befehl &H03  0-6          liest aktuelle Leistung
'                          read actual power
'Data "3;am,read actual power;L,[0 to 30000,00];7"
         If Commandpointer = 2 Then
            If Command_b(2) < 7 Then
               Tempb = Command_b(2) + 1
               Temp_dw = Power_(Tempb)
               If Command_mode = 0 Then
                  Printbin Temp_dw
               Else
                  I2c_tx = String(stringlength , 0)
                  I2c_pointer = 1
                  I2c_length = 4
                  I2c_tx_b(1) = Temp_dw_b4
                  I2c_tx_b(2) = Temp_dw_b3
                  I2c_tx_b(3) = Temp_dw_b2
                  I2c_tx_b(4) = Temp_dw_b1
               End If
            Else
               Error_no = 4
               Gosub Last_err
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 4
'Befehl &H04               lese aktuellen Widerstand
'                          read actual resistor
'Data "4;aa,read actual resistor;L,[0 to 10000,00]"
         If Command_mode = 0 Then
            Printbin Resistor
         Else
            Temp_dw = Resistor
            I2c_tx = String(stringlength , 0)
            I2c_pointer = 1
            I2c_length = 4
            I2c_tx_b(1) = Temp_dw_b4
            I2c_tx_b(2) = Temp_dw_b3
            I2c_tx_b(3) = Temp_dw_b2
            I2c_tx_b(4) = Temp_dw_b1
         End If
         Gosub Command_received
'
      Case 5
'Befehl &H05               gewuenschter Widerstand mOhm
'                          required resistor mOhm
'Data "5;oa,required resistor;L,mOhm"
         If Commandpointer = 5 Then
            If On_Off_mode = 0 Then
               Required_r_b4 = command_b(2)
               Required_r_b3 = command_b(3)
               Required_r_b2 = command_b(4)
               Required_r_b1 = command_b(5)
               R_or_p = 0
            Else
               Error_no = 4
               Gosub Last_err
            End If
         Else
            Incr Commandpointer
         End If
'
      Case 6
'Befehl &H06               gewuenschter Widerstand mOhm lesen
'                          read required resistor mOhm
'Data "6;aa,required resistor;L,mOhm"
         If Command_mode = 0 Then
            Printbin Required_r
         Else
            I2c_tx = String(stringlength , 0)
            I2c_pointer = 1
            I2c_length = 4
            I2c_tx_b(1) = Required_r_b4
            I2c_tx_b(2) = Required_r_b3
            I2c_tx_b(3) = Required_r_b2
            I2c_tx_b(4) = Required_r_b1
         End If
'
      Case 7
'Befehl &H07               gewuenschter Leistung (W)
'                          required power (W)
'Data "7;oa,required power;w,Watt"
         If Commandpointer = 3 Then
            If On_off_mode = 0 Then
               Required_p_b2 = command_b(2)
               Required_p_b1 = command_b(3)
               R_or_p = 1
            Else
               Error_no = 4
               Gosub Last_err
            End If
         Else
            Incr Commandpointer
         End If
'
      Case 8
'Befehl &H08               gewuenschter Leistung (W) lesen
'                          required power (W)
'Data "8;aa,required power;w,Watt"
         If Command_mode = 0 Then
            Printbin Required_p
         Else
            I2c_tx = String(stringlength , 0)
            I2c_pointer = 1
            I2c_length = 2
            I2c_tx_b(1) = Required_r_b2
            I2c_tx_b(2) = Required_r_b1
         End If
'
      Case 9
'Befehl &H09 0|1           Wechsellast schreiben
'                          write (start) on /off mode
'Data "9;oa,on off mode;a"
         If Commandpointer = 2 Then
            If Command_b(2) < 2 Then
               On_off_mode = Command_b(2)
               On_off_counter = 0
            Else
               Error_no = 4
               Gosub Last_err
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 10
'Befehl &H0A 0-256         Maximale Leistung pro Fet
'                          maximun power per FET
'Data "10;oa;maximum power per FET;b,Watt"
         If Commandpointer = 2 Then
            Max_power = Command_b(2)
            Max_power_eeram = Max_power
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 11
'Befehl &H0B               Maximale Leistung pro Fet lesen
'                          maximun power per FET
'Data "11;aa;maximum power per FET;b,Watt"
         If Command_mode = 0 Then
            Printbin Max_power
         Else
            I2c_tx = String(stringlength , 0)
            I2c_pointer = 1
            I2c_length = 1
            I2c_tx_b(1) = Max_power
         End If
'
      Case 12
'Befehl &H0C 0-6           Zahl der Fets
'                          number of FETS
'Data "12;oa,number of FETs;b,[1 to 7]"
         If Commandpointer = 2 Then
            If Command_b(2) < 7 Then
               Number_of_Fets = Command_b(2)
               Number_of_fets_eeram = Number_of_fets
            Else
               Error_no = 4
               Gosub Last_err
            End If
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 13
'Befehl &H0D               Zahl der Fets lesen
'                          read number of FETS
'Data "13;aa,number of FETs;b,[1 to 7]"
         If Command_mode = 0 Then
            Printbin Number_of_Fets
         Else
            I2c_tx = String(stringlength , 0)
            I2c_pointer = 1
            I2c_length = 1
            I2c_tx_b(1) = Number_of_Fets
         End If
'
      Case 240
'Befehl &HF0 0-13,
'            253,254 255   announcement aller Befehle lesen
'                          read announcement lines
'Data "240;am,ANNOUNCEMENTS;120;20"
         If Commandpointer = 2 Then
            Select Case Command_b(2)
               Case 253:
                  A_line = 19
                  Announceline = 20
                  Gosub Sub_restore
               Case 254
                  A_line = 0
                  Announceline = 1
                  Gosub Sub_restore
               Case 255                                    'so more lines will be transmitted
                  A_line = 0
                  Gosub Sub_restore
               Case  Is < No_of_announcelines
                  A_line = Command_b(2)
                  Gosub Sub_restore
               Case Else
                  Error_no = 0
                  Gosub Last_err
            End Select
            Gosub Command_received
         Else
            Incr Commandpointer
         End If
'
      Case 252
'Befehl &HFC               Liest letzen Fehler
'                          read last error
'Data "252;aa,LAST ERROR;20,last_error"
         I2c_tx = String(stringlength , 0)                 'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = 1                                   'so 1st byte <> 0!!
         Temps = Str(command_no)
         I2c_length = Len(temps)
         For Tempb = 1 To I2c_length                       'leave space for length
            I2c_tx_b(tempb + 1) = Temps_b(tempb)
         Next Tempb
         Incr I2c_length                                   'because of 1 byte with length
         Tempb = Len(last_error)
         For Tempc = 1 To Tempb
            Tempd = Tempc + I2c_length                     'write at the end
            I2c_tx_b(tempd) = Last_error_b(tempc)
         Next Tempc
         I2c_length = Tempd                                'last tempd is length
         Decr Tempd
         I2c_tx_b(1) = Tempd
         Gosub Command_received
'
       Case 253
'Befehl &HFD               geraet aktiv antwort
'                          Life signal
'Data "253;aa,MYC INFO;b,&H04,BUSY"
         I2c_tx = String(stringlength , 0)                'will delete buffer and restart ponter
         I2c_pointer = 1
         I2c_tx_b(1) = 4                                   'no info
         I2c_length = 1
         Gosub Command_received
'
      Case 254
'Befehl &HFE <n> <n>       Individualisierung schreiben
'                          write indivdualization
'Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,21"
         If Commandpointer >= 2 Then
            Select Case Command_b(2)
               Case 0
                  If Commandpointer = 2 Then
                     Incr Commandpointer
                  Else
                     If Commandpointer = 3 Then
                        L = Command_b(3)
                        If L = 0 Then
                           Gosub Command_received
                        Else
                           If L > 20 Then L = 20
                           L = L + 3
                           Incr Commandpointer
                        End If
                     Else
                        If Commandpointer = L Then
                           Dev_name = String(20 , 0)
                           For Tempb = 4 To L
                              Dev_name_b(tempb -3) = Command_b(tempb)
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
                  If Commandpointer < 4 Then
                     Incr Commandpointer
                  Else                                    'as per announcement: 1 byte string
                     I2C_name = Command_b(4)
                     i2C_name_eeram=I2C_name
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
                     Gosub Last_err
                     End If
                     Gosub Command_received
                  Else
                     Incr Commandpointer
                  End If
               Case Else
                  Error_no = 0
                  Gosub Last_err
            End Select
         Else
           Incr Commandpointer
         End If
'
      Case 255
'Befehl &HFF <n>           Individualisierung lesen
'                          read indivdualization
'Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,5;1,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;1,USB,1"
        If Commandpointer = 2 Then
            I2c_tx = String(stringlength , 0)             'delete buffer and restart ponter
            I2c_pointer = 1
            Select Case Command_b(2)
               Case 0
                  I2c_length = Len(dev_name)
                  I2c_tx_b(1) = I2c_length
                  For Tempb = 1 To I2c_length
                     I2c_tx_b(tempb + 1) = Dev_name_b(tempb)
                  Next Tempb
                  Incr I2c_length
               Case 1
                  I2c_tx_b(1) = Dev_number
                  I2c_length = 2
               Case 2
                  I2C_tx="{001}"
                  I2C_tx_b(2) = I2C_name
                  I2c_length = 2
               Case 3
                  Tempb = Adress / 2
                  I2c_tx_b(1) = Tempb
                  I2c_length = 1
               Case Else
                  Error_no = 0                             'ignore anything else
                  Gosub Last_err
            End Select
            Gosub Command_received
         Else
               Incr Commandpointer
         End If
'
      Case Else
         Error_no = 0                                      'ignore anything else
         Gosub Last_err
      End Select
Return
'
'==================================================
'
End
'
'announce text
'
Announce0:
'Befehl &H00               basic annoumement wird gelesen
'                          basic announcement is read
Data "0;m;DK1RI;electronic load;V01.0;1;120;14;20"
'
Announce1:
'Befehl &H01               lese aktuelle Spannung
'                          read actual voltage
Data "1;aa,read actual voltage;b,[0 to 100]"
'
Announce2:
'Befehl &H02  0-6          liest aktuellen Strom
'                          read actual current
Data "2;am,read actual current;L,[0 to 30,00];7"
'
Announce3:
'Befehl &H03  0-6          liest aktuelle Leistung
'                          read actual power
Data "3;am,read actual power;L,[0 to 30000,00];7"
'
Announce4:
'Befehl &H04               lese aktuellen Widerstand
'                          read actual resistor
Data "4;aa,read actual resistor;L,[0 to 10000,00]"
'
Announce5:
'Befehl &H05               gewuenschter Widerstand mOhm
'                          required resistor mOhm
Data "5;oa,required resistor;L,mOhm"
'
Announce6:
'Befehl &H06               gewuenschter Widerstand mOhm lesen
'                          read required resistor mOhm
Data "6;aa,required resistor;L,mOhm"

Announce7:
'Befehl &H07               gewuenschter Leistung (W)
'                          required power (W)
Data "7;oa,required power;w,Watt"
'
Announce8:
'Befehl &H08               gewuenschter Leistung (W) lesen
'                          required power (W)
Data "8;aa,required power;w,Watt"
'
Announce9:
'Befehl &H09 0|1           Wechsellast schreiben
'                          write (start) on /off mode
Data "9;oa,on off mode;a"
'
Announce10:
'Befehl &H0A 0-256         Maximale Leistung pro Fet
'                          maximun power per FET
Data "10;oa;maximum power per FET;b,Watt"
'
Announce11:
'Befehl &H0B               Maximale Leistung pro Fet lesen
'                          maximun power per FET
Data "11;aa;maximum power per FET;b,Watt"
'
Announce12:
'Befehl &H0C 0-6           Zahl der Fets
'                          number of FETS
Data "12;oa,number of FETs;b,[1 to 7]"
'
Announce13:
'Befehl &H0D               Zahl der Fets lesen
'                          read number of FETS
Data "13;aa,number of FETs;b,[1 to 7]"
'
Announce14:
'Befehl &HF0 0-13,
'            253,254 255   announcement aller Befehle lesen
'                          read announcement lines
Data "240;am,ANNOUNCEMENTS;120;20"
'
Announce15:
'Befehl &HFC               Liest letzen Fehler
'                          read last error
Data "252;aa,LAST ERROR;20,last_error"
'
Announce16:
'Befehl &HFD               geraet aktiv antwort
'                          Life signal
Data "253;aa,MYC INFO;b,&H04,BUSY"
'
Announce17:
'Befehl &HFE <n> <n>       Individualisierung schreiben
'                          write indivdualization
Data "254;oa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,21"
'
Announce18:
'Befehl &HFF <n>           Individualisierung lesen
'                          read indivdualization
Data "255;aa,INDIVIDUALIZATION;20,NAME,Device 1;b,NUMBER,1;1,I2C,1;b,ADRESS,5;1,RS232,1;b,BAUDRATE,0,{19200};3,NUMBER_OF_BITS,8n1;1,USB,1"
'
Announce19:
Data"R !$5 !$7 IF $9=1"