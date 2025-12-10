' Command_required
' 20251207
'
Ignore:
   Old_commandpointer = Commandpointer
   Gosub Command_received
Return
'

FFF0:
' Data linelength is limited to 254 Byte
' F0 deliver not more than Tx_length byte, but complete line always
#IF Command_is_2_byte = 0
   If Commandpointer >= 3 Then
      Old_commandpointer = Commandpointer
      A_line = Command_b(2)
      Number_of_lines = Command_b(3)
      Tx_write_pointer = 4
#ELSE
   B_temp1 = No_of_announcelines
   If Btemp_1 <= 256 Then
      B_temp1 = 4
      B_temp6 = 0
   Else
      B_temp1 = 6
      B_temp6 = 1
   End If
   If Commandpointer >= B_temp1 Then
      Old_commandpointer = Commandpointer
      If B_temp2 = 0 Then
         A_line = Command_b(3)
         Number_of_lines = DIO_b(4)
         Tx_write_pointer = 5
      Else
         A_line = DIO_b(3) * 256
         A_line = A_line + Command_b(4)
         Number_of_lines = Command_b(5) * 256
         Number_of_lines = Number_of_lines + DIO_b(6)
         Tx_write_pointer = 7
      End If
#ENDIF
      If A_line < No_of_announcelines And Number_of_lines < No_of_announcelines Then
         If Number_of_lines > 0 Then
#IF Command_is_2_byte = 0
            Tx_write_pointer = 4
#ELSE
            Tx_write_pointer = 7
#ENDIF
            ' Number of actual lines
            W_temp1 = 0
            '  actual line
            W_temp3 = A_line
            Do
               Temps1 = Lookupstr(W_temp3, Announce)
               B_temp3 = Len(Temps1)
               ' addiotional line fit into string?
               W_temp2 = Tx_write_pointer + B_temp3
               Incr B_temp4
               If W_temp2 <= DIO_length Then
                  Tx_b(Tx_write_pointer) = B_temp3
                  Incr Tx_write_pointer
                  For B_temp1 = 1 To B_temp3
                     Tx_b(Tx_write_pointer) = Temps1_b(B_temp1)
                     Incr Tx_write_pointer
                  Next B_temp1
                  Incr W_temp1
                  Incr W_temp3
               End If
               Decr Number_of_lines
            Loop Until Number_of_lines = 0
#IF Command_is_2_byte = 0
            Tx_b(1) = &HF0
            Tx_b(2) = Command_b(2)
            B_temp1 = W_temp1
            Tx_b(3) = B_temp1
#ELSE       Tx_b(1) = Command_b(1)
            If B_temp6 = 0 Then
               Tx_b(2) = Command_b(2)
               DIO_b(3) = A_line
            Else
               Tx_b(3) = Command_b(3)
               Tx_b(4) = Command_b(4)
                Tx_b(5) = High(W_temp1)
                Tx_b(6) = Low(W_temp1)
            End If
#ENDIF
            Gosub Print_tx
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
FFF6:
#IF Command_is_2_byte = 0
   If Commandpointer >= 3 Then
      Tx_write_pointer = 3
      Old_commandpointer = Commandpointer
      If Mode_in= 1 Then
         Not_valid_at_this_time
         Gosub Command_received
         Return
      End If
      Select Case Command_b(2)
#ELSE
   If Commandpointer >= 4 Then
      Tx_write_pointer = 4
      Old_commandpointer = Commandpointer
      If Mode_in= 1 Then
         Not_valid_at_this_time
         Gosub Command_received
         Return
      End If
      Select Case Command_b(3)
#ENDIF
         Case 0
            If Command_origin <> 2 Then
               ' config Jumper required
               If Mode_in = 0 Then
                  B_temp2 = Command_b(Tx_write_pointer)
                  If B_temp2 < 4 Then
                     Baudrate = B_temp2
                     Baudrate_eeram = Baudrate
                  Else
                     Parameter_error
                  End If
               Else
                  Not_valid_at_this_time
               End If
            Else
               Not_valid_at_this_time
            End If
            Gosub Command_received
         Case 1
            If Command_b(Tx_write_pointer) = 0 Then
               Gosub Command_received
            Else
               B_temp1 = Command_b(Tx_write_pointer)
               B_temp6 = B_temp1 + Tx_write_pointer
               Incr Tx_write_pointer
               If Commandpointer >= B_temp6 Then
                  Old_commandpointer = Commandpointer
                  If B_temp1 < Name_len Then
                     If Command_origin <> 2 Then
                           Ser_mode = string (3, 0)
                        For B_temp2 = 1 To B_temp1
                           Ser_mode_b(B_temp2) = Command_b(Tx_write_pointer)
                           Incr Tx_write_pointer
                        Next B_temp2
                        Radio_name_eeram = Radio_name
                     Else
                        Not_valid_at_this_time
                     End If
                  Else
                     Parameter_error
                  End If
                  Gosub Command_received
               End If
            End If
         Case 2
            If Command_origin <> 4 Then
               B_temp2 = Command_b(Tx_write_pointer)
               If B_temp2 < 7 Then
                  Radio_type = B_temp2
                  Radio_type_eeram = Radio_type
               Else
                  Parameter_error
               End If
            Else
               Not_valid_at_this_time
            End If
            Gosub Command_received
         Case 3
            If Command_b(Tx_write_pointer) = 0 Then
               Gosub Command_received
            Else
               B_temp1 = Command_b(Tx_write_pointer)
               B_temp6 = B_temp1 + Tx_write_pointer
               Incr Tx_write_pointer
               If Commandpointer >= B_temp6 Then
                  Old_commandpointer = Commandpointer
                  If B_temp1 < Name_len Then
                     If Command_origin <> 4 Then
                        Radio_name = string (Name_len, 0)
                        For B_temp2 = 1 To B_temp1
                           Radio_name_b(B_temp2) = Command_b(Tx_write_pointer)
                           Incr Tx_write_pointer
                        Next B_temp2
                        Radio_name_eeram = Radio_name
                        Select Case Radio_type
                           Case 4
                              Gosub Write_name_4
                        End Select
                     Else
                        Not_valid_at_this_time
                     End If
                  Else
                     Parameter_error
                  End If
                  Gosub Command_received
               End If
            End If
#IF Use_I2c = 1
         Case 4
            If Command_origin <> 3 Then
               B_temp2 = Command_b(Tx_write_pointer)
               If B_temp2 < 128 Then
                  B_temp2 = B_temp2 * 2
                  Adress = B_temp2
                  Adress_eeram = Adress
                  Gosub Reset_i2c
               Else
                 Parameter_error
               End If
            Else
               Not_valid_at_this_time
            End If
            Gosub Command_received
#ENDIF
            $include "__command254.bas"
'
         Case Else
            Parameter_error
            Gosub Command_received
      End Select
   End If
Return
'
FFF7:
#IF Command_is_2_byte = 0
      If Commandpointer >= 2 Then
         Old_commandpointer = Commandpointer
         Tx_b(1) = &HF7
         Tx_b(2) = Command_b(2)
         Tx_write_pointer = 3
         Select Case Command_b(2)
#ELSE
      If Commandpointer >= 3 Then
         Old_commandpointer = Commandpointer
         Tx_time = 1
         Tx_b(1) = &HFF
         Tx_b(2) = &HFF
         Tx_b(3) = Command_b(2)
         Tx_write_pointer = 4
         Select Case Commnad_b32)
#ENDIF
            Case 0
               Tx_b(Tx_write_pointer) = Baudrate
               Incr Tx_write_pointer
            Case 1
               B_temp3 = Len(Ser_mode)
               Tx_b(Tx_write_pointer) = B_temp3
               Incr Tx_write_pointer
               For B_temp1 = 1 to B_temp3
                  Tx_b(Tx_write_pointer) = Ser_mode_b(B_temp1)
                  Incr Tx_write_pointer
               Next B_temp1
            Case 2
               Tx_b(Tx_write_pointer) = Radio_type
               Incr Tx_write_pointer
            Case 3
               B_temp3 = Len(Radio_name)
               Tx_b(Tx_write_pointer) = B_temp3
               Incr Tx_write_pointer
               For B_temp1 = 1 to B_temp3
                  Tx_b(Tx_write_pointer) = Radio_name_b(B_temp1)
                  Incr Tx_write_pointer
               Next B_temp1
#IF Use_i2c = 1
            Case 4
               B_temp2 = Adress / 2
               Tx_b(Tx_write_pointer) = B_temp2
               Incr Tx_write_pointer
#ENDIF
'
            $include "__command255.bas"
'
            Case Else
               Parameter_error
               Tx_write_pointer = 0
         End Select
         If Tx_write_pointer > 0 Then
            Gosub Print_tx
         End If
         Gosub Command_received
      End If
Return
'
FFFC:
   Old_commandpointer = Commandpointer
   Tx = String(30, 0)
#IF Command_is_2_byte = 0
   Tx_b(1) = &HFC
   B_temp1 = 3
#Else
   Tx_b(1) = &HFF
   Tx_b(2) = &HFC
   B_temp1 = 4
#ENDIF
   Temps1 = Str(Command_no)
   B_temp4 = Len (Temps1)
   For B_temp2 = 1 To B_temp4
      Tx_b(B_temp1) = Temps1_b(B_temp2)
      Incr B_temp1
   Next B_temp2
   Select Case Error_no
      Case 0
         Temps1 = ": command not found: "
      Case 1
         Temps1 = ": I2C error: "
      Case 2
         Temps1 = ": watchdog reset: "
      Case 3
         Temps1 = ": command watchdog: "
      Case 4
         Temps1 = ": parameter error: "
      Case 5
         Temps1 = ": tx time too long: "
      Case 6
         Temps1 = ": not valid at that time: "
      Case 7
         Temps1 = ": i2c_buffer overflow: "
      Case 8
         Temps1 = ": I2c not ready to receive: "
'
     $include "__command252.bas"

      Case 255
         Temps1 = ": no error: "
      Case Else
         Temps1 = ": other error: "
   End Select
   B_temp4 = Len (Temps1)
   For B_temp2 = 1 To B_temp4
      Tx_b(B_temp1) = Temps1_b(B_temp2)
      Incr  B_temp1
   Next B_temp2
   Temps1 = Str(Error_cmd_no)
   B_temp4 = Len (Temps1)
   For B_temp2 = 1 To B_temp4
      Tx_b(B_temp1) = Temps1_b(B_temp2)
      Incr B_temp1
   Next B_temp2
#IF Command_is_2_byte = 0
   Tx_b(2) = B_temp1 - 3
#ELSE
   Tx_b(3) = B_temp1 - 4
#ENDIF
   Tx_write_pointer = B_temp1
   Gosub Print_tx
   Gosub Command_received
Return
'
FFFD:
   Old_commandpointer = Commandpointer
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
   Gosub Print_tx
   Gosub Command_received
Return
'
FFFE:
#IF Command_is_2_byte = 0
   If Commandpointer >= 3 Then
      Tx_write_pointer = 3
      Old_commandpointer = Commandpointer
      Select Case Command_b(2)
#ELSE
   If Commandpointer >= 4 Then
      Tx_write_pointer = 4
      Old_commandpointer = Commandpointer
      Select Case Command_b(3)
#ENDIF
         Case 0
            If Command_b(Tx_write_pointer) = 0 Then
               Gosub Command_received
            Else
               B_temp1 = Command_b(Tx_write_pointer)
               B_temp6 = B_temp1 + Tx_write_pointer
               Incr Tx_write_pointer
               If Commandpointer >= B_temp6 Then
                  If B_temp1 <= 20 Then
                     Old_commandpointer = Commandpointer
                     Dev_name = String(20 , 0)
                     For B_temp2 = 1 To B_temp1
                        Dev_name_b(B_temp2) = Command_b(Tx_write_pointer)
                        Incr Tx_write_pointer
                     Next B_temp2
                     Dev_name_eeram = Dev_name
                     Gosub Command_received
                  Else
                     Parameter_error
                  End If
                  Gosub Command_received
               End If
            End If
         Case 1
            Dev_number = Command_b(Tx_write_pointer)
            Dev_number_eeram = Dev_number
            Gosub Command_received
         Case 2
            If Command_origin <> 2 Then
               ' config Jumper required
               If Mode_in = 0 Then
                  B_temp2 = Command_b(Tx_write_pointer)
                  If B_temp2 < 2 Then
                     Serial_active = B_temp2
                     Serial_active_eeram = Serial_active
                  Else
                     Parameter_error
                  End If
               Else
                  Not_valid_at_this_time
               End If
            Else
               Not_valid_at_this_time
            End If
            Gosub Command_received
         Case 3
            If Command_origin <> 2 Then
               ' config Jumper required
               If Mode_in = 0 Then
                  B_temp2 = Command_b(Tx_write_pointer)
                  If B_temp2 < 2 Then
                     USB_active = B_temp2
                     USB_active_eeram = USB_active
                  Else
                     Parameter_error
                  End If
               Else
                  Not_valid_at_this_time
               End If
            Else
               Not_valid_at_this_time
            End If
            Gosub Command_received
         Case 4
            If Command_origin <> 4 Then
               ' config Jumper required
               If Mode_in = 0 Then
                  B_temp2 = Command_b(Tx_write_pointer)
                  If B_temp2 < 2 Then
                     Radio_active = B_temp2
                     Radio_active_eeram = Radio_active
                  Else
                     Parameter_error
                  End If
               Else
                  Not_valid_at_this_time
               End If
            Else
               Not_valid_at_this_time
            End If
            Gosub Command_received
#IF Use_I2c = 1
         Case 5
            If Command_origin <> 3 Then
               ' config Jumper required
               If Mode_in = 0 Then
                  B_temp2 = Command_b(Tx_write_pointer)
                  If B_temp2 < 2 Then
                     I2C_active = B_temp2
                     I2C_active_eeram = I2C_active
                  Else
                     Parameter_error
                  End If
               Else
                  Not_valid_at_this_time
               End If
            Else
               Not_valid_at_this_time
            End If
            Gosub Command_received
#ENDIF
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
         Old_commandpointer = Commandpointer
         Tx_b(1) = &HFF
         Tx_b(2) = Command_b(2)
         Tx_write_pointer = 3
         Select Case Command_b(2)
#ELSE
      If Commandpointer >= 3 Then
         Old_commandpointer = Commandpointer
         Tx_time = 1
         Tx_b(1) = &HFF
         Tx_b(2) = &HFF
         Tx_b(3) = Command_b(2)
         Tx_write_pointer = 4
         Select Case Commnad_b32)
#ENDIF
            Case 0
               B_temp3 = Len(Dev_name)
               Tx_b(Tx_write_pointer) = B_temp3
               Incr Tx_write_pointer
               For B_temp1 = 1 To B_temp3
                  Tx_b(Tx_write_pointer) = Dev_name_b(B_temp1)
                  Incr Tx_write_pointer
               Next B_temp1
            Case 1
               Tx_b(Tx_write_pointer) = Dev_number
               Incr Tx_write_pointer
            Case 2
               Tx_b(Tx_write_pointer) = Serial_active
               Incr Tx_write_pointer
            Case 3
               Tx_b(Tx_write_pointer) = USB_active
               Incr Tx_write_pointer
            Case 4
               Tx_b(Tx_write_pointer) = Radio_active
               Incr Tx_write_pointer
#IF Use_i2c = 1
            Case 5
               Tx_b(Tx_write_pointer) = I2c_active
               Incr Tx_write_pointer
#ENDIF
'
            $include "__command255.bas"
'
            Case Else
               Parameter_error
               Tx_write_pointer = 0
         End Select
         If Tx_write_pointer > 0 Then
            Gosub Print_tx
         End If
         Gosub Command_received
      End If
Return