'name : sprachausgabe.bas
'Version V04.1 20200823
'purpose : Play 10 voice/music amples from ELV MSM4 module
'This Programm workes as I2C slave or using RS232
'Can be used with  sprachausgabe Version V02.0 by DK1RI
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
' Inputs / Outputs : see file __config.bas
'
' MSM4 Modul input voltage must not exceed 3.3V! -> use open collector!
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
$regfile = "m88pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.11\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 20
Const No_of_announcelines = 9
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.11\_Constants_and_variables.bas"
'
'20MHz / 1024 / 2500 = 7,8  Hz -> 128ms
Const T_Short = 2500
'
'20MHz / 1024 / 60000 = 0,325Hz -> 3,2s
Const T_long = 60000
'
'20MHz / 1024 / 64500 / 4 = 0,078Hz -> 13,2s
Const T_10s = 64500
'
Dim Time_ As Word
Dim Voicea As Byte
Dim Voiceb As Byte
Dim Time2 As Byte
Dim Config_at_start As Byte
'
$initmicro
'----------------------------------------------------
$include "common_1.11\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.11\_Config.bas"
'
'----------------------------------------------------
$include "common_1.11\_Main.bas"
'
Wait 1
'----------------------------------------------------
$include "common_1.11\_Loop_start.bas"
'
'----------------------------------------------------
'check timer
If Time_ > 0 Then
   If Timer1 >= Time_ Then
      If Time2 = 0 Then
         Gosub Control_sound_off
      Else
         If Time2 = 1 Then
            Gosub Control_sound_off
            If Config_at_start = 2 Then
               'set normal mode (2+3)
               Time_ = T_10s
               Time2 = 5
               Voicea = 2
               Voiceb = 3
               Gosub Control_sound
               Decr Config_at_start
            Else
               Config_at_start = 0
            End If
         Else
            Timer1 = 0
            Decr Time2
         End If
      End If
   End If
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
'----------------------------------------------------
_init_micro:
Voice1 Alias PortC.0
Reset Voice1
Config Voice1 = Input
'
Voice2 Alias PortC.1
Reset Voice2
Config Voice2 = Input
'
Voice3 Alias PortB.0
Reset Voice3
Config Voice3 = Input
'
Voice4 Alias PortB.1
Reset Voice4
Config Voice4 = Input
'
Voice5 Alias PortD.2
Reset Voice5
Config Voice5 = Input
'
Voice6 Alias PortD.3
Reset Voice6
Config Voice6 = Input
'
Voice7 Alias PortD.4
Reset Voice7
Config Voice2 = Input
'
Voice8 Alias PortD.7
Reset Voice8
Config Voice8 = Input
'
Voice9 Alias PortD.6
Reset Voice9
Config Voice9 = Input
'
Voice10 Alias PortD.5
Reset Voice10
Config Voice10 = Input
Return
'
Control_sound:
' DDR = 0 -> Input with pllup - > high
Start Timer1
Select Case Voicea
   Case 1
      Config Voice1 = Output
   Case 2
      Config Voice2 = Output
   Case 3
      Config Voice3 = Output
   Case 4
      Config Voice4 = Output
   Case 5
      Config Voice5 = Output
   Case 6
      Config Voice6 = Output
   Case 7
      Config Voice7 = Output
   Case 8
      Config Voice8 = Output
   Case 9
      Config Voice9 = Output
   Case 10
      Config Voice10 = Output
End Select
Select Case Voiceb
   Case 0
      NOP
   Case 1
      Config Voice1 = Output
   Case 2
      Config Voice2 = Output
   Case 3
      Config Voice3 = Output
   Case 4
      Config Voice4 = Output
   Case 5
      Config Voice5 = Output
   Case 6
      Config Voice6 = Output
   Case 7
      Config Voice7 = Output
   Case 8
      Config Voice8 = Output
   Case 9
      Config Voice9 = Output
   Case 10
      Config Voice10 = Output
   End Select
Return
'
Control_sound_off:
'DDR to input
Stop Timer1
Timer1 = 0
Time_ = 0
Time2 = 0
Voicea = 0
Voiceb = 0
' Set to Input
Config Voice1 = Input
Config Voice2 = Input
Config Voice3 = Input
Config Voice4 = Input
Config Voice5 = Input
Config Voice6 = Input
Config Voice7 = Input
Config Voice8 = Input
Config Voice9 = Input
Config Voice10 = Input
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