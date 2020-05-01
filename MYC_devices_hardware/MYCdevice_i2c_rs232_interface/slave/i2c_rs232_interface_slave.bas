'-----------------------------------------------------------------------
'name : rs232_i2c_interface_slave.bas
'Version V06.1, 20200427
'purpose : I2C-RS232_interface Slave
'This Programm workes as I2C slave
'Can be used with hardware rs232_i2c_interface Version V05.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1.10 with includefiles must be copied to the directory of this file!
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
' Inputs / Outputs : see file __config.bas
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
$regfile = "m88pdef.dat"
'$regfile = "m168pdef.dat"
'$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.10\_Processor.bas"
'
'----------------------------------------------------
'
' 1 ... 127:
Const I2c_address = 1
Const No_of_announcelines = 8
Const Tx_factor = 15
' For Test:10 (~ 10 seconds), real usage:2 (~ 1 second)
'
Const S_length = 32
Const Rs232_length = 250
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.10\_Constants_and_variables.bas"
'
Dim Rs232_in As String * Rs232_length
'RS232 input
Dim Rs232_in_b(Rs232_length) As Byte At Rs232_in Overlay
Dim Rs232_pointer As Byte
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
'RS232 got data for I2C ?
'Input on RS232 is stored in a buffer and transferred on read request to I2C buffer
'actual start is position 1 always
B_temp1 = Ischarwaiting()
If B_temp1 = 1 Then
   B_temp1 = Waitkey()
   If Rs232_pointer < Rs232_length Then
      Incr Rs232_pointer
      Printbin B_temp1
      Rs232_in_b(Rs232_pointer) = B_temp1
   End If
End If
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