'-----------------------------------------------------------------------
'name : dtmf_sender.bas
'Version V07.0, 20230716
'purpose : Programm for sending MYC protocol as DTMF Signals
'This Programm workes as I2C slave or serial protocoll
'Can be used with hardware rs232_i2c_interface Version V05.1 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,13 with includefiles must be copied to the directory of this file!
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
'
' Detailed description
'
'----------------------------------------------------
$regfile = "m88pdef.dat"
'$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 10000000
$include "common_1.13\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 7
Const No_of_announcelines = 13
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim Dtmf_duration As Byte
Dim Dtmf_duration_eeram As Eram Byte
Dim Dtmf_pause As Byte
Dim Dtmf_pause_eeram As Eram Byte
Dim Dtmf_char As Byte
'
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

Send_dtmf:
   B_temp3 = 255
   Select Case Dtmf_char
     Case 48 to 57
        B_temp3 = Dtmf_char - 48
     Case  42
        B_temp3 = 10
     Case 35
        B_temp3 = 11
     Case 65 to 68
        B_temp3 = Dtmf_char - 53
     Case 97 to 100
        B_temp3 = Dtmf_char - 85
     Case Else
        Parameter_error
   End Select
   If B_temp3 <> 255 Then
      If No_myc = 1 Then
         Printbin Dtmf_char
      End If
      Dtmfout B_temp3, Dtmf_duration
      Waitms dtmf_pause
   End If
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