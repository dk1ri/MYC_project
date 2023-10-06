'name : homematic_OC8.bas
'Version V07.0, 20231001
'purpose : Programm for receiving Homematic signal with HM-MOD-OC8 or HmIP-MOD-OC8
'Can be used with hardware homematic_interface V01.1 by DK1RI
'
'This firmware isr identical to the HmIP-MOD-RE8 Firmware, but this have the learn function
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
'1..127:
Const I2c_address = 25
Const No_of_announcelines = 12
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
Const T_factor = 1953
Const T_Short = 2
'0,2s
Const T_long = 50
'5 s
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim Switch As Byte
Dim K as Word
Dim Kk As Byte
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
'----------------------------------------------------
'
_init_micro:
Config TA1 = output
Set TA1
Config TA2 = output
Set TA2
Config TA3 = output
Set TA3
Config TA4 = output
Set TA4
Config TA5 = output
Set TA5
Config TA6 = output
Set TA6
Config TA7 = output
Set TA7
Config TA8 = output
Set TA8
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
      Case 0:
         Reset Ta1
      Case 1:
         Reset Ta2
      Case 2:
         Reset Ta3
      Case 3:
         Reset Ta4
      Case 4:
         Reset Ta5
      Case 5:
         Reset Ta6
      Case 6:
         Reset Ta7
      Case 7:
         Reset Ta8
   End Select
   Start Timer1
   Busy = 1
Return
'
Switch_off:
   Stop Timer1
   Timer1 = 0
   Kk = 0
   Porta = &HFF
   Switch = 0
   Busy = 0
Return
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