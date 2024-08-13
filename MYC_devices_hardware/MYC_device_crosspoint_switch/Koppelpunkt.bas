'name : Koppelpunkt_bascom.bas
'Version V03.1, 20240812
'purpose : Program for 8x8crosspoint switch
'This Programm workes as I2C slave or with serial protocol
'Can be used with hardware koppelpunkt_eagle Version V01.1 (V02.0) by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1.13 with includefiles must be copied to the directory of this file!
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
$include "common_1.13\_Processor.bas"
'
$initmicro
'
'----------------------------------------------------
'
' 1 ... 127
Const I2c_address = 27
Const No_of_announcelines = 24
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.13\_Constants_and_variables.bas"
'
Dim K_mode As Byte
' 0: 8x8; 1: 8x4; 2: 4x4
Dim K_mode_eeram As Eram Byte
'conntected inputs (0 to 8) to 8 outputs:
Dim Mat(8) As Byte
Dim Mat88(8) As Byte
Dim Mat88_eeram(8) As Eram Byte
'
Dim Mat84(8) As Byte
Dim Mat84_eeram(8) As Eram Byte
'
Dim Mat44(8) As Byte
Dim Mat44_eeram(8) As Eram Byte
'
Dim Out_byte As Byte
'
Dim Used(3) As Byte
Waitms 10

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
_init_micro:
Reset Wr
Reset Latch
Return
'
Reset_start:
' Turn on all buffers
' required:&B00001001 (low nibble used only)
'Byte is decreased by one by shift_in
'
B_temp1 = 1
While B_temp1 <= 8
   Mat(B_temp1) = &B00001010
   B_temp1 = B_temp1 + 1
Wend
Gosub Copy_Mat
'
K_mode = K_mode_eeram
B_temp1 = 1
While B_temp1 <= 8
   If K_mode = 0 Then
      Mat(B_temp1) = Mat88_eeram(B_temp1)
   Elseif K_mode = 0 Then
      Mat(B_temp1) = Mat84_eeram(B_temp1)
   Else
      Mat(B_temp1) = Mat44_eeram(B_temp1)
   End If
   B_temp1 = B_temp1 + 1
Wend
Gosub Copy_mat
Used(K_mode) = 1
Return
'
Set_command:
If Commandpointer >= 2 Then
   If Command_b(2) < 9 Then
      B_temp4 = Command_b(2)
      If K_mode = 0 Then
         Mat(B_temp3) = B_temp4
         Gosub Copy_mat
      Elseif K_mode = 1 Then
         If B_temp3 < 5 Then
            Mat(B_temp3) = B_temp4
            ' other output with same input:
            B_temp3 = B_temp3 + 4
            Mat(B_temp3) = B_temp4
         Else
            Mat(B_temp3) = B_temp4
            ' other output with same input:
            B_temp3 = B_temp3 - 4
            Mat(B_temp3) = B_temp4
         End If
      Else
         ' Kmod == 2
         If B_temp3 < 5 Then
            If B_temp4 < 4 Then
               Mat(B_temp3) = B_temp4
               B_temp3 = B_temp3 + 4
               Mat(B_temp3) = B_temp4 + 4
            Else
               Mat(B_temp3) = B_temp4 - 4
               B_temp3 = B_temp3 - 4
               Mat(B_temp3) = B_temp4
            End If
         Else
            If B_temp4 < 4 Then
               Mat(B_temp3) = B_temp4 + 4
               B_temp3 = B_temp3 - 4
               Mat(B_temp3) = B_temp4
            Else
               Mat(B_temp3) = B_temp4
               B_temp3 = B_temp3 - 4
               Mat(B_temp3) = B_temp4 - 4
            End If
         End If
      End If
      Gosub Copy_mat
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
Copy_Mat:
' Shift in for Output 5 6 7 8 1 2 3 4: 4bit each
For B_temp1 = 5 to 8
   Out_byte = Mat(B_temp1)
   Gosub Shift_in
Next B_temp1
For B_temp1 = 1 to 4
   Out_byte = Mat(B_temp1)
   Gosub Shift_in
Next B_temp1
'
NOP
Set Latch
NOP
NOP
Reset Latch
NOP
Return
'
Shift_in:
If Out_byte = 0 Then
   Out_byte = 0B00001000
Else
   Out_byte = Out_byte - 1
End If
For B_temp2 = 3 To 0 Step - 1
   D0 = Out_byte.B_temp2
   NOP
   NOP
   NOP
   Set Wr
   NOP
   NOP
   Reset Wr
   NOP
Next B_temp2
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