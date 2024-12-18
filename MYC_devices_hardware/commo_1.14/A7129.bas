' A7129 functons
' 20201210
'
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