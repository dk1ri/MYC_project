' Some subs
' 20240317
'
#IF Use_command_received = 1
Command_received:
Commandpointer = 0
Command_pointer = 0
Tx_pointer = 1
Cmd_watchdog = 0
Incr Command_no
If Command_no = Error_cmd_no Then
   Error_cmd_no = 0
   Error_no = 255
End If
Return
#ENDIF
'
#IF Use_print_tx = 1
Print_tx:
Decr  Tx_write_pointer
For B_temp2 = 1 To Tx_write_pointer
   B_temp3 = Tx_b(B_temp2)
   Printbin B_temp3
Next B_temp2
Tx_pointer = 1
Tx_write_pointer = 1
Tx_time = 0
Return
#ENDIF
'
#IF Use_sub_restore = 1
Sub_restore:
' basic announcement
' commands as temporary storage
Command = Lookupstr(0, Announce)
B_temp3 = Len(Command)
Tx_b(1) = &H00
Tx_b(2) = B_temp3
Tx_write_pointer = 3
For B_temp2 = 1 To B_temp3
   Tx_b(Tx_write_pointer) = Command_b(B_temp2)
   Incr Tx_write_pointer
Next B_temp2
Return
#ENDIF
'
#IF Use_seri = 1
Sub Seri()
If Command_pointer < Stringlength Then Incr Command_pointer
Command_b(Command_pointer) = UDR
New_data = 1
Command_mode = 1
End Sub
#ENDIF
'
#IF Use_reset_i2c = 1
Reset_i2c:
Watch_twi = 0
Twsr = 0
Config TWI = 400000
Twdr = Not_valid_cmd
Twar = Adress
Twcr = &B01000101
Return
#ENDIF
'
#IF Use_i2c = 1
Sub I2c()
   ' only the following TWSR values will occur (all action use ack, no multiple master / arbitration/ general call):
   ' receive:60/96 -> start read, 80/128 88/136 -> data read, A0/160 -> stop read
   ' transmit: A8/168 -> start, load data, A8/168 B8/184 -> data written, C0/192 -> data with NOTACK (stop)
   ' only two of them require actions (&H80 und &HB8); all (!) others set TWCR only
   B_temp1 = TWSR And &HFC
   Select Case B_temp1
      Case &H60
         Twcr = &B11000101
      Case &H68
         Twcr = &B11000101
      Case &H70
         Twcr = &B11000101
      Case &H78
         Twcr = &B11000101
      Case &H80
         If Command_pointer < Stringlength Then Incr Command_pointer
            Command_b(Command_pointer) = TWDR
            Command_mode = 2
            New_data = 1
            Twcr = &B11000101
      Case &H88
         If Command_pointer < Stringlength Then Incr Command_pointer
            Command_b(Command_pointer) = TWDR
            Command_mode = 2
            New_data = 1
            Twcr = &B11000101
      Case &H90
         If Command_pointer < Stringlength Then Incr Command_pointer
            Command_b(Command_pointer) = TWDR
            Command_mode = 2
            New_data = 1
            Twcr = &B11000101
      Case &H98
         If Command_pointer < Stringlength Then Incr Command_pointer
            Command_b(Command_pointer) = TWDR
            Command_mode = 2
            New_data = 1
            Twcr = &B11000101
      Case &HA0
         Twcr = &B11000101
'
         'slave send:
         'a slave send command must always be completed (or until timeout)
         'incoming commands are ignored as long as tx is not empty
         'for multi line F0 command tx may be loaded a few times if necessary.
         'multiple announcelines are loaded by line
      Case &HA8
         If Tx_pointer < Tx_write_pointer And I2c_active = 1 Then
            TWDR = Tx_b(Tx_pointer)
            Incr Tx_pointer
         Else
            TWDR = Not_valid_cmd
         End If
         Twcr = &B11000101
      Case &HB0
         If Tx_pointer < Tx_write_pointer And I2c_active = 1 Then
            TWDR = Tx_b(Tx_pointer)
            Incr Tx_pointer
         Else
            TWDR = Not_valid_cmd
         End If
         Twcr = &B11000101
      Case &HB8
         If Tx_pointer < Tx_write_pointer And I2c_active = 1 Then
            TWDR = Tx_b(Tx_pointer)
            Incr Tx_pointer
         Else
            TWDR = Not_valid_cmd
         End If
         Twcr = &B11000101
      Case &HC0
         TWDR = Not_valid_cmd
         Twcr = &B11000101
      Case &HC8
         TWDR = Not_valid_cmd
         Twcr = &B11000101
      Case Else
#IF Use_reset_i2c = 1
         Gosub Reset_i2c
#ENDIF
   End Select
   If Tx_pointer >= Tx_write_pointer Then
      Tx_pointer = 1
      Tx_write_pointer = 1
      Tx_time = 0
      If Number_of_lines > 0 Then Gosub Sub_restore
   End If

End Sub
#ENDIF