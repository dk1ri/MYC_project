'name : infrarot_tx _philips_tv_2908.bas
'Version V05.2, 20200614
'purpose : Programm to send RC5 Codes to Philips TV 2908
'This Programm workes as I2C slave or serial interface
'Can be used with hardware rs232_i2c_interface Version V05.1 by DK1RI
'++++++++++++++++++++++++++++++++++++++++++++++++++++
'
' ---> Description / name of program
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,10 must be copied to the directory of this file!
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
' For announcements and rules see Data section at the end
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'$regfile = "m168pdef.dat"
$regfile = "m328pdef.dat"
$crystal = 20000000
'
'-----------------------------------------------------
$include "common_1.10\_Processor.bas"
'
'----------------------------------------------------
'
'1...128:
Const I2c_address = 15
Const No_of_announcelines = 47
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
'
$include "__use.bas"
$include "common_1.10\_Constants_and_variables.bas"
'
'----------------------------------------------------
Dim Togglebit As Byte
Dim Rc5_adress As Byte
'
'----------------------------------------------------
$include "common_1.10\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.10\_Config.bas"
'
'----------------------------------------------------
$include "common_1.10\_Main.bas"
'
'----------------------------------------------------
$include "common_1.10\_Loop_start.bas"
'
'----------------------------------------------------
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
Send_rc5:
printbin b_Temp1
Rc5send Togglebit, Rc5_adress, b_Temp1
Set Ir_led
'Switch of IR LED
Return
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