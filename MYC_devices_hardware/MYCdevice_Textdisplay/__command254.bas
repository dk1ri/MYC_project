' additional command 254 parameters
'
      Case 5
         ' Displaysize
         If Commandpointer >= 3 Then
            b_Temp2 = Command_b(3)
            Select Case b_Temp2
               Case 0
                  b_Chars = 32
               Case 1
                  b_Chars = 40
               Case Else
                  Parameter_error
            End Select
            b_Chars_eeram = b_Chars
            Gosub Config_lcd
            Gosub Command_received
         End If