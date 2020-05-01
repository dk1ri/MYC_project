'name : textdisplay.bas
'Version V03.3 20200422
'purpose : Textdisplay
'Can be used with hardware textdisplay Version V03.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory common_1,10 must be copied to the directory of this file!
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
$include "common_1.10\_Processor.bas"
'
'----------------------------------------------------
'
'1...127:
Const I2c_address = 16
Const No_of_announcelines = 17
Const Tx_factor = 10
' For Test:10 (~ 10 seconds), real usage:1 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.10\_Constants_and_variables.bas"
'
'----------------------------------------------------
'
Dim B_cmp1 as Byte
Dim B_cmp1_eeram As Eram Byte
Dim B_cmp2 as Byte
Dim B_cmp2_eeram As Eram Byte
Dim B_row As Byte
Dim B_col As Byte
Dim B_chars As Byte
Dim B_chars2 As Byte
' b_Chars / 2
Dim B_chars_eeram As Eram Byte
'32: 2* 16, 40: 2*20 Display
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
'
LCD_write:
   If Commandpointer >= 2 Then
      Select Case Command_b(2)
         Case 0
            'string empty
            Gosub Command_received
         Case Is > b_Chars
            Parameter_error
            Gosub Command_received
      End Select
      If Commandpointer >= 3 Then
         B_temp3 = Command_b(2) + 2
         If Commandpointer >= b_Temp3 Then
            For b_Temp2= 3 To Commandpointer
               LCD Chr(Command_b(b_Temp2))
               Incr b_Col
               If b_Col > b_Chars2 Then
                  If b_Row = 2 Then
                     b_Row = 1
                     Home Upper
                  Else
                     b_Row = 2
                     Home Lower
                  End If
                  b_Col = 1
               End If
            Next b_Temp2
            Gosub Command_received
         End If
      End If
   End If
Return
'
LCD_locate_write:
If Commandpointer >= 2 Then
   If Command_b(2) > B_chars Then
      Parameter_error
      Gosub Command_received
   End If
   If Commandpointer >= 3 Then
      If Command_b(3) > 0 Then
         If Command_b(3) > B_chars Then
            Parameter_error
            Gosub Command_received
         Else
            B_temp2 = Command_b(3) + 3
            If Commandpointer >= B_temp2 Then
               If Command_b(2) > B_chars2 Then
                  b_Row = 2
               Else
                  b_Row = 1
               End If
               b_Temp3 = b_Row - 1
               b_Temp3 = b_Temp3 * b_Chars2
               b_Col = Command_b(2) - b_Temp3
               Incr b_Col
               'Command_b(2) is 0 based, Col 1 based
               Locate b_Row , b_Col
               For b_Temp2 = 4 To Commandpointer
                  LCD Chr(Command_b(b_Temp2))
                  Incr b_Col
                  If b_Col > b_Chars2 Then
                     If b_Row = 2 Then
                        b_Row = 1
                        Home Upper
                     Else
                        b_Row = 2
                        Home Lower
                     End If
                     b_Col = 1
                  End If
               Next b_Temp2
               Gosub Command_received
            End If
         End If
      End If
   End If
End If
Return
'
LCD_locate:
If Commandpointer >= 2 Then
   If Command_b(2) < b_Chars Then
   'Command_b(2): 0 ... Chars - 1
      If Command_b(2) >= b_Chars2 Then
         b_Row = 2
      Else
         b_Row = 1
      End If
      b_Temp3 = b_Row - 1
      b_Temp3 = b_Temp3 * b_Chars2
      b_Col = Command_b(2) - b_Temp3
      Incr b_Col
      Locate b_Row , b_Col
   Else_Parameter_error
   Gosub Command_received
End If
Return
'
Config_lcd:
If b_Chars = 32 Then
   Config LCD = 16*2
Else
   Config LCD = 20*2
End If
B_chars2 = B_chars / 2
Initlcd
Home upper
Cls
Cursor on blink
B_row = 1
B_col = 1
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