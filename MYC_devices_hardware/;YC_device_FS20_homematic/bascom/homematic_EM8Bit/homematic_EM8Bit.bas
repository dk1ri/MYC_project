'-----------------------------------------------------------------------
'name : homematic_EM8Bit.bas
'Version V07.0, 20231001
'purpose : Programm for sending Homematic signal with HM-MOD-EM8Bit
'Can be used with hardware homematic_interface V01.1 by DK1RI
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
$crystal = 10000000
$include "common_1.13\_Processor.bas"
'
'----------------------------------------------------
'
'1..127:
Const I2c_address = 36
Const No_of_announcelines = 10
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 -> 0,56s
Const S_length = 32
'
'stop for Timer1
Const T_factor = 1953
Const T_Short = 2
'0,2s
Const T_long = 50
'5 s
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim K as Word
Dim Kk As Byte
Dim Switch As Byte
Dim Busy As Byte
Dim Kanal_mode As Byte
Dim Kanal_mode_eeram As Eram Byte
'0: 4 Kanal, 1: 8 Kanal
Dim Check_success As Byte
Dim Transmit_error As Byte
Dim Window_contact As Byte
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
' Circuit diagram: Out1 - Out8, V, W, X, Y
' voltage input, must be set to 0
Config PortA = Output
Porta = 0
Config PortB.0 = Output
Reset PortB.0
Config PortB.1 = Output
Reset PortB.1
Config PortB.2 = Output
Reset PortB.2
Config PortB.7 = Output
Reset PortB.7
' outputs set to 1 (inactive)
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
Config TA00 = Output
Set TA00
Config DU3 = Output
Set DU3
Config TA10 = Output
Set TA10
Config TA20 = Output
Set TA20

'
' inputs set pullup
Return
'
Switch_on:
   Select Case Switch
      Case 1
         Reset TA10
      Case 2
         Reset TA20
   End Select
   If Kanal_mode < 2 Then
      Start Timer1
      Busy = 1
   End If
Return
'
Switch_off:
   Set TA10
   Set TA20
   Stop Timer1
   Timer1 = 0
   Kk = 0
   Switch = 0
   Busy = 0
Return
'
Configuration:
stop Watchdog
Reset TA00
Waitms 200
Set TA00
Select Case Command_b(2)
   Case 1
      Reset TA10
      Waitms 200
      Set TA10
   Case 1
      Reset TA20
      Waitms 200
      Set TA20
   Case 1
      Reset DU3
      Waitms 200
      Set DU3
End Select
Start Watchdog
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