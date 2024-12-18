' wireless functons for all moduls
' 20201211
'
Read_register:
   Reset SCS
   spiout Register, 1
   spiin  Spi_in, Spi_len
   Set SCS
Return
'
Write_Register:
   Reset SCS
   spiout Register, 2
   Set SCS
Return
'
Write_wireless_string:
   Reset SCS
   spiout SPI_string, Spi_len
   Set SCS
   Spi_string = String(200,0)
Return
'
Add_length:
   ' add length to Command
   ' length is wireless_tx_length
   ' additionally shift B_temp2 bytes right
   ' result is Spi_string
   B_temp4 = wireless_tx_length
   Incr B_temp1
   B_temp1 = B_temp1 + B_temp2
   Incr B_temp2
   For B_temp3 = B_temp1 to B_temp2 Step - 1
      Spi_string_b(B_temp3) = Command_b(B_temp4)
      Decr wireless_tx_length
   Next B_temp3
   Spi_string_b(B_temp4) = wireless_tx_length
Return
'
Remove_length:
   ' remove length from Spi_in
   ' length is wireles_rx_length
   wireless_tx_length = Spi_in_b(1)
   B_temp2 = 2
   For B_temp1 = 1 to wireless_tx_length
      Spi_in_b(B_temp1) = Spi_in_b(B_temp2)
      Incr B_temp2
   Next B_temp1
Return
'
Tx_wireless_start:
   ' used for answers of commands of client and transparent mode of server
   wireless_tx_length = Command_pointer - 1
   B_temp2 = 1
   ' no additional shift
   Gosub Add_length
   #IF Radiotype = 1
      Gosub Lora_tx
   #EndIF
   #If Radiotype = 2
      spi_len = wireless_tx_length
      Gosub 7129_tx
   #EndIF
   Command = string(250,0)
Return
'
Receive_wireless:
   'Spi_in has data (for A7129)
   ' First char is length
   wireless_rx_length = Spi_in_b(1)
   ' shift 1 byte left and copy to command
   B_temp2 = 2
   For B_temp1 = 1 To wireless_rx_length
      Command_b(B_temp1) = Spi_in_b(B_temp2)
      Incr _temp2
   Next B_temp1
   If wireless_active = 1 Then
      ' client  -> is command
      B_temp3 = 1
      Command_pointer = wireless_rx_length + 1
   Else
      ' server -> print answer from client
      B_temp3 = 1
      Tx_write_pointer = wireless_rx_length + 1
      For B_temp2 = 2 to B_temp1
         Tx_b(B_temp3) = Spi_in_b(B_temp2)
         incr B_temp3
      Next B_temp2
      Gosub Print_tx
   End If
   Spi_in = String(100,0)
Return
'