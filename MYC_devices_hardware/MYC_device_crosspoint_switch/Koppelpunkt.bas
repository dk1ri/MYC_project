'name : Koppelpunkt_bascom.bas
'Version V01.3, 20200826
'purpose : Program for 8x8crosspoint switch
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware koppelpunkt_eagle Version V02.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1.11 with includefiles must be copied to the directory of this file!
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
' Inputs /Outputs : see file __config
' For announcements and rules see Data section in announcements.bas
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
' Detailed description
'
'----------------------------------------------------
'$regfile = "m168def.dat"
'for ATMega168
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.11\_Processor.bas"
'
$initmicro
'
'----------------------------------------------------
'
' 1 ... 127
Const I2c_address = 27
Const No_of_announcelines = 20
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.11\_Constants_and_variables.bas"
'
Dim K_mode As Byte
' 0: 8x8; 1: 8x4; 2: 4x4
Dim K_mode_eeram As Eram Byte
Dim Mat(8) As Byte
'conntected inputs (0 to 8) to 8 outputs
Dim Mat_eeram(8) As Eram Byte
Dim M(8) As Byte
'
Waitms 10

'----------------------------------------------------
$include "common_1.11\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.11\_Config.bas"
'
'----------------------------------------------------
$include "common_1.11\_Main.bas"
'
'----------------------------------------------------
$include "common_1.11\_Loop_start.bas"
'
'----------------------------------------------------
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
Reset Wr
Reset Latch
Return
'
Copy_Mat:
If Mat(1) = 0 Then
   M(1) = 0B00001000
Else
   M(1) = Mat(1) - 1
End If
If Mat(2) = 0 Then
   M(2) = 0B00001000
Else
   M(2) = Mat(2) - 1
End If
If Mat(3) = 0 Then
   M(3) = 0B00001000
Else
   M(3) = Mat(3) - 1
End If
If Mat(4) = 0 Then
   M(4) = 0B00001000
Else
   M(4) = Mat(4) - 1
End If
If Mat(5) = 0 Then
   M(5) = 0B00001000
Else
   M(5) = Mat(5) - 1
End If
If Mat(6) = 0 Then
   M(6) = 0B00001000
Else
   M(6) = Mat(6) - 1
End If
If Mat(7) = 0 Then
   M(7) = 0B00001000
Else
   M(7) = Mat(7) - 1
End If
If Mat(8) = 0 Then
   M(8) = 0B00001000
Else
   M(8) = Mat(8) - 1
End If
Gosub Send_data
Return
'
Send_data:
' Shift in for Output 5 6 7 8 1 2 3 4: 4bit each
B_temp3 = M(5)
Gosub Shift_in
B_temp3 = M(6)
Gosub Shift_in
B_temp3 = M(7)
Gosub Shift_in
B_temp3 = M(8)
Gosub Shift_in
B_temp3 = M(1)
Gosub Shift_in
B_temp3 = M(2)
Gosub Shift_in
B_temp3 = M(3)
Gosub Shift_in
B_temp3 = M(4)
Gosub Shift_in
'
NOP
Set Latch
NOP
NOP
Reset Latch
Return
'
Shift_in:
For B_temp2 = 3 To 0 Step -1
   D0 = B_temp3.B_temp2
   NOP
   NOP
   NOP
   Set Wr
   NOP
   NOP
   Reset Wr
Next B_temp2
Return
'
Output_off:
For B_temp3 = 1 To 8
   If Mat(B_temp3) = B_temp2 Then
      ' GND
      Mat(B_temp3) = 0
   End If
Next B_temp3
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