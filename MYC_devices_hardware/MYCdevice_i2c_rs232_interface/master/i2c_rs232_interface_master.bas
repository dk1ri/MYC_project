'name : rs232_i2c_interface_master.bas
'Version V06.1, 2020042
'purpose : Programm for serial to i2c Interface for test of MYC devices
'This Programm workes as I2C master
'Can be used with hardware rs232_i2c_interface Version V05.1 by DK1RI
'
'++++++++++++++++++++++++++++++++++++++++++++++++++++
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,10 with includefiles must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!7!!!!!!!!!
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
' Inputs / Outputs : see file __config.bas
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'$regfile = "m88pdef.dat"
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.10\_Processor.bas"
'
'$lib "i2cv2.lbx"
'
'----------------------------------------------------
'
'1...127:
' not used
Const I2c_address = 0
' for I2c control
Const I2c_adress_ = 1
Const No_of_announcelines = 19
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.10\_Constants_and_variables.bas"
'
Dim I2c_len As Byte
Dim I2c_start As Byte
Dim Adress_ as Byte
Dim Adress__eeram As Eram Byte
Dim Rx(Stringlength) As Byte
'
'----------------------------------------------------
$include "common_1.10\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.10\_Config.bas"
'
'----------------------------------------------------
$include "common_1.10\_Main.bas"
print "start"
'
'----------------------------------------------------
$include "common_1.10\_Loop_start.bas"
'
'----------------------------------------------------
$include "common_1.10\_Main_end.bas"
'
' End of Main start subs
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