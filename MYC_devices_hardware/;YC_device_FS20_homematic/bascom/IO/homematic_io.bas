'name : homematic_io.bas
'Version V06.2, 20231002
'purpose : Programm for interfacing to HMIP-MIO16 board
'Can be used with hardware FS20_interface V01.1 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory common_1.13 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.13\_Introduction_master_copyright.bas"
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
$crystal = 20000000
$include "common_1.13\_Processor.bas"
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
Const T_Short = 2
'0,2 s
Const T_long = 6
'0.6 s
'
Const Pwm_time = 1024
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim K as Word
Dim Kk As Byte
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
Dim Last_switch As Byte
Dim Last_status As Byte
'
$initmicro
'
'----------------------------------------------------
$include "common_1.13\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.13\_Config.bas"
'
'----------------------------------------------------
' procedures at start
'
'----------------------------------------------------
$include "common_1.13\_Main.bas"
'
'----------------------------------------------------
$include "common_1.13\_Loop_start.bas"
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
$include "common_1.13\_Main_end.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.13\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.13\_Init.bas"
'
'----------------------------------------------------
$include "common_1.13\_Subs.bas"
'
_init_micro:
Return
'
Check_input_status:
'This will not interrupt the F0 command
If Number_of_lines > 0 Then Return
B_temp1 = Not Out1
If Switch_status_old1 <> B_temp1 Then
   Last_switch = 1
   Last_status = B_temp1
   Switch_status_old1 = B_temp1
   Gosub status_changed
Else
   B_temp1 = Not Out2
   If Switch_status_old2 <> B_temp1 Then
      Last_switch = 2
      Last_status = B_temp1
      Switch_status_old2 = B_temp1
      Gosub Status_changed
   Else
      B_temp1 = Not Out3
      If Switch_status_old3 <> B_temp1 Then
         Last_switch = 3
         Last_status = B_temp1
         Switch_status_old3 = B_temp1
         Gosub Status_changed
      Else
         B_temp1 = Not Out4
         If Switch_status_old4 <> B_temp1 Then
            Last_switch = 4
            Last_status = B_temp1
            Switch_status_old4 = B_temp1
            Gosub Status_changed
         Else
            B_temp1 = Not Out5
            If Switch_status_old5 <> B_temp1 Then
               Last_switch = 5
               Last_status = B_temp1
               Switch_status_old5 = B_temp1
               Gosub Status_changed
            Else
               B_temp1 = Not Out6
               If Switch_status_old6 <> B_temp1 Then
                  Last_switch = 6
                  Last_status = B_temp1
                  Switch_status_old6 = B_temp1
                  Gosub status_changed
               Else
                  B_temp1 = Not Out7
                  If Switch_status_old7 <> B_temp1 Then
                     Last_switch = 7
                     Last_status = B_temp1
                     Switch_status_old7 = B_temp1
                     Gosub Status_changed
                  Else
                     B_temp1 = Not Out8
                     If Switch_status_old8 <> B_temp1 Then
                        Last_switch = 8
                        Last_status = B_temp1
                        Switch_status_old8 = B_temp1
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
Tx_b(1) = &H06
Tx_b(2) = 2
Tx_b(3) = Last_switch + &H30
Tx_b(4) = Last_status + &H30
Tx_write_pointer = 5
If Command_mode = 1 Then Gosub Print_tx
Return
'
Switch_on:
   Select Case Switch
      Case 1
         Reset Digital1
      Case 2
         Reset Digital2
      Case 3
         Reset Digital3
      Case 4
         Reset Digital4
   End Select
   Start Timer1
   Busy = 1
Return
'
Switch_off:
   Stop Timer1
   Timer1 = 0
   Kk = 0
   Set Digital1
   Set Digital2
   Set Digital3
   Set Digital4
   Switch = 0
   Busy = 0
Return
'
'----------------------------------------------------
$include "_Commands.bas"
$include "common_1.13\_Commands_required.bas"
'
$include "common_1.13\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'