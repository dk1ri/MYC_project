'-----------------------------------------------------------------------
'name : Fs20_8_kanal_tx.bas
'Version V07.0, 20230926
'purpose : Programm for sending FS20 Signals
'Can be used with hardware FS20_interface V03.4 by DK1RI
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
Const I2c_address = 12
Const No_of_announcelines = 21
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'20MHz / 1024 / 1953 = 10  Hz -> 100ms
Const T_factor = 1953
'0,1 s
Const T_Short = 1
'0.6 s
Const T_long = 5
'2 s for timer
Const T_timer = 20
'6 s  for config
Const T_modus = 60
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim K as Word
Dim Kk As Word
Dim Switch As Byte
Dim Switch1 As Byte
Dim Send_length As Byte
' contain values &H01 to &H04!
Dim Housecode As String * 9
Dim Housecode_b(8) As Byte At Housecode Overlay
Dim Housecode_eeram As Eram String * 9
' contain 8 2 bit values (Ascii 1 to 4) - 48 -> Switch number 1 to 4
Dim Kanal_mode As Byte
Dim Kanal_mode_eeram As Eram Byte
Dim Busy As Byte
Dim S_temp10 As String * 10
Dim S_temp10_b(10) As Byte At S_temp10  Overlay
Dim Send_string As String * 10
Dim Send_string_b(10) As Byte At Send_string Overlay
Dim Send_pointer As Byte
Dim Dimm_chanal As Byte
Dim Wait_ As Byte
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
Wait 1
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
Gosub Select_busy
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
Select_busy:
If Wait_ = 0 Then
   Select Case Busy:
      Case 0:
         ' new command can be done
         NOP
      Case 1
         ' in action: switch, dim, 4 chanal timer or 4/8 chanal command, no new command
         NOP
      Case 2:
         ' start config (housecode,reset) (set config -> data)
         ' uses case 2 - case 4
         ' switch and switch1 are set
         ' Send first data
         Gosub Switch_off
         Send_pointer = 1
         Gosub Send_more_bytes
         Busy = 3
         ' Wait_ = 1 already set
      Case 3:
         If Send_pointer <= Send_length Then
         Gosub Switch_off
            Gosub Send_more_bytes
         Else
            Gosub Switch_off
         End If
      Case 4:
         ' 8 chanal timer
         ' Case 4 - Case 6
         NOP
      Case 5:
         ' 8ch timer
         B_temp1 = Switch1
         Gosub Switch_off1
         K = T_short
         Busy = 6
         Wait_ = 1
         Start Timer1
      Case 6:
         Gosub Switch_off
   End Select
End If
Return
'
Send_more_bytes:
   ' sending "data"
   K = T_short
   switch = Send_string_b(Send_pointer)
   switch1 = 0
   Gosub Switch_on
   Incr Send_pointer
   Wait_ = 1
   Start Timer1
Return
'
Switch_on:
   ' switch: &H01 to &H08
   Select Case Switch
      Case 1:
         Config Ta1 = Output
         Reset Ta1
      Case 2:
         Config Ta2 = Output
         Reset Ta2
      Case 3:
         Config Ta3 = Output
         Reset Ta2
      Case 4:
         Config Ta4 = Output
         Reset Ta4
      Case 5:
         Config Ta5 = Output
         Reset Ta5
      Case 6:
         Config Ta6 = Output
         Reset Ta6
      Case 7:
         Config Ta7 = Output
         Reset Ta7
      Case 8:
         Config Ta8 = Output
         Reset Ta8
   End Select
   Select Case Switch1
      Case 1:
         Config Ta1 = Output
         Reset Ta1
      Case 2:
         Config Ta2 = Output
         Reset Ta2
      Case 3:
         Config Ta3 = Output
         Reset Ta2
      Case 4:
         Config Ta4 = Output
         Reset Ta4
      Case 5:
         Config Ta5 = Output
         Reset Ta5
      Case 6:
         Config Ta6 = Output
         Reset Ta6
      Case 7:
         Config Ta7 = Output
         Reset Ta7
      Case 8:
         Config Ta8 = Output
         Reset Ta8
   End Select
Return
'
Switch_off:
   Stop Timer1
   Timer1 = 0
   Kk = 0
   Wait_ = 0
   Busy = 0
   Config Ta1 = Input
   Config Ta2 = Input
   Config Ta3 = Input
   Config Ta4 = Input
   Config Ta5 = Input
   Config Ta6 = Input
   Config Ta7 = Input
   Config Ta8 = Input
Return
'
Switch_off1:
   ' B_temp1: &H01 to &H08
   Select Case B_temp1
      Case 1:
         Config Ta1 = Input
      Case 2:
         Config Ta2 = Input
      Case 3:
         Config Ta3 = Input
      Case 4:
         Config Ta4 = Input
      Case 5:
         Config Ta5 = Input
      Case 6:
         Config Ta6 = Input
      Case 7:
         Config Ta7 = Input
      Case 8:
         Config Ta8 = Input
   End Select
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