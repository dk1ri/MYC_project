' additional commands
'20204020
'
01:
   If b_Chars = 32 Then
      Gosub LCD_write
   Else
      Command_not_found
      Gosub Command_received
   End If
Return
'
02:
   If b_Chars = 32 Then
      Gosub LCD_locate_write
   Else
      Command_not_found
      Gosub Command_received
   End If
Return
'
03:
   If b_Chars = 32 Then
      Gosub LCD_locate
   Else
      Command_not_found
      Gosub Command_received
   End If
Return
'
04:
   If b_Chars = 40 Then
      Gosub LCD_write
   Else
      Command_not_found
      Gosub Command_received
   End If
Return
'
05:
   If b_Chars = 40 Then
      Gosub LCD_locate_write
   Else
      Command_not_found
      Gosub Command_received
   End If
Return
'
06:
   If b_Chars = 40 Then
      Gosub LCD_locate
   Else
      Command_not_found
      Gosub Command_received
   End If
Return
'
07:
   Gosub Config_lcd
   Gosub Command_received
Return
'
08:
   If Commandpointer >= 2 Then
      B_cmp1 = Command_b(2)
      B_cmp1_eeram = B_cmp1
      Pwm1a = b_Cmp1
      Gosub Command_received
   End If
Return
'
09:
   Tx_time = 1
   Tx_b(1) = &H09
   Tx_b(2) = B_cmp1
   Tx_write_pointer = 3
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'