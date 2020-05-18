'-----------------------------------------------------------------------
'name : dtmf_rbc_bascom.bas
'Version V04.1, 20200518
'purpose : Programm for sending MYC protocol as DTMF Signals for remote Shack of MFJ (TM)
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,10 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.10\_Introduction_master_copyright.bas"
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
'
' Detailed description
'
'----------------------------------------------------
$Lib "Mcs.lib"
'$regfile = "m168def.dat"
$regfile = "m328pdef.dat"
'for ATMega328
'
'-----------------------------------------------------
$crystal = 10000000
$include "common_1.10\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 14
Const No_of_announcelines = 61
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.10\_Constants_and_variables.bas"
'
Dim Templ As Dword
Dim Templl As Dword
Dim Templll As Dword
Dim Templlll As Dword
Dim New_commandmode As Byte
Dim Commandmode As byte
' ! there is command_mode as well !!!!!
Dim Dtmf_duration As Byte
Dim Dtmfchar As Byte
Dim Dtmf_duration_eeram As Eram Byte
Dim Dtmf_pause As Byte
Dim Dtmf_pause_eeram As Eram Byte
Dim Vfo_a_b As Byte
Dim Memory_set_recall As Byte
Dim Antenna As Byte
Dim Func As Byte
Dim Ta As Byte
Dim Tb As Long
Dim Tc As Byte
Dim Td As Dword
Dim Te As Byte
Dim Tf As Byte
'
'----------------------------------------------------
$include "common_1.10\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.10\_Config.bas"
'
'----------------------------------------------------
' procedures at start
'
'----------------------------------------------------
$include "common_1.10\_Main.bas"
'
'----------------------------------------------------
$include "common_1.10\_Loop_start.bas"
'
'----------------------------------------------------
'
' ---> Specific actions
'
$include "common_1.10\_Main_end.bas"
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.10\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.10\_Init.bas"
'
'----------------------------------------------------
$include "common_1.10\_Subs.bas"
'
'----------------------------------------------------
'
Dtmf:
   Dtmfout Dtmfchar , Dtmf_duration
   Printbin Dtmfchar
   Waitms Dtmf_pause
   Set DTMF_
Return
'
Send_dtmf:
'Convert Command_b -> Te digits
'Tb: limit
'Tc: Start DTMF character
'Td: highest divisor
'Te: number of digits
'Tf: end Dtmf character
'
Templ = Command_b(2)
If Ta > 2 Then
   'create Templ (Dword) from Ta - 1 bytes
   For B_temp1 = 3 To Ta
      Templ = Templ * 256
      Templ = Templ + Command_b(B_temp1)
   Next B_temp1
End If
If Templ < Tb Then
   'check limit
   If New_commandmode < 10 Then Gosub Setcommandmode
   If Tc < 255 Then
      Dtmfchar = Tc
      Gosub Dtmf
     End If
   'convert to Te  digits
   Templl = Td
   For B_temp1 = 1 To Te
      Templlll = Templ / Templl
      DTMFchar = Templlll
      Gosub Dtmf
      Templll = Dtmfchar * Templl
      Templ = Templ - Templll
      Templl = Templl / 10
   Next B_temp1
   If Tf < 255 Then
      Dtmfchar = Tf
      Gosub Dtmf
   End If
Else
   Error_no = 4
   Error_cmd_no = Command_no
End If
Gosub Command_received
Return
'
Frequency:
'long word / 4 byte 0 to 9999999 -> 7 digits
New_commandmode = 1
Tb = 10000000
Tc = Vfo_a_b
Td = 1000000
Te = 7
Tf = Vfo_a_b
Gosub Send_dtmf
Return
'
Memory:
'1 byte, 0 to 99 -> 2 digits
New_commandmode = 1
Tb = 100
Tc = Memory_set_recall
Td = 10
Te = 2
Tf = 255
Gosub Send_dtmf
Return
'
Single_dtmf_char:
   Gosub Setcommandmode
   DTMFchar = b_Temp1
   Gosub Dtmf
   Gosub Command_received
Return
'
Command3_1_5:
Gosub Setcommandmode
Select Case Command_b(2)
   Case 0                                       'off: 0 Func
      Dtmfchar = 0
      Gosub Dtmf
      Dtmfchar = Func
      Gosub Dtmf
   Case 1                                       'on: Func
      Dtmfchar = Func
      Gosub Dtmf
   Case Else
      Error_no = 4
      Error_cmd_no = Command_no
End Select
Gosub Command_received
'
Tx_function:
New_commandmode = 4
Gosub Setcommandmode
Select Case Command_b(2)
   Case 0
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 1
      Gosub Dtmf
   Case 1
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 2
      Gosub Dtmf
   Case 2
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 3
      Gosub Dtmf
   Case 3
      If Func = 9 Then
         Dtmfchar = Func
         Gosub Dtmf
         Dtmfchar = 4
         Gosub Dtmf
      Else
         Error_no = 4
         Error_cmd_no = Command_no
      End If
   Case Else
      Error_no = 4
      Error_cmd_no = Command_no
End Select
Gosub Command_received
Return
'
Command6_:
New_commandmode = 6
Gosub Setcommandmode
Select Case Command_b(2)
   Case 0
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 0
      Gosub Dtmf
   Case 1
      Dtmfchar = Func
      Gosub Dtmf
      Dtmfchar = 1
      Gosub Dtmf
   Case Else
      Error_no = 4
      Error_cmd_no = Command_no
End Select
Gosub Command_received
'
Setcommandmode:
   If Commandmode <> New_commandmode Then
      Commandmode = New_commandmode
      Dtmfchar = 11
      Gosub Dtmf
      Dtmfchar = New_commandmode
      Gosub Dtmf
   End If
Return
'
'
'----------------------------------------------------
   $include "common_1.10\_Commandparser.bas"
'
'-----------------------------------------------------
$include "_Commands.bas"
$include "common_1.10\_Commands_required.bas"
'
$include "common_1.10\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'