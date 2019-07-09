' Command 254
'1.7.0, 190512
'
   Case 254
      If Commandpointer >= 2 Then
         Select Case Command_b(2)
            Case 0
               If Commandpointer >= 3 Then
                  If Command_b(3) = 0 Then
                     Gosub Command_received
                  Else
                     b_Temp1 = Command_b(3) + 3
                     If Commandpointer >= b_Temp1 Then
                        Dev_name = String(20 , 0)
                        If b_Temp1 > 23 Then b_Temp1 = 23
                        For b_Temp2 = 4 To b_Temp1
                           Dev_name_b(b_Temp2 - 3) = Command_b(b_Temp2)
                        Next b_Temp2
                        Dev_name_eeram = Dev_name
                     Else_Incr_Commandpointer
                  End If
               Else_Incr_Commandpointer
            Case 1
               If Commandpointer >= 3 Then
                  Dev_number = Command_b(3)
                  Dev_number_eeram = Dev_number
                  Gosub Command_received
               Else_Incr_Commandpointer
            Case 2
               If Commandpointer >= 3 Then
                  If Command_b(3) < 2 Then
                     I2C_active = Command_b(3)
                     I2C_active_eeram = I2C_active
                     Else_Parameter_error
                  Gosub Command_received
               Else_Incr_Commandpointer
            Case 3
               If Commandpointer >= 3 Then
                   b_Temp2 = Command_b(3)
                   If b_Temp2 < 128 Then
                      b_Temp2 = b_Temp2 * 2
                      Adress = b_Temp2
                      Adress_eeram = Adress
                      Gosub Reset_i2c
                   Else_Parameter_error
                   Gosub Command_received
               Else_Incr_Commandpointer
            Case 4
               If Commandpointer >= 3 Then
                  b_Temp2 = Command_b(3)
                  If b_Temp2 < 2 Then
                     Serial_active = b_Temp2
                     Serial_active_eeram = Serial_active
                  Else_Parameter_error
                  Gosub Command_received
               Else_Incr_Commandpointer
'
                $include "__command254.bas"
'
            Case Else
               Parameter_error
               Gosub Command_received
         End Select
      Else_Incr_Commandpointer