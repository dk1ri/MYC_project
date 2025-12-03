' Some subs
' 20240817
'
Command_received:
   Commandpointer = 0
   Command_pointer = 0
   Last_command_pointer = 0
   Tx_pointer = 1
   Cmd_watchdog = 0
   Incr Command_no
   If Command_no = Error_cmd_no Then
      Error_cmd_no = 0
      Error_no = 255
   End If
Return
'
Print_tx:
   Decr  Tx_write_pointer
   For B_temp2 = 1 To Tx_write_pointer
      B_temp3 = Tx_b(B_temp2)
      Printbin B_temp3
   Next B_temp2
'
   B_temp6 = InterfaceFU
   ' no resend of answers of commands
 '  If From_wireless = 0 Then
     If Radio_type > 0 and  B_temp6 = 1 Then
        ' Answer of commands for FU only!!! (no commands for interface in transparent mode!)
        If Tx_write_pointer > 0 Then
           wireless_tx_length = Tx_write_pointer
           Select Case Radio_type
              Case 1
                 Gosub RFM95_send0
              Case 4
                 Gosub nRF24_send4
           End Select
        End If
  '   End If
   End If
'
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
   If Serial_activ = 1 Then
      If Command_pointer < Stringlength Then Incr Command_pointer
      Command_b(Command_pointer) = B_temp1
   End If
End Sub
'
Check_command_allowed:
   command_allowed = 0
   If Serial_active = 1 Or USB_active = 1  Then Serial_activ = 1
   If Serial_activ = 1 Or i2c_active = 1 Or Radio_type > 0 Then Command_allowed = 1
Return
'
#IF Use_i2c = 1
Reset_i2c:
   Watch_twi = 0
   Twsr = 0
   Config TWI = 400000
   Twdr = Not_valid_cmd
   Twar = Adress
   Twcr = &B01000101
Return
'
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
            Twcr = &B11000101
      Case &H88
         If Command_pointer < Stringlength Then Incr Command_pointer
            Command_b(Command_pointer) = TWDR
            Twcr = &B11000101
      Case &H90
         If Command_pointer < Stringlength Then Incr Command_pointer
            Command_b(Command_pointer) = TWDR
            Twcr = &B11000101
      Case &H98
         If Command_pointer < Stringlength Then Incr Command_pointer
            Command_b(Command_pointer) = TWDR
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
         If Tx_pointer < Tx_write_pointer And I2c_activ = 1 Then
            TWDR = Tx_b(Tx_pointer)
            Incr Tx_pointer
         Else
            TWDR = Not_valid_cmd
         End If
         Twcr = &B11000101
      Case &HB0
         If Tx_pointer < Tx_write_pointer And I2c_activ = 1 Then
            TWDR = Tx_b(Tx_pointer)
            Incr Tx_pointer
         Else
            TWDR = Not_valid_cmd
         End If
         Twcr = &B11000101
      Case &HB8
         If Tx_pointer < Tx_write_pointer And I2c_activ = 1 Then
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
      Gosub Reset_i2c
   End Select
   If Tx_pointer >= Tx_write_pointer Then
      Tx_pointer = 1
      Tx_write_pointer = 1
      Tx_time = 0
      If Number_of_lines > 0 Then Gosub Sub_restore
   End If
End Sub
#ENDIF
'
#IF Use_wireless = 1
' There is a transparent mode (for interface only) and a MYC mode.
' This is necessary for the interface, because the interface do not know the length of other commands.
'
' Interface:
' Transparent mode:
' Data are directly and immediately sent from I2C / serial / USB to radio modul.
' Received data (Spi_in) are sent to I2C / serial / USB.
'
' MYC Mode:
' It works as all other MYC FU.
' (but: Interface get no commands via radio interface
'
' other FU:
' FU is in MYC Mode always
' wireless interface is enabled by individualization,
'
wireless_setup:
   Select Case Radio_type
      Case 1
         Gosub RFM95_setup0
      Case 4
         Gosub nRF24_setup4
   End Select
Return
'
Sub Read_spi(Byval B_temp1 As Byte)
   ' SCS must not go "high" between spiout and spiin !!!!!!
   Reset ScS
   spiout Spi_out_b(1), 1
   spiin  Spi_in_b(1), B_temp1
   Set ScS
End Sub
'
Sub Write_spi(Byval Spi_len As Byte)
   Reset ScS
   spiout Spi_out_b(1), Spi_len
   Set ScS
End Sub
'
#ENDIF
   '
create_send_string:
   ' add Radioname
   B_temp4 = Len(Radio_name)
   ' Add name
   For B_temp2 = 1 To B_temp4
      spi_out_b(B_temp2 + 1) = Radio_name_b(B_temp2)
   Next B_temp2
   B_temp6 = InterfaceFU
   For B_temp1 = 1 to wireless_tx_length
      Incr B_temp2
      If B_temp6 = 0 Then
         spi_out_b(B_temp2) = command_b(B_temp1)
      Else
         Spi_out_b(B_temp2) = Tx_b(B_temp1)
      End If
   Next B_temp1
   wireless_tx_length = B_temp2
Return