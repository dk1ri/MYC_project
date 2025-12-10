' Some subs
' 20251207
'
Command_received:
   ' check if serial and I2c are ready
   If Serial_print_started = 0 And I2C_started = 0 Then
      If Cmd_error = 0 Then
         Commandpointer = Commandpointer - Old_commandpointer
      Else
         Commandpointer = 0
      End If
      Old_commandpointer = 0
      Tx_write_pointer = 1
      Cmd_watchdog = 0
      Incr Command_no
      If Command_no = Error_cmd_no Then
         Error_cmd_no = 0
         Error_no = 255
      End If
      Cmd_error = 0
      Reset Watchdog
      End If
Return
'
Print_tx:
   Serial_print_started = 1
   Decr  Tx_write_pointer
   For W_temp2 = 1 To Tx_write_pointer
      B_temp3 = Tx_b(W_temp2)
      Printbin B_temp3
   Next W_temp2
'
   B_temp6 = InterfaceFU
   ' no resend of answers of commands
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
   End If
'
   Tx_write_pointer = 1
   Serial_print_started = 0
   Gosub Command_received
Return
'
Print_basic:
   ' basic announcement
   Old_commandpointer = Commandpointer
   Tx = Lookupstr(0, Announce)
   B_temp3 = Len(Tx)
   B_temp2 = B_temp3 + 2
   ' Shift right
   For B_temp1 = B_temp3 To 1 Step - 1
      Tx_b(B_temp2) = Tx_b(B_temp1)
      Decr B_temp2
   Next B_temp1
   Tx_b(1) = &H00
   Tx_b(2) = B_temp3
   Tx_write_pointer = B_temp3 + 3
   Gosub Print_tx
   Gosub Command_received
Return
'
Sub Seri()
   B_temp1 = UDR
   If Commandpointer < Stringlength Then Incr Commandpointer
   Command_b(Commandpointer) = B_temp1
   Command_origin = 2
End Sub
'
#IF Use_i2c = 1
Reset_i2c:
   Watch_twi = 0
   Twsr = 0
   Config TWI = 400000
   Twdr = Not_valid_cmd
   Twar = Adress
   Twcr = &B01000101
   I2C_started = 0
Return
'
Sub I2c()
   If I2c_active = 0 Then
       Twcr = &B11000101
       Return
   End If
   ' only the following TWSR values will occur (all action use ack, no multiple master / arbitration/ general call):
   ' receive:60/96 -> start read, 80/128 88/136 -> data read, A0/160 -> stop read
   ' transmit: A8/168 -> start, load data, A8/168 B8/184 -> data written, C0/192 -> data with NOTACK (stop)
   ' only two of them require actions (&H80 und &HB8); all (!) others set TWCR only
   I2C_started = 1
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
         If Commandpointer < Stringlength Then Incr Commandpointer
            Command_b(Commandpointer) = TWDR
            Command_origin = 3
            Twcr = &B11000101
      Case &H88
         If Commandpointer < Stringlength Then Incr Commandpointer
            Command_b(Commandpointer) = TWDR
            Twcr = &B11000101
            Command_origin = 3
      Case &H90
         If Commandpointer < Stringlength Then Incr Commandpointer
            Command_b(Commandpointer) = TWDR
            Twcr = &B11000101
            Command_origin = 3
      Case &H98
         If Commandpointer < Stringlength Then Incr Commandpointer
            Command_b(Commandpointer) = TWDR
            Twcr = &B11000101
            Command_origin = 3
      Case &HA0
         Twcr = &B11000101
'
         'slave send:
         ' send up to 65535 characters in a line
         'a slave send command must always be completed (or until timeout)
         'incoming commands are queued as long as tx is not empty
         'All loaded by line
         'I2c and serial work in parallel. If any I2C Int occur print wait until I2C is ready (I2C_started st to 0 again)
         'otherwise finish if serial is finished. (I2C_started)
      Case &HA8
         If Tx_pointer < Tx_write_pointer Then
            TWDR = Tx_b(Tx_pointer)
            Incr Tx_pointer
         Else
            TWDR = Not_valid_cmd
         End If
         Twcr = &B11000101
      Case &HB0
         If Tx_pointer < Tx_write_pointer Then
            TWDR = Tx_b(Tx_pointer)
            Incr Tx_pointer
         Else
            TWDR = Not_valid_cmd
         End If
         Twcr = &B11000101
      Case &HB8
         If Tx_pointer < Tx_write_pointer Then
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
      I2C_started = 0
      Gosub Command_received
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
create_send_string:
   ' add Radioname
   B_temp4 = Len(Radio_name)
   ' Add name
   For B_temp2 = 1 To B_temp4
      spi_IO_b(B_temp2 + 1) = Radio_name_b(B_temp2)
   Next B_temp2
   B_temp6 = InterfaceFU
   For B_temp1 = 1 to wireless_tx_length
      Incr B_temp2
      If B_temp6 = 0 Then
         spi_IO_b(B_temp2) = command_b(B_temp1)
      Else
         Spi_IO_b(B_temp2) = Tx_b(B_temp1)
      End If
   Next B_temp1
   wireless_tx_length = B_temp2
Return
#ENDIF
'
Sub Read_spi(Byval B_temp1 As Byte)
   ' SCS must not go "high" between spiout and spiin !!!!!!
   Reset ScS
   spiout Spi_IO_b(1), 1
   spiin  Spi_IO_b(1), B_temp1
   Set ScS
End Sub
'
Sub Write_spi(Byval Spi_len As Byte)
   Reset ScS
   spiout Spi_IO_b(1), Spi_len
   Set ScS
End Sub
'