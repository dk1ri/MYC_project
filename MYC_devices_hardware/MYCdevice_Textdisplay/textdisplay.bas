'name : textdisplay.bas
'Version V04.0 20230501
'purpose : Textdisplay 16x2 character
'Can be used with hardware textdisplay Version V03.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory common_1,12 must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.12\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
'-----------------------------------------------------------------------
' Inputs / Outputs: see __config.bas
'
'-----------------------------------------------------------------------
'Missing/errors:
'
'-----------------------------------------------------------------------
'$regfile = "m168pdef.dat"
$regfile = "m328pdef.dat"
'
'----------------------------------------------------
$crystal = 20000000
$include "common_1.12\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 16
Const No_of_announcelines = 11
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.12\_Constants_and_variables.bas"
'
'----------------------------------------------------
'
Dim B_cmp1 as Byte
Dim B_cmp1_eeram As Eram Byte
Dim B_row As Byte
Dim B_col As Byte
Dim B_chars As Byte
Dim B_chars2 As Byte
' b_Chars / 2
'
'----------------------------------------------------
$include "common_1.12\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.12\_Config.bas"
'
'----------------------------------------------------
$include "common_1.12\_Main.bas"
'
'----------------------------------------------------
$include "common_1.12\_Loop_start.bas"
'
'----------------------------------------------------
$include "common_1.12\_Main_end.bas"
'
' End of Main start subs
'
'----------------------------------------------------
$include "common_1.12\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.12\_Init.bas"
'
'----------------------------------------------------
$include "common_1.12\_Subs.bas"
'
'----------------------------------------------------
$include "_Commands.bas"
$include "common_1.12\_Commands_required.bas"
'
$include "common_1.12\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'