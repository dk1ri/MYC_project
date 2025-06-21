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
Print_tx:
Decr  Tx_write_pointer
For B_temp2 = 1 To Tx_write_pointer
   B_temp3 = Tx_b(B_temp2)
   If Interface_FU = 0 Then
      ' Interface Myc Mode
      If Interface_mode = 1 Then
         Printbin B_temp3
      End If
   Else
      ' FU
      Printbin B_temp3
   End If
Next B_temp2
If Interface_FU = 0 Then
   ' Interface
   If Interface_mode = 0 Then
      ' Transparent
      Gosub Tx_wireless_start0
   End If
Else
   ' FU
   If wireless_active = 1 Then
      Select Case Radio_type
         Case is < 3
            Gosub Tx_wireless_start0
         Case 3
            Gosub Tx3
      End Select
   End If
End If
Tx_pointer = 1
Tx_write_pointer = 1
Tx_time = 0
Return
'
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
'
Sub Seri()
B_temp1 = UDR
If Serial_active = 1 Then
   If Command_pointer < Stringlength Then Incr Command_pointer
   Command_b(Command_pointer) = B_temp1
   New_data = 1
End If
End Sub
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
            New_data = 1
            Twcr = &B11000101
      Case &H88
         If Command_pointer < Stringlength Then Incr Command_pointer
            Command_b(Command_pointer) = TWDR
            New_data = 1
            Twcr = &B11000101
      Case &H90
         If Command_pointer < Stringlength Then Incr Command_pointer
            Command_b(Command_pointer) = TWDR
            New_data = 1
            Twcr = &B11000101
      Case &H98
         If Command_pointer < Stringlength Then Incr Command_pointer
            Command_b(Command_pointer) = TWDR
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

Check_interfaces:
   Serial_active = 0
   If Serial_activ = 1 Or USB_active = 1 Then
      Serial_active = 1
   End If
 '  Command_allowed = 0
   If I2c_active = 1 Or serial_active = 1 Then
    '     Command_allowed = 1
   End If
   If wireless_active = 1 Then
 '     Command_allowed = 1
   End If
Return
'
' wireless
'
' There is a transparent mode (for interface only) and a MYC mode.
' This is necessary for the interface, because the interface do not know the length of other commands.
'
' Interface:
' Transparent mode:
' Data are directly and imediately sent from I2C / serial / USB to radio modul.
' Received data (Spi_in) are sent to I2C / serial / USB.
'
' MYC Mode:
' It works as all MYC FU.
' (but: Interface get no commands via radio interface
'
'
' other FU:
' FU is in MYC Mode always
' wireless interface is enabled by individualization,
'
wireless_setup:
B_temp1 = InterfaceFU
B_temp2 = 0
If B_temp1 = 0 Then
   If Interface_mode = 0 Then
      ' transparent
      ' Interface: has radio module always
      B_temp2 = 1
   End If
Else
   ' FU
   If Wireless_active = 1 Then
      B_temp2 = 1
   End If
End If
If B_temp2 = 1 Then
   ' init radio module
   Select Case R_type
      Case 0
         Gosub RFM95_setup0
      'Case 1
         'Gosub RFM95_setup0
      'Case2
         'Gosub RFM95_setup0
      Case 3
         Gosub nrf24_setup3
   End Select
  '
End If
Return
'
' for wireless
Read_register:
   spiout Register_b(1), 1
   spiin  Spi_in_b(1), Spi_len
Return
'
Write_Register1:
   spiout Register_b(1), 1
Return
'
Write_Register:
   spiout Register_b(1), 2
Return
'
Write_3Register:
   spiout Register_b(1), 4
Return
'
Write_wireless_string:
   spiout Tx, Spi_len
Return
'
Read_fifo:
   spiout Register_b(1), 1
   spiin  Spi_in_b(1), Rx_bytes
Return