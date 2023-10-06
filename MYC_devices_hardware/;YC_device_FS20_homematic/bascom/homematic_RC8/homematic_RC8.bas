'-----------------------------------------------------------------------
'name : homematic_RC8.bas
'Version V07.0, 202300929
'purpose : Programm for sending Homematic signals with HMIP-MOD-RC8
'Can be used with hardware FS20_interface V01.1 by DK1RI
'
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
'1..127:
Const I2c_address = 34
Const No_of_announcelines = 8
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 -> 0,56s
Const S_length = 32
'
'stop for Timer1
Const T_factor = 1953
Const T_Short = 2
'0,2s
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim K as Word
Dim Kk As Byte
Dim Switch As Byte
Dim Busy As Byte
Dim Transmit_error As Byte
'
$initmicro
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
'check timer
If Timer1 > T_factor Then
   Timer1 = 0
   Incr Kk
   If Kk > K Then Gosub Switch_off
End If
'
' check success
If Stg_ = 1 Then Transmit_error = 1
If Str_ = 1 Then Transmit_error = 2
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
' Circuit diagram: Out1 - Out8, V
' voltage input, must be set to 0
Config PortA = Output
Porta = 0
Config PortB.7 = Output
PortB.7 = 0
'
Config Ta1 = Output
Set TA1
Config Ta2 = Output
Set TA2
Config Ta3 = Output
Set TA3
Config Ta4 = Output
Set TA4
Config TA5= Output
Set TA5
Config Ta6 = Output
Set TA6
Set PortD.7
Config Ta8 = Output
Set TA8
'others as input ok
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
   Set Ta1
   Set Ta2
   Set Ta3
   Set Ta4
   Set Ta5
   Set Ta6
   Set Ta7
   Set Ta8
   Stop Timer1
   Timer1 = 0
   Kk = 0
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