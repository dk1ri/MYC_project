' A7129 functons
' 20201210
'
' RYFA689 (A2179):
' Frequeny: 433MHz
' initial Set paramters taken from C file by manufacturer
' Master /Slave mode not used: (no ACKK !) just send and receive
' if Func send info and CR send data at that time info is lost and command as well
'
Read_fifo:
   Reset SCS
   B_temp1 = FiFo_r
   spiout B_temp1, 1
   ' read 64 Byte always
   spiin  Spi_in, 64
   Set SCS
Return
'
Write_page_register:
   Spi_string_b(1) = &H07
   Spi_string_b(2) = B_temp1
   Spi_string_b(2) = B_temp5 Or Crystal_d2
   Reset SCS
   spiout SPI_string, 2
   Set SCS
   Spi_string_b(1) = B_temp2
   SPi_string_b(2) = B_temp3
   Spi_string_b(3) = B_temp4
   Reset SCS
   spiout SPI_string, 3
   Set SCS
   Spi_string = String(200,0)
Return
'
Set_standby_mode:
 'standby mode to set registers in Lora
   Spi_String_b(1) = Standby
   Spi_len = 1
   Gosub Write_wireless_string
Return
 '
Set_rx_mode:
 'standby mode to set registers in Lora
   Spi_String_b(1) = Rx_mode
   Spi_len = 1
   Gosub Write_wireless_string
Return
 '
Set_tx_mode:
 'standby mode to set registers in Lora
   Spi_String_b(1) = tx_mode
   Spi_len = 1
   Gosub Write_wireless_string
Return
'
7129_tx:
   Gosub Set_standby_mode
   Spi_string_b(1) = Tx_mode
   Gosub Write_wireless_string:
   Gosub Set_tx_mode
   Wait_for_rx_ready = 1
   ' set GIO1 then will return to standby mode
   Spi_string = string(100,0)
Return
'
7129_rx:
   'usually the modem is in rx mode and wait for GIO1 (valid packet)
   If GIO1 = 1 Then
      'data valid, read 64 byte
      Gosub Read_fifo
      Gosub Receive_wireless
   End If
Return
'
Write_id:
'write Id_code
   Spi_string_b( 1) = Id_code_w
   B_temp2 = 2
   For B_temp1 = 1 to Name_len
      Spi_string_b(B_temp2) = Radio_name_b(B_temp1)
      Incr B_temp2
   Next B_temp1
   Spi_len = Name_len + 1
   Gosub Write_wireless_string
Return
'
Read_id:
   'read Id_code
   Register_b(1) = Id_code_r
   Spi_len = Name_len
   Gosub Read_register
   Radio_name = Spi_in
   If radio_name <> Radio_name_eram Then
      Radio_name_eram = Radio_name
   End If
   Spi_in = String(100,0)
Return
'
Tx_wireless_start:
   ' used for answers of commands of client and transparent mode of server
   wireless_tx_length = Command_pointer - 1
   B_temp2 = 1
   ' no additional shift
   Gosub Add_length
      spi_len = wireless_tx_length
      Gosub 7129_tx
   Command = string(250,0)
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