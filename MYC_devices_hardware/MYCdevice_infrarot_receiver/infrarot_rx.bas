'-----------------------------------------------------------------------
'name : infrarot_rx_bascom.bas
'Version V07.0, 20230712
'purpose : Programm for receiving infrared RC5 Signals
'This Programm workes as I2C slave, or serial
'Can be used with hardware i2c_rs232_interface Version V05.1 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,13 must be copied to the directory of this file!
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
' Timer0
'-----------------------------------------------------
' Inputs / Outputs : see __config file
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
'$regfile = "m88def.dat"
'$regfile = "m328pdef.dat"
$crystal = 20000000
$include "common_1.13\_Processor.bas"
'
'----------------------------------------------------
'
'1...128:
Const I2c_address = 12
Const No_of_announcelines = 11
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
'
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
' Specific Constants Variables
' 1 rc5 byte cobverted to 2byte decimal + , 
Const Rc5_stringlength = 81
'
Dim Valid_adress As Byte
Dim Valid_adress_eeram As Eram Byte
Dim Rc5buffer As String * Rc5_stringlength
Dim Rc5buffer_b(Rc5_stringlength) As Byte At Rc5buffer Overlay
Dim Rc5_overflow As Byte
Dim Rc5_writepointer As Byte
'Rc5_bit, Rc5_adress and Rc5_command are predefines variables
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
If _rc5_bits.4 = 1 Then
   _rc5_bits.4 = 0
   'enable next data
   'the toggle bit toggles on each new received command
   'toggle bit is bit 7. Extended RC5 bit is in bit 6
   b_Temp1 = Rc5_address And &B00011111
   b_Temp3 = Rc5_command And &B00111111
   If No_myc = 1 Then
      'Rc5_adress
      b_Temp2 = b_Temp1 / 10
      b_Temp2 = b_Temp2 + 48
      Printbin b_Temp2
      b_Temp2 = b_Temp1 Mod 10
      b_Temp2 = b_Temp2 + 48
      Printbin b_Temp2
      'RC5 command
      b_Temp2 = b_Temp3 / 10
      b_Temp2 = b_Temp2 + 48
      Printbin b_Temp2
      b_Temp2 = b_Temp3 Mod 10
      b_Temp2 = b_Temp2 + 48
      Printbin b_Temp2
   Else
      If b_Temp1 = Valid_adress Then
         If Rc5_writepointer < Rc5_stringlength Then
            Rc5buffer_b(Rc5_writepointer) = b_Temp3
            Incr  Rc5_writepointer
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
Reset_rc5buffer:
Rc5_writepointer = 1
Rc5_overflow = 0
Rc5buffer = String(Rc5_stringlength,255)
Return
'
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