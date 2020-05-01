' additional commands
'
01:
Tx_time = 1
Waitus 70
Reset PortB.2
For B_temp1 = 1 To 7
   B_temp2 = B_temp1 + 191
   'read register 0 to 6
   Spiout B_temp2, 1
   Waitus 70
   Spiin Spi_buffer(B_temp1), 1
   Waitus 70
Next B_temp1
Set PortB.2
Gosub Calculate_unix_time
Tx_b(1) = &H01
Tx_write_pointer = 10
If Command_mode = 1 Then  Gosub Print_tx
Gosub Command_received
Return
'
02:
If Commandpointer >= 3 Then
   If Command_b(2) < 15 Then
      Spi_buffer1 = String(Length_spi, 0)
      Spi_buffer(1) = Command_b(2) + 128
      Spi_buffer(2) =  Command_b(3)
      Reset PortB.2
      Spiout Spi_buffer(1), 1
      Waitus 70
      Spiout Spi_buffer(2), 1
      Waitus 70
      Set PortB.2
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
03:
If Commandpointer >= 2 Then
   If Command_b(2) < 15 Then
      Tx_time = 1
      Spi_buffer(1) = Command_b(2) + 192
      Reset PortB.2
      Waitus 70
      Spiout Spi_buffer(1), 1
      Waitus 70
      Spi_buffer1 = String(Length_spi, 0)
      Spiin Spi_buffer(1), 1
      Waitus 70
      Set PortB.2
      Tx_b(1) = &H03
      Tx_b(2) = Command_b(2)
      Tx_b(3) = Spi_buffer(1)
      TX_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'