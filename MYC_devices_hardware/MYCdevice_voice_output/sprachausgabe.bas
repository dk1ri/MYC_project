'name : sprachausgabe.bas
'Version V05.0 20230725
'purpose : Play 10 voice/music amples from ELV MSM4 module
'This Programm workes as I2C slave or using RS232
'Can be used with  sprachausgabe Version V02.0 by DK1RI
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
$include "common_1.13\_Processor.bas"
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
$include "common_1.13\_Constants_and_variables.bas"
'
'20MHz / 1024 / 2500 = 3.9  Hz -> 254ms (should be < 2s)
Const T_Short = 5000
'
'20MHz / 1024 / 50000 = 0,39Hz -> 2.5s  (should be 2 2s)
Const T_long = 50000
'
'20MHz / 1024 / 65500 = 0,298Hz -> 3.35s
Const T_10s = 65500
'
Dim Time_ As Word
Dim Voicea As Byte
Dim Voiceb As Byte
Dim Config_at_start As Byte
Dim 10s_loops As Byte
'
$initmicro
Wait 3
'----------------------------------------------------
$include "common_1.13\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.13\_Config.bas"
'
'----------------------------------------------------
$include "common_1.13\_Main.bas"
'
'----------------------------------------------------
$include "common_1.13\_Loop_start.bas"
'
'----------------------------------------------------
'check timer
If Time_ > 0 Then
   If Timer1 >= Time_ Then
      If 10s_loops > 1 Then
         ' at init or change mode
         Timer1 = 0
         Decr 10s_loops
      Else
         If Config_at_start = 0 Then
             ' short long or 10s
             Gosub Control_sound_off
         Else
            If Config_at_start = 2 Then
               Gosub Control_sound_off
               ' set normal mode (2+3)
               Time_ = T_10s
               10s_loops = 5
               Voicea = 2
               Voiceb = 3
               Gosub Control_sound
               Decr Config_at_start
            Else
               ' Config_at_start = 1 -> init finished
               Gosub Control_sound_off
               Config_at_start = 0
               10s_loops = 0
            End If
         End If
      End If
   End If
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
_init_micro:
' set "open" -> no uullup
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
' set one (or 2) pin as output low
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
$include "common_1.13\_Commands_required.bas"
'
$include "common_1.13\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'