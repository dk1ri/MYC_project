'-----------------------------------------------------------------------
'name : homematic_RC8.bas
'Version V06.2, 202008013
'purpose : Programm for sending Homematic_IP signals with HMIP-MOD-RC8
'Can be used with hardware FS20_interface V03.3 by DK1RI (not with earlier versions)
'
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
'1..127:
Const I2c_address = 34
Const No_of_announcelines = 14
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 -> 0,56s
Const S_length = 32
'
'10MHz / 1024 / 977 = 10  Hz -> 100ms
'stop for Timer1
Const T_factor = 977
Const T_Short = 1
'0,1 s
Const T_long = 6
'0.6 s
'----------------------------------------------------
$include "__use.bas"
$include "common_1.11\_Constants_and_variables.bas"
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
'
$initmicro
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
'check timer
If Timer1 > T_factor Then
   Timer1 = 0
   Incr Kk
   If Kk > K Then Gosub Switch_off
End If
'
' check success
If Sts_ = 1 Then
   ' command started, wait for ok/nok
   Check_success = 1
Else
   If Check_success = 1 Then
      ' check ok/nok
      If Str_ = 1 Then Transmit_error = 1
      If Str_ = 0 And Stg_ = 1 Then Transmit_error = 0
         Check_success = 0
   ' else
      ' do nothing
   End If
End If
'
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
'----------------------------------------------------
'
_init_micro:
' Circuit diagram: INA - INH
' isolation required
Config PortA = Output
'
Config Sp_ = Input
Config Tp_ = Input
Config Up_ = Input
Config Vp_ = Input
Config Wp_ = Input
Config Xp_ = Input
Config Yp_ = Input
Config Zp_ = Input
Return
'
Switch_on:
   Select Case Switch
      Case 1
         Set Porta.0
      Case 2
         Set Porta.1
      Case 3
         Set Porta.2
      Case 4
         Set Porta.3
      Case 5
         Set Porta.4
      Case 6
         Set Porta.5
      Case 7
         Set Porta.6
      Case 8
         Set Porta.7
   End Select
   If Kanal_mode < 2 Then
      Start Timer1
      Busy = 1
   End If
Return
'
Switch_off:
   PortA = 0
   Stop Timer1
   Timer1 = 0
   Kk = 0
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