' nRF25 Subs
' 20250607
'
Read_status4:
   spiin Spi_in_b(1), 1
Return
'
Tx3:
   Register_b(1) = W_TX_PAYLOAD4
   Register_b(2) = 4
   Gosub Write_register
   Register_b(1) = FLUSH_TX4
   Gosub Write_register1
Return
'
nrf24_setup3:
Return