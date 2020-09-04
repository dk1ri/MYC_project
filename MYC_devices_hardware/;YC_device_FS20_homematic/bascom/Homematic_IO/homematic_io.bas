'name : homematic_io.bas
'Version V06.2, 202008017
'purpose : Programm for receiving homematic Signals
'Can be used with hardware FS20_interface V03.3 by DK1RI (not with earlier veesions)
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory common_1.11 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.11\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
'-----------------------------------------------------
' Inputs /Outputs : see file __config
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
' Detailed description
'
'----------------------------------------------------
$regfile = "m1284pdef.dat"
'for ATMega1284
'
'-----------------------------------------------------
$crystal = 10000000
$include "common_1.11\_Processor.bas"
'
'----------------------------------------------------
'
Const Command_is_2_byte = 0
'1..127
Const I2c_address = 26
Const No_of_announcelines = 13
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'20MHz / 1024 / 1953 = 10  Hz -> 100ms
'stop for Timer1
Const T_factor = 1953
Const T_Short = 1
'0,1 s
Const T_long = 6
'0.6 s
'
Const Pwm_time = 1024
'----------------------------------------------------
$include "__use.bas"
$include "common_1.11\_Constants_and_variables.bas"
'
Dim K as Word
Dim Kk As Byte
Dim Hmode As Byte
' on /off (default, 1: Toggle, 2: Status
Dim Hmode_eeram As Eram Byte
Dim Switch As Byte
Dim Analog_out(4) As Word
Dim Switch_status_old1 As Byte
Dim Switch_status_old2 As Byte
Dim Switch_status_old3 As Byte
Dim Switch_status_old4 As Byte
Dim Switch_status_old5 As Byte
Dim Switch_status_old6 As Byte
Dim Switch_status_old7 As Byte
Dim Switch_status_old8 As Byte
Dim Busy As Byte
'
$initmicro
'
'----------------------------------------------------
$include "common_1.11\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.11\_Config.bas"
'
'----------------------------------------------------
' procedures at start
'
'----------------------------------------------------
$include "common_1.11\_Main.bas"
'
'----------------------------------------------------
$include "common_1.11\_Loop_start.bas"
'
'----------------------------------------------------
'
Gosub Check_input_status
'
'check timer
If Timer1 > T_factor Then
   Timer1 = 0
   Incr Kk
   If Kk > K Then Gosub Switch_off
End If
'
If Timer3 > Pwm_time Then
   ' next cycle
   Timer3 =  0
   If Analog_out(1) > 0 Then Set Analog1
   If Analog_out(2) > 0 Then Set Analog2
   If Analog_out(3) > 0 Then Set Analog3
   If Analog_out(4) > 0 Then Set Analog4
Else
   If Timer3 >= Analog_out(1) Then Reset Analog1
   If Timer3 >= Analog_out(2) Then Reset Analog2
   If Timer3 >= Analog_out(3) Then Reset Analog3
   If Timer3 >= Analog_out(4) Then Reset Analog4
'
End If
'
$include "common_1.11\_Main_end.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.11\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.11\_Init.bas"
'
'----------------------------------------------------
$include "common_1.11\_Subs.bas"
'
_init_micro:
Config S_ = Output
S_ = 0
Config T_ = Output
T_ = 0
Config U_ = Output
U_ = 0
Config V_ = Output
V_ = 0
Config W_ = Output
W_ = 0
Config X_ = Output
X_ = 0
Config Y_ = Output
Y_ = 0
Config Z_ = Output
Z_ = 0
Return
'
Check_input_status:
'This will not interrupt the F0 command
If Number_of_lines > 0 Then Return
B_temp2 = Not Sch1
If Switch_status_old1 <> B_temp2 Then
   Tx_b(2) = 1
   Switch_status_old1 = B_temp2
   Gosub status_changed
Else
   B_temp2 = Not Sch2
   If Switch_status_old2 <> B_temp2 Then
      Tx_b(2) = 2
      Switch_status_old2 = B_temp2
      Gosub Status_changed
   Else
      B_temp2 = Not Sch3
      If Switch_status_old3 <> B_temp2 Then
         Tx_b(2) = 3
         Switch_status_old3 = B_temp2
         Gosub Status_changed
      Else
         B_temp2 = Not Sch4
         If Switch_status_old4 <> B_temp2 Then
            Tx_b(2) = 4
            Switch_status_old4 = B_temp2
            Gosub Status_changed
         Else
            B_temp2 = Not Sch5
            If Switch_status_old5 <> B_temp2 Then
               Tx_b(2) = 5
               Switch_status_old5 = B_temp2
               Gosub Status_changed
            Else
               B_temp2 = Not Sch6
               If Switch_status_old6 <> B_temp2 Then
                  Tx_b(2) = 6
                  Switch_status_old6 = B_temp2
                  Gosub status_changed
               Else
                  B_temp2 = Not Sch7
                  If Switch_status_old7 <> B_temp2 Then
                     Tx_b(2) = 7
                     Switch_status_old7 = B_temp2
                     Gosub Status_changed
                  Else
                     B_temp2 = Not Sch8
                     If Switch_status_old8 <> B_temp2 Then
                        Tx_b(2) = 8
                        Switch_status_old8 = B_temp2
                        Gosub Status_changed
                     End If
                  End If
               End If
            End If
         End If
      End If
   End If
End If
Return
'
Status_changed:
Tx_b(1) = &H01
Tx_b(3) = B_temp2
Tx_write_pointer = 4
If Command_mode = 1 Then Gosub Print_tx
Return
'
Switch_on:
   Select Case Switch
      Case 1
         Reset D1
      Case 2
         Reset D2
      Case 3
         Reset D3
      Case 4
         Reset D4
   End Select
   Start Timer1
   Busy = 1
Return
'
Switch_off:
   Stop Timer1
   Timer1 = 0
   Kk = 0
   D1 = 1
   D2 = 1
   D3 = 1
   D4 = 1
   Switch = 0
   Busy = 0
Return
'
'----------------------------------------------------
$include "_Commands.bas"
$include "common_1.11\_Commands_required.bas"
'
$include "common_1.11\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'