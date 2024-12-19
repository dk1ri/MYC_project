' Command_required
' 202240317
'
Ignore:
   'ignore this
   Command_pointer = 0
   Commandpointer = 0
Return
'

FFF0:
' F0 deliver not more than Tx_length byte, but complete line always
#IF Command_is_2_byte = 0
   If Commandpointer >= 3 Then
      A_line = Command_b(2)
      Number_of_lines = Command_b(3)
#ELSE
   If Commandpointer >= 6 Then
      A_line = Command_b(3) * 256
      A_line = A_line + Command_b(4)
      Number_of_lines = Command_b(5) * 256
      Number_of_lines = Number_of_lines + Command_b(6)
#ENDIF
      ' At that point Commands is not needed until end of sub
      ' -> used for temporary storage of announdements
      If A_line < No_of_announcelines And Number_of_lines < No_of_announcelines Then
         If Number_of_lines > 0 Then
            If Command_mode = 1 Then
               F0stop = 0
               Tx_time = 1
#IF Command_is_2_byte = 0
      Tx_b(1) = &HF0
      Tx_b(2) = A_line
      Tx_b(3) = Number_of_lines
      Tx_write_pointer = 4
#ELSE
      Tx_b(1) = &HFF
      Tx_b(2) = &HF0
      Tx_b(3) = High(A_line)
      Tx_b(4) = Low (A_line)
      Tx_b(5) = High(Number_of_lines)
      Tx_b(6) = Low(Number_of_lines)
      Tx_write_pointer = 7
#ENDIF
               Command = Lookupstr(A_line, Announce)
               B_temp3 = Len(Command)
               Tx_b(Tx_write_pointer) = B_temp3
               Incr Tx_write_pointer
               For B_temp2 = 1 To B_temp3
                   Tx_b(Tx_write_pointer) = Command_b(B_temp2)
                   Incr Tx_write_pointer
               Next B_temp2
               F0elements = 1
               Incr A_line
               Decr Number_of_lines
               If Number_of_lines > 0 Then
                  'additional announcement lines
                  While Number_of_lines > 0  and F0stop = 0
                     Command = Lookupstr(A_line, Announce)
                     B_temp3 = Len(Command)
                     W_temp1 = Tx_write_pointer + B_temp3
                    Incr W_temp1
                    If W_temp1 < Stringlength Then
                       Tx_b(Tx_write_pointer) = B_temp3
                       Incr Tx_write_pointer
                       For B_temp2 = 1 To B_temp3
                          Tx_b(Tx_write_pointer) = Command_b(B_temp2)
                          Incr Tx_write_pointer
                       Next B_temp2
                       Incr F0elements
                    Else
                       F0stop = 1
                    End If
                    Decr Number_of_lines
                    Incr A_line
                  Wend
               End If
               Tx_b(3) = F0elements
               Gosub Print_tx
            End If
         End If
      Else_Parameter_error
      Gosub Command_received
   End If
Return
'
FFF8:
#IF Command_is_2_byte = 0
   If Commandpointer >= 2 Then
      If Command_b(2) = 0 Then
         If wireless_active = 0 Then
            'Switch to transparent mode, server only
            Myc_mode = 0
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else
         If Command_b(2) <= Name_len Then
            ' change name
            B_temp1 = Command_b(2)
            If Commandpointer >= B_temp1 Then
               Radio_name = String(4,&H878) ' "x"
               B_temp2 = 1
               For B_temp1 = 3 to Commandpointer
                  Radio_name_b(B_temp2) = Command_b(B_temp1)
                  B_temp2 = B_temp2 + 1
               Next B_temp1
               #IF RadioType = 2
                  Gosub Write_id
               #EndIF
               Radio_name_eram = Radio_name
               Gosub Command_received
            Else
               Parameter_error
               Gosub Command_received
            End If
         Else
            Parameter_error
            Gosub Command_received
         End If
      End If
   End If
#ENDIF
#IF Command_is_2_byte = 1
   If Commandpointer >= 3 Then
      If Command_b(3) = 0 Then
         If wireless_active = 0 Then
            'Switch to transparent mode, server only
            Myc_mode = 0
         Else
            Parameter_error
         End If
         Gosub Command_received
      Else
         If Command_b(3) <= Name_len Then
            ' change name
            B_temp1 = Command_b(3)
            If Commandpointer >= B_temp1 Then
               Radio_name = String(4,&H878) ' "x"
               B_temp2 = 1
               For B_temp1 = 4 to Commandpointer
                  Radio_name_b(B_temp2) = Command_b(B_temp1)
                  B_temp2 = B_temp2 + 1
               Next B_temp1
               #IF RadioType = 2
                  Gosub Write_id
               #EndIF
               Radio_name_eram = Radio_name
               Gosub Command_received
            Else
               Parameter_error
               Gosub Command_received
            End If
         Else
            Parameter_error
            Gosub Command_received
         End If
      End If
   End If
#ENDIF
Return

FFFC:
      Tx_time = 1
      Tx = String(30, 0)
#IF Command_is_2_byte = 0
      Tx_b(1) = &HFC
      B_temp1 = 3
#Else
      Tx_b(1) = &HFF
      Tx_b(2) = &HFC
      B_temp1 = 4
#ENDIF
      Temps = Str(Command_no)
      B_temp4 = Len (Temps)
      For B_temp2 = 1 To B_temp4
         Tx_b(B_temp1) = Temps_b(B_temp2)
         Incr B_temp1
      Next B_temp2
      Select Case Error_no
         Case 0
            Temps = ": command not found: "
         Case 1
            Temps = ": I2C error: "
         Case 2
            Temps = ": watchdog reset: "
         Case 3
            Temps = ": command watchdog: "
         Case 4
            Temps = ": parameter error: "
         Case 5
            Temps = ": tx time too long: "
         Case 6
            Temps = ": not valid at that time: "
         Case 7
            Temps = ": i2c_buffer overflow: "
         Case 8
            Temps = ": I2c not ready to receive: "
'
        $include "__command252.bas"

         Case 255
            Temps = ": no error: "
         Case Else
            Temps = ": other error: "
      End Select
      B_temp4 = Len (Temps)
      For B_temp2 = 1 To B_temp4
         Tx_b(B_temp1) = Temps_b(B_temp2)
         Incr  B_temp1
      Next B_temp2
      Temps = Str(Error_cmd_no)
      B_temp4 = Len (Temps)
      For B_temp2 = 1 To B_temp4
         Tx_b(B_temp1) = Temps_b(B_temp2)
         Incr B_temp1
      Next B_temp2
#IF Command_is_2_byte = 0
      Tx_b(2) = B_temp1 - 3
#ELSE
      Tx_b(3) = B_temp1 - 4
#ENDIF
      Tx_write_pointer = B_temp1
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
FFFD:
      Tx_time = 1
#IF Command_is_2_byte = 0
      Tx_b(1) = &HFD
      Tx_b(2) = 4
      'no info
      Tx_write_pointer = 3
#ELSE
      Tx_b(1) = &HFF
      Tx_b(2) = &HFD
      Tx_b(3) = 4
      'no info
      Tx_write_pointer = 4
#ENDIF
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
#IF Use_FE_FF = 1
FFFE:
#IF Command_is_2_byte = 0
      If Commandpointer >= 2 Then
         Select Case Command_b(2)
            Case 0
               If Commandpointer >= 3 Then
                  If Command_b(3) = 0 Then
                     Gosub Command_received
                  Else
                     B_temp1 = Command_b(3) + 3
                     If Commandpointer >= B_temp1 Then
                        Dev_name = String(20 , 0)
                        If B_temp1 > 23 Then B_temp1 = 23
                        For B_temp2 = 4 To B_temp1
                           Dev_name_b(B_temp2 - 3) = Command_b(B_temp2)
                        Next B_temp2
                        Dev_name_eeram = Dev_name
                        Gosub Command_received
                     End If
                  End If
               End If
            Case 1
               If Commandpointer >= 3 Then
                  Dev_number = Command_b(3)
                  Dev_number_eeram = Dev_number
                  Gosub Command_received
               End If
            Case 2
               If Commandpointer >= 3 Then
                  If Command_b(3) < 2 Then
                     I2C_active = Command_b(3)
                     I2C_active_eeram = I2C_active
                     Else_Parameter_error
                  Gosub Command_received
               End If
            Case 3
               If Commandpointer >= 3 Then
                   B_temp2 = Command_b(3)
                   If B_temp2 < 128 Then
                      B_temp2 = B_temp2 * 2
                      Adress = B_temp2
                      Adress_eeram = Adress
#IF Use_reset_i2c = 1
                      Gosub Reset_i2c
#ENDIF
                   Else_Parameter_error
                   Gosub Command_received
               End If
            Case 4
               If Commandpointer >= 3 Then
                  B_temp2 = Command_b(3)
                  If B_temp2 < 2 Then
                     Serial_active = B_temp2
                     Serial_active_eeram = Serial_active
                  Else_Parameter_error
                  Gosub Command_received
               End If
#ELSE
      If Commandpointer >= 3 Then
         Select Case Command_b(3)
            Case 0
               If Commandpointer >= 3 Then
                  If Command_b(4) = 0 Then
                     Gosub Command_received
                  Else
                     B_temp1 = Command_b(4) + 3
                     If Commandpointer >= B_temp1 Then
                        Dev_name = String(20 , 0)
                        If B_temp1 > 23 Then B_temp1 = 23
                        For B_temp2 = 4 To B_temp1
                           Dev_name_b(B_temp2 - 3) = Command_b(B_temp2)
                        Next B_temp2
                        Dev_name_eeram = Dev_name
                     End If
                  End If
               End If
            Case 1
               If Commandpointer >= 4 Then
                  Dev_number = Command_b(4)
                  Dev_number_eeram = Dev_number
                  Gosub Command_received
               End If
            Case 2
               If Commandpointer >= 4 Then
                  If Command_b(4) < 2 Then
                     I2C_active = Command_b(4)
                     I2C_active_eeram = I2C_active
                     Else_Parameter_error
                  Gosub Command_received
               End If
            Case 3
               If Commandpointer >= 4 Then
                   B_temp2 = Command_b(4)
                   If B_temp2 < 128 Then
                      B_temp2 = B_temp2 * 2
                      Adress = B_temp2
                      Adress_eeram = Adress
                      Gosub Reset_i2c
                   Else_Parameter_error
                   Gosub Command_received
               End If
            Case 4
               If Commandpointer >= 4 Then
                  B_temp2 = Command_b(4)
                  If B_temp2 < 2 Then
                     Serial_active = B_temp2
                     Serial_active_eeram = Serial_active
                  Else_Parameter_error
                  Gosub Command_received
               End If
#ENDIF
'
                $include "__command254.bas"
'
            Case Else
               Parameter_error
               Gosub Command_received
         End Select
      End If
Return
'
FFFF:
#IF Command_is_2_byte = 0
      If Commandpointer >= 2 Then
         Tx_time = 1
         Tx_b(1) = &HFF
         Tx_b(2) = Command_b(2)
         Select Case Command_b(2)
            Tx_write_pointer = 0
            Case 0
               'Will send &HFF00 for empty string
               S_temp1 = String(20,255)
               If Dev_name = S_temp1 Then
                  Dev_name = "Device1"
                  Dev_name_eeram = Dev_name
               End If
               B_temp3 = Len(Dev_name)
               Tx_b(3) = B_temp3
               Tx_write_pointer = 4
               B_temp2 = 1
               While B_temp2 <= B_temp3
                  Tx_b(Tx_write_pointer) = Dev_name_b(B_temp2)
                  Incr Tx_write_pointer
                  Incr B_temp2
               Wend
            Case 1
               Tx_b(3) = Dev_number
               Tx_write_pointer = 4
            Case 2
               Tx_b(3) = I2c_active
               Tx_write_pointer = 4
            Case 3
               B_temp2 = Adress / 2
               Tx_b(3) = B_temp2
               Tx_write_pointer = 4
            Case 4
               Tx_b(3) = Serial_active
               Tx_write_pointer = 4
            Case 5
               Tx_b(3) = 0
               Tx_write_pointer = 4
            Case 6
               Tx_b(3) = 3
               Tx_b(4) = "8"
               Tx_b(5) = "N"
               Tx_b(6) = "1"
               Tx_write_pointer = 7
#ELSE
      If Commandpointer >= 3 Then
         Tx_time = 1
         Tx_b(1) = &HFF
         Tx_b(2) = &HFF
         Tx_b(3) = Command_b(2)
         Select Case Command_b(3)
            Tx_write_pointer = 0
            Case 0
               'Will send &HFF0000 for empty string
               B_temp3 = Len(Dev_name)
               Tx_b(4) = B_temp3
               Tx_write_pointer = 5
               B_temp2 = 1
               While B_temp2 <= B_temp3
                  Tx_b(Tx_write_pointer) = Dev_name_b(B_temp2)
                  Incr Tx_write_pointer
                  Incr B_temp2
               Wend
            Case 1
               Tx_b(4) = Dev_number
               Tx_write_pointer = 5
            Case 2
               Tx_b(4) = I2c_active
               Tx_write_pointer = 5
            Case 3
               B_temp2 = Adress / 2
               Tx_b(4) = B_temp2
               Tx_write_pointer = 5
            Case 4
               Tx_b(4) = Serial_active
               Tx_write_pointer = 5
            Case 5
               Tx_b(4) = 0
               Tx_write_pointer = 5
            Case 6
               Tx_b(4) = 3
               Tx_b(5) = "8"
               Tx_b(6) = "N"
               Tx_b(7) = "1"
               Tx_write_pointer = 8
#ENDIF
'
            $include "__command255.bas"
'
            Case Else
               Parameter_error
         End Select
         If Tx_write_pointer > 0 Then
            If Command_mode = 1 Then Gosub Print_tx
         End If
         Gosub Command_received
      End If
Return
#ENDIF