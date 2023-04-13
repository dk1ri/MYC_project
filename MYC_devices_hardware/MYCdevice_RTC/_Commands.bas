' additional commands
'  20230409
'
01:
Tx_time = 1
Gosub Read_time
Tx_b(1) = &H01
Tx_b(2) = Unixtime3
'first 4 byte are 0  little endian -> big endian
Tx_b(3) = Unixtime2
Tx_b(4) = Unixtime1
Tx_b(5) = Unixtime0
Tx_write_pointer = 6
If Command_mode = 1 Then  Gosub Print_tx
Gosub Command_received
Return
'
02:
Tx_time = 1
Gosub Read_time
Tx_b(1) = &H02
Tx_b(2) = S_hour_b(1)
Tx_b(3) = S_hour_b(2)
Tx_b(4) = 32
Tx_b(5) = S_minute_b(1)
Tx_b(6) = S_minute_b(2)
Tx_b(7) = 32
Tx_b(8) = S_second_b(1)
Tx_b(9) = S_second_b(2)
Tx_write_pointer = 10
If Command_mode = 1 Then  Gosub Print_tx
Gosub Command_received
Return
'
03:
Tx_time = 1
Gosub Read_time
Tx_b(1) = &H03
Tx_b(2) = D_time_b(3)
Tx_b(3) = D_time_b(2)
Tx_b(4) = D_time_b(1)
Tx_write_pointer = 5
If Command_mode = 1 Then  Gosub Print_tx
Gosub Command_received
Return
'
04:
Tx_time = 1
Gosub Read_time
Tx_b(1) = &H04
Tx_b(2) = High(Year_w)
Tx_b(3) = low(Year_w)
Tx_write_pointer = 4
If Command_mode = 1 Then  Gosub Print_tx
Gosub Command_received
Return
'
05:
Tx_time = 1
Gosub Read_time
Tx_b(1) = &H05
Tx_b(2) = Month
Tx_write_pointer = 3
If Command_mode = 1 Then  Gosub Print_tx
Gosub Command_received
Return
'
06:
Tx_time = 1
Gosub Read_time
Tx_b(1) = &H06
Tx_b(2) = Day_b
Tx_write_pointer = 3
If Command_mode = 1 Then  Gosub Print_tx
Gosub Command_received
Return
'
07:
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
08:
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
      Tx_b(1) = &H08
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