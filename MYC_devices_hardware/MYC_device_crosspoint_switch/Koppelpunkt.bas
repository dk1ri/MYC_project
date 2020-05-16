'name : Koppelpunkt_bascom.bas
'Version V01.2, 20200516
'purpose : Program for 8x8crosspoint switch
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware koppelpunkt_eagle Version V01.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,8 with includefiles must be copied to the directory of this file!
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
' Detailed description
'
'----------------------------------------------------
'$regfile = "m168def.dat"
'for ATMega168
$regfile = "m328pdef.dat"
'
'-----------------------------------------------------
$crystal = 20000000
$include "common_1.10\_Processor.bas"
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
$include "common_1.10\_Constants_and_variables.bas"
'
Dim K_mode As Byte
Dim K_mode_eeram As Eram Byte
Dim Mat(8) As Byte
Dim M(4) As Byte
'
Waitms 10

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
_init_micro:
Reset Wr
Reset Latch
Return
'
Send_data:
   ' Swquence of outputs (B_temp3) is 5 6 7 8 1 2 3 4
   B_temp6 = 1
   B_temp3 = 5
   For B_Temp1 = 1 To 2
      ' 2 Multiplexer
      For B_temp2 = 1 To 2
         ' 2 Matpositions each
         ' 2 Outputs each a 4 Bit
         B_temp4 = Mat(B_temp3)
         Select Case B_temp4
            Case 0
               ' GND
               B_temp4 = &B00001000
            Case 1 To 8
               Decr B_temp4
            Case &HFF
               ' Buffer on
               B_temp4 = &B00001001
            Case &HFE
               ' Buffer off
               B_temp4 = &B00001010
         End Select
         Shift B_temp4, Left, 4
         Incr B_temp3
         B_temp5 = Mat(B_temp3)
         Select Case B_temp5
            Case 0
               ' GND
               B_temp5 = &B00001000
            Case 1 To 8
               ' inputs 1 to 8
               Decr B_temp5
            Case &HFF
               ' Buffer on
               B_temp5 = &B00001001
            Case &HFE
               ' Buffer off
               B_temp5 = &B00001010
         End Select
         M(B_temp6) = B_temp4 Or B_temp5
         B_temp5 = M(B_temp6)
         Incr B_temp6
         Incr B_temp3
      Next B_temp2
      B_temp3 = B_temp3 - 8
   Next B_temp1
'
   ' Shift out M
   For B_temp1 = 1 To 4
      B_temp3 = M(B_temp1)
      For B_temp2 = 7 To 0 Step -1
         D0 = B_temp3.B_temp2
         NOP
         NOP
         NOP
         Set Wr
         NOP
         NOP
         Reset Wr
      Next B_temp2
   Next B_temp1
   NOP
   Set Latch
   NOP
   NOP
   Reset Latch
Return
'
Switch_off_on:
Mat(1) = &HFF
Mat(2) = &HFF
Mat(3) = &HFF
Mat(4) = &HFF
If K_mode = 0 Or K_mode = 2 Then
' on
   Mat(5) = &HFF
   Mat(6) = &HFF
   Mat(7) = &HFF
   Mat(8) = &HFF
Else
' off
   Mat(5) = &HFE
   Mat(6) = &HFE
   Mat(7) = &HFE
   Mat(8) = &HFE
End If
Gosub Send_data
Return
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